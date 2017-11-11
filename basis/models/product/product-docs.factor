USING: help.syntax help.markup kernel math classes classes.tuple
calendar models ;
IN: models.product

HELP: product
{ $class-description "Product model values are computed by collecting the values from a sequence of underlying models into a new sequence. Product models are automatically updated when underlying models change. Product models are constructed by " { $link <product> } "."
$nl
"A product model whose children are all " { $link "models.range" } " conforms to the " { $link "range-model-protocol" } " and represents a point in n-dimensional space which is bounded by a rectangle." }
{ $examples
    "The following code displays a pair of sliders, and an updating label showing their current values:"
    { $code
        "USING: models models.product models.range ui.gadgets"
        "ui.gadgets.labels ui.gadgets.packs ui.gadgets.panes"
        "ui.gadgets.sliders ;"
        ""
        ": <funny-model> ( -- model ) 0 10 0 100 1 <range> ;"
        ": <funny-slider> ( model -- slider ) horizontal <slider> ;"
        ""
        "<funny-model> <funny-model> 2array"
        "[ <pile> [ horizontal <slider> add-gadget ] reduce gadget. ]"
        "[ <product> [ unparse ] <arrow> <label-control> gadget. ]"
        "bi"
    }
} ;

HELP: <product>
{ $values { "models" "a sequence of models" } { "product" "a new " { $link product } } }
{ $description "Creates a new instance of " { $link product } ". The value of the new product model is obtained by mapping the " { $snippet "value" } " slot accessor over the given sequence of models." }
{ $examples "See the example in the documentation for " { $link product } "." } ;

ARTICLE: "models.product" "Product models"
"Product model values are computed by collecting the values from a sequence of underlying models into a new sequence."
{ $subsections
    product
    <product>
} ;

ABOUT: "models.product"
