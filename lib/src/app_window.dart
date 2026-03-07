import 'dart:async';

import 'system_tray_platform.dart';

/// Representation of native window
class AppWindow {
  AppWindow() {
    _init();
  }

  /// Show native window
  Future<void> show() async {
    await SystemTrayPlatform.instance.showAppWindow();
  }

  /// Hide native window
  Future<void> hide() async {
    await SystemTrayPlatform.instance.hideAppWindow();
  }

  /// Close native window
  Future<void> close() async {
    await SystemTrayPlatform.instance.closeAppWindow();
  }

  void _init() async {
    await SystemTrayPlatform.instance.initAppWindow();
  }
}
