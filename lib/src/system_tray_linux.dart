import 'dart:async';

import 'package:dart_xdg_status_notifier_item/dart_xdg_status_notifier_item.dart';

import 'constants.dart';
import 'menu.dart';
import 'menu_item.dart';
import 'system_tray_platform.dart';

class SystemTrayLinux extends SystemTrayPlatform {
  final Map<int, DBusMenuItem> _menuMap = {};
  StatusNotifierItemClient? _client;

  void Function(String eventName)? _systemTrayEventCallback;
  void Function(int menuId, int menuItemId)? _menuItemSelectedCallback;

  @override
  Future<void> initAppWindow() async {
    // No-op for pure dart linux backend
  }

  @override
  Future<void> showAppWindow() async {
    // No-op for pure dart linux backend
  }

  @override
  Future<void> hideAppWindow() async {
    // No-op for pure dart linux backend
  }

  @override
  Future<void> closeAppWindow() async {
    // No-op for pure dart linux backend
  }

  @override
  Future<bool> initSystemTray({
    required String trayId,
    required String iconPath,
    String? title,
    String? toolTip,
    bool isTemplate = false,
  }) async {
    _client = StatusNotifierItemClient(
        id: trayId,
        iconName: iconPath,
        title: title ?? '',
        menu: DBusMenuItem(children: []),
        onContextMenu: (x, y) async {
          if (_systemTrayEventCallback != null) {
            _systemTrayEventCallback!(kSystemTrayEventRightClick);
          }
        },
        onActivate: (x, y) async {
          if (_systemTrayEventCallback != null) {
            _systemTrayEventCallback!(kSystemTrayEventClick);
          }
        },
        onSecondaryActivate: (x, y) async {
          if (_systemTrayEventCallback != null) {
            _systemTrayEventCallback!(kSystemTrayEventDoubleClick);
          }
        });

    if (toolTip != null && toolTip.isNotEmpty) {
      _client!.toolTip = StatusNotifierToolTip(
          iconName: 'icon-name', title: toolTip, body: '', iconPixmap: []);
    }

    await _client!.connect();
    return true;
  }

  @override
  Future<bool> setSystemTrayInfo({
    String? title,
    String? iconPath,
    String? toolTip,
    bool isTemplate = false,
  }) async {
    if (_client != null) {
      if (iconPath != null) _client!.iconName = iconPath;
      if (title != null) _client!.title = title;
      if (toolTip != null) {
        _client!.toolTip = StatusNotifierToolTip(
            iconName: 'icon-name', title: toolTip, body: '', iconPixmap: []);
      }
    }
    return true;
  }

  @override
  Future<void> setContextMenu(int menuId) async {
    if (_menuMap.containsKey(menuId) && _client != null) {
      await _client!.updateMenu(_menuMap[menuId]!);
    }
  }

  @override
  Future<void> popUpContextMenu() async {
    // Not typically supported directly via xdg_status_notifier_item without shell interaction
  }

  @override
  Future<String> getTitle() async {
    return _client?.title ?? "";
  }

  @override
  Future<void> destroySystemTray() async {
    if (_client != null) {
      await _client!.close();
      _client = null;
    }
  }

  @override
  void registerSystemTrayEventHandler(
      void Function(String eventName) callback) {
    _systemTrayEventCallback = callback;
  }

  DBusMenuItem _buildMenuItem(MenuItemBase item, int menuId) {
    if (item is MenuSeparator) {
      return DBusMenuItem.separator();
    }

    if (item is SubMenu) {
      final children =
          item.children.map((e) => _buildMenuItem(e, menuId)).toList();
      return DBusMenuItem(
        label: item.label,
        enabled: item.enabled,
        children: children,
      );
    }

    if (item is MenuItemCheckbox) {
      return DBusMenuItem.checkmark(item.label,
          state: item.checked, enabled: item.enabled, onClicked: () async {
        if (_menuItemSelectedCallback != null) {
          _menuItemSelectedCallback!(menuId, item.menuItemId ?? -1);
        }
      });
    }

    return DBusMenuItem(
        label: item.label,
        enabled: item.enabled,
        onClicked: () async {
          if (_menuItemSelectedCallback != null) {
            _menuItemSelectedCallback!(menuId, item.menuItemId ?? -1);
          }
        });
  }

  @override
  Future<bool> buildMenu(int menuId, List<MenuItemBase> menus) async {
    final children = menus.map((e) => _buildMenuItem(e, menuId)).toList();
    final menu = DBusMenuItem(children: children);
    _menuMap[menuId] = menu;

    if (_client != null) {
      // Re-apply if it is the current context menu (We might need to track which menu is active, but updating all is fine for basic behavior)
    }
    return true;
  }

  @override
  Future<void> setMenuItemLabel(
      int menuId, int menuItemId, String label) async {
    // For pure dart implementation, since menus are built from object state, we just require the caller to re-set context menu
  }

  @override
  Future<void> setMenuItemImage(
      int menuId, int menuItemId, String imageAbsolutePath) async {}

  @override
  Future<void> setMenuItemEnable(
      int menuId, int menuItemId, bool enabled) async {}

  @override
  Future<void> setMenuItemCheck(
      int menuId, int menuItemId, bool checked) async {}

  @override
  void registerMenuItemSelectedCallback(
      void Function(int menuId, int menuItemId) callback) {
    _menuItemSelectedCallback = callback;
  }
}
