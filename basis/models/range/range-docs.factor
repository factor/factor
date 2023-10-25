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

HELP: range-value
{ $values { "range" range } { "value" object } }
{ $contract "Outputs the current value of a range model." } ;

HELP: range-page-value
{ $values { "range" range } { "value" object } }
{ $contract "Outputs the page size of a range model." } ;

HELP: range-min-value
{ $values { "range" range } { "value" object } }
{ $contract "Outputs the minimum value of a range model." } ;

HELP: range-max-value
{ $values { "range" range } { "value" object } }
{ $contract "Outputs the maximum value of a range model." } ;

HELP: range-max-value*
{ $values { "range" range } { "value" object } }
{ $contract "Outputs the slider position for a range model. Since the bottom of the slider cannot exceed the maximum value, this is equal to the maximum value minus the page size." } ;

HELP: set-range-value
{ $values { "value" object } { "range" range } }
{ $description "Sets the current value of a range model." } ;

HELP: set-range-page-value
{ $values { "value" object } { "range" range } }
{ $description "Sets the page size of a range model." } ;

HELP: set-range-min-value
{ $values { "value" object } { "range" range } }
{ $description "Sets the minimum value of a range model." } ;

HELP: set-range-max-value
{ $values { "value" object } { "range" range } }
{ $description "Sets the maximum value of a range model." } ;

ARTICLE: "range-model-protocol" "Range model protocol"
"The " { $link range } " class supports a range model protocol."
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
