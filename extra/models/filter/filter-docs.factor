USING: help.syntax help.markup kernel math classes classes.tuple
calendar models ;
IN: models.filter

HELP: filter
{ $class-description "Filter model values are computed by applying a quotation to the value of another model. Filters are automatically updated when the underlying model changes. Filters are constructed by " { $link <filter> } "." }
{ $examples
    "The following code displays a label showing the result of applying " { $link sq } " to the value 5:"
    { $code
        "USING: models ui.gadgets.labels ui.gadgets.panes ;"
        "5 <model> [ sq ] <filter> [ number>string ] <filter>"
        "<label-control> gadget."
    }
    "An exercise for the reader is to keep the original model around on the stack, and change its value to 6, observing that the label will immediately display 36."
} ;

HELP: <filter>
{ $values { "model" model } { "quot" "a quotation with stack effect " { $snippet "( obj -- newobj )" } } { "filter" "a new " { $link filter } } }
{ $description "Creates a new instance of " { $link filter } ". The value of the new filter model is computed by applying the quotation to the value." }
{ $examples "See the example in the documentation for " { $link filter } "." } ;

ARTICLE: "models-filter" "Filter models"
"Filter model values are computed by applying a quotation to the value of another model."
{ $subsection filter }
{ $subsection <filter> } ;

ABOUT: "models-filter"
