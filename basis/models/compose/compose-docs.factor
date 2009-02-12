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
        "USING: models models.compose models.range ui.gadgets"
        "ui.gadgets.labels ui.gadgets.packs ui.gadgets.panes"
        "ui.gadgets.sliders ;"
        ""
        ": <funny-model> ( -- model ) 0 10 0 100 <range> ;"
        ": <funny-slider> ( model -- slider ) horizontal <slider> ;"
        ""
        "<funny-model> <funny-model> 2array"
        "[ <pile> [ horizontal <slider> add-gadget ] reduce gadget. ]"
        "[ <compose> [ unparse ] <filter> <label-control> gadget. ]"
        "bi"
    }
} ;

HELP: <compose>
{ $values { "models" "a sequence of models" } { "compose" "a new " { $link compose } } }
{ $description "Creates a new instance of " { $link compose } ". The value of the new compose model is obtained by mapping the " { $snippet "value" } " slot accessor over the given sequence of models." }
{ $examples "See the example in the documentation for " { $link compose } "." } ;

ARTICLE: "models-compose" "Composed models"
"Composed model values are computed by collecting the values from a sequence of underlying models into a new sequence."
{ $subsection compose }
{ $subsection <compose> } ;

ABOUT: "models-compose"
