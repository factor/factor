USING: ui.commands help.markup help.syntax ui.gadgets
ui.gadgets.presentations ui.operations kernel models classes ;
IN: ui.gadgets.lists

HELP: +secondary+
{ $description "A key which may be set in the hashtable passed to " { $link define-operation } ". If set to a true value, this operation becomes the default operation performed when " { $snippet "RET" } " is pressed in a " { $link list } " gadget where the current selection is a presentation matching the operation's predicate." } ;

HELP: list
{ $class-description
    "A list control is backed by a " { $link model } " holding a sequence of objects, and displays as a list of " { $link presentation } " instances of these objects."
    $nl
    "Lists are created by calling " { $link <list> } "."
    { $command-map list "keyboard-navigation" }
} ;

HELP: <list>
{ $values { "hook" { $quotation ( list -- ) } } { "presenter" { $quotation ( object -- label ) } } { "model" model } { "gadget" list } }
{ $description "Creates a new " { $link list } "."
$nl
"The model value must be a sequence. The list displays presentations of elements with labels obtained by applying the " { $snippet "presenter" } " quotation to each object. The " { $snippet "hook" } " quotation is called when a presentation is selected." } ;

HELP: list-value
{ $values { "list" list } { "object" object } }
{ $description "Outputs the currently selected list value." } ;

ARTICLE: "ui.gadgets.lists" "List gadgets"
"The " { $vocab-link "ui.gadgets.lists" } " vocabulary implements lists, which displays a list of presentations (see " { $link "ui.gadgets.presentations" } ")."
{ $subsections
    list
    <list>
    list-value
} ;

ABOUT: "ui.gadgets.lists"
