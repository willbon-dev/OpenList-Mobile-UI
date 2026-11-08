import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/models/site.dart';
import '../../../generated/l10n.dart';
import '../../../utils/video_brightness_volume.dart';
import '../../../core/utils/file_types.dart';
import '../../../services/auth_service.dart';

/// 长按倍速基线；竖直拖动的速率映射：每 120 逻辑像素 ±0.5x。
const double _speedBase = 2.0;
const double _speedPerPx = 0.5 / 120.0;
const double _speedMin = 1.0;
const double _speedMax = 4.0;

enum _PanMode { none, seek, brightness, volume }

enum _Bubble { none, seek, brightness, volume, speed }

/// 视频/音频播放页。
///
/// 手势（未锁定时）：
/// - 双击：播放/暂停
/// - 长按：进入倍速（默认 2x）；长按后竖直拖动连续调节（上拖加速、
///   下拖减速，范围 1x~4x）；松手恢复原倍速与播放状态
/// - 水平滑：进度预览，松手定位
/// - 左侧竖滑：亮度；右侧竖滑：音量
/// - 单击：控制栏显隐（3 秒自动隐藏）
class VideoPlayerPage extends StatefulWidget {
  final Site site;
  final String filePath;
  final String title;
  final bool isAudio;

  const VideoPlayerPage({
    super.key,
    required this.site,
    required this.filePath,
    required this.title,
    this.isAudio = false,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _failed = false;

  bool _showControls = true;
  Timer? _hideTimer;
  bool _locked = false;
  bool _fullscreen = false;

  // 用户选定的固定倍速（菜单）；长按倍速不影响该值
  double _rate = 1.0;

  // 长按倍速态
  bool _tempSpeed = false;
  bool _wasPlayingBeforeSpeed = false;
  Offset? _longPressOrigin;

  // 播放进度刷新（控制栏可见时节流 setState）
  Duration _lastPos = Duration.zero;

  // 手势
  _PanMode _panMode = _PanMode.none;
  Offset _panStart = Offset.zero;
  Duration _seekStart = Duration.zero;
  Duration _seekTarget = Duration.zero;
  double _panStartBrightness = 0.5;
  double _panStartVolume = 0.5;

  // 拖动实时预览：节流 seek，画面/进度条跟随手指
  DateTime? _lastPreviewSeekAt;
  Duration? _lastPreviewSeekTarget;

  _Bubble _bubble = _Bubble.none;
  double _bubbleValue = 0;

  final PlayerBrightnessVolume _bv = PlayerBrightnessVolume();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _bv.init();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    setState(() {
      _failed = false;
      _initialized = false;
    });
    try {
      // 经 AuthService 调 fsGet: 返回的 raw_url 自带 sign，播放器可直接访问
      final info = await AuthService.to
          .execute(widget.site, (client) => client.fsGet(widget.filePath));
      final url = info.rawUrl;
      if (url.isEmpty) throw Exception(S.current.cannotPreview);

      final controller =
          VideoPlayerController.networkUrl(Uri.parse(url));
      _controller = controller;
      await controller.initialize();
      await controller.setPlaybackSpeed(_rate);

      // 根据视频分辨率自动横竖屏：横屏视频直接进入全屏横屏，
      // 竖屏视频保持竖屏；音频文件不做旋转
      if (!widget.isAudio) {
        final size = controller.value.size;
        if (size.width > 0 && size.height > 0 && size.width > size.height) {
          _fullscreen = true;
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
          await SystemChrome
              .setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        }
      }

      if (!mounted) {
        await controller.dispose();
        return;
      }
      controller.addListener(_onPlaybackTick);
      setState(() => _initialized = true);
      await controller.play();
      WakelockPlus.enable();
      _scheduleHide();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _controller = null;
      });
    }
  }

  /// 控制栏可见时节流刷新进度。
  void _onPlaybackTick() {
    if (!mounted) return;
    final pos = _controller?.value.position;
    if (pos == null || pos == _lastPos) return;
    _lastPos = pos;
    if (_showControls) setState(() {});
  }

  bool get _isPlaying => _controller?.value.isPlaying ?? false;

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_locked) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    debugPrint('vp: _toggleControls -> ${!_showControls}');
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleHide();
  }

  Future<void> _togglePlay() async {
    final c = _controller;
    debugPrint('vp: _togglePlay isPlaying=$_isPlaying');
    if (c == null) return;
    if (c.value.isPlaying) {
      await c.pause();
      WakelockPlus.disable();
    } else {
      await c.play();
      WakelockPlus.enable();
    }
    // 暂停后播放位置不再变化，_onPlaybackTick 不会触发 setState，
    // 需要手动刷新，否则左下角播放/暂停图标不切换
    if (mounted) setState(() {});
    _scheduleHide();
  }

  Future<void> _setSpeed(double rate) async {
    _rate = rate;
    if (!_tempSpeed) {
      await _controller?.setPlaybackSpeed(rate);
    }
  }

  // ------------------------------------------------------------ gestures

  void _onLongPressStart(LongPressStartDetails d) {
    if (_locked || _controller == null || !_initialized) return;
    _tempSpeed = true;
    _wasPlayingBeforeSpeed = _isPlaying;
    _applySpeed(_speedBase);
    setState(() {
      _bubble = _Bubble.speed;
      _bubbleValue = _speedBase;
    });
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails d) {
    if (_locked || !_tempSpeed || _longPressOrigin == null) return;
    // 以按下位置为基准：上拖（dy<0）加速、下拖减速
    final dy = d.localPosition.dy - _longPressOrigin!.dy;
    final delta = dy * _speedPerPx * -1;
    final rate = (_speedBase + delta).clamp(_speedMin, _speedMax);
    _applySpeed(rate);
    setState(() => _bubbleValue = rate);
  }

  /// 记录长按起点（MoveUpdate 里拿不到 Start 的位置，在 start 时缓存）。
  void _rememberOrigin(Offset o) => _longPressOrigin = o;

  void _onLongPressEnd(LongPressEndDetails d) {
    if (_locked || !_tempSpeed) return;
    _exitTempSpeed();
  }

  Future<void> _applySpeed(double rate) async {
    await _controller?.setPlaybackSpeed(rate);
  }

  void _exitTempSpeed() {
    if (!_tempSpeed) return;
    _tempSpeed = false;
    _applySpeed(_rate);
    if (!_wasPlayingBeforeSpeed && _isPlaying) {
      _controller?.pause();
      WakelockPlus.disable();
    }
    if (mounted) setState(() => _bubble = _Bubble.none);
  }

  void _onPanStart(DragStartDetails d) {
    if (_locked || _controller == null || !_initialized) {
      debugPrint('vp: panStart ignored locked=$_locked init=$_initialized');
      return;
    }
    debugPrint('vp: panStart at ${d.localPosition}');
    _panStart = d.localPosition;
    _panMode = _PanMode.none;
    _seekStart = _controller!.value.position;
    _panStartBrightness = _bv.brightness;
    _panStartVolume = _bv.volume;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_locked || _controller == null || !_initialized) return;
    final size = context.size ?? MediaQuery.sizeOf(context);
    final dx = d.localPosition.dx - _panStart.dx;
    final dy = d.localPosition.dy - _panStart.dy;

    if (_panMode == _PanMode.none) {
      if (dx.abs() < 10 && dy.abs() < 10) return;
      if (dx.abs() >= dy.abs()) {
        _panMode = _PanMode.seek;
        debugPrint('vp: panMode=seek dx=$dx dy=$dy size=$size');
      } else {
        final x = _panStart.dx;
        if (x < size.width / 3) {
          _panMode = _PanMode.brightness;
          debugPrint('vp: panMode=brightness x=$x');
        } else if (x > size.width * 2 / 3) {
          _panMode = _PanMode.volume;
          debugPrint('vp: panMode=volume x=$x');
        } else {
          debugPrint('vp: panMode=none (middle vertical) x=$x');
          return; // 中部竖滑不响应
        }
      }
    }

    final duration = _controller!.value.duration;
    switch (_panMode) {
      case _PanMode.seek:
        if (duration == Duration.zero) return;
        final ratio = dx / size.width * 0.5; // 全屏宽 = 50% 时长
        final targetMs =
            (_seekStart.inMilliseconds + ratio * duration.inMilliseconds)
                .round();
        _seekTarget = Duration(
            milliseconds:
                targetMs.clamp(0, duration.inMilliseconds));
        // 边拖边 seek（200ms 节流或远跳立即）：画面实时切换跟随手指
        final now = DateTime.now();
        final farJump = _lastPreviewSeekTarget != null &&
            (_seekTarget - _lastPreviewSeekTarget!).abs() >
                const Duration(seconds: 3);
        if (_lastPreviewSeekAt == null ||
            farJump ||
            now.difference(_lastPreviewSeekAt!) >
                const Duration(milliseconds: 200)) {
          _lastPreviewSeekAt = now;
          _lastPreviewSeekTarget = _seekTarget;
          _controller!.seekTo(_seekTarget);
        }
        setState(() {
          _bubble = _Bubble.seek;
          _bubbleValue = _seekTarget.inMilliseconds / 1.0;
        });
        break;
      case _PanMode.brightness:
        final value = (_panStartBrightness - dy / size.height)
            .clamp(0.0, 1.0);
        _bv.setBrightness(value);
        setState(() {
          _bubble = _Bubble.brightness;
          _bubbleValue = value;
        });
        break;
      case _PanMode.volume:
        final value = (_panStartVolume - dy / size.height)
            .clamp(0.0, 1.0);
        _bv.setVolume(value);
        setState(() {
          _bubble = _Bubble.volume;
          _bubbleValue = value;
        });
        break;
      case _PanMode.none:
        break;
    }
  }

  void _onPanEnd(DragEndDetails d) {
    if (_panMode == _PanMode.seek && _bubble == _Bubble.seek) {
      _controller?.seekTo(_seekTarget);
    }
    _lastPreviewSeekAt = null;
    _lastPreviewSeekTarget = null;
    if (mounted) {
      setState(() {
        _bubble = _Bubble.none;
        _panMode = _PanMode.none;
      });
    }
    if (_showControls) _scheduleHide();
  }

  // ------------------------------------------------------------- control

  Future<void> _toggleFullscreen() async {
    setState(() => _fullscreen = !_fullscreen);
    if (_fullscreen) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _scheduleHide();
  }

  Future<void> _pickSpeed() async {
    _hideTimer?.cancel();
    final picked = await showModalBottomSheet<double>(
      context: context,
      builder: (ctx) => SafeArea(
        // 横屏下屏幕高度有限，选项列表需可滚动
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(S.current.playerSpeed,
                    style: Theme.of(ctx).textTheme.titleMedium),
              ),
              for (final r in const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0])
                ListTile(
                  dense: true,
                  title: Text('${r}x'),
                  trailing: r == _rate
                      ? Icon(Icons.check,
                          color: Theme.of(ctx).colorScheme.primary)
                      : null,
                  onTap: () => Navigator.of(ctx).pop(r),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) await _setSpeed(picked);
    _scheduleHide();
  }

  Future<void> _exit() async {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    WakelockPlus.disable();
    _bv.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller?.removeListener(_onPlaybackTick);
    _controller?.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PopScope(
        canPop: true,
        child: _failed
            ? _buildError()
            : !_initialized
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : _buildPlayer(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: Colors.white54),
          const SizedBox(height: 12),
          Text(
            S.current.playbackError(S.current.operationFailed('')),
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: _initPlayer,
                child: Text(S.current.retry,
                    style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _exit,
                child: Text(S.current.close,
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer() {
    final controller = _controller!;
    final isAudio = widget.isAudio;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 媒体层
        if (isAudio)
          _buildAudioCover()
        else
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(
                controller,
                // 旋转后重建 texture 表面：fvp 纹理不随屏幕方向更新
                // buffer transform，否则画面会旋转 90°
                key: ValueKey(_fullscreen),
              ),
            ),
          ),
        // 手势层（在控制层之下：空白区域事件由它处理；
        // 控制层可见时按钮/滑条区域在 Stack 命中测试中短路，不会走到这里）
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _locked
              ? _showUnlockHint
              : () {
                  debugPrint(
                      'vp: gesture onTap (toggle controls) show=$_showControls');
                  _toggleControls();
                },
          onDoubleTap: _locked
              ? null
              : () {
                  debugPrint('vp: gesture onDoubleTap');
                  _togglePlay();
                },
          onLongPressStart: (d) {
            _rememberOrigin(d.localPosition);
            _onLongPressStart(d);
          },
          onLongPressMoveUpdate: _onLongPressMoveUpdate,
          onLongPressEnd: _onLongPressEnd,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
        ),
        // 控制层（渐变背景不吸收命中，按钮/滑条正常交互）
        AnimatedOpacity(
          opacity: _showControls && !_locked ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !_showControls || _locked,
            child: _buildControls(controller),
          ),
        ),
        // 锁定态解锁按钮
        if (_locked)
          Center(
            child: IconButton(
              icon: Icon(Icons.lock_open,
                  color: Colors.white.withValues(alpha: 0.9), size: 32),
              onPressed: () {
                setState(() => _locked = false);
                _scheduleHide();
              },
            ),
          ),
        // 手势指示气泡
        if (_bubble != _Bubble.none) _buildBubble(),
      ],
    );
  }

  Widget _buildAudioCover() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_note,
              size: 96, color: theme.colorScheme.primary.withValues(alpha: 0.8)),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(S.current.audioTrack,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildControls(VideoPlayerController controller) {
    // 拖动快进时进度条/时间显示跟随手指的目标位置，
    // 而不是实际播放位置（实际 seek 完成前会滞后）
    final position = _bubble == _Bubble.seek
        ? _seekTarget
        : controller.value.position;
    final duration = controller.value.duration;
    final buffered = controller.value.buffered.isNotEmpty
        ? controller.value.buffered.last.end
        : Duration.zero;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 背景渐变：纯视觉层，IgnorePointer 避免吸收空白区域的触摸命中
        // （否则控制栏可见时手势层收不到事件）
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent, Colors.black54],
                  stops: [0, 0.3, 1],
                ),
              ),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          // 顶栏
          SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    debugPrint('vp: btn back');
                    _exit();
                  },
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _locked ? Icons.lock : Icons.lock_open,
                    color: Colors.white,
                  ),
                  tooltip: _locked
                      ? S.current.unlockScreen
                      : S.current.lockScreen,
                  onPressed: () {
                    debugPrint('vp: btn lock');
                    setState(() => _locked = true);
                  },
                ),
              ],
            ),
          ),
          // 底栏
          SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 进度条
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Text(
                        Formatters.duration(position),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12),
                          ),
                          child: Slider(
                            value: duration > Duration.zero
                                ? position.inMilliseconds
                                    .clamp(0, duration.inMilliseconds)
                                    .toDouble()
                                : 0,
                            max: duration.inMilliseconds.toDouble(),
                            secondaryTrackValue:
                                buffered.inMilliseconds.toDouble(),
                            onChanged: duration > Duration.zero
                                ? (v) {
                                    controller.seekTo(
                                        Duration(milliseconds: v.round()));
                                    _scheduleHide();
                                  }
                                : null,
                          ),
                        ),
                      ),
                      Text(
                        duration > Duration.zero
                            ? Formatters.duration(duration)
                            : S.current.unknownDuration,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // 按钮行
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: _togglePlay,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        debugPrint('vp: btn speed');
                        _pickSpeed();
                      },
                      child: Text(
                        '${_rate}x',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _fullscreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        debugPrint('vp: btn fullscreen');
                        _toggleFullscreen();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          ],
        ),
      ],
    );
  }

  Widget _buildBubble() {
    switch (_bubble) {
      case _Bubble.seek:
        final sign =
            _seekTarget >= _seekStart ? '+' : '-';
        final delta = _seekTarget - _seekStart;
        final deltaAbs =
            delta < Duration.zero ? -delta : delta;
        return _topBubble(
          '$sign${Formatters.duration(deltaAbs)}'
          '  →  ${Formatters.duration(_seekTarget)}',
        );
      case _Bubble.brightness:
      case _Bubble.volume:
        final isB = _bubble == _Bubble.brightness;
        return Center(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isB ? Icons.brightness_6 : Icons.volume_up,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  '${(_bubbleValue * 100).round()}%',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      case _Bubble.speed:
        return Center(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${_bubbleValue.toStringAsFixed(_bubbleValue == _bubbleValue.roundToDouble() ? 0 : 1)}x',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
      case _Bubble.none:
        return const SizedBox.shrink();
    }
  }

  Widget _topBubble(String text) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 8,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ),
    );
  }

  bool _unlockHintShown = false;
  void _showUnlockHint() {
    if (_unlockHintShown) return;
    _unlockHintShown = true;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _unlockHintShown = false;
    });
  }
}
