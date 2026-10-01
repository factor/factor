USING: help.markup help.syntax strings ui.backend.windows windows.tray ;
IN: ui.backend.windows

HELP: add-tray-icon
{ $values { "title" string } }
{ $description "Adds the default notification-area icon for the current world, replacing any existing default icon. Its initial action raises the world. Closing the world removes the icon." }
{ $notes "Use " { $link current-tray-icon } " to configure its action and menu, or " { $link <tray-icon> } " to create additional icons." } ;

HELP: current-tray-icon
{ $values { "icon/f" { $maybe tray-icon } } }
{ $description "Returns the default tray icon for the current world, or " { $snippet "f" } " if none has been added." } ;

HELP: remove-tray-icon
{ $description "Removes the default tray icon for the current world, if present. Calling this more than once is harmless." } ;
