USING: help.syntax help.markup kernel math classes classes.tuple
calendar models ;
IN: models.compose

HELP: compose
{ $class-description "Composed model values are computed by collecting the values from a sequence of underlying models into a new sequence. Composed models are automatically updated when underlying models change. Composed models are constructed by " { $link <compose> } "."
$nl
"A composed model whose children are all " { $link "models-range" } " conforms to the " { $link "range-model-protocol" } " and represents a point in n-dimensional space which is bounded by a rectangle." }
{ $examples
    "The following code displays a pair of sliders, and an updating label showing their current values:"
    { $code
        "USING: models ui.gadgets.labels ui.gadgets.sliders ui.gadgets.panes ;"
        ": <funny-slider> <x-slider> 100 over set-slider-max ;"
        "<funny-slider> <funny-slider> 2array"
        "dup make-pile gadget."
        "dup [ gadget-model ] map <compose> [ unparse ] <filter>"
        "<label-control> gadget."
    }
} ;

HELP: <compose>
{ $values { "models" "a sequence of models" } { "compose" "a new " { $link compose } } }
{ $description "Creates a new instance of " { $link compose } ". The value of the new compose model is obtained by mapping " { $link model-value } " over the given sequence of models." }
{ $examples "See the example in the documentation for " { $link compose } "." } ;

ARTICLE: "models-compose" "Composed models"
"Composed model values are computed by collecting the values from a sequence of underlying models into a new sequence."
{ $subsection compose }
{ $subsection <compose> } ;

ABOUT: "models-compose"
