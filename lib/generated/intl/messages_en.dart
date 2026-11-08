// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(count) => "${count} item(s)";

  static String m1(error) => "Failed to cancel all notifications: ${error}";

  static String m2(error) => "Failed to cancel download notification: ${error}";

  static String m3(error) => "Failed to check install permission: ${error}";

  static String m4(error) => "Failed to clear download directory: ${error}";

  static String m5(filename) =>
      "Are you sure you want to cancel downloading \"${filename}\"?";

  static String m6(filename) =>
      "Are you sure you want to delete file \"${filename}\"? This action cannot be undone.";

  static String m7(filename) =>
      "Are you sure you want to delete the download record of \"${filename}\"?";

  static String m8(error) => "Connection failed: ${error}";

  static String m9(error) => "Failed to create OpenList directory: ${error}";

  static String m10(path) => "Create OpenList download directory: ${path}";

  static String m11(count) => "Currently ${count} files are downloading";

  static String m12(error) => "Failed to delete file: ${error}";

  static String m13(name) => "Delete \"${name}\"?";

  static String m14(count) => "Delete ${count} selected item(s)?";

  static String m15(name) => "Delete site \"${name}\"?";

  static String m16(path) => "Delete storage ${path}?";

  static String m17(url) => "Download cancelled: ${url}";

  static String m18(filename) => "Download complete: ${filename}";

  static String m19(filename) => "Download complete: ${filename}";

  static String m20(filename) => "${filename} download completed";

  static String m21(filename) => "Download failed: ${filename}";

  static String m22(filename) => "Download failed: ${filename}";

  static String m23(count) => "Download (${count})";

  static String m24(progress) => "Download progress: ${progress}%";

  static String m25(current, total) => "Downloading file ${current}/${total}";

  static String m26(filename) => "File deleted: ${filename}";

  static String m27(index) => "File ${index} download failed";

  static String m28(size) => "Size: ${size}";

  static String m29(time) => "Time: ${time}";

  static String m30(error) => "Failed to get download directory: ${error}";

  static String m31(error) => "Failed to get download file list: ${error}";

  static String m32(error, line) =>
      "Invalid JSON format at line ${line}: ${error}";

  static String m33(count) => "${count} items";

  static String m34(error) => "Load failed: ${error}";

  static String m35(error) => "Sign in failed: ${error}";

  static String m36(count) =>
      "${count} files completed, click to jump to download manager";

  static String m37(payload) => "Notification clicked: ${payload}";

  static String m38(error) =>
      "Failed to initialize notification manager: ${error}";

  static String m39(error) => "Failed to open download directory: ${error}";

  static String m40(error) => "Open file exception: ${error}";

  static String m41(error) => "Failed to open file: ${error}";

  static String m42(error) => "Failed to open file manager: ${error}";

  static String m43(message, type) => "Open file result: ${type} - ${message}";

  static String m44(path) => "OpenList download directory: ${path}";

  static String m45(error) => "Operation failed: ${error}";

  static String m46(error) => "Failed to parse filename: ${error}";

  static String m47(error) => "Playback failed: ${error}";

  static String m48(name) => "Rename \"${name}\"";

  static String m49(error) => "Restore backup failed: ${error}";

  static String m50(error) => "Save failed: ${error}";

  static String m51(count) => "${count} result(s) found";

  static String m52(count) => "${count} selected";

  static String m53(error) =>
      "Failed to show download complete notification: ${error}";

  static String m54(error) =>
      "Failed to show download progress notification: ${error}";

  static String m55(error) =>
      "Failed to show single file complete notification: ${error}";

  static String m56(filename) => "Start download: ${filename}";

  static String m57(filename) => "Start download: ${filename}";

  static String m58(path) => "Trying to open file: ${path}";

  static String m59(error) => "Upload failed: ${error}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addSite": MessageLookupByLibrary.simpleMessage("Add site"),
    "additionJson": MessageLookupByLibrary.simpleMessage(
      "Driver config (JSON)",
    ),
    "additionJsonInvalid": MessageLookupByLibrary.simpleMessage(
      "Config JSON is invalid",
    ),
    "additionalItems": m0,
    "apkDownloadCompleteMessage": MessageLookupByLibrary.simpleMessage(
      "APK file download completed, do you want to install?",
    ),
    "appName": MessageLookupByLibrary.simpleMessage("OpenList"),
    "audioTrack": MessageLookupByLibrary.simpleMessage("Audio"),
    "autoCheckForUpdates": MessageLookupByLibrary.simpleMessage(
      "Auto check for updates",
    ),
    "autoCheckForUpdatesDesc": MessageLookupByLibrary.simpleMessage(
      "Check for updates when app starts",
    ),
    "autoStartIssue": MessageLookupByLibrary.simpleMessage(
      "Auto-Start Information",
    ),
    "autoStartIssueDesc": MessageLookupByLibrary.simpleMessage(
      "When enabling auto-start, it\'s recommended to disable battery optimization for the app. Currently, after enabling auto-start, the service will automatically start in the background after system reboot, but may not show a notification in the notification bar. Rest assured, the service is running normally. You can check the service status through the quick settings tile in the notification shade, or return to the main interface to check the service toggle to confirm if the service has started.",
    ),
    "autoStartWebPage": MessageLookupByLibrary.simpleMessage(
      "Set web page as startup page",
    ),
    "autoStartWebPageDesc": MessageLookupByLibrary.simpleMessage(
      "Default page when opening main interface",
    ),
    "backAgainToExit": MessageLookupByLibrary.simpleMessage(
      "Press back again to exit",
    ),
    "backupRestored": MessageLookupByLibrary.simpleMessage(
      "Backup restored successfully",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("Basic Info"),
    "batchCopy": MessageLookupByLibrary.simpleMessage("Copy"),
    "batchDelete": MessageLookupByLibrary.simpleMessage("Delete"),
    "batchDownload": MessageLookupByLibrary.simpleMessage("Download"),
    "batchDownloadComplete": MessageLookupByLibrary.simpleMessage(
      "Batch download complete",
    ),
    "batchMove": MessageLookupByLibrary.simpleMessage("Move"),
    "bootAutoStartService": MessageLookupByLibrary.simpleMessage(
      "Boot auto-start service",
    ),
    "bootAutoStartServiceDesc": MessageLookupByLibrary.simpleMessage(
      "Automatically start OpenList service after boot. (Please make sure to grant auto-start permission)",
    ),
    "browserDownload": MessageLookupByLibrary.simpleMessage("Browser Download"),
    "browserDownloadMethod": MessageLookupByLibrary.simpleMessage(
      "Browser Download",
    ),
    "browserDownloadMethodDesc": MessageLookupByLibrary.simpleMessage(
      "Use system browser",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelAllNotificationsFailed": m1,
    "cancelDownload": MessageLookupByLibrary.simpleMessage("Cancel Download"),
    "cancelDownloadNotificationFailed": m2,
    "cancelled": MessageLookupByLibrary.simpleMessage("Cancelled"),
    "cannotGetBaseDownloadDirectory": MessageLookupByLibrary.simpleMessage(
      "Cannot get base download directory",
    ),
    "cannotGetDownloadDirectory": MessageLookupByLibrary.simpleMessage(
      "Cannot get download directory",
    ),
    "cannotGetDownloadDirectoryError": MessageLookupByLibrary.simpleMessage(
      "Cannot get download directory",
    ),
    "cannotInstallApkFile": MessageLookupByLibrary.simpleMessage(
      "Cannot install APK file, you may need to enable \"Install unknown apps\" in settings",
    ),
    "cannotInstallApkNeedPermission": MessageLookupByLibrary.simpleMessage(
      "Cannot install APK file, you may need to enable \"Install unknown apps\" in settings",
    ),
    "cannotPreview": MessageLookupByLibrary.simpleMessage(
      "Preview is not supported for this file type",
    ),
    "checkDownloadManagerForFiles": MessageLookupByLibrary.simpleMessage(
      "Please check download manager via bottom navigation bar to view download files",
    ),
    "checkForUpdates": MessageLookupByLibrary.simpleMessage(
      "Check for updates",
    ),
    "checkImageInDownloadFolder": MessageLookupByLibrary.simpleMessage(
      "Please check image in download folder",
    ),
    "checkInstallPermissionFailed": m3,
    "clear": MessageLookupByLibrary.simpleMessage("Clear"),
    "clearAll": MessageLookupByLibrary.simpleMessage("Clear All"),
    "clearDownloadDirectoryFailed": m4,
    "clearFailed": MessageLookupByLibrary.simpleMessage("Clear failed"),
    "clearRecords": MessageLookupByLibrary.simpleMessage("Clear Records"),
    "clearSucceeded": MessageLookupByLibrary.simpleMessage("Clear finished"),
    "cleared": MessageLookupByLibrary.simpleMessage(
      "Download directory cleared",
    ),
    "clickToJumpToDownloadManager": MessageLookupByLibrary.simpleMessage(
      "Click to jump to download manager",
    ),
    "close": MessageLookupByLibrary.simpleMessage("Close"),
    "completed": MessageLookupByLibrary.simpleMessage("Completed"),
    "completedTime": MessageLookupByLibrary.simpleMessage("Completed time"),
    "configSavedRestartRequired": MessageLookupByLibrary.simpleMessage(
      "Config saved. Please restart OpenList service to take effect.",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("OK"),
    "confirmCancelDownload": m5,
    "confirmClear": MessageLookupByLibrary.simpleMessage("Confirm Clear"),
    "confirmClearAllFiles": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to clear all download files? This action cannot be undone.",
    ),
    "confirmDelete": MessageLookupByLibrary.simpleMessage("Confirm Delete"),
    "confirmDeleteFile": m6,
    "confirmDeleteRecord": m7,
    "confirmDownload": MessageLookupByLibrary.simpleMessage("Confirm Download"),
    "confirmDownloadMessage": MessageLookupByLibrary.simpleMessage(
      "Do you want to download this file?",
    ),
    "confirmSaveConfigMessage": MessageLookupByLibrary.simpleMessage(
      "Modifying configuration may cause service unavailable. Are you sure to save?",
    ),
    "confirmSaveConfigTitle": MessageLookupByLibrary.simpleMessage(
      "Confirm Save",
    ),
    "connectionFailed": m8,
    "connectionOk": MessageLookupByLibrary.simpleMessage("Connection OK"),
    "continueDownload": MessageLookupByLibrary.simpleMessage(
      "Continue Download",
    ),
    "copiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "Copied to clipboard",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Copied successfully"),
    "copyTo": MessageLookupByLibrary.simpleMessage("Copy to"),
    "createOpenListDirectoryFailed": m9,
    "createOpenListDownloadDirectory": m10,
    "createSuccess": MessageLookupByLibrary.simpleMessage(
      "Created successfully",
    ),
    "createdTime": MessageLookupByLibrary.simpleMessage("Created"),
    "currentDownloadingFiles": m11,
    "currentIsLatestVersion": MessageLookupByLibrary.simpleMessage(
      "Current is latest version",
    ),
    "currentlyDownloading": MessageLookupByLibrary.simpleMessage("Downloading"),
    "dataDirectory": MessageLookupByLibrary.simpleMessage("data Directory"),
    "databaseNotSavedIssue": MessageLookupByLibrary.simpleMessage(
      "Database Not Saved Issue",
    ),
    "databaseNotSavedIssueDesc": MessageLookupByLibrary.simpleMessage(
      "If you don\'t manually close OpenList, the database may not be saved to the corresponding db file. If you encounter this issue, please manually close the app to resolve it. (The switch is located in the main program menu on the OpenList interface, as well as in the notification bar)",
    ),
    "defaultSite": MessageLookupByLibrary.simpleMessage("Default site"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteFailed": MessageLookupByLibrary.simpleMessage("Delete failed"),
    "deleteFile": MessageLookupByLibrary.simpleMessage("Delete file"),
    "deleteFileFailedLog": m12,
    "deleteItemConfirm": m13,
    "deleteItemsConfirm": m14,
    "deleteRecord": MessageLookupByLibrary.simpleMessage("Delete record"),
    "deleteSiteConfirm": m15,
    "deleteStorage": MessageLookupByLibrary.simpleMessage("Delete storage"),
    "deleteStorageConfirm": m16,
    "deleteSuccess": MessageLookupByLibrary.simpleMessage(
      "Deleted successfully",
    ),
    "description": MessageLookupByLibrary.simpleMessage("Description:"),
    "desktopShortcut": MessageLookupByLibrary.simpleMessage("Desktop shortcut"),
    "directDownload": MessageLookupByLibrary.simpleMessage("Direct Download"),
    "directDownloadApk": MessageLookupByLibrary.simpleMessage(
      "Direct Download APK",
    ),
    "directDownloadMethod": MessageLookupByLibrary.simpleMessage(
      "Direct Download",
    ),
    "directDownloadMethodDesc": MessageLookupByLibrary.simpleMessage(
      "Use in-app downloader",
    ),
    "doneTasks": MessageLookupByLibrary.simpleMessage("Finished"),
    "download": MessageLookupByLibrary.simpleMessage("download"),
    "downloadApk": MessageLookupByLibrary.simpleMessage("Download APK"),
    "downloadCancelled": m17,
    "downloadCancelledStatus": MessageLookupByLibrary.simpleMessage(
      "Download cancelled",
    ),
    "downloadCancelledText": MessageLookupByLibrary.simpleMessage(
      "Download cancelled",
    ),
    "downloadComplete": m18,
    "downloadCompleteChannel": MessageLookupByLibrary.simpleMessage(
      "Download Complete",
    ),
    "downloadCompleteChannelDesc": MessageLookupByLibrary.simpleMessage(
      "File download complete notification",
    ),
    "downloadCompleteFile": m19,
    "downloadCompleteNotificationTitle": m20,
    "downloadCompleteTitle": MessageLookupByLibrary.simpleMessage(
      "Download Complete",
    ),
    "downloadDirectory": MessageLookupByLibrary.simpleMessage(
      "Download Directory",
    ),
    "downloadDirectoryCleared": MessageLookupByLibrary.simpleMessage(
      "Download directory cleared",
    ),
    "downloadDirectoryOpened": MessageLookupByLibrary.simpleMessage(
      "Download directory opened",
    ),
    "downloadDirectoryPathUnknown": MessageLookupByLibrary.simpleMessage(
      "Download directory path unknown",
    ),
    "downloadFailed": MessageLookupByLibrary.simpleMessage("Download failed"),
    "downloadFailedFile": m21,
    "downloadFailedWithError": m22,
    "downloadFunctionTest": MessageLookupByLibrary.simpleMessage(
      "Download Function Test",
    ),
    "downloadInstructions": MessageLookupByLibrary.simpleMessage(
      "• Files will be downloaded to system download directory\\n• Download progress will show notifications\\n• You can choose to open file after download completes\\n• If filename exists, a number will be added automatically\\n• Please check download manager via bottom navigation bar to view files",
    ),
    "downloadManager": MessageLookupByLibrary.simpleMessage("Download"),
    "downloadManagerWithCount": m23,
    "downloadProgress": m24,
    "downloadProgressChannel": MessageLookupByLibrary.simpleMessage(
      "Download Progress",
    ),
    "downloadProgressDesc": MessageLookupByLibrary.simpleMessage(
      "Show file download progress",
    ),
    "downloadRecordsCleared": MessageLookupByLibrary.simpleMessage(
      "Download records cleared",
    ),
    "downloadStarted": MessageLookupByLibrary.simpleMessage("Download started"),
    "downloadThisFile": MessageLookupByLibrary.simpleMessage(
      "Download this file？",
    ),
    "downloadToOpen": MessageLookupByLibrary.simpleMessage(
      "Download and open with another app",
    ),
    "downloading": MessageLookupByLibrary.simpleMessage("Downloading"),
    "downloadingFileProgress": m25,
    "downloadingImage": MessageLookupByLibrary.simpleMessage(
      "Downloading image...",
    ),
    "driver": MessageLookupByLibrary.simpleMessage("Driver"),
    "driverSpecific": MessageLookupByLibrary.simpleMessage(
      "Driver specific options",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editOpenListConfig": MessageLookupByLibrary.simpleMessage(
      "Edit OpenList Config",
    ),
    "editSite": MessageLookupByLibrary.simpleMessage("Edit site"),
    "editStorage": MessageLookupByLibrary.simpleMessage("Edit storage"),
    "embeddedSite": MessageLookupByLibrary.simpleMessage("Embedded site"),
    "embeddedSiteDesc": MessageLookupByLibrary.simpleMessage(
      "The OpenList server built into this app",
    ),
    "embeddedUserManaged": MessageLookupByLibrary.simpleMessage(
      "Managed automatically by the app (built-in account, password-free)",
    ),
    "emptyFolder": MessageLookupByLibrary.simpleMessage("This folder is empty"),
    "emptyList": MessageLookupByLibrary.simpleMessage("Nothing here"),
    "enableWebBrowser": MessageLookupByLibrary.simpleMessage(
      "Enable embedded web browser",
    ),
    "enableWebBrowserDesc": MessageLookupByLibrary.simpleMessage(
      "Allow the Web page to run the embedded browser",
    ),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enterOtp": MessageLookupByLibrary.simpleMessage("Enter the 2FA code"),
    "failed": MessageLookupByLibrary.simpleMessage("Failed"),
    "fileDeleted": MessageLookupByLibrary.simpleMessage("File deleted"),
    "fileDeletedLog": m26,
    "fileDetails": MessageLookupByLibrary.simpleMessage("File details"),
    "fileDownloadFailed": m27,
    "fileInfo": MessageLookupByLibrary.simpleMessage("File info"),
    "fileLocation": MessageLookupByLibrary.simpleMessage("File Location"),
    "fileLocationTip": MessageLookupByLibrary.simpleMessage(
      "You can use a file manager to find this file, or try installing the appropriate app to open it.",
    ),
    "fileManagerOpened": MessageLookupByLibrary.simpleMessage(
      "File manager opened",
    ),
    "fileName": MessageLookupByLibrary.simpleMessage("File name"),
    "fileNotFound": MessageLookupByLibrary.simpleMessage(
      "File not found or has been deleted",
    ),
    "fileNotFoundWillCreateOnSave": MessageLookupByLibrary.simpleMessage(
      "File not found. Will create on save.",
    ),
    "filePath": MessageLookupByLibrary.simpleMessage("Path"),
    "filePermissionDenied": MessageLookupByLibrary.simpleMessage(
      "File permission denied. Please check app permissions.",
    ),
    "fileSavedTo": MessageLookupByLibrary.simpleMessage("File saved to:"),
    "fileSize": m28,
    "fileTime": m29,
    "filesTab": MessageLookupByLibrary.simpleMessage("Files"),
    "findApkInDownloadFolder": MessageLookupByLibrary.simpleMessage(
      "Please find APK file in download folder to install",
    ),
    "folderName": MessageLookupByLibrary.simpleMessage("Folder name"),
    "folderPassword": MessageLookupByLibrary.simpleMessage("Folder password"),
    "followSystem": MessageLookupByLibrary.simpleMessage("Follow System"),
    "general": MessageLookupByLibrary.simpleMessage("General"),
    "generalSettings": MessageLookupByLibrary.simpleMessage("General"),
    "getDownloadDirectoryFailed": m30,
    "getDownloadFileListFailed": m31,
    "getDownloadPathFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to get",
    ),
    "goTo": MessageLookupByLibrary.simpleMessage("GO"),
    "goToSettings": MessageLookupByLibrary.simpleMessage("Go to Settings"),
    "grantManagerStoragePermission": MessageLookupByLibrary.simpleMessage(
      "Grant [Manage external storage] permission",
    ),
    "grantNotificationPermission": MessageLookupByLibrary.simpleMessage(
      "Grant [Notification] permission",
    ),
    "grantNotificationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Used for foreground service keep alive",
    ),
    "grantStoragePermission": MessageLookupByLibrary.simpleMessage(
      "Grant [external storage] permission",
    ),
    "grantStoragePermissionDesc": MessageLookupByLibrary.simpleMessage(
      "Mounting local storage is a must, otherwise no permission to read and write files",
    ),
    "imageDownloadSuccess": MessageLookupByLibrary.simpleMessage(
      "Image download success",
    ),
    "importConfig": MessageLookupByLibrary.simpleMessage("Import config"),
    "importSuccess": MessageLookupByLibrary.simpleMessage("Config imported"),
    "importantSettings": MessageLookupByLibrary.simpleMessage(
      "Important settings",
    ),
    "inProgress": MessageLookupByLibrary.simpleMessage("In Progress"),
    "initServerHint": MessageLookupByLibrary.simpleMessage(
      "Set up an admin account to finish initialization",
    ),
    "initSiteTitle": MessageLookupByLibrary.simpleMessage("Site title"),
    "initialize": MessageLookupByLibrary.simpleMessage("Initialize"),
    "initializingNotificationManager": MessageLookupByLibrary.simpleMessage(
      "Initializing notification manager",
    ),
    "installNow": MessageLookupByLibrary.simpleMessage("Install Now"),
    "invalidJsonFormat": m32,
    "itemsCount": m33,
    "jumpToOtherApp": MessageLookupByLibrary.simpleMessage(
      "Jump to other app？",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "languageSettings": MessageLookupByLibrary.simpleMessage(
      "Language Settings",
    ),
    "languageSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "Select app display language",
    ),
    "laterInstall": MessageLookupByLibrary.simpleMessage("Install Later"),
    "loadDownloadFilesFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to load download files",
    ),
    "loadFailed": m34,
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "lockScreen": MessageLookupByLibrary.simpleMessage("Lock"),
    "login": MessageLookupByLibrary.simpleMessage("Sign in"),
    "loginFailed": m35,
    "manage": MessageLookupByLibrary.simpleMessage("Manage"),
    "modifiedTime": MessageLookupByLibrary.simpleMessage("Modified time"),
    "modifyAdminPassword": MessageLookupByLibrary.simpleMessage(
      "Modify Admin Password",
    ),
    "moreOptions": MessageLookupByLibrary.simpleMessage("More options"),
    "mountPath": MessageLookupByLibrary.simpleMessage("Mount path"),
    "mountPathInvalid": MessageLookupByLibrary.simpleMessage(
      "Mount path must start with /",
    ),
    "mountStorage": MessageLookupByLibrary.simpleMessage("Mount storage"),
    "mountSuccess": MessageLookupByLibrary.simpleMessage("Storage mounted"),
    "move": MessageLookupByLibrary.simpleMessage("Move"),
    "moveSuccess": MessageLookupByLibrary.simpleMessage("Moved successfully"),
    "moveTo": MessageLookupByLibrary.simpleMessage("Move to"),
    "multipleFilesCompleted": m36,
    "needInstallPermission": MessageLookupByLibrary.simpleMessage(
      "Install Permission Required",
    ),
    "needInstallPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "To install APK files, install permission is required. Please enable it manually in settings.",
    ),
    "needInstallPermissionToInstallApk": MessageLookupByLibrary.simpleMessage(
      "Install permission is required to install APK files",
    ),
    "newFolder": MessageLookupByLibrary.simpleMessage("New folder"),
    "newVersionFound": MessageLookupByLibrary.simpleMessage(
      "New Version Found",
    ),
    "noActiveDownloads": MessageLookupByLibrary.simpleMessage(
      "No active downloads",
    ),
    "noAppToOpenFile": MessageLookupByLibrary.simpleMessage(
      "No app found to open this file",
    ),
    "noBackupFound": MessageLookupByLibrary.simpleMessage(
      "No backup file found",
    ),
    "noCompletedDownloads": MessageLookupByLibrary.simpleMessage(
      "No completed downloads",
    ),
    "noMoreData": MessageLookupByLibrary.simpleMessage("No more data"),
    "noPermissionToInstallApk": MessageLookupByLibrary.simpleMessage(
      "No permission to install APK file, please enable install permission in settings",
    ),
    "noPermissionToInstallApkFile": MessageLookupByLibrary.simpleMessage(
      "No permission to install APK file, please enable install permission in settings",
    ),
    "noPermissionToOpenFile": MessageLookupByLibrary.simpleMessage(
      "No permission to open this file",
    ),
    "notificationClicked": m37,
    "notificationManagerInitFailed": m38,
    "notificationManagerInitialized": MessageLookupByLibrary.simpleMessage(
      "Notification manager initialized successfully",
    ),
    "ok": MessageLookupByLibrary.simpleMessage("OK"),
    "open": MessageLookupByLibrary.simpleMessage("Open"),
    "openDirectory": MessageLookupByLibrary.simpleMessage("Open Directory"),
    "openDownloadDirectoryFailed": m39,
    "openDownloadManager": MessageLookupByLibrary.simpleMessage(
      "Open Download Manager",
    ),
    "openDownloadTestPage": MessageLookupByLibrary.simpleMessage(
      "Do you want to open download test page?",
    ),
    "openFile": MessageLookupByLibrary.simpleMessage("Open file"),
    "openFileException": m40,
    "openFileFailed": m41,
    "openFileManager": MessageLookupByLibrary.simpleMessage(
      "Open File Manager",
    ),
    "openFileManagerFailed": m42,
    "openFileResult": m43,
    "openListDownloadDirectory": m44,
    "openSourceLicenses": MessageLookupByLibrary.simpleMessage(
      "Open Source Licenses",
    ),
    "openWebAdmin": MessageLookupByLibrary.simpleMessage("Open web admin"),
    "openWebAdminDesc": MessageLookupByLibrary.simpleMessage(
      "Open current site in system default browser",
    ),
    "openlist": MessageLookupByLibrary.simpleMessage("OpenList"),
    "openlistMobile": MessageLookupByLibrary.simpleMessage("OpenList Mobile"),
    "operationFailed": m45,
    "operationSuccess": MessageLookupByLibrary.simpleMessage(
      "Operation succeeded",
    ),
    "otpCodeHint": MessageLookupByLibrary.simpleMessage("6-digit code"),
    "otpRequired": MessageLookupByLibrary.simpleMessage("2FA code required"),
    "parseFilenameFailed": m46,
    "pending": MessageLookupByLibrary.simpleMessage("Pending"),
    "playbackError": m47,
    "playerSpeed": MessageLookupByLibrary.simpleMessage("Speed"),
    "preparingDownload": MessageLookupByLibrary.simpleMessage(
      "Preparing download...",
    ),
    "preparingDownloadStatus": MessageLookupByLibrary.simpleMessage(
      "Preparing download...",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "protectedFolder": MessageLookupByLibrary.simpleMessage(
      "This folder is password protected",
    ),
    "qrExport": MessageLookupByLibrary.simpleMessage("Export as QR"),
    "qrExportHint": MessageLookupByLibrary.simpleMessage(
      "Scan this QR in another device to import the config",
    ),
    "qrImport": MessageLookupByLibrary.simpleMessage("Scan QR to import"),
    "qrInvalid": MessageLookupByLibrary.simpleMessage(
      "QR content is not a valid config",
    ),
    "qrScanHint": MessageLookupByLibrary.simpleMessage(
      "Point the camera at a QR code",
    ),
    "qrScanTitle": MessageLookupByLibrary.simpleMessage("Scan QR code"),
    "refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "releasePage": MessageLookupByLibrary.simpleMessage("Release Page"),
    "remark": MessageLookupByLibrary.simpleMessage("Remark"),
    "rename": MessageLookupByLibrary.simpleMessage("Rename"),
    "renamePrompt": m48,
    "renameSuccess": MessageLookupByLibrary.simpleMessage(
      "Renamed successfully",
    ),
    "resetEmbeddedPwd": MessageLookupByLibrary.simpleMessage(
      "Reset embedded admin password",
    ),
    "resetEmbeddedPwdDesc": MessageLookupByLibrary.simpleMessage(
      "Reset it if you forgot the password, then sign in again",
    ),
    "resetPwdDone": MessageLookupByLibrary.simpleMessage(
      "Password reset. Please sign in with the new password",
    ),
    "restartingService": MessageLookupByLibrary.simpleMessage(
      "Restarting OpenList service...",
    ),
    "restoreBackup": MessageLookupByLibrary.simpleMessage("Restore Backup"),
    "restoreBackupFailed": m49,
    "retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "rootDir": MessageLookupByLibrary.simpleMessage("Root"),
    "rootFolderPath": MessageLookupByLibrary.simpleMessage("Root folder path"),
    "running": MessageLookupByLibrary.simpleMessage("Running"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveAndRestart": MessageLookupByLibrary.simpleMessage("Save and Restart"),
    "saveFailed": m50,
    "saveOnly": MessageLookupByLibrary.simpleMessage("Save Only"),
    "saveSuccess": MessageLookupByLibrary.simpleMessage("Saved"),
    "saved": MessageLookupByLibrary.simpleMessage("Saved"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "searchDriver": MessageLookupByLibrary.simpleMessage("Search driver"),
    "searchKeywordsHint": MessageLookupByLibrary.simpleMessage(
      "Type keywords to search",
    ),
    "searchNotEnabled": MessageLookupByLibrary.simpleMessage(
      "Server search index is not enabled. Turn it on in the admin panel",
    ),
    "searchResultCount": m51,
    "searching": MessageLookupByLibrary.simpleMessage("Searching..."),
    "selectAll": MessageLookupByLibrary.simpleMessage("Select all"),
    "selectAppToOpen": MessageLookupByLibrary.simpleMessage(
      "Select app to open",
    ),
    "selectDownloadMethod": MessageLookupByLibrary.simpleMessage(
      "Select download method",
    ),
    "selectedCount": m52,
    "serverNotInitialized": MessageLookupByLibrary.simpleMessage(
      "Server is not initialized",
    ),
    "serviceRestartFailed": MessageLookupByLibrary.simpleMessage(
      "Failed to restart service. Please restart manually.",
    ),
    "serviceRestartOnlyAndroid": MessageLookupByLibrary.simpleMessage(
      "Service restart is only supported on Android",
    ),
    "serviceRestartSuccess": MessageLookupByLibrary.simpleMessage(
      "Service restarted successfully",
    ),
    "sessionExpired": MessageLookupByLibrary.simpleMessage(
      "Session expired, signing in again...",
    ),
    "setAdminPassword": MessageLookupByLibrary.simpleMessage(
      "Set Admin password",
    ),
    "setAsDefault": MessageLookupByLibrary.simpleMessage("Set as default"),
    "setDefaultDirectory": MessageLookupByLibrary.simpleMessage(
      "Set as default directory?",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "shareFeatureNotImplemented": MessageLookupByLibrary.simpleMessage(
      "Share feature not implemented yet",
    ),
    "shareFile": MessageLookupByLibrary.simpleMessage("Share file"),
    "shareLink": MessageLookupByLibrary.simpleMessage("Share Link"),
    "shareLinkDesc": MessageLookupByLibrary.simpleMessage(
      "Share download link",
    ),
    "showDownloadCompleteNotificationFailed": m53,
    "showDownloadProgressNotificationFailed": m54,
    "showHiddenFiles": MessageLookupByLibrary.simpleMessage(
      "Show hidden files",
    ),
    "showInFileManager": MessageLookupByLibrary.simpleMessage(
      "Show in file manager",
    ),
    "showSingleFileCompleteNotificationFailed": m55,
    "silentJumpApp": MessageLookupByLibrary.simpleMessage("Silent jump app"),
    "silentJumpAppDesc": MessageLookupByLibrary.simpleMessage(
      "Jump to other app without prompt",
    ),
    "simplifiedChinese": MessageLookupByLibrary.simpleMessage("简体中文"),
    "siteManage": MessageLookupByLibrary.simpleMessage("Site manager"),
    "siteName": MessageLookupByLibrary.simpleMessage("Site name"),
    "siteOtpCode": MessageLookupByLibrary.simpleMessage("2FA code (optional)"),
    "sitePassword": MessageLookupByLibrary.simpleMessage("Password"),
    "siteUrlHint": MessageLookupByLibrary.simpleMessage(
      "e.g. http://192.168.1.10:5244",
    ),
    "siteUsername": MessageLookupByLibrary.simpleMessage("Username"),
    "size": MessageLookupByLibrary.simpleMessage("Size"),
    "sort": MessageLookupByLibrary.simpleMessage("Sort"),
    "sortByName": MessageLookupByLibrary.simpleMessage("By name"),
    "sortByTime": MessageLookupByLibrary.simpleMessage("By time"),
    "sortByType": MessageLookupByLibrary.simpleMessage("By type"),
    "startDownload": m56,
    "startDownloadFile": m57,
    "startTime": MessageLookupByLibrary.simpleMessage("Start time"),
    "startWebBrowser": MessageLookupByLibrary.simpleMessage(
      "Start web browser",
    ),
    "stopWebBrowser": MessageLookupByLibrary.simpleMessage("Stop"),
    "stopped": MessageLookupByLibrary.simpleMessage("Stopped"),
    "storageEmpty": MessageLookupByLibrary.simpleMessage(
      "No storages mounted yet",
    ),
    "storageManage": MessageLookupByLibrary.simpleMessage("Storage management"),
    "storageManageDesc": MessageLookupByLibrary.simpleMessage(
      "Mount, import, edit, enable/disable server storages",
    ),
    "targetFolder": MessageLookupByLibrary.simpleMessage("Target folder"),
    "taskEmpty": MessageLookupByLibrary.simpleMessage("No tasks"),
    "taskManage": MessageLookupByLibrary.simpleMessage("Server tasks"),
    "taskManageDesc": MessageLookupByLibrary.simpleMessage(
      "Offline download / upload / copy / move / decompress tasks",
    ),
    "testConnection": MessageLookupByLibrary.simpleMessage("Test connection"),
    "testDirectDownloadFunction": MessageLookupByLibrary.simpleMessage(
      "Test direct download function",
    ),
    "testDownloadJsonFile": MessageLookupByLibrary.simpleMessage(
      "Test download JSON file",
    ),
    "testDownloadLargeFile": MessageLookupByLibrary.simpleMessage(
      "Test download large file (1MB)",
    ),
    "testDownloadPngImage": MessageLookupByLibrary.simpleMessage(
      "Test download PNG image",
    ),
    "testing": MessageLookupByLibrary.simpleMessage("Testing connection..."),
    "textTooLarge": MessageLookupByLibrary.simpleMessage(
      "File is too large to preview (> 1MB)",
    ),
    "troubleshooting": MessageLookupByLibrary.simpleMessage("Troubleshooting"),
    "troubleshootingDesc": MessageLookupByLibrary.simpleMessage(
      "Common issues and solutions",
    ),
    "tryToOpenFile": m58,
    "uiSettings": MessageLookupByLibrary.simpleMessage("UI"),
    "undoneTasks": MessageLookupByLibrary.simpleMessage("In progress"),
    "unknownDuration": MessageLookupByLibrary.simpleMessage("Unknown duration"),
    "unlockScreen": MessageLookupByLibrary.simpleMessage("Unlock screen"),
    "upload": MessageLookupByLibrary.simpleMessage("Upload"),
    "uploadFailed": m59,
    "uploadFile": MessageLookupByLibrary.simpleMessage("Upload files"),
    "uploadSuccess": MessageLookupByLibrary.simpleMessage("Upload succeeded"),
    "uploading": MessageLookupByLibrary.simpleMessage("Uploading..."),
    "userCancelledDownload": MessageLookupByLibrary.simpleMessage(
      "User cancelled download",
    ),
    "userCancelledDownloadError": MessageLookupByLibrary.simpleMessage(
      "User cancelled download",
    ),
    "view": MessageLookupByLibrary.simpleMessage("View"),
    "viewDownloadDirectory": MessageLookupByLibrary.simpleMessage(
      "View download directory",
    ),
    "viewDownloadFiles": MessageLookupByLibrary.simpleMessage(
      "View download files",
    ),
    "viewDownloads": MessageLookupByLibrary.simpleMessage("View Downloads"),
    "viewLocation": MessageLookupByLibrary.simpleMessage("View Location"),
    "viewThirdPartyLicenses": MessageLookupByLibrary.simpleMessage(
      "View third-party licenses",
    ),
    "wakeLock": MessageLookupByLibrary.simpleMessage("Wake lock"),
    "wakeLockDesc": MessageLookupByLibrary.simpleMessage(
      "Prevent CPU from sleeping when screen is off. (May cause app killed in background on some devices)",
    ),
    "webBrowserDownloadInProgress": MessageLookupByLibrary.simpleMessage(
      "The browser cannot stop while a download is in progress",
    ),
    "webBrowserStatus": MessageLookupByLibrary.simpleMessage(
      "Embedded web browser",
    ),
    "webBrowserStopped": MessageLookupByLibrary.simpleMessage(
      "The embedded web browser is stopped",
    ),
    "webPage": MessageLookupByLibrary.simpleMessage("Web Page"),
    "wrongPassword": MessageLookupByLibrary.simpleMessage("Wrong password"),
  };
}
