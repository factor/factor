USING: ui.commands help.markup help.syntax ui.gadgets words
kernel hashtables strings classes quotations sequences
ui.gestures ;
IN: ui.operations

: $operations ( element -- )
    >quotation call( -- obj )
    f operations>commands
    command-map. ;

: $operation ( element -- )
    first +keyboard+ word-prop gesture>string $snippet ;

HELP: +keyboard+
{ $description "A key which may be set in the hashtable passed to " { $link define-operation } ". The value is a gesture." } ;

HELP: +primary+
{ $description "A key which may be set in the hashtable passed to " { $link define-operation } ". If set to a true value, this operation becomes the default operation performed when a presentation matching the operation's predicate is clicked with the mouse." } ;

HELP: operation
{ $description "An abstraction for an operation which may be performed on a presentation."
$nl
"Operations have the following slots:"
{ $list
    { { $snippet "predicate" } " - a quotation with stack effect " { $snippet "( obj -- ? )" } }
    { { $snippet "command" } " - a " { $link word } }
    { { $snippet "translator" } " - a quotation with stack effect " { $snippet "( obj -- newobj )" } ", or " { $link f } }
    { { $snippet "hook" } " - a quotation with stack effect " { $snippet "( obj -- newobj )" } ", or " { $link f } }
    { { $snippet "listener?" } " - a boolean" }
} } ;

HELP: operation-gesture
{ $values { "operation" operation } { "gesture" "a gesture or " { $link f } } }
{ $description "Outputs the keyboard gesture associated with the operation." } ;

HELP: operations
{ $var-description "Global variable holding a vector of " { $link operation } " instances. New operations can be added with " { $link define-operation } "." } ;

HELP: object-operations
{ $values { "obj" object } { "operations" "a sequence of " { $link operation } " instances" } }
{ $description "Outputs a sequence of operations applicable to the given object, by testing each defined operation's " { $snippet "predicate" } " quotation in turn." } ;

HELP: primary-operation
{ $values { "obj" object } { "operation" { $maybe operation } } }
{ $description "Outputs the operation which should be invoked when a presentation of " { $snippet "obj" } " is clicked." } ;

HELP: secondary-operation
{ $values { "obj" object } { "operation" { $maybe operation } } }
{ $description "Outputs the operation which should be invoked when a " { $snippet "RET" } " is pressed while a presentation of " { $snippet "obj" } " is selected in a list." } ;

HELP: define-operation
{ $values { "pred" { $quotation "( obj -- ? )" } } { "command" word } { "flags" hashtable } }
{ $description "Defines an operation on objects matching the predicate. The hashtable can contain the following keys:"
    { $list
        { { $link +listener+ } " - if set to a true value, the operation will run in the listener" }
        { { $link +description+ } " - can be set to a string description of the operation" }
        { { $link +primary+ } " - if set to a true value, the operation will be output by " { $link primary-operation } " when applied to an object satisfying the predicate" }
        { { $link +secondary+ } " - if set to a true value, the operation will be output by " { $link secondary-operation } " when applied to an object satisfying the predicate" }
        { { $link +keyboard+ } " - can be set to a keyboard gesture; the guesture will be used by " { $link define-operation-map } }
    }
} ;

HELP: define-operation-map
{ $values { "class" "a class word" } { "group" string } { "blurb" { $maybe string } } { "object" object } { "translator" { $quotation "( obj -- newobj )" } ", or " { $link f } } }
{ $description "Defines a command map named " { $snippet "group" } " on " { $snippet "class" } " consisting of operations applicable to " { $snippet "object" } ". The translator quotation is applied to the target gadget, and the result of the translator is passed to the operation." } ;

HELP: $operations
{ $values { "element" "a sequence" } }
{ $description "Converts the element to a quotation and calls it; the resulting quotation must have stack effect " { $snippet "( -- obj )" } ". Prints a list of operations applicable to the object, together with keyboard shortcuts." } ;

HELP: $operation
{ $values { "element" "a sequence containing a single word" } }
{ $description "Prints the keyboard shortcut associated with the word, which must have been previously defined as an operation by a call to " { $link define-operation } "." } ;

ARTICLE: "ui-operations" "Operations"
"Operations are commands performed on presentations."
{ $subsection operation }
{ $subsection define-operation }
{ $subsection primary-operation }
{ $subsection secondary-operation }
{ $subsection define-operation-map }
"When documenting gadgets, operation documentation can be automatically generated:"
{ $subsection $operations }
{ $subsection $operation } ;

ABOUT: "ui-operations"
