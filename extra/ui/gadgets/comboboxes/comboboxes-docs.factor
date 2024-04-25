! Copyright (C) 2023 Your name.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel sequences strings ui.gadgets.tables 
models ;
IN: ui.gadgets.comboboxes

HELP: <combobox>
{ $values
    { "options" { "a " { $link sequence } " of " { $link string } "s" } }
    { "combobox" object }
}
{ $description "Creates a combo box from a list of strings." } ;

HELP: combo-table
{ $class-description "Class that po" } ;

HELP: combobox
{ $class-description "The class of comboboxes. The combobox dropdown is a "
{ $link table } " with clickable elements." } ;

ARTICLE: "ui.gadgets.comboboxes" "Combobox gadgets"
"Comboboxes are UI elements that provide a dropdown menu for selecting from a "
"list of set options."
$nl
"Factor comboboxes use the " { $link model } " present in its inherited model "
"slot to indicate updates to the combobox label value."
;

ABOUT: "ui.gadgets.comboboxes"
