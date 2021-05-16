USING: help.markup help.syntax ui.tools.button-list ;
IN: ui.tools.button-list

HELP: show-active-buttons-popup
{ $description "Displays a popup window for fuzzy selection of any labeled button in any window of the session." } ;

HELP: com-show-active-buttons
{ $description "Mapped to a keyboard gesture to execute " { $link show-active-buttons-popup } "." } ;
