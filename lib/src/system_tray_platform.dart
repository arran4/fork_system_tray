import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'menu.dart';
import 'menu_item.dart';
import 'system_tray_linux.dart';
import 'system_tray_method_channel.dart';
import 'constants.dart';

abstract class SystemTrayPlatform {
  static SystemTrayPlatform? _instance;

  static SystemTrayPlatform get instance {
    if (_instance != null) return _instance!;
    if (Platform.isLinux) {
      _instance = SystemTrayLinux();
    } else {
      _instance = SystemTrayMethodChannel();
    }
    return _instance!;
  }

  Future<void> initAppWindow();
  Future<void> showAppWindow();
  Future<void> hideAppWindow();
  Future<void> closeAppWindow();

  Future<bool> initSystemTray({
    required String trayId,
    required String iconPath,
    String? title,
    String? toolTip,
    bool isTemplate = false,
  });

  Future<bool> setSystemTrayInfo({
    String? title,
    String? iconPath,
    String? toolTip,
    bool isTemplate = false,
  });

  Future<void> setContextMenu(int menuId);
  Future<void> popUpContextMenu();
  Future<String> getTitle();
  Future<void> destroySystemTray();

  void registerSystemTrayEventHandler(void Function(String eventName) callback);

  Future<bool> buildMenu(int menuId, List<MenuItemBase> menus);

  Future<void> setMenuItemLabel(int menuId, int menuItemId, String label);
  Future<void> setMenuItemImage(
      int menuId, int menuItemId, String imageAbsolutePath);
  Future<void> setMenuItemEnable(int menuId, int menuItemId, bool enabled);
  Future<void> setMenuItemCheck(int menuId, int menuItemId, bool checked);

  void registerMenuItemSelectedCallback(
      void Function(int menuId, int menuItemId) callback);
}
