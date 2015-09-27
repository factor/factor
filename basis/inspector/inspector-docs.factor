USING: help.markup help.syntax kernel classes io io.styles mirrors
inspector.private ;
IN: inspector

ARTICLE: "inspector" "The inspector"
"The inspector displays a tabular view of an object and adds navigation and editing features. Inspector words are found in the " { $vocab-link "inspector" } " vocabulary."
$nl
"Starting the inspector:"
{ $subsections inspect }
"The inspector supports a number of commands which operate on the most recently inspected object:"
{ $subsections
    &push
    &back
    &at
    &put
    &add
    &rename
    &delete
}
"A variable holding the current object:"
{ $subsections me }
"A description of an object can be printed without starting the inspector:"
{ $subsections describe } ;

ABOUT: "inspector"

HELP: describe
{ $values { "obj" object } }
{ $description "Print a tabular overview of the object."
$nl
"For sequences and hashtables, this outputs the entries of the collection. For all other object types, slot names and values are shown." }
{ $examples { $code "global describe" } } ;

HELP: inspector-stack
{ $var-description "If the inspector is running, this variable holds previously-inspected objects." } ;

HELP: &push
{ $values { "obj" object } }
{ $description "If the inspector is running, outputs the object currently being inspected." } ;

HELP: inspector
{ $values { "obj" object } }
{ $description "Starts a new inspector and prints a brief help message. If an inspector is already running, this starts a nested inspector. An alternative word that reuses the current inspector instance is " { $link inspect } "." } ;

HELP: inspect
{ $values { "obj" object } }
{ $description "If an inspector is already running, displays the slots of the object in the current inspector. If an inspector is not running, starts a new inspector." } ;

HELP: &at
{ $values { "n" "a non-negative integer" } }
{ $description "Inspects the " { $snippet "n" } "th slot of the current object. Use " { $link &back } " to return." } ;

HELP: &put
{ $values { "value" object } { "n" "a non-negative integer" } }
{ $description "Sets the " { $snippet "n" } "th slot of the current object to the given value." }
{ $errors "Throws an error if the object does not support this operation." } ;

HELP: &add
{ $values { "value" object } { "key" object } }
{ $description "Adds a key/value pair to the current object." }
{ $errors "Throws an error if the object does not support this operation." } ;

HELP: &delete
{ $values { "n" "a non-negative integer" } }
{ $description "Deletes the " { $snippet "n" } "th slot from the current object." }
{ $errors "Throws an error if the object does not support this operation." } ;

HELP: &rename
{ $values { "key" object } { "n" "a non-negative integer" } }
{ $description "Changes the key of the " { $snippet "n" } "th slot of the current object." }
{ $errors "Throws an error if the object does not support this operation." } ;

HELP: &back
{ $description "Returns to the previously-inspected object." } ;

{ &back &at &put &add &delete } related-words

HELP: me
{ $var-description "The currently inspected object." } ;
