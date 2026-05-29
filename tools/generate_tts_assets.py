import asyncio
import re
from pathlib import Path

import edge_tts


ROOT = Path(__file__).resolve().parents[1]
VOCAB_FILE = ROOT / "lib" / "app" / "controllers" / "vocabulary_modules.dart"
PHONICS_FILE = ROOT / "lib" / "app" / "controllers" / "phonics_controller.dart"
PHONICS_SCREEN_FILE = ROOT / "lib" / "app" / "screens" / "phonics_screen.dart"
PREPOSITIONS_FILE = ROOT / "lib" / "app" / "controllers" / "prepositions_controller.dart"
LETTER_SOUNDS_FILE = ROOT / "lib" / "app" / "controllers" / "letter_sounds_controller.dart"
NUMBERS_FILE = ROOT / "lib" / "app" / "controllers" / "numeric_en_controller.dart"
VOCAB_DIR = ROOT / "assets" / "audio" / "tts" / "vocabulary"
PHONICS_WORD_DIR = ROOT / "assets" / "audio" / "tts" / "phonics" / "word"
PHONICS_PHRASE_DIR = ROOT / "assets" / "audio" / "tts" / "phonics" / "phrase"
PHONICS_PROMPT_DIR = ROOT / "assets" / "audio" / "tts" / "phonics" / "prompt"
PHONICS_SOUND_DIR = ROOT / "assets" / "audio" / "tts" / "phonics" / "sound"
PHONICS_INTRO_DIR = ROOT / "assets" / "audio" / "tts" / "phonics" / "intro"
PREPOSITIONS_WORD_DIR = ROOT / "assets" / "audio" / "tts" / "prepositions" / "word"
PREPOSITIONS_PHRASE_DIR = ROOT / "assets" / "audio" / "tts" / "prepositions" / "phrase"
PREPOSITIONS_PROMPT_DIR = ROOT / "assets" / "audio" / "tts" / "prepositions" / "prompt"
PREPOSITIONS_INTRO_DIR = ROOT / "assets" / "audio" / "tts" / "prepositions" / "intro"
LETTER_SOUNDS_INTRO_DIR = ROOT / "assets" / "audio" / "tts" / "letter_sounds" / "intro"
LETTER_SOUNDS_SOUND_DIR = ROOT / "assets" / "audio" / "tts" / "letter_sounds" / "sound"
LETTER_SOUNDS_WORD_DIR = ROOT / "assets" / "audio" / "tts" / "letter_sounds" / "word"
LETTER_SOUNDS_CHANT_DIR = ROOT / "assets" / "audio" / "tts" / "letter_sounds" / "chant"
LETTER_SOUNDS_PROMPT_DIR = ROOT / "assets" / "audio" / "tts" / "letter_sounds" / "prompt"
NUMBERS_DIR = ROOT / "assets" / "audio" / "tts" / "numbers"
SHAPES_DIR = ROOT / "assets" / "audio" / "tts" / "shapes"
STORIES_DIR = ROOT / "assets" / "audio" / "tts" / "stories"
EN_VOICE = "en-US-AvaNeural"
ZH_VOICE = "zh-CN-XiaoxiaoNeural"


def slugify(value: str) -> str:
    normalized = value.lower().replace("&", "and")
    slug = re.sub(r"[^a-z0-9]+", "-", normalized)
    return slug.strip("-")


def parse_vocabulary_titles() -> list[str]:
    text = VOCAB_FILE.read_text(encoding="utf-8")
    return re.findall(r"VocabularyItem\(title: '([^']+)'", text)


def parse_numeric_words() -> list[str]:
    text = NUMBERS_FILE.read_text(encoding="utf-8")
    return re.findall(r"englishWord: '([^']+)'", text)


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


def parse_phonics_voice_map() -> dict[str, str]:
    text = PHONICS_SCREEN_FILE.read_text(encoding="utf-8")
    pattern = re.compile(r"const Map<String, String> _phonicsVoices = \{(.*?)\};", re.S)
    match = pattern.search(text)
    if not match:
        return {}

    entries = re.findall(r"'([^']+)': '([^']+)'", match.group(1))
    return {key: value for key, value in entries}


def parse_prepositions() -> list[dict[str, str]]:
    text = PREPOSITIONS_FILE.read_text(encoding="utf-8")
    pattern = re.compile(
        r"PrepositionScene\(\s*"
        r"title: '([^']*)',\s*"
        r"chineseTitle: '([^']*)',\s*"
        r"exampleSentence: '([^']*)',\s*"
        r"chinesePrompt: '([^']*)',\s*"
        r"playHint: '([^']*)',",
        re.S,
    )
    items = []
    for match in pattern.findall(text):
        items.append(
            {
                "title": match[0],
                "chinese_title": match[1],
                "example_sentence": match[2],
                "chinese_prompt": match[3],
                "play_hint": match[4],
            }
        )
    return items


def parse_letter_sound_stages() -> list[dict[str, str]]:
    text = LETTER_SOUNDS_FILE.read_text(encoding="utf-8")
    pattern = re.compile(
        r"LetterSoundStage\(\s*"
        r"code: '([^']*)',\s*"
        r"title: '([^']*)',\s*"
        r"subtitle: '([^']*)',\s*"
        r"chinesePrompt: '([^']*)',",
        re.S,
    )
    return [
        {
            "code": code,
            "title": title,
            "subtitle": subtitle,
            "prompt": prompt,
        }
        for code, title, subtitle, prompt in pattern.findall(text)
    ]


def parse_letter_sound_items() -> list[dict[str, str]]:
    text = LETTER_SOUNDS_FILE.read_text(encoding="utf-8")
    pattern = re.compile(
        r"LetterSoundItem\(\s*"
        r"letter: '([^']*)',\s*"
        r"phonicsText: '([^']*)',\s*"
        r"soundCue: '([^']*)',\s*"
        r"primaryWord: '([^']*)',\s*"
        r"secondaryWord: '([^']*)',\s*"
        r"primaryEmoji: '([^']*)',\s*"
        r"secondaryEmoji: '([^']*)',\s*"
        r"chinesePrompt: '([^']*)',\s*"
        r"chant: '([^']*)',",
        re.S,
    )
    items = []
    for match in pattern.findall(text):
        items.append(
            {
                "letter": match[0],
                "phonics": match[1],
                "sound_cue": match[2],
                "primary_word": match[3],
                "secondary_word": match[4],
                "primary_emoji": match[5],
                "secondary_emoji": match[6],
                "prompt": match[7],
                "chant": match[8],
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
    phonics_voice_map = parse_phonics_voice_map()

    for title in parse_vocabulary_titles():
        tasks.append(
            (
                title,
                EN_VOICE,
                VOCAB_DIR / f"{slugify(title)}.mp3",
            )
        )

    for word in parse_numeric_words():
        tasks.append(
            (
                word,
                EN_VOICE,
                NUMBERS_DIR / f"{slugify(word)}.mp3",
            )
        )

    tasks.append(
        (
            "Welcome to numbers. Tap a number and listen.",
            EN_VOICE,
            NUMBERS_DIR / "intro.mp3",
        )
    )

    for item in parse_phonics_items():
        key = slugify(item["title"])
        sound_text = phonics_voice_map.get(item["title"], item["sound_cue"].split(",")[0])
        tasks.append(
            (
                sound_text,
                EN_VOICE,
                PHONICS_SOUND_DIR / f"{key}.mp3",
            )
        )
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

    tasks.append(
        (
            "Welcome to phonics. Tap the sound first, then hear the word, and say it with me.",
            EN_VOICE,
            PHONICS_INTRO_DIR / "welcome.mp3",
        )
    )

    for item in parse_prepositions():
        key = slugify(item["title"])
        tasks.append(
            (
                item["title"],
                EN_VOICE,
                PREPOSITIONS_WORD_DIR / f"{key}.mp3",
            )
        )
        tasks.append(
            (
                item["example_sentence"],
                EN_VOICE,
                PREPOSITIONS_PHRASE_DIR / f"{key}.mp3",
            )
        )
        tasks.append(
            (
                item["chinese_prompt"],
                ZH_VOICE,
                PREPOSITIONS_PROMPT_DIR / f"{key}.mp3",
            )
        )

    tasks.append(
        (
            "Welcome to prepositions. First watch where the ball goes, then hear the word and the sentence.",
            EN_VOICE,
            PREPOSITIONS_INTRO_DIR / "welcome.mp3",
        )
    )

    for stage in parse_letter_sound_stages():
        key = slugify(stage["code"])
        tasks.append(
            (
                stage["prompt"],
                ZH_VOICE,
                LETTER_SOUNDS_INTRO_DIR / f"{key}.mp3",
            )
        )

    tasks.append(
        (
            "欢迎来到字母发音乐园。先听声音，再看图片，最后勇敢说出来。",
            ZH_VOICE,
            LETTER_SOUNDS_INTRO_DIR / "welcome.mp3",
        )
    )

    for item in parse_letter_sound_items():
        key = slugify(item["letter"])
        tasks.append(
            (
                item["sound_cue"],
                EN_VOICE,
                LETTER_SOUNDS_SOUND_DIR / f"{key}.mp3",
            )
        )
        tasks.append(
            (
                item["primary_word"],
                EN_VOICE,
                LETTER_SOUNDS_WORD_DIR / f"{key}-1.mp3",
            )
        )
        tasks.append(
            (
                item["secondary_word"],
                EN_VOICE,
                LETTER_SOUNDS_WORD_DIR / f"{key}-2.mp3",
            )
        )
        tasks.append(
            (
                item["chant"],
                EN_VOICE,
                LETTER_SOUNDS_CHANT_DIR / f"{key}.mp3",
            )
        )
        tasks.append(
            (
                item["prompt"],
                ZH_VOICE,
                LETTER_SOUNDS_PROMPT_DIR / f"{key}.mp3",
            )
        )

    for shape in (
        "circle",
        "square",
        "triangle",
        "rectangle",
        "star",
        "heart",
        "oval",
        "diamond",
    ):
        tasks.append(
            (
                shape,
                EN_VOICE,
                SHAPES_DIR / f"{slugify(shape)}.mp3",
            )
        )

    tasks.append(
        (
            "Welcome to shapes. Tap a shape and hear its name.",
            EN_VOICE,
            SHAPES_DIR / "intro.mp3",
        )
    )

    stories = {
        "the-little-cat": "This is a cat. The cat is on the mat. The cat says meow.",
        "the-red-ball": "I see a red ball. The ball is big and round. The ball can bounce.",
        "bear-in-the-box": "The bear is in the box. The bear looks out. Hello, little bear.",
    }
    for key, text in stories.items():
        tasks.append((text, EN_VOICE, STORIES_DIR / f"{key}.mp3"))

    tasks.append(
        (
            "Welcome to stories. Tap a story card and listen to the short story.",
            EN_VOICE,
            STORIES_DIR / "intro.mp3",
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
