import 'dart:async';

import 'package:flutter/services.dart';

import 'menu.dart';
import 'menu_item.dart';
import 'system_tray_platform.dart';

class SystemTrayMethodChannel extends SystemTrayPlatform {
  static const MethodChannel _appWindowChannel =
      MethodChannel("flutter/system_tray/app_window");
  static const MethodChannel _trayChannel =
      MethodChannel("flutter/system_tray/tray");
  static const MethodChannel _menuManagerChannel =
      MethodChannel("flutter/system_tray/menu_manager");

  void Function(String eventName)? _systemTrayEventCallback;
  void Function(int menuId, int menuItemId)? _menuItemSelectedCallback;

  SystemTrayMethodChannel() {
    _trayChannel.setMethodCallHandler((call) async {
      if (call.method == 'SystemTrayEventCallback') {
        if (_systemTrayEventCallback != null) {
          final String eventName = call.arguments;
          _systemTrayEventCallback!(eventName);
        }
      }
    });

    _menuManagerChannel.setMethodCallHandler((call) async {
      if (call.method == 'MenuItemSelectedCallback') {
        final int menuId = call.arguments['menu_id'];
        final int menuItemId = call.arguments['menu_item_id'];
        if (_menuItemSelectedCallback != null) {
          _menuItemSelectedCallback!(menuId, menuItemId);
        }
      }
    });
  }

  @override
  Future<void> initAppWindow() async {
    await _appWindowChannel.invokeMethod("InitAppWindow");
  }

  @override
  Future<void> showAppWindow() async {
    await _appWindowChannel.invokeMethod("ShowAppWindow");
  }

  @override
  Future<void> hideAppWindow() async {
    await _appWindowChannel.invokeMethod("HideAppWindow");
  }

  @override
  Future<void> closeAppWindow() async {
    await _appWindowChannel.invokeMethod("CloseAppWindow");
  }

  @override
  Future<bool> initSystemTray({
    required String trayId,
    required String iconPath,
    String? title,
    String? toolTip,
    bool isTemplate = false,
  }) async {
    return await _trayChannel.invokeMethod(
      "InitSystemTray",
      <String, dynamic>{
        "tray_id": trayId,
        "title": title,
        "iconpath": iconPath,
        "tooltip": toolTip,
        "is_template": isTemplate,
      },
    );
  }

  @override
  Future<bool> setSystemTrayInfo({
    String? title,
    String? iconPath,
    String? toolTip,
    bool isTemplate = false,
  }) async {
    return await _trayChannel.invokeMethod(
      "SetSystemTrayInfo",
      <String, dynamic>{
        "title": title,
        "iconpath": iconPath,
        "tooltip": toolTip,
        "is_template": isTemplate,
      },
    );
  }

  @override
  Future<void> setContextMenu(int menuId) async {
    await _trayChannel.invokeMethod("SetContextMenu", menuId);
  }

  @override
  Future<void> popUpContextMenu() async {
    await _trayChannel.invokeMethod("PopupContextMenu");
  }

  @override
  Future<String> getTitle() async {
    return await _trayChannel.invokeMethod("GetTitle");
  }

  @override
  Future<void> destroySystemTray() async {
    await _trayChannel.invokeMethod("DestroySystemTray");
  }

  @override
  void registerSystemTrayEventHandler(
      void Function(String eventName) callback) {
    _systemTrayEventCallback = callback;
  }

  @override
  Future<bool> buildMenu(int menuId, List<MenuItemBase> menus) async {
    try {
      return await _menuManagerChannel
          .invokeMethod("CreateContextMenu", <String, dynamic>{
        "menu_id": menuId,
        "menu_list": menus.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> setMenuItemLabel(
      int menuId, int menuItemId, String label) async {
    await _menuManagerChannel.invokeMethod("SetLabel", {
      "menu_id": menuId,
      "menu_item_id": menuItemId,
      "label": label,
    });
  }

  @override
  Future<void> setMenuItemImage(
      int menuId, int menuItemId, String imageAbsolutePath) async {
    await _menuManagerChannel.invokeMethod("SetImage", {
      "menu_id": menuId,
      "menu_item_id": menuItemId,
      "image": imageAbsolutePath,
    });
  }

  @override
  Future<void> setMenuItemEnable(
      int menuId, int menuItemId, bool enabled) async {
    await _menuManagerChannel.invokeMethod("SetEnable", {
      "menu_id": menuId,
      "menu_item_id": menuItemId,
      "enabled": enabled,
    });
  }

  @override
  Future<void> setMenuItemCheck(
      int menuId, int menuItemId, bool checked) async {
    await _menuManagerChannel.invokeMethod("SetCheck", {
      "menu_id": menuId,
      "menu_item_id": menuItemId,
      "checked": checked,
    });
  }

  @override
  void registerMenuItemSelectedCallback(
      void Function(int menuId, int menuItemId) callback) {
    _menuItemSelectedCallback = callback;
  }
}
