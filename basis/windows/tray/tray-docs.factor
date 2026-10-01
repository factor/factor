USING: destructors help.markup help.syntax quotations sequences strings
windows.tray windows.types ;
IN: windows.tray

HELP: tray-icon
{ $class-description "A disposable Windows notification-area icon owned by a native window. The " { $slot "action" } " quotation has stack effect " { $snippet "( -- )" } " and runs on mouse activation, keyboard activation, or a notification click. The " { $slot "menu" } " sequence contains pairs of labels and quotations with stack effect " { $snippet "( -- )" } "; " { $snippet "f" } " entries are separators. Right-clicking opens this menu. Both slots can be changed after construction." }
{ $notes "Callbacks run on the owning UI thread. Factor UI windows remove their icons when closed and restore them when Explorer recreates the taskbar. Explicitly calling " { $link dispose } " removes an icon sooner." } ;

HELP: <tray-icon>
{ $values { "title" string } { "hwnd" HWND } { "icon" tray-icon } }
{ $description "Adds a notification-area icon using the Factor application icon and the supplied tooltip. Multiple icons can share one owner window. The initial action does nothing and the initial menu is empty." }
{ $notes "The owner must remain alive and process Windows messages. Factor UI windows handle these messages automatically. Custom window procedures must forward " { $link WM_FACTOR_TRAYICON } " to " { $link handle-tray-event } ", call " { $link restore-tray-icons } " on the registered TaskbarCreated message, and call " { $link dispose-window-tray-icons } " before destroying the window." } ;

HELP: set-tray-icon-tip
{ $values { "title" string } { "icon" tray-icon } }
{ $description "Changes an icon's tooltip. Text is limited to 127 UTF-16 code units, without splitting surrogate pairs." } ;

HELP: show-tray-notification
{ $values { "title" string } { "text" string } { "icon" tray-icon } }
{ $description "Requests a Windows information notification associated with an existing tray icon. An empty body dismisses its notification. The title and body are limited to 63 and 255 UTF-16 code units respectively, without splitting surrogate pairs." }
{ $notes "Windows controls the display duration and may suppress the notification according to user settings or quiet time. This uses Shell_NotifyIcon, rather than the WinRT notification API." } ;

HELP: show-tray-menu
{ $values { "icon" tray-icon } }
{ $description "Opens the icon's native context menu at the cursor and invokes the selected item's quotation. Cancellation invokes no quotation. An empty menu does nothing." } ;

HELP: handle-tray-event
{ $values { "hwnd" HWND } { "wParam" "a Windows message parameter" } { "lParam" "a Windows message parameter" } }
{ $description "Dispatches a version-4 notification-area callback to the matching icon. Messages for unknown icon IDs are ignored." } ;

HELP: dispose-window-tray-icons
{ $values { "hwnd" HWND } }
{ $description "Disposes all notification-area icons belonging to one window." } ;

HELP: restore-tray-icons
{ $description "Re-adds live icons after Explorer recreates the taskbar, preserving tooltips, actions, and menus. Previous notifications are not replayed." } ;

HELP: tray-icon-error
{ $error-description "Windows rejected a notification-area operation. The " { $slot "operation" } " slot identifies the Shell_NotifyIcon operation." } ;

ARTICLE: "windows.tray" "Windows notification-area icons"
"The " { $vocab-link "windows.tray" } " vocabulary provides tray icons, native context menus, and notifications for Windows. This vocabulary is Windows-only."
{ $subsections <tray-icon> tray-icon set-tray-icon-tip show-tray-notification show-tray-menu }
"For an existing Factor UI window, create an icon with its native handle:"
{ $code
  "USING: accessors io namespaces ui.backend.windows ui.gadgets"
  "ui.gadgets.worlds windows.tray ;"
  "\"My application\" world get handle>> hWnd>> <tray-icon>"
  "    [ \"Activated\" print ] >>action"
  "    { { \"Say hello\" [ \"Hello\" print ] } } >>menu"
  "    \"Ready\" \"Background work is complete.\" rot show-tray-notification" }
"The existing " { $snippet "add-tray-icon" } " and " { $snippet "remove-tray-icon" } " words in " { $vocab-link "ui.backend.windows" } " manage one default icon for the current world. " { $snippet "current-tray-icon" } " returns it so that its action and menu can be configured." ;

ABOUT: "windows.tray"
