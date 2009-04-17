USING: help.markup help.syntax kernel io system prettyprint continuations ;
IN: listener

ARTICLE: "listener-watch" "Watching variables in the listener"
"The listener prints the concepts of the data and retain stacks after every expression. It can also print values of dynamic variables which are added to a watch list:"
{ $subsection visible-vars }
"To add or remove a single variable:"
{ $subsection show-var }
{ $subsection hide-var }
"To add and remove multiple variables:"
{ $subsection show-vars }
{ $subsection hide-vars }
"Hiding all visible variables:"
{ $subsection hide-all-vars } ;

HELP: show-var
{ $values { "var" "a variable name" } }
{ $description "Adds a variable to the watch list; its value will be printed by the listener after every expression." } ;

HELP: show-vars
{ $values { "seq" "a sequence of variable names" } }
{ $description "Adds a sequence of variables to the watch list; their values will be printed by the listener after every expression." } ;

HELP: hide-var
{ $values { "var" "a variable name" } }
{ $description "Removes a variable from the watch list." } ;

HELP: hide-vars
{ $values { "seq" "a sequence of variable names" } }
{ $description "Removes a sequence of variables from the watch list." } ;

HELP: hide-all-vars
{ $description "Removes all variables from the watch list." } ;

ARTICLE: "listener" "The listener"
"The listener evaluates Factor expressions read from a stream. The listener is the primary interface to the Factor runtime. Typically, you write Factor code in a text editor, then load it using the listener and test it."
$nl
"The classical first program can be run in the listener:"
{ $example "\"Hello, world\" print" "Hello, world" }
"Multi-line expressions are supported:"
{ $example "{ 1 2 3 } [\n    .\n] each" "1\n2\n3" }
"The listener knows when to expect more input by looking at the height of the stack. Parsing words such as " { $link POSTPONE: { } " leave elements on the parser stack, and corresponding words such as " { $link POSTPONE: } } " pop them."
{ $subsection "listener-watch" }
"To start a nested listener:"
{ $subsection listener }
"To exit the listener, invoke the " { $link return } " word."
$nl
"Multi-line quotations can be read independently of the rest of the listener:"
{ $subsection read-quot } ;

ABOUT: "listener"

HELP: read-quot
{ $values { "quot/f" "a parsed quotation, or " { $link f } " indicating end of file" } }
{ $description "Reads a Factor expression which possibly spans more than one line from " { $link input-stream } ". Additional lines of input are read while the parser stack height is greater than one. Since structural parsing words push partial quotations on the stack, this will keep on reading input until all delimited parsing words are terminated." } ;

HELP: listener
{ $description "Prompts for expressions on " { $link input-stream } " and evaluates them until end of file is reached." } ;
