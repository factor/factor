IN: models.arrow.smart
USING: help.syntax help.markup models.product models.arrow ;

HELP: <smart-arrow>
{ $values { "quot" { $quotation ( ... -- output ) } } }
{ $description "A macro that expands into a form with the stack effect of the quotation. The form constructs a model which applies the quotation to values from an underlying " { $link product } " model having as many components as the quotation has inputs." }
{ $examples
  "A model which adds the values of two existing models:"
  { $example
    "USING: models models.arrow.smart accessors kernel math prettyprint ;"
    "1 <model> 2 <model> [ + ] <smart-arrow>"
    "[ activate-model ] [ value>> ] bi ."
    "3"
  }
} ;

HELP: <?smart-arrow>
{ $values { "quot" { $quotation ( ... -- output ) } } }
{ $description "Like " { $link <smart-arrow> } ", but with the semantics of " { $link <?arrow> } "." } ;

ARTICLE: "models.arrow.smart" "Smart arrow models"
"The " { $vocab-link "models.arrow.smart" } " vocabulary generalizes arrows to arbitrary input arity. They're called “smart” because they resemble " { $link "combinators.smart" } "."
{ $subsections <smart-arrow> } ;

ABOUT: "models.arrow.smart"
