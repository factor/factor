USING: help.markup help.syntax ui.gadgets.buttons
ui.gadgets.editors ui.frp.gadgets ;
IN: ui.frp.gadgets

HELP: <frp-button>
{ $values { "gadget" "the button's label" } { "button" button } }
{ $description "Creates an button whose signal updates on clicks.  " } ;

HELP: <frp-table>
{ $values { "model" "values the table is to display" } { "table" frp-table } }
{ $description "Creates an " { $link frp-table } } ;

HELP: <frp-table*>
{ $values { "table" frp-table } }
{ $description "Creates an " { $link frp-table } " with no initial values to display" } ;

HELP: <frp-list>
{ $values { "column-model" "values the table is to display" } { "table" frp-table } }
{ $description "Creates an " { $link frp-table } " with a val-quot that renders each element as its own row" } ;

HELP: <frp-list*>
{ $values { "table" frp-table } }
{ $description "Creates an frp-list with no initial values to display" } ;

HELP: indexed
{ $values { "table" frp-table } }
{ $description "Sets the output model of an frp-table to the selected-index, rather than the selected-value" } ;

HELP: <frp-field>
{ $values { "field" model-field } }
{ $description "Creates a field with an empty initial value" } ;