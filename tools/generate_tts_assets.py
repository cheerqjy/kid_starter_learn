import asyncio
import re
from pathlib import Path

import edge_tts


ROOT = Path(__file__).resolve().parents[1]
VOCAB_FILE = ROOT / "lib" / "app" / "controllers" / "vocabulary_modules.dart"
PHONICS_FILE = ROOT / "lib" / "app" / "controllers" / "phonics_controller.dart"
VOCAB_DIR = ROOT / "assets" / "audio" / "tts" / "vocabulary"
PHONICS_WORD_DIR = ROOT / "assets" / "audio" / "tts" / "phonics" / "word"
PHONICS_PHRASE_DIR = ROOT / "assets" / "audio" / "tts" / "phonics" / "phrase"
PHONICS_PROMPT_DIR = ROOT / "assets" / "audio" / "tts" / "phonics" / "prompt"
EN_VOICE = "en-US-AvaNeural"
ZH_VOICE = "zh-CN-XiaoxiaoNeural"


def slugify(value: str) -> str:
    normalized = value.lower().replace("&", "and")
    slug = re.sub(r"[^a-z0-9]+", "-", normalized)
    return slug.strip("-")


def parse_vocabulary_titles() -> list[str]:
    text = VOCAB_FILE.read_text(encoding="utf-8")
    return re.findall(r"VocabularyItem\(title: '([^']+)'", text)


def parse_phonics_items() -> list[dict[str, str]]:
    text = PHONICS_FILE.read_text(encoding="utf-8")
    pattern = re.compile(
        r"PhonicsItem\(\s*"
        r"symbol: '([^']*)',\s*"
        r"title: '([^']*)',\s*"
        r"exampleWord: '([^']*)',\s*"
        r"examplePhrase: '([^']*)',\s*"
        r"soundCue: '([^']*)',\s*"
        r"chinesePrompt: '([^']*)',\s*"
        r"mouthTip: '([^']*)',",
        re.S,
    )
    items = []
    for match in pattern.findall(text):
        items.append(
            {
                "symbol": match[0],
                "title": match[1],
                "example_word": match[2],
                "example_phrase": match[3],
                "sound_cue": match[4],
                "prompt": match[5],
                "mouth_tip": match[6],
            }
        )
    return items


async def save_tts(text: str, voice: str, target: Path) -> None:
    if target.exists():
        return
    target.parent.mkdir(parents=True, exist_ok=True)
    communicate = edge_tts.Communicate(text=text, voice=voice)
    await communicate.save(str(target))


async def main() -> None:
    tasks = []

    for title in parse_vocabulary_titles():
        tasks.append(
            (
                title,
                EN_VOICE,
                VOCAB_DIR / f"{slugify(title)}.mp3",
            )
        )

    for item in parse_phonics_items():
        key = slugify(item["title"])
        tasks.append(
            (
                item["example_word"],
                EN_VOICE,
                PHONICS_WORD_DIR / f"{key}.mp3",
            )
        )
        tasks.append(
            (
                f"Listen and say. {item['example_phrase']}",
                EN_VOICE,
                PHONICS_PHRASE_DIR / f"{key}.mp3",
            )
        )
        tasks.append(
            (
                item["prompt"],
                ZH_VOICE,
                PHONICS_PROMPT_DIR / f"{key}.mp3",
            )
        )

    semaphore = asyncio.Semaphore(6)

    async def guarded(text: str, voice: str, target: Path) -> None:
        async with semaphore:
            await save_tts(text, voice, target)

    await asyncio.gather(*(guarded(text, voice, target) for text, voice, target in tasks))
    print(f"Generated {len(tasks)} audio tasks.")


if __name__ == "__main__":
    asyncio.run(main())
