USING: help.markup help.syntax monads ui.frp.signals ;
IN: ui.frp.instances
IN: ui.frp.instances
ARTICLE: { "ui.frp.instances" "explanation" } "FRP Instances"
"Signals are all functors, as " { $link fmap } " corresponds directly to " { $link <mapped> } $nl
"Moduls also impliment monad functionalities. " { $link bind } "ing switches between two models. " $nl
"Also, a gadget is a monad. Binding recieves a model and adds the resulting gadget onto the parent. " $nl
"Examples of these instances can be seen in the " { $vocab-link "darcs-ui" } " vocabulary." ;
ABOUT: { "ui.frp.instances" "explanation" }