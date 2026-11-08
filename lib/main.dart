import 'package:android_intent_plus/android_intent.dart';
import 'package:openlist_mobile/generated/l10n.dart';
import 'package:openlist_mobile/pages/files/files_controller.dart';
import 'package:openlist_mobile/pages/files/files_page.dart';
import 'package:openlist_mobile/pages/openlist/openlist.dart';
import 'package:openlist_mobile/pages/app_update_dialog.dart';
import 'package:openlist_mobile/pages/settings/settings.dart';
import 'package:openlist_mobile/pages/download_manager_page.dart';
import 'package:openlist_mobile/services/auth_service.dart';
import 'package:openlist_mobile/services/site_manager.dart';
import 'package:openlist_mobile/utils/download_manager.dart';
import 'package:openlist_mobile/utils/notification_manager.dart';
import 'package:openlist_mobile/utils/service_manager.dart';
import 'package:openlist_mobile/utils/language_controller.dart';
import 'package:openlist_mobile/utils/web_browser_manager.dart';
import 'package:fade_indexed_stack/fade_indexed_stack.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'contant/native_bridge.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // mdk 内核替换官方 video_player 后端（全格式硬解）
  fvp.registerWith();

  // Native file client services
  Get.put(AuthService());
  final siteManager = Get.put(SiteManager());
  await siteManager.init();

  // Initialize language controller
  Get.put(LanguageController());

  await WebBrowserManager.instance.initialize();

  // Initialize notification manager
  await NotificationManager.initialize();

  // Initialize service manager (supports both Android and iOS)
  await ServiceManager.instance.initialize();
  
  // For iOS: Ensure service is started on first launch
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    try {
      // Check if service is running
      final isRunning = await ServiceManager.instance.checkServiceStatus();
      if (!isRunning) {
        // Start service automatically on iOS
        await ServiceManager.instance.startService();
      }
    } catch (e) {
      debugPrint('Failed to start iOS service on launch: $e');
    }
  }
  
  // Android WebView debugging
  if (!kIsWeb &&
      kDebugMode &&
      defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder: (languageController) {
        // 如果语言控制器设置为跟随系统，则使用null让系统自动选择
        // 否则使用指定的locale
        Locale? appLocale = languageController.locale;
        
        return GetMaterialApp(
          title: 'OpenList',
          themeMode: ThemeMode.system,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blueGrey,
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blueGrey,
            /* dark theme settings */
          ),
          locale: appLocale,
          fallbackLocale: const Locale('en'),
          supportedLocales: S.delegate.supportedLocales,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MyHomePage(title: ""),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  static const filesPageIndex = 0;

  /// 两次返回视为退出的时间窗口
  static const _exitConfirmWindow = Duration(seconds: 2);

  /// 返回键处理：
  /// - 文件 Tab：先退出多选/搜索，再逐级返回上级目录；
  /// - 已在根目录（或其他 Tab）：第一次返回仅提示，窗口内再按一次才回桌面。
  Future<void> _onBackInvoked(_MainController controller) async {
    final isFilesTab = controller.selectedIndex.value == filesPageIndex;
    if (isFilesTab && Get.isRegistered<FilesController>()) {
      final files = Get.find<FilesController>();
      if (files.selectionMode.value) {
        files.exitSelectionMode();
        return;
      }
      if (files.searchMode.value) {
        files.exitSearch();
        return;
      }
      if (files.path.value != '/') {
        files.loadDirectory(FilesController.parentOf(files.path.value));
        return;
      }
    }

    final now = DateTime.now();
    if (controller.lastBackPress != null &&
        now.difference(controller.lastBackPress!) <= _exitConfirmWindow) {
      // 显式回到桌面（launcher），而不是退到任务栈里的上一个应用；
      // 进程与前台服务保持存活，嵌入式服务器不受影响
      if (defaultTargetPlatform == TargetPlatform.android) {
        const AndroidIntent(
          action: 'android.intent.action.MAIN',
          category: 'android.intent.category.HOME',
        ).launch();
      } else {
        await SystemNavigator.pop();
      }
      return;
    }
    controller.lastBackPress = now;
    NativeBridge.common.toast(S.current.backAgainToExit);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(_MainController());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBackInvoked(controller);
      },
      child: Scaffold(
        body: Obx(
          () => FadeIndexedStack(
            lazy: true,
            index: controller.selectedIndex.value,
            children: [
              const FilesScreen(),
              const OpenListScreen(),
              const DownloadManagerPage(),
              const SettingsScreen()
            ],
          ),
        ),
        bottomNavigationBar: Obx(() => NavigationBar(
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.folder_outlined),
                    selectedIcon: const Icon(Icons.folder),
                    label: S.current.filesTab,
                  ),
                  NavigationDestination(
                    icon: SvgPicture.asset(
                      "assets/openlist.svg",
                      color: Theme.of(context).hintColor,
                      width: 32,
                      height: 32,
                    ),
                    label: S.current.appName,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.arrow_downward),
                    label: _getDownloadLabel(),
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.settings),
                    label: S.current.settings,
                  ),
                ],
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: (int index) {
                  controller.setPageIndex(index);
                })),
      ),
    );
  }

  String _getDownloadLabel() {
    int activeCount = DownloadManager.activeTasks.length;
    if (activeCount > 0) {
      return S.current.downloadManagerWithCount(activeCount);
    } else {
      return S.current.downloadManager;
    }
  }
}

class _MainController extends GetxController {
  final selectedIndex = MyHomePage.filesPageIndex.obs;

  /// 上次按返回键的时间（顶层双击退出判定用）
  DateTime? lastBackPress;

  setPageIndex(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (await NativeBridge.appConfig.isAutoCheckUpdateEnabled()) {
        AppUpdateDialog.checkUpdateAndShowDialog(Get.context!, null);
      }
    });

    super.onInit();
  }
}