import 'package:flutter/foundation.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

/// 播放器手势调节的亮度/音量封装。
///
/// 亮度：调节**应用内**亮度（无需系统权限），进入播放页时保存原值，
/// 退出时恢复。音量：系统媒体音量，调节后不回滚（与系统播放器一致）。
class PlayerBrightnessVolume {
  double? _savedBrightness;
  double _brightness = 0.5;
  double _lastVolume = 0.5;

  /// 初始化：保存当前亮度、取当前音量。应在进入播放页时调用。
  Future<void> init() async {
    try {
      _savedBrightness = await ScreenBrightness.instance.application;
      _brightness = _savedBrightness ?? 0.5;
    } catch (_) {
      _savedBrightness = null;
      _brightness = 0.5;
    }
    try {
      VolumeController.instance.showSystemUI = false;
      _lastVolume = await VolumeController.instance.getVolume();
    } catch (_) {
      _lastVolume = 0.5;
    }
  }

  double get volume => _lastVolume;

  /// 当前应用亮度（拖动基准）。
  double get brightness => _brightness;

  Future<void> setBrightness(double value) async {
    _brightness = value.clamp(0.0, 1.0);
    try {
      await ScreenBrightness.instance
          .setApplicationScreenBrightness(_brightness);
    } catch (e) {
      debugPrint('setBrightness failed: $e');
    }
  }

  Future<void> setVolume(double value) async {
    _lastVolume = value.clamp(0.0, 1.0);
    try {
      await VolumeController.instance.setVolume(_lastVolume);
    } catch (e) {
      debugPrint('setVolume failed: $e');
    }
  }

  /// 退出播放页时恢复亮度。音量不恢复。
  Future<void> dispose() async {
    final saved = _savedBrightness;
    if (saved != null) {
      try {
        await ScreenBrightness.instance.setApplicationScreenBrightness(saved);
      } catch (_) {}
    }
    try {
      VolumeController.instance.removeListener();
    } catch (_) {}
  }
}
