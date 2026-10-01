USING: help.markup help.syntax strings ui.backend.windows windows.tray ;
IN: ui.backend.windows

ARTICLE: "ui.backend.windows-startup" "Windows window startup"
"The backend selects the system theme before constructing gadgets, while preserving an explicitly selected Factor theme. It configures the native window's dark frame before showing it."
"On systems supporting DWM cloaking, the window remains composed but invisible until its first OpenGL frame has been presented. It then becomes visible and receives focus. A minimized launch is uncloaked immediately so its taskbar entry remains available. Unsupported systems show the window normally."
"Opaque DirectWrite text is rendered once into an opaque native bitmap. Translucent text and selection highlights use the coverage renderer." ;

HELP: add-tray-icon
{ $values { "title" string } }
{ $description "Adds the default notification-area icon for the current world, replacing any existing default icon. Its initial action raises the world. Closing the world removes the icon." }
{ $notes "Use " { $link current-tray-icon } " to configure its action and menu, or " { $link <tray-icon> } " to create additional icons." } ;

HELP: current-tray-icon
{ $values { "icon/f" { $maybe tray-icon } } }
{ $description "Returns the default tray icon for the current world, or " { $snippet "f" } " if none has been added." } ;

HELP: remove-tray-icon
{ $description "Removes the default tray icon for the current world, if present. Calling this more than once is harmless." } ;
