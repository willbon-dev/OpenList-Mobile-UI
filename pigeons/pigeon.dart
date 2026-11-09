import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class AppConfig {
  bool isWakeLockEnabled();

  void setWakeLockEnabled(bool enabled);

  bool isStartAtBootEnabled();

  void setStartAtBootEnabled(bool enabled);

  bool isAutoCheckUpdateEnabled();

  void setAutoCheckUpdateEnabled(bool enabled);

  bool isAutoOpenWebPageEnabled();

  void setAutoOpenWebPageEnabled(bool enabled);

  String getDataDir();

  void setDataDir(String dir);

  bool isSilentJumpAppEnabled();

  void setSilentJumpAppEnabled(bool enabled);
}

@HostApi()
abstract class NativeCommon {
  bool startActivityFromUri(String intentUri);

  /// 用系统查看器/播放器直接打开本地文件（ACTION_VIEW + FileProvider），
  /// 不触发媒体权限弹窗；无应用可打开或文件不存在返回 false
  bool openFileWithViewer(String path);

  int getDeviceSdkInt();

  String getDeviceCPUABI();

  String getVersionName();

  int getVersionCode();

  void toast(String msg);

  void longToast(String msg);
}

@HostApi()
abstract class Android {
  void addShortcut();

  void startService();

  void setAdminPwd(String pwd);

  /// 创建或重置原生 UI 专用内置账号（幂等），返回生效的用户名
  String ensureAppUser(String username, String password);

  int getOpenListHttpPort();

  bool isRunning();

  String getOpenListVersion();
}

@FlutterApi()
abstract class Event {
  void onServiceStatusChanged(bool isRunning);

  void onServerLog(
    int level,
    String time,
    String log,
  );
}
