USING: help.markup help.syntax models monads sequences
ui.gadgets.buttons ui.gadgets.tracks ;
IN: ui.frp

! Layout utilities

HELP: ,
{ $values { "uiitem" "a gadget or model" } }
{ $description "Used in a series of gadgets created by a box, accumulating the gadget" } ;
HELP: ->
{ $values { "uiitem" "a gadget or model" } { "model" model } }
{ $description "Like " { $link , } "but passes its model on for further use." } ;
HELP: <hbox>
{ $values { "gadgets" "a list of gadgets" } { "track" track } }
{ $syntax "[ gadget , gadget , ... ] <hbox>" }
{ $description "Creates an horizontal track containing the gadgets listed in the quotation" } ;
HELP: <vbox>
{ $values { "gadgets" "a list of gadgets" } { "track" track } }
{ $syntax "[ gadget , gadget , ... ] <hbox>" }
{ $description "Creates an vertical track containing the gadgets listed in the quotation" } ;

! Gadgets
HELP: <frp-button>
{ $values { "text" "the button's label" } { "button" button } }
{ $description "Creates an button whose model updates on clicks" } ;

HELP: <merge>
{ $values { "models" "a list of models" } { "model" merge-model } }
{ $description "Creates a model that merges the updates of others" } ;

HELP: <filter>
{ $values { "model" model } { "quot" "quotation with stack effect ( a b -- c )" } { "filter-model" filter-model } }
{ $description "Creates a model that uses the updates of another model when they satisfy a given predicate" } ;

HELP: <fold>
{ $values { "oldval" "starting value" } { "quot" "applied to update and previous values" } { "model" model } { "model'" model } }
{ $description "Similar to " { $link reduce } " but works on models, applying a quotation to the previous and new values at each update" } ;

HELP: <switch>
{ $values { "signal1" model } { "signal2" model } { "signal'" model } }
{ $description "Creates a model that starts with the behavior of model1 and switches to the behavior of model2 on its update" } ;

ARTICLE: { "frp" "instances" } "FRP Instances"
"Models are all functors, as " { $link fmap } " corresponds directly to the " { $link "models.arrow" } " vocabulary. "
"Also, a gadget is a monad. Binding recieves a model and creates a new gadget." ;

