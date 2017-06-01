USING: accessors help.markup help.syntax ui.gadgets.buttons
ui.gadgets.editors models ui.gadgets ;
IN: ui.gadgets.controls

HELP: <model-btn>
{ $values { "gadget" "the button's label" } { "button" button } }
{ $description "Creates an button whose signal updates on clicks.  " } ;

HELP: <model-border-btn>
{ $values { "text" "the button's label" } { "button" button } }
{ $description "Creates an button whose signal updates on clicks.  " } ;

HELP: <table>
{ $values { "model" "values the table is to display" } { "table" table } }
{ $description "Creates an " { $link table } } ;

HELP: <table*>
{ $values { "table" table } }
{ $description "Creates an " { $link table } " with no initial values to display" } ;

HELP: <list>
{ $values { "column-model" "values the table is to display" } { "table" table } }
{ $description "Creates an " { $link table } " with a val-quot that renders each element as its own row" } ;

HELP: <list*>
{ $values { "table" table } }
{ $description "Creates an model-list with no initial values to display" } ;

HELP: indexed
{ $values { "table" table } }
{ $description "Sets the output model of an table to the selected-index, rather than the selected-value" } ;

HELP: <model-field>
{ $values { "model" model } { "gadget" model-field } }
{ $description "Creates a field with an initial value" } ;

HELP: <model-field*>
{ $values { "field" model-field } }
{ $description "Creates a field with an empty initial value" } ;

HELP: <empty-field>
{ $values { "model" model } { "field" model-field } }
{ $description "Creates a field with an empty initial value that switches to another signal on its update" } ;

HELP: <model-editor>
{ $values { "model" model } { "gadget" model-field } }
{ $description "Creates an editor with an initial value" } ;

HELP: <model-editor*>
{ $values { "editor" "an editor" } }
{ $description "Creates a editor with an empty initial value" } ;

HELP: <empty-editor>
{ $values { "model" model } { "editor" "an editor" } }
{ $description "Creates a field with an empty initial value that switches to another signal on its update" } ;

HELP: <model-action-field>
{ $values { "field" action-field } }
{ $description "Field that updates its model with its contents when the user hits the return key" } ;

HELP: IMG-MODEL-BTN:
{ $syntax "IMAGE-MODEL-BTN: filename" }
{ $description "Creates a button using a tiff image named as specified found in the icons subdirectory of the vocabulary path" } ;

HELP: IMG-BTN:
{ $syntax "[ do-something ] IMAGE-BTN: filename" }
{ $description "Creates a button using a tiff image named as specified found in the icons subdirectory of the vocabulary path, calling the specified quotation on click" } ;

HELP: output-model
{ $values { "gadget" gadget } { "model" model } }
{ $description "Returns the model a gadget uses for output. Often the same as " { $link model>> } } ;
