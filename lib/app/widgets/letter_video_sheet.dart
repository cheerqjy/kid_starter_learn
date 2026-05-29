import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

import '../constant.dart';
import '../models/letter_sound_models.dart';

class LetterVideoSheet extends StatefulWidget {
  final List<LetterSoundItem> items;
  final int initialIndex;
  final String stageTitle;

  const LetterVideoSheet({
    Key? key,
    required this.items,
    required this.initialIndex,
    required this.stageTitle,
  }) : super(key: key);

  @override
  State<LetterVideoSheet> createState() => _LetterVideoSheetState();
}

class _LetterVideoSheetState extends State<LetterVideoSheet> {
  final CacheManager _cacheManager = DefaultCacheManager();

  VideoPlayerController? _controller;
  StreamSubscription<FileResponse>? _downloadSubscription;
  int _currentIndex = 0;
  double? _progress;
  bool _isPreparing = true;
  bool _isCached = false;
  String? _errorMessage;

  LetterSoundItem get _item => widget.items[_currentIndex];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    unawaited(_loadVideo());
  }

  @override
  void dispose() {
    _downloadSubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadVideo() async {
    setState(() {
      _isPreparing = true;
      _isCached = false;
      _progress = null;
      _errorMessage = null;
    });

    await _downloadSubscription?.cancel();
    _downloadSubscription = null;
    await _controller?.dispose();
    _controller = null;

    try {
      final cached = await _cacheManager.getFileFromCache(_item.videoUrl);
      if (cached != null) {
        _isCached = true;
        await _initializeController(VideoPlayerController.file(cached.file));
        return;
      }

      _downloadSubscription = _cacheManager
          .getFileStream(_item.videoUrl, withProgress: true)
          .listen((response) async {
        if (!mounted) {
          return;
        }

        if (response is DownloadProgress) {
          final totalSize = response.totalSize;
          setState(() {
            _progress = response.progress ??
                (totalSize == null || totalSize == 0
                    ? null
                    : response.downloaded / totalSize);
          });
          return;
        }

        if (response is FileInfo) {
          _isCached = true;
          await _downloadSubscription?.cancel();
          _downloadSubscription = null;
          await _initializeController(
              VideoPlayerController.file(response.file));
        }
      });
    } catch (_) {
      await _fallbackToNetwork();
    }
  }

  Future<void> _initializeController(VideoPlayerController controller) async {
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isPreparing = false;
        _errorMessage = null;
      });
    } catch (_) {
      await controller.dispose();
      await _fallbackToNetwork();
    }
  }

  Future<void> _fallbackToNetwork() async {
    try {
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(_item.videoUrl));
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isPreparing = false;
        _isCached = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPreparing = false;
        _errorMessage = '视频暂时打不开，请检查网络后再试一次。';
      });
    }
  }

  Future<void> _showIndex(int nextIndex) async {
    if (nextIndex < 0 || nextIndex >= widget.items.length) {
      return;
    }
    setState(() {
      _currentIndex = nextIndex;
    });
    await _loadVideo();
  }

  Widget _buildVideoArea() {
    if (_errorMessage != null) {
      return _VideoStatusCard(
        icon: Icons.wifi_off_rounded,
        title: '视频暂时无法播放',
        subtitle: _errorMessage!,
        trailing: FilledButton(
          onPressed: _loadVideo,
          child: const Text('重试'),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      final progress = _progress;
      return _VideoStatusCard(
        icon: Icons.cloud_download_rounded,
        title: progress == null ? '正在准备视频' : '正在缓存视频',
        subtitle: progress == null
            ? '第一次打开会联网下载，缓存好后下次会更快。'
            : '缓存进度 ${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
        trailing: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 5,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(color: Colors.black),
              child: VideoPlayer(_controller!),
            ),
            Positioned(
              right: 14,
              top: 14,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCached
                          ? Icons.offline_bolt_rounded
                          : Icons.wifi_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isCached ? '已缓存' : '在线播放',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    if (_controller == null) {
                      return;
                    }
                    if (_controller!.value.isPlaying) {
                      await _controller!.pause();
                    } else {
                      await _controller!.play();
                    }
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _controller!.value.isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 180),
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFDFDFD),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 54,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '磨耳朵视频',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: kTitleTextColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.stageTitle} · 首次播放会自动缓存到本机',
                style: const TextStyle(
                  fontSize: 15,
                  color: kBodyTextColor,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildVideoArea(),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: _item.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: _item.accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _item.letter,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _item.soundCue,
                                        style: const TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w800,
                                          color: kTitleTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_item.primaryEmoji} ${_item.primaryWord}   ${_item.secondaryEmoji} ${_item.secondaryWord}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: kBodyTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _item.chinesePrompt,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: kBodyTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _currentIndex == 0
                                  ? null
                                  : () => _showIndex(_currentIndex - 1),
                              icon: const Icon(Icons.chevron_left_rounded),
                              label: const Text('上一个'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _isPreparing
                                  ? null
                                  : () async {
                                      if (_controller == null) {
                                        return;
                                      }
                                      await _controller!.seekTo(Duration.zero);
                                      await _controller!.play();
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                              icon: const Icon(Icons.replay_rounded),
                              label: const Text('重新看'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed:
                                  _currentIndex == widget.items.length - 1
                                      ? null
                                      : () => _showIndex(_currentIndex + 1),
                              icon: const Icon(Icons.chevron_right_rounded),
                              label: const Text('下一个'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoStatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _VideoStatusCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: const Color(0xFFFF8A65)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: kTitleTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: kBodyTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          trailing,
        ],
      ),
    );
  }
}
