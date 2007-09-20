USING: help.markup help.syntax kernel classes io io.styles ;
IN: inspector

ARTICLE: "inspector" "The inspector"
"The inspector displays a tabular view of an object and adds navigation and editing features. Inspector words are found in the " { $vocab-link "inspector" } " vocabulary."
$nl
"Starting the inspector:"
{ $subsection inspect }
"The inspector supports a number of commands which operate on the most recently inspected object:"
{ $subsection &push }
{ $subsection &back }
{ $subsection &at }
{ $subsection &put }
{ $subsection &add }
{ $subsection &rename }
{ $subsection &delete }
"A variable holding the current object:"
{ $subsection me }
"A variable holding inspector history:"
{ $subsection inspector-stack }
"A customization hook:"
{ $subsection inspector-hook }
"A description of an object can be printed without starting the inspector:"
{ $subsection describe }
{ $subsection describe* }
"A word for getting very brief descriptions of words and general objects:"
{ $subsection summary } ;

ABOUT: "inspector"

HELP: value-editor
{ $values { "path" "a sequence of keys" } }
{ $description "Prettyprints the value at a path, and if the output stream supports it, a graphical gadget for editing the object." }
{ $notes "To learn about paths, see " { $link "mirrors" } "." } ;

{ presented-path presented-printer value-editor } related-words

HELP: describe
{ $values { "obj" object } }
{ $description "Print a tabular overview of the object."
$nl
"For sequences and hashtables, this outputs the entries of the collection. For all other object types, slot names and values are shown." }
{ $examples { $code "global describe" } } ;

HELP: describe*
{ $values { "obj" object } { "flags" "an assoc" } }
{ $description "Print a tabular overview of the object."
$nl
"The assoc can contain any of the following keys:"
{ $list
    { { $link +number-rows+ } " - if set to a true value, every row of output will begin with a row number." }
    { { $link +editable+ } " - if set to a true value, keys and values will be editable in place, if the output stream supports it." }
    { { $link +sequence+ } " - if set to a true value, keys will not be printed, only values." }
} }
{ $notes "This word is a factor of " { $link describe } " and " { $link inspect } "." } ;

HELP: summary
{ $values { "object" object } { "string" "a string" } }
{ $contract "Outputs a brief description of the object." } ;

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

HELP: inspector-hook
{ $var-description "A quotation with stack effect " { $snippet "( obj -- )" } ", called by the inspector to display an overview of an object."
$nl
"The default implementation calls " { $link describe } " which outputs on the " { $link stdio } " stream, but the graphical listener sets this variable so that calling " { $link inspect } " in the UI opens the graphical inspector." } ;
