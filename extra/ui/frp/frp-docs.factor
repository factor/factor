USING: ui.frp help.syntax help.markup monads sequences ;
IN: ui.frp

! Layout utilities

HELP: ,
{ $description "Used in a series of gadgets created by a box, accumulating the gadget" } ;
HELP: ->
{ $description "Like " { $link , } "but passes its model on for further use." } ;
HELP: <hbox>
{ $syntax "[ gadget , gadget , ... ] <hbox>" }
{ $description "Creates an horizontal track containing the gadgets listed in the quotation" } ;
HELP: <vbox>
{ $syntax "[ gadget , gadget , ... ] <hbox>" }
{ $description "Creates an vertical track containing the gadgets listed in the quotation" } ;

! Gadgets
HELP: <frp-button>
{ $description "Creates an button whose model updates on clicks" } ;

HELP: <merge>
{ $description "Creates a model that merges the updates of two others" } ;

HELP: <filter>
{ $description "Creates a model that uses the updates of another model when they satisfy a given predicate" } ;

HELP: <fold>
{ $description "Similar to " { $link reduce } " but works on models, applying a quotation to the previous and new values at each update" } ;

HELP: switch
{ $description "Creates a model that starts with the behavior of model1 and switches to the behavior of model2 on its update" } ;

ARTICLE: { "frp" "instances" } "FRP Instances"
"Models are all functors, as " { $link fmap } " corresponds directly to the " { $link "models.arrow" } " vocabulary.  "
"Also, a gadget is a monad.  Binding recieves a model and creates a new gadget." ;

