# Issue Report: Remove Remaining C++ Plugin Code (AppWindow)

## Description
Currently, the Linux implementation of `system_tray` still relies on a C++ plugin (`linux/system_tray_plugin.cc`, `linux/app_window.cc`) to handle `AppWindow` functionality. This includes:
- Initializing the application window reference.
- Showing/Hiding the window.
- Closing the window.
- Handling window state events (iconification).

## Goal
Eliminate the C++ plugin completely to have a pure Dart implementation for Linux.

## Requirements
To achieve this, the `AppWindow` functionality must be ported to Dart. Approaches include:

1.  **Use `dart:ffi` with GTK:**
    - Bind to `libgtk-3.so`.
    - Implement `gtk_widget_show`, `gtk_widget_hide`, `gtk_window_close`, `gtk_window_move`, `gtk_window_present`, `gtk_window_deiconify`.
    - Find the top-level GTK window handle. This might require interacting with the Flutter engine's window handle if exposed, or searching for it.

2.  **Use existing packages:**
    - Packages like `window_manager` or `bitsdojo_window` already implement window control for Linux (often using C++ plugins themselves, but widely used).
    - If a pure Dart dependency is strictly required, Option 1 is preferred.

3.  **Update `SystemTrayPlatform`:**
    - Ensure `SystemTrayPlatform` has methods for `showAppWindow`, `hideAppWindow`, etc.
    - Implement them in `LinuxSystemTray` using the FFI bindings.

## Benefits
- No C++ compilation required for the package.
- Simplified build process.
- easier distribution.
