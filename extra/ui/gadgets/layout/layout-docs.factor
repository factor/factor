USING: help.markup help.syntax models ui.gadgets.tracks ;
IN: ui.gadgets.layout

HELP: ,
{ $values { "item" "a gadget or model" } }
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

HELP: $
{ $syntax "$ PLACEHOLDER-NAME $" }
{ $description "Defines an insertion point in a template named PLACEHOLDER-NAME which can be used by calling its name" } ;

HELP: with-interface
{ $values { "quot" "quotation that builds a template and inserts into it" } }
{ $description "Create templates, used with " { $link POSTPONE: $ } } ;

ARTICLE: "ui.gadgets.layout" "GUI Layout"
"Laying out GUIs works the same way as building lists with " { $vocab-link "make" }
". Gadgets are layed out using " { $vocab-link "ui.gadgets.tracks" } " through " { $link <hbox> } " and " { $link <vbox> } ", which allow both fixed and percentage widths. "
{ $link , } " and " { $link -> }  " add a model or gadget to the gadget you're building. "
"Also, books can be made with " { $link <book> } ". "
{ $link <spacer> } "s add flexable space between items." $nl
"Using " { $link with-interface } ", one can pre-build templates to add items to later: "
"Like in the StringTemplate framework for java, placeholders are defined using $ PLACERHOLDER-NAME $ "
"Using PLACEHOLDER-NAME again sets it as the current insertion point. "
"For examples using normal layout, see the " { $vocab-link "sudokus" } " demo. "
"For examples of templating, see the " { $vocab-link "recipes" } " demo." ;

ABOUT: "ui.gadgets.layout"
