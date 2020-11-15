USING: help.syntax help.markup kernel math classes classes.tuple
calendar models ;
IN: models.arrow

HELP: arrow
{ $class-description "Arrow model values are computed by applying a quotation to the value of another model. Arrows are automatically updated when the underlying model changes. Arrows are constructed by " { $link <arrow> } "." }
{ $examples
    "The following code displays a label showing the result of applying " { $link sq } " to the value 5:"
    { $code
        "USING: models models.arrow math.parser ui.gadgets.labels ui.gadgets.panes ;"
        "5 <model> [ sq ] <arrow> [ number>string ] <arrow>"
        "<label-control> gadget."
    }
    "An exercise for the reader is to keep the original model around on the stack, and change its value to 6, observing that the label will immediately display 36."
} ;

HELP: ?arrow
{ $class-description "Like " { $link arrow } ", but only updates value if it is different from the last update. Arrows are constructed by " { $link <?arrow> } "." } ;

HELP: <arrow>
{ $values { "model" model } { "quot" { $quotation ( obj -- newobj ) } } { "arrow" "a new " { $link arrow } } }
{ $description "Creates a new instance of " { $link arrow } ". The value of the new arrow model is computed by applying the quotation to the value." }
{ $examples "See the example in the documentation for " { $link arrow } "." } ;

HELP: <?arrow>
{ $values { "model" model } { "quot" { $quotation ( obj -- newobj ) } } { "?arrow" "a new " { $link ?arrow } } }
{ $description "Creates a new instance of " { $link ?arrow } ". The value of the new arrow model is computed by applying the quotation to the value, but only set if the value actually changed. This prevents connected observers from being updated if the value did not change since the last update." }
{ $examples "See the example in the documentation for " { $link arrow } "." } ;

ARTICLE: "models.arrow" "Arrow models"
"Arrow model values are computed by applying a quotation to the value of another model."
{ $subsections
    arrow
    <arrow>
} ;

ABOUT: "models.arrow"
