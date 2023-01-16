USING: help.syntax help.markup kernel math classes classes.tuple
calendar models models.product ;
IN: models.range

HELP: range
{ $class-description "Range models implement the " { $link "range-model-protocol" } " with real numbers as the minimum, current, maximum, and page size. Range models are created with " { $link <range> } "." }
{ $notes { $link "ui.gadgets.sliders" } " use range models." } ;

HELP: <range>
{ $values { "value" real } { "page" real } { "min" real } { "max" real } { "step" real } { "range" range } }
{ $description "Creates a new " { $link range } " model." } ;

HELP: range-model
{ $values { "range" range } { "model" model } }
{ $description "Outputs a model holding a range model's current value." }
{ $notes "This word is not part of the " { $link "range-model-protocol" } ", and can only be used on direct instances of " { $link range } "." } ;

HELP: range-min
{ $values { "range" range } { "model" model } }
{ $description "Outputs a model holding a range model's minimum value." }
{ $notes "This word is not part of the " { $link "range-model-protocol" } ", and can only be used on direct instances of " { $link range } "." } ;

HELP: range-max
{ $values { "range" range } { "model" model } }
{ $description "Outputs a model holding a range model's maximum value." }
{ $notes "This word is not part of the " { $link "range-model-protocol" } ", and can only be used on direct instances of " { $link range } "." } ;

HELP: range-page
{ $values { "range" range } { "model" model } }
{ $description "Outputs a model holding a range model's page size." }
{ $notes "This word is not part of the " { $link "range-model-protocol" } ", and can only be used on direct instances of " { $link range } "." } ;

HELP: move-by
{ $values { "amount" real } { "range" range } }
{ $description "Adds a number to a range model's current value." }
{ $side-effects "range" } ;

HELP: move-by-page
{ $values { "amount" real } { "range" range } }
{ $description "Adds a multiple of the page size to a range model's current value." }
{ $side-effects "range" } ;

ARTICLE: "models.range" "Range models"
"Range models ensure their value is a real number within a fixed range."
{ $subsections
    range
    <range>
}
"Range models conform to a protocol for getting and setting the current value, as well as the endpoints of the range."
{ $subsections "range-model-protocol" } ;

ARTICLE: "range-model-protocol" "Range model protocol"
"The range model protocol is implemented by the " { $link range } " and " { $link product } " classes. User-defined models may implement it too."
{ $subsections
    range-value
    range-page-value
    range-min-value
    range-max-value
    range-max-value*
    set-range-value
    set-range-page-value
    set-range-min-value
    set-range-max-value
} ;

ABOUT: "models.range"
