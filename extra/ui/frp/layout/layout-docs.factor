USING: help.markup help.syntax models ui.gadgets.tracks ui.frp.layout ;
IN: ui.frp.layout

HELP: ,
{ $values { "uiitem" "a gadget or model" } }
{ $description "Used in a series of gadgets created by a box, accumulating the gadget" } ;

HELP: ,%
{ $syntax "gadget ,% width" }
{ $description "Like ',' but stretches the gadget to always fill a percent of the parent" } ;

HELP: ->
{ $values { "uiitem" "a gadget or model" } { "model" model } }
{ $description "Like ',' but passes its model on for further use." } ;

HELP: ->%
{ $syntax "gadget ,% width" }
{ $description "Like '->' but stretches the gadget to always fill a percent of the parent" } ;

HELP: <spacer>
{ $description "Grows to fill any empty space in a box" } ;

HELP: <hbox>
{ $values { "gadgets" "a list of gadgets" } { "track" track } }
{ $syntax "[ gadget , gadget , ... ] <hbox>" }
{ $description "Creates an horizontal track containing the gadgets listed in the quotation" } ;
HELP: <vbox>
{ $values { "gadgets" "a list of gadgets" } { "track" track } }
{ $syntax "[ gadget , gadget , ... ] <hbox>" }
{ $description "Creates an vertical track containing the gadgets listed in the quotation" } ;