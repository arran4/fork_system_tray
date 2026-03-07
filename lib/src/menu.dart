import 'package:flutter/material.dart';

import 'menu_item.dart';
import 'system_tray_platform.dart';
import 'utils.dart';

class Menu {
  static final Map<int, Menu> _menuMap = {};

  /// The ID to use the next time a menu needs an ID assigned.
  static int _nextMenuId = 1;

  List<MenuItemBase>? _menus;

  int _menuId = 1;

  int _menuItemId = 1;

  bool _updateInProgress = false;

  Menu() {
    SystemTrayPlatform.instance
        .registerMenuItemSelectedCallback(_callbackHandler);
  }

  int get menuId => _menuId;

  int get nextMenuItemId {
    return _menuItemId++;
  }

  Future<bool> buildFrom(List<MenuItemBase> menus) async {
    _menuId = _nextMenuId++;
    _menus = menus;
    _menuMap.putIfAbsent(_menuId, () => this);
    return await _createContextMenu(_menus!);
  }

  T? findItemByName<T>(final String name) {
    return _findItemByName(name, _menus!) as T;
  }

  MenuItemBase? _findItemByName(
      final String name, final List<MenuItemBase> menus) {
    MenuItemBase? item;
    for (final menuItem in menus) {
      if (menuItem is SubMenu) {
        item = _findItemByName(name, menuItem.children);
      } else if (menuItem.name == name) {
        item = menuItem;
      }

      if (item != null) {
        break;
      }
    }
    return item;
  }

  MenuItemBase? _findItemById(
      final int? menuItemId, final List<MenuItemBase>? menus) {
    MenuItemBase? item;
    if (menuItemId != null && menus != null) {
      for (final menuItem in menus) {
        if (menuItem is SubMenu) {
          item = _findItemById(menuItemId, menuItem.children);
        } else if (menuItem.menuItemId == menuItemId) {
          item = menuItem;
        }

        if (item != null) {
          break;
        }
      }
    }
    return item;
  }

  Future<bool> _createContextMenu(List<MenuItemBase> menus) async {
    bool result = false;
    try {
      _updateInProgress = true;

      await _channelRepresentationForMenus(menus);

      result = await SystemTrayPlatform.instance.buildMenu(_menuId, menus);
      _updateInProgress = false;
    } catch (e) {
      debugPrint('Exception create context menu: $e');
    }
    return result;
  }

  Future<void> _channelRepresentationForMenus(List<MenuItemBase> menus) async {
    _menuItemId = 1;
    await _channelRepresentationForMenu(menus);
  }

  Future<void> _channelRepresentationForMenu(List<MenuItemBase> menus) async {
    for (final menuItem in menus) {
      menuItem.menuId = menuId;
      menuItem.menuItemId = nextMenuItemId;
      menuItem.imageAbsolutePath = await Utils.getIcon(menuItem.image);

      if (menuItem is SubMenu) {
        await _channelRepresentationForMenu(menuItem.children);
      }
    }
  }

  void _callbackHandler(int menuId, int menuItemId) {
    if (_updateInProgress) {
      debugPrint(
          'Warning: Menu selection callback received during menu update.');
      return;
    }

    final MenuItemBase? menuItem =
        _findItemById(menuItemId, _menuMap[menuId]?._menus);

    debugPrint('MenuItemBase select menuId:$menuId menuItemId:$menuItemId');

    final callback = menuItem?.onClicked;
    if (callback != null) {
      callback(menuItem!);
    }
  }
}
