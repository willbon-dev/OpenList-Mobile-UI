// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(count) => "${count} 项配置";

  static String m1(error) => "取消所有通知失败: ${error}";

  static String m2(error) => "取消下载通知失败: ${error}";

  static String m3(error) => "检查安装权限失败: ${error}";

  static String m4(error) => "清理下载目录失败: ${error}";

  static String m5(filename) => "确定要取消下载 \"${filename}\" 吗？";

  static String m6(filename) => "确定要删除文件 \"${filename}\" 吗？此操作不可撤销。";

  static String m7(filename) => "确定要删除 \"${filename}\" 的下载记录吗？";

  static String m8(error) => "连接失败: ${error}";

  static String m9(error) => "创建OpenList目录失败: ${error}";

  static String m10(path) => "创建OpenList下载目录: ${path}";

  static String m11(count) => "当前有 ${count} 个文件在下载";

  static String m12(error) => "删除文件失败: ${error}";

  static String m13(name) => "确定删除 \"${name}\" 吗？";

  static String m14(count) => "确定删除选中的 ${count} 项吗？";

  static String m15(name) => "确定删除站点 \"${name}\" 吗？";

  static String m16(path) => "确认删除存储 ${path}？";

  static String m17(url) => "下载已取消: ${url}";

  static String m18(filename) => "下载完成: ${filename}";

  static String m19(filename) => "下载完成: ${filename}";

  static String m20(filename) => "${filename} 下载完毕";

  static String m21(filename) => "下载失败: ${filename}";

  static String m22(filename) => "下载失败: ${filename}";

  static String m23(count) => "下载管理(${count})";

  static String m24(progress) => "下载进度: ${progress}%";

  static String m25(current, total) => "正在下载第 ${current}/${total} 个文件";

  static String m26(filename) => "已删除文件: ${filename}";

  static String m27(index) => "第 ${index} 个文件下载失败";

  static String m28(size) => "大小: ${size}";

  static String m29(time) => "时间: ${time}";

  static String m30(error) => "获取下载目录失败: ${error}";

  static String m31(error) => "获取下载文件列表失败: ${error}";

  static String m32(error, line) => "JSON格式错误,第${line}行:${error}";

  static String m33(count) => "共 ${count} 项";

  static String m34(error) => "加载失败:${error}";

  static String m35(error) => "登录失败: ${error}";

  static String m36(count) => "${count} 个文件已完成，点击跳转到下载管理";

  static String m37(payload) => "通知被点击: ${payload}";

  static String m38(error) => "通知管理器初始化失败: ${error}";

  static String m39(error) => "打开下载目录失败: ${error}";

  static String m40(error) => "打开文件异常: ${error}";

  static String m41(error) => "打开文件失败: ${error}";

  static String m42(error) => "打开文件管理器失败: ${error}";

  static String m43(message, type) => "打开文件结果: ${type} - ${message}";

  static String m44(path) => "OpenList下载目录: ${path}";

  static String m45(error) => "操作失败: ${error}";

  static String m46(error) => "解析文件名失败: ${error}";

  static String m47(error) => "播放失败: ${error}";

  static String m48(name) => "重命名 \"${name}\"";

  static String m49(error) => "恢复备份失败:${error}";

  static String m50(error) => "保存失败:${error}";

  static String m51(count) => "找到 ${count} 个结果";

  static String m52(count) => "已选 ${count} 项";

  static String m53(error) => "显示下载完成通知失败: ${error}";

  static String m54(error) => "显示下载进度通知失败: ${error}";

  static String m55(error) => "显示单个文件下载完成通知失败: ${error}";

  static String m56(filename) => "开始下载: ${filename}";

  static String m57(filename) => "开始下载: ${filename}";

  static String m58(path) => "尝试打开文件: ${path}";

  static String m59(error) => "上传失败: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("关于"),
    "add": MessageLookupByLibrary.simpleMessage("添加"),
    "addSite": MessageLookupByLibrary.simpleMessage("添加站点"),
    "additionJson": MessageLookupByLibrary.simpleMessage("驱动配置（JSON）"),
    "additionJsonInvalid": MessageLookupByLibrary.simpleMessage("配置 JSON 格式错误"),
    "additionalItems": m0,
    "apkDownloadCompleteMessage": MessageLookupByLibrary.simpleMessage(
      "APK文件已下载完成，是否要安装？",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("OpenList"),
    "audioTrack": MessageLookupByLibrary.simpleMessage("音频"),
    "autoCheckForUpdates": MessageLookupByLibrary.simpleMessage("自动检查更新"),
    "autoCheckForUpdatesDesc": MessageLookupByLibrary.simpleMessage(
      "启动时自动检查更新",
    ),
    "autoStartIssue": MessageLookupByLibrary.simpleMessage("自启动相关说明"),
    "autoStartIssueDesc": MessageLookupByLibrary.simpleMessage(
      "设置自启动时建议把app的电池优化一并关闭，当前在开启自启动后，系统重启时服务会自动在后台启动，但可能不会在通知栏弹出通知。请放心，服务已正常运行，您可以在通知栏快捷开关查看服务状态，或回到主界面查看服务开关确认服务是否已启动。",
    ),
    "autoStartWebPage": MessageLookupByLibrary.simpleMessage("将网页设置为打开首页"),
    "autoStartWebPageDesc": MessageLookupByLibrary.simpleMessage("打开主界面时的首页"),
    "backAgainToExit": MessageLookupByLibrary.simpleMessage("再按一次返回键退出"),
    "backupRestored": MessageLookupByLibrary.simpleMessage("备份已恢复"),
    "basicInfo": MessageLookupByLibrary.simpleMessage("基础信息"),
    "batchCopy": MessageLookupByLibrary.simpleMessage("批量复制"),
    "batchDelete": MessageLookupByLibrary.simpleMessage("批量删除"),
    "batchDownload": MessageLookupByLibrary.simpleMessage("批量下载"),
    "batchDownloadComplete": MessageLookupByLibrary.simpleMessage("批量下载完成"),
    "batchMove": MessageLookupByLibrary.simpleMessage("批量移动"),
    "bootAutoStartService": MessageLookupByLibrary.simpleMessage("开机自启动服务"),
    "bootAutoStartServiceDesc": MessageLookupByLibrary.simpleMessage(
      "在开机后自动启动OpenList服务。（请确保授予自启动权限）",
    ),
    "browserDownload": MessageLookupByLibrary.simpleMessage("浏览器下载"),
    "browserDownloadMethod": MessageLookupByLibrary.simpleMessage("浏览器下载"),
    "browserDownloadMethodDesc": MessageLookupByLibrary.simpleMessage(
      "使用系统浏览器",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "cancelAllNotificationsFailed": m1,
    "cancelDownload": MessageLookupByLibrary.simpleMessage("取消下载"),
    "cancelDownloadNotificationFailed": m2,
    "cancelled": MessageLookupByLibrary.simpleMessage("已取消"),
    "cannotGetBaseDownloadDirectory": MessageLookupByLibrary.simpleMessage(
      "无法获取基础下载目录",
    ),
    "cannotGetDownloadDirectory": MessageLookupByLibrary.simpleMessage(
      "无法获取下载目录",
    ),
    "cannotGetDownloadDirectoryError": MessageLookupByLibrary.simpleMessage(
      "无法获取下载目录",
    ),
    "cannotInstallApkFile": MessageLookupByLibrary.simpleMessage(
      "无法安装 APK 文件，可能需要在设置中开启\"允许安装未知来源应用\"",
    ),
    "cannotInstallApkNeedPermission": MessageLookupByLibrary.simpleMessage(
      "无法安装 APK 文件，可能需要在设置中开启\"允许安装未知来源应用\"",
    ),
    "cannotPreview": MessageLookupByLibrary.simpleMessage("该文件类型暂不支持预览"),
    "checkDownloadManagerForFiles": MessageLookupByLibrary.simpleMessage(
      "请通过底部导航栏的\"下载管理\"查看下载文件",
    ),
    "checkForUpdates": MessageLookupByLibrary.simpleMessage("检查更新"),
    "checkImageInDownloadFolder": MessageLookupByLibrary.simpleMessage(
      "请在下载目录查看图片",
    ),
    "checkInstallPermissionFailed": m3,
    "clear": MessageLookupByLibrary.simpleMessage("清空"),
    "clearAll": MessageLookupByLibrary.simpleMessage("清空所有"),
    "clearDownloadDirectoryFailed": m4,
    "clearFailed": MessageLookupByLibrary.simpleMessage("清空失败"),
    "clearRecords": MessageLookupByLibrary.simpleMessage("清空记录"),
    "clearSucceeded": MessageLookupByLibrary.simpleMessage("清除已完成"),
    "cleared": MessageLookupByLibrary.simpleMessage("已清空下载目录"),
    "clickToJumpToDownloadManager": MessageLookupByLibrary.simpleMessage(
      "点击跳转到下载管理",
    ),
    "close": MessageLookupByLibrary.simpleMessage("关闭"),
    "completed": MessageLookupByLibrary.simpleMessage("已完成"),
    "completedTime": MessageLookupByLibrary.simpleMessage("完成时间"),
    "configSavedRestartRequired": MessageLookupByLibrary.simpleMessage(
      "配置已保存,请重启OpenList服务以生效",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("确认"),
    "confirmCancelDownload": m5,
    "confirmClear": MessageLookupByLibrary.simpleMessage("确认清空"),
    "confirmClearAllFiles": MessageLookupByLibrary.simpleMessage(
      "确定要清空所有下载文件吗？此操作不可撤销。",
    ),
    "confirmDelete": MessageLookupByLibrary.simpleMessage("确认删除"),
    "confirmDeleteFile": m6,
    "confirmDeleteRecord": m7,
    "confirmDownload": MessageLookupByLibrary.simpleMessage("确认下载"),
    "confirmDownloadMessage": MessageLookupByLibrary.simpleMessage(
      "是否要下载这个文件？",
    ),
    "confirmSaveConfigMessage": MessageLookupByLibrary.simpleMessage(
      "修改配置可能导致服务不可用,确定保存吗?",
    ),
    "confirmSaveConfigTitle": MessageLookupByLibrary.simpleMessage("确认保存"),
    "connectionFailed": m8,
    "connectionOk": MessageLookupByLibrary.simpleMessage("连接成功"),
    "continueDownload": MessageLookupByLibrary.simpleMessage("继续下载"),
    "copiedToClipboard": MessageLookupByLibrary.simpleMessage("已复制到剪贴板"),
    "copy": MessageLookupByLibrary.simpleMessage("复制"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("复制成功"),
    "copyTo": MessageLookupByLibrary.simpleMessage("复制到"),
    "createOpenListDirectoryFailed": m9,
    "createOpenListDownloadDirectory": m10,
    "createSuccess": MessageLookupByLibrary.simpleMessage("创建成功"),
    "createdTime": MessageLookupByLibrary.simpleMessage("创建时间"),
    "currentDownloadingFiles": m11,
    "currentIsLatestVersion": MessageLookupByLibrary.simpleMessage("已经是最新版本"),
    "currentlyDownloading": MessageLookupByLibrary.simpleMessage("正在下载"),
    "dataDirectory": MessageLookupByLibrary.simpleMessage("data 文件夹路径"),
    "databaseNotSavedIssue": MessageLookupByLibrary.simpleMessage("数据库未保存问题"),
    "databaseNotSavedIssueDesc": MessageLookupByLibrary.simpleMessage(
      "如不手动关闭OpenList，则数据库可能不会被保存到对应的db文件中，如遇到此问题，请手动关闭以解决此问题。（开关位于主程序菜单OpenList界面，以及通知栏的通知上）",
    ),
    "defaultSite": MessageLookupByLibrary.simpleMessage("默认站点"),
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "deleteFailed": MessageLookupByLibrary.simpleMessage("删除失败"),
    "deleteFile": MessageLookupByLibrary.simpleMessage("删除文件"),
    "deleteFileFailedLog": m12,
    "deleteItemConfirm": m13,
    "deleteItemsConfirm": m14,
    "deleteRecord": MessageLookupByLibrary.simpleMessage("删除记录"),
    "deleteSiteConfirm": m15,
    "deleteStorage": MessageLookupByLibrary.simpleMessage("删除存储"),
    "deleteStorageConfirm": m16,
    "deleteSuccess": MessageLookupByLibrary.simpleMessage("删除成功"),
    "description": MessageLookupByLibrary.simpleMessage("说明："),
    "deselectAll": MessageLookupByLibrary.simpleMessage("取消全选"),
    "desktopShortcut": MessageLookupByLibrary.simpleMessage("桌面快捷方式"),
    "directDownload": MessageLookupByLibrary.simpleMessage("直接下载"),
    "directDownloadApk": MessageLookupByLibrary.simpleMessage("直接下载APK"),
    "directDownloadMethod": MessageLookupByLibrary.simpleMessage("直接下载"),
    "directDownloadMethodDesc": MessageLookupByLibrary.simpleMessage(
      "使用应用内下载器",
    ),
    "doneTasks": MessageLookupByLibrary.simpleMessage("已完成"),
    "download": MessageLookupByLibrary.simpleMessage("下载"),
    "downloadApk": MessageLookupByLibrary.simpleMessage("下载APK"),
    "downloadCancelled": m17,
    "downloadCancelledStatus": MessageLookupByLibrary.simpleMessage("下载已取消"),
    "downloadCancelledText": MessageLookupByLibrary.simpleMessage("下载已取消"),
    "downloadComplete": m18,
    "downloadCompleteChannel": MessageLookupByLibrary.simpleMessage("下载完成"),
    "downloadCompleteChannelDesc": MessageLookupByLibrary.simpleMessage(
      "文件下载完成通知",
    ),
    "downloadCompleteFile": m19,
    "downloadCompleteNotificationTitle": m20,
    "downloadCompleteTitle": MessageLookupByLibrary.simpleMessage("下载完成"),
    "downloadDirectory": MessageLookupByLibrary.simpleMessage("下载目录"),
    "downloadDirectoryCleared": MessageLookupByLibrary.simpleMessage("已清理下载目录"),
    "downloadDirectoryOpened": MessageLookupByLibrary.simpleMessage("已打开下载目录"),
    "downloadDirectoryPathUnknown": MessageLookupByLibrary.simpleMessage(
      "下载目录路径未知",
    ),
    "downloadFailed": MessageLookupByLibrary.simpleMessage("下载失败"),
    "downloadFailedFile": m21,
    "downloadFailedWithError": m22,
    "downloadFunctionTest": MessageLookupByLibrary.simpleMessage("下载功能测试"),
    "downloadInstructions": MessageLookupByLibrary.simpleMessage(
      "• 文件将下载到系统下载目录\\n• 下载过程会显示进度通知\\n• 下载完成后可以选择打开文件\\n• 如果文件名重复会自动添加序号\\n• 请通过底部导航栏的\\\"下载管理\\\"查看下载文件",
    ),
    "downloadManager": MessageLookupByLibrary.simpleMessage("下载管理"),
    "downloadManagerWithCount": m23,
    "downloadProgress": m24,
    "downloadProgressChannel": MessageLookupByLibrary.simpleMessage("下载进度"),
    "downloadProgressDesc": MessageLookupByLibrary.simpleMessage("显示文件下载进度"),
    "downloadRecordsCleared": MessageLookupByLibrary.simpleMessage("已清空下载记录"),
    "downloadStarted": MessageLookupByLibrary.simpleMessage("已开始下载"),
    "downloadThisFile": MessageLookupByLibrary.simpleMessage("下载此文件吗？"),
    "downloadToOpen": MessageLookupByLibrary.simpleMessage("下载后用其他应用打开"),
    "downloading": MessageLookupByLibrary.simpleMessage("下载中"),
    "downloadingFileProgress": m25,
    "downloadingImage": MessageLookupByLibrary.simpleMessage("正在下载图片..."),
    "driver": MessageLookupByLibrary.simpleMessage("驱动"),
    "driverSpecific": MessageLookupByLibrary.simpleMessage("驱动专属配置"),
    "edit": MessageLookupByLibrary.simpleMessage("编辑"),
    "editOpenListConfig": MessageLookupByLibrary.simpleMessage(
      "修改OpenList配置文件",
    ),
    "editSite": MessageLookupByLibrary.simpleMessage("编辑站点"),
    "editStorage": MessageLookupByLibrary.simpleMessage("编辑存储"),
    "embeddedSite": MessageLookupByLibrary.simpleMessage("内嵌站点"),
    "embeddedSiteDesc": MessageLookupByLibrary.simpleMessage(
      "App 内置的 OpenList 服务器",
    ),
    "embeddedUserManaged": MessageLookupByLibrary.simpleMessage(
      "由应用自动管理（内置账号免密登录）",
    ),
    "emptyFolder": MessageLookupByLibrary.simpleMessage("此文件夹为空"),
    "emptyList": MessageLookupByLibrary.simpleMessage("暂无内容"),
    "enableWebBrowser": MessageLookupByLibrary.simpleMessage("启用内置网页浏览器"),
    "enableWebBrowserDesc": MessageLookupByLibrary.simpleMessage(
      "允许网页页面运行内置浏览器",
    ),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enterOtp": MessageLookupByLibrary.simpleMessage("请输入两步验证码"),
    "failed": MessageLookupByLibrary.simpleMessage("失败"),
    "fileDeleted": MessageLookupByLibrary.simpleMessage("文件已删除"),
    "fileDeletedLog": m26,
    "fileDetails": MessageLookupByLibrary.simpleMessage("文件详情"),
    "fileDownloadFailed": m27,
    "fileInfo": MessageLookupByLibrary.simpleMessage("文件信息"),
    "fileLocation": MessageLookupByLibrary.simpleMessage("文件位置"),
    "fileLocationTip": MessageLookupByLibrary.simpleMessage(
      "您可以使用文件管理器找到此文件，或者尝试安装相应的应用来打开它。",
    ),
    "fileManagerOpened": MessageLookupByLibrary.simpleMessage("已打开文件管理器"),
    "fileName": MessageLookupByLibrary.simpleMessage("文件名"),
    "fileNotFound": MessageLookupByLibrary.simpleMessage("文件不存在或已被删除"),
    "fileNotFoundWillCreateOnSave": MessageLookupByLibrary.simpleMessage(
      "文件不存在,保存时将创建",
    ),
    "filePath": MessageLookupByLibrary.simpleMessage("路径"),
    "filePermissionDenied": MessageLookupByLibrary.simpleMessage(
      "文件权限被拒绝,请检查应用权限",
    ),
    "fileSavedTo": MessageLookupByLibrary.simpleMessage("文件已保存到:"),
    "fileSize": m28,
    "fileTime": m29,
    "filesTab": MessageLookupByLibrary.simpleMessage("文件"),
    "findApkInDownloadFolder": MessageLookupByLibrary.simpleMessage(
      "请在下载目录找到APK文件进行安装",
    ),
    "folderName": MessageLookupByLibrary.simpleMessage("文件夹名称"),
    "folderPassword": MessageLookupByLibrary.simpleMessage("文件夹密码"),
    "followSystem": MessageLookupByLibrary.simpleMessage("跟随系统"),
    "general": MessageLookupByLibrary.simpleMessage("通用"),
    "generalSettings": MessageLookupByLibrary.simpleMessage("常规设置"),
    "getDownloadDirectoryFailed": m30,
    "getDownloadFileListFailed": m31,
    "getDownloadPathFailed": MessageLookupByLibrary.simpleMessage("获取失败"),
    "goTo": MessageLookupByLibrary.simpleMessage("前往"),
    "goToSettings": MessageLookupByLibrary.simpleMessage("去设置"),
    "grantManagerStoragePermission": MessageLookupByLibrary.simpleMessage(
      "申请【所有文件访问权限】",
    ),
    "grantNotificationPermission": MessageLookupByLibrary.simpleMessage(
      "申请【通知权限】",
    ),
    "grantNotificationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "用于前台服务保活",
    ),
    "grantStoragePermission": MessageLookupByLibrary.simpleMessage(
      "申请【读写外置存储权限】",
    ),
    "grantStoragePermissionDesc": MessageLookupByLibrary.simpleMessage(
      "挂载本地存储时必须授予，否则无权限读写文件",
    ),
    "imageDownloadSuccess": MessageLookupByLibrary.simpleMessage("图片下载成功"),
    "importConfig": MessageLookupByLibrary.simpleMessage("导入配置"),
    "importSuccess": MessageLookupByLibrary.simpleMessage("配置已导入"),
    "importantSettings": MessageLookupByLibrary.simpleMessage("重要"),
    "inProgress": MessageLookupByLibrary.simpleMessage("进行中"),
    "initServerHint": MessageLookupByLibrary.simpleMessage("请设置管理员账号完成初始化"),
    "initSiteTitle": MessageLookupByLibrary.simpleMessage("站点标题"),
    "initialize": MessageLookupByLibrary.simpleMessage("初始化"),
    "initializingNotificationManager": MessageLookupByLibrary.simpleMessage(
      "初始化通知管理器",
    ),
    "installNow": MessageLookupByLibrary.simpleMessage("立即安装"),
    "invalidJsonFormat": m32,
    "itemsCount": m33,
    "jsonExport": MessageLookupByLibrary.simpleMessage("JSON 导出"),
    "jsonImport": MessageLookupByLibrary.simpleMessage("JSON 导入"),
    "jsonImportHint": MessageLookupByLibrary.simpleMessage("粘贴存储配置 JSON"),
    "jsonInvalid": MessageLookupByLibrary.simpleMessage("JSON 解析失败或不是有效的存储配置"),
    "jumpToOtherApp": MessageLookupByLibrary.simpleMessage("跳转到其他APP ？"),
    "language": MessageLookupByLibrary.simpleMessage("语言"),
    "languageSettings": MessageLookupByLibrary.simpleMessage("语言设置"),
    "languageSettingsDesc": MessageLookupByLibrary.simpleMessage("选择应用显示语言"),
    "laterInstall": MessageLookupByLibrary.simpleMessage("稍后安装"),
    "loadDownloadFilesFailed": MessageLookupByLibrary.simpleMessage("加载下载文件失败"),
    "loadFailed": m34,
    "loading": MessageLookupByLibrary.simpleMessage("加载中..."),
    "lockScreen": MessageLookupByLibrary.simpleMessage("锁定"),
    "login": MessageLookupByLibrary.simpleMessage("登录"),
    "loginFailed": m35,
    "manage": MessageLookupByLibrary.simpleMessage("管理"),
    "modifiedTime": MessageLookupByLibrary.simpleMessage("修改时间"),
    "modifyAdminPassword": MessageLookupByLibrary.simpleMessage("修改Admin密码"),
    "moreOptions": MessageLookupByLibrary.simpleMessage("更多选项"),
    "mountPath": MessageLookupByLibrary.simpleMessage("挂载路径"),
    "mountPathInvalid": MessageLookupByLibrary.simpleMessage("挂载路径必须以 / 开头"),
    "mountStorage": MessageLookupByLibrary.simpleMessage("挂载存储"),
    "mountSuccess": MessageLookupByLibrary.simpleMessage("挂载成功"),
    "move": MessageLookupByLibrary.simpleMessage("移动"),
    "moveSuccess": MessageLookupByLibrary.simpleMessage("移动成功"),
    "moveTo": MessageLookupByLibrary.simpleMessage("移动到"),
    "multipleFilesCompleted": m36,
    "needInstallPermission": MessageLookupByLibrary.simpleMessage("需要安装权限"),
    "needInstallPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "为了安装 APK 文件，需要授予安装权限。请在设置中手动开启。",
    ),
    "needInstallPermissionToInstallApk": MessageLookupByLibrary.simpleMessage(
      "需要安装权限才能安装 APK 文件",
    ),
    "newFolder": MessageLookupByLibrary.simpleMessage("新建文件夹"),
    "newVersionFound": MessageLookupByLibrary.simpleMessage("发现新版本"),
    "noActiveDownloads": MessageLookupByLibrary.simpleMessage("暂无进行中的下载"),
    "noAppToOpenFile": MessageLookupByLibrary.simpleMessage("没有找到可以打开此文件的应用"),
    "noBackupFound": MessageLookupByLibrary.simpleMessage("未找到备份文件"),
    "noCompletedDownloads": MessageLookupByLibrary.simpleMessage("暂无已完成的下载"),
    "noMoreData": MessageLookupByLibrary.simpleMessage("没有更多了"),
    "noPermissionToInstallApk": MessageLookupByLibrary.simpleMessage(
      "没有权限安装 APK 文件，请在设置中开启安装权限",
    ),
    "noPermissionToInstallApkFile": MessageLookupByLibrary.simpleMessage(
      "没有权限安装 APK 文件，请在设置中开启安装权限",
    ),
    "noPermissionToOpenFile": MessageLookupByLibrary.simpleMessage("没有权限打开此文件"),
    "notificationClicked": m37,
    "notificationManagerInitFailed": m38,
    "notificationManagerInitialized": MessageLookupByLibrary.simpleMessage(
      "通知管理器初始化成功",
    ),
    "ok": MessageLookupByLibrary.simpleMessage("确定"),
    "open": MessageLookupByLibrary.simpleMessage("打开"),
    "openDirectory": MessageLookupByLibrary.simpleMessage("打开目录"),
    "openDownloadDirectoryFailed": m39,
    "openDownloadManager": MessageLookupByLibrary.simpleMessage("打开下载管理"),
    "openDownloadTestPage": MessageLookupByLibrary.simpleMessage(
      "是否要打开下载测试页面？",
    ),
    "openFile": MessageLookupByLibrary.simpleMessage("打开文件"),
    "openFileException": m40,
    "openFileFailed": m41,
    "openFileManager": MessageLookupByLibrary.simpleMessage("打开文件管理器"),
    "openFileManagerFailed": m42,
    "openFileResult": m43,
    "openListDownloadDirectory": m44,
    "openSourceLicenses": MessageLookupByLibrary.simpleMessage("开源许可证"),
    "openWebAdmin": MessageLookupByLibrary.simpleMessage("打开网页管理后台"),
    "openWebAdminDesc": MessageLookupByLibrary.simpleMessage("使用系统默认浏览器打开当前站点"),
    "openlist": MessageLookupByLibrary.simpleMessage("OpenList"),
    "openlistMobile": MessageLookupByLibrary.simpleMessage("OpenList Mobile"),
    "operationFailed": m45,
    "operationSuccess": MessageLookupByLibrary.simpleMessage("操作成功"),
    "otpCodeHint": MessageLookupByLibrary.simpleMessage("6位动态验证码"),
    "otpRequired": MessageLookupByLibrary.simpleMessage("需要两步验证码"),
    "parseFilenameFailed": m46,
    "pending": MessageLookupByLibrary.simpleMessage("等待中"),
    "playbackError": m47,
    "playerSpeed": MessageLookupByLibrary.simpleMessage("倍速"),
    "preparingDownload": MessageLookupByLibrary.simpleMessage("准备下载..."),
    "preparingDownloadStatus": MessageLookupByLibrary.simpleMessage("准备下载..."),
    "preview": MessageLookupByLibrary.simpleMessage("预览"),
    "protectedFolder": MessageLookupByLibrary.simpleMessage("此文件夹需要密码"),
    "qrExport": MessageLookupByLibrary.simpleMessage("导出配置二维码"),
    "qrExportHint": MessageLookupByLibrary.simpleMessage("在其他设备上扫描此二维码即可导入配置"),
    "qrImport": MessageLookupByLibrary.simpleMessage("扫码导入配置"),
    "qrInvalid": MessageLookupByLibrary.simpleMessage("二维码内容不是有效的存储配置"),
    "qrScanHint": MessageLookupByLibrary.simpleMessage("对准二维码即可自动识别"),
    "qrScanTitle": MessageLookupByLibrary.simpleMessage("扫描二维码"),
    "refresh": MessageLookupByLibrary.simpleMessage("刷新"),
    "releasePage": MessageLookupByLibrary.simpleMessage("发布页面"),
    "remark": MessageLookupByLibrary.simpleMessage("备注"),
    "rename": MessageLookupByLibrary.simpleMessage("重命名"),
    "renamePrompt": m48,
    "renameSuccess": MessageLookupByLibrary.simpleMessage("重命名成功"),
    "resetEmbeddedPwd": MessageLookupByLibrary.simpleMessage("重置内嵌管理员密码"),
    "resetEmbeddedPwdDesc": MessageLookupByLibrary.simpleMessage(
      "忘记密码时可重置后重新登录",
    ),
    "resetPwdDone": MessageLookupByLibrary.simpleMessage("密码已重置，请用新密码重新登录"),
    "restartingService": MessageLookupByLibrary.simpleMessage(
      "正在重启OpenList服务...",
    ),
    "restoreBackup": MessageLookupByLibrary.simpleMessage("恢复备份"),
    "restoreBackupFailed": m49,
    "retry": MessageLookupByLibrary.simpleMessage("重试"),
    "rootDir": MessageLookupByLibrary.simpleMessage("根目录"),
    "rootFolderPath": MessageLookupByLibrary.simpleMessage("根目录路径"),
    "running": MessageLookupByLibrary.simpleMessage("运行中"),
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveAndRestart": MessageLookupByLibrary.simpleMessage("保存并重启"),
    "saveFailed": m50,
    "saveOnly": MessageLookupByLibrary.simpleMessage("仅保存"),
    "saveSuccess": MessageLookupByLibrary.simpleMessage("保存成功"),
    "saved": MessageLookupByLibrary.simpleMessage("已保存"),
    "search": MessageLookupByLibrary.simpleMessage("搜索"),
    "searchDriver": MessageLookupByLibrary.simpleMessage("搜索驱动"),
    "searchKeywordsHint": MessageLookupByLibrary.simpleMessage("输入关键词搜索"),
    "searchNotEnabled": MessageLookupByLibrary.simpleMessage(
      "服务器未启用搜索索引，请在管理后台开启",
    ),
    "searchResultCount": m51,
    "searching": MessageLookupByLibrary.simpleMessage("搜索中..."),
    "selectAll": MessageLookupByLibrary.simpleMessage("全选"),
    "selectAppToOpen": MessageLookupByLibrary.simpleMessage("选择应用打开"),
    "selectDownloadMethod": MessageLookupByLibrary.simpleMessage("选择下载方式"),
    "selectedCount": m52,
    "serverNotInitialized": MessageLookupByLibrary.simpleMessage("服务器尚未初始化"),
    "serviceRestartFailed": MessageLookupByLibrary.simpleMessage(
      "服务重启失败,请手动重启",
    ),
    "serviceRestartOnlyAndroid": MessageLookupByLibrary.simpleMessage(
      "服务重启仅支持Android系统",
    ),
    "serviceRestartSuccess": MessageLookupByLibrary.simpleMessage("服务重启成功"),
    "sessionExpired": MessageLookupByLibrary.simpleMessage("登录已过期，正在重新登录..."),
    "setAdminPassword": MessageLookupByLibrary.simpleMessage("设置Admin密码"),
    "setAsDefault": MessageLookupByLibrary.simpleMessage("设为默认"),
    "setDefaultDirectory": MessageLookupByLibrary.simpleMessage("是否设为初始目录？"),
    "settings": MessageLookupByLibrary.simpleMessage("设置"),
    "shareFeatureNotImplemented": MessageLookupByLibrary.simpleMessage(
      "分享功能待实现",
    ),
    "shareFile": MessageLookupByLibrary.simpleMessage("分享文件"),
    "shareLink": MessageLookupByLibrary.simpleMessage("分享链接"),
    "shareLinkDesc": MessageLookupByLibrary.simpleMessage("分享下载链接"),
    "showDownloadCompleteNotificationFailed": m53,
    "showDownloadProgressNotificationFailed": m54,
    "showHiddenFiles": MessageLookupByLibrary.simpleMessage("显示隐藏文件"),
    "showInFileManager": MessageLookupByLibrary.simpleMessage("在文件管理器中显示"),
    "showSingleFileCompleteNotificationFailed": m55,
    "silentJumpApp": MessageLookupByLibrary.simpleMessage("静默跳转APP"),
    "silentJumpAppDesc": MessageLookupByLibrary.simpleMessage("跳转APP时，不弹出提示框"),
    "simplifiedChinese": MessageLookupByLibrary.simpleMessage("简体中文"),
    "siteManage": MessageLookupByLibrary.simpleMessage("站点管理"),
    "siteName": MessageLookupByLibrary.simpleMessage("站点名称"),
    "siteOtpCode": MessageLookupByLibrary.simpleMessage("两步验证码（可选）"),
    "sitePassword": MessageLookupByLibrary.simpleMessage("密码"),
    "siteUrlHint": MessageLookupByLibrary.simpleMessage(
      "例如 http://192.168.1.10:5244",
    ),
    "siteUsername": MessageLookupByLibrary.simpleMessage("用户名"),
    "size": MessageLookupByLibrary.simpleMessage("大小"),
    "sort": MessageLookupByLibrary.simpleMessage("排序"),
    "sortByName": MessageLookupByLibrary.simpleMessage("按文件名"),
    "sortByTime": MessageLookupByLibrary.simpleMessage("按时间"),
    "sortByType": MessageLookupByLibrary.simpleMessage("按类型"),
    "startDownload": m56,
    "startDownloadFile": m57,
    "startTime": MessageLookupByLibrary.simpleMessage("开始时间"),
    "startWebBrowser": MessageLookupByLibrary.simpleMessage("启动网页浏览器"),
    "stopWebBrowser": MessageLookupByLibrary.simpleMessage("停止"),
    "stopped": MessageLookupByLibrary.simpleMessage("已停止"),
    "storageEmpty": MessageLookupByLibrary.simpleMessage("还没有挂载任何存储"),
    "storageManage": MessageLookupByLibrary.simpleMessage("存储管理"),
    "storageManageDesc": MessageLookupByLibrary.simpleMessage(
      "挂载、导入、编辑、启停服务器存储",
    ),
    "targetFolder": MessageLookupByLibrary.simpleMessage("目标文件夹"),
    "taskEmpty": MessageLookupByLibrary.simpleMessage("暂无任务"),
    "taskManage": MessageLookupByLibrary.simpleMessage("服务器任务"),
    "taskManageDesc": MessageLookupByLibrary.simpleMessage(
      "离线下载 / 上传 / 复制 / 移动 / 解压任务管理",
    ),
    "testConnection": MessageLookupByLibrary.simpleMessage("测试连接"),
    "testDirectDownloadFunction": MessageLookupByLibrary.simpleMessage(
      "测试直接下载功能",
    ),
    "testDownloadJsonFile": MessageLookupByLibrary.simpleMessage("测试下载JSON文件"),
    "testDownloadLargeFile": MessageLookupByLibrary.simpleMessage(
      "测试下载大文件(1MB)",
    ),
    "testDownloadPngImage": MessageLookupByLibrary.simpleMessage("测试下载PNG图片"),
    "testing": MessageLookupByLibrary.simpleMessage("正在测试连接..."),
    "textTooLarge": MessageLookupByLibrary.simpleMessage("文件过大，无法预览（超过 1MB）"),
    "troubleshooting": MessageLookupByLibrary.simpleMessage("疑难解答"),
    "troubleshootingDesc": MessageLookupByLibrary.simpleMessage("常见问题与解决方案"),
    "tryToOpenFile": m58,
    "uiSettings": MessageLookupByLibrary.simpleMessage("界面"),
    "undoneTasks": MessageLookupByLibrary.simpleMessage("进行中"),
    "unknownDuration": MessageLookupByLibrary.simpleMessage("未知时长"),
    "unlockScreen": MessageLookupByLibrary.simpleMessage("解锁屏幕"),
    "upload": MessageLookupByLibrary.simpleMessage("上传"),
    "uploadFailed": m59,
    "uploadFile": MessageLookupByLibrary.simpleMessage("上传文件"),
    "uploadSuccess": MessageLookupByLibrary.simpleMessage("上传成功"),
    "uploading": MessageLookupByLibrary.simpleMessage("正在上传..."),
    "userCancelledDownload": MessageLookupByLibrary.simpleMessage("用户取消下载"),
    "userCancelledDownloadError": MessageLookupByLibrary.simpleMessage(
      "用户取消下载",
    ),
    "view": MessageLookupByLibrary.simpleMessage("查看"),
    "viewDownloadDirectory": MessageLookupByLibrary.simpleMessage("查看下载目录"),
    "viewDownloadFiles": MessageLookupByLibrary.simpleMessage("查看下载文件"),
    "viewDownloads": MessageLookupByLibrary.simpleMessage("查看下载"),
    "viewLocation": MessageLookupByLibrary.simpleMessage("查看位置"),
    "viewThirdPartyLicenses": MessageLookupByLibrary.simpleMessage("查看第三方许可证"),
    "wakeLock": MessageLookupByLibrary.simpleMessage("唤醒锁"),
    "wakeLockDesc": MessageLookupByLibrary.simpleMessage(
      "开启防止锁屏后CPU休眠，保持进程在后台运行。（部分系统可能导致杀后台）",
    ),
    "webBrowserDownloadInProgress": MessageLookupByLibrary.simpleMessage(
      "下载进行中，无法停止浏览器",
    ),
    "webBrowserStatus": MessageLookupByLibrary.simpleMessage("内置网页浏览器"),
    "webBrowserStopped": MessageLookupByLibrary.simpleMessage("内置网页浏览器已停止"),
    "webPage": MessageLookupByLibrary.simpleMessage("网页"),
    "webTab": MessageLookupByLibrary.simpleMessage("网页"),
    "wrongPassword": MessageLookupByLibrary.simpleMessage("密码错误"),
  };
}
