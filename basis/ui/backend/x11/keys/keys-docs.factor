USING: help.markup help.syntax math ;
IN: ui.backend.x11.keys

HELP: code>sym
{ $values { "code" integer } { "name/code/f" "a gesture name, character code, or f" } { "action?" "a boolean" } }
{ $description "Converts an X11 keysym to a gesture symbol. Printable keypad keys are converted to their character codes and treated as ordinary text keys. Navigation and function keys return gesture names with action? set, while modifier keys return f." } ;
