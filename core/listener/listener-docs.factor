USING: help.markup help.syntax kernel io system prettyprint ;
IN: listener

ARTICLE: "listener" "The listener"
"The listener evaluates Factor expressions read from a stream. The listener is the primary interface to the Factor runtime. Typically, you write Factor code in a text editor, then load it using the listener and test it."
$nl
"The classical first program can be run in the listener:"
{ $example "\"Hello, world\" print" "Hello, world" }
"Multi-line phrases are supported:"
{ $example "{ 1 2 3 } [\n    .\n] each" "1\n2\n3" }
"The listener knows when to expect more input by looking at the height of the stack. Parsing words such as " { $link POSTPONE: { } " leave elements on the parser stack, and corresponding words such as " { $link POSTPONE: } } " pop them."
$nl
"A very common operation is to inspect the contents of the data stack in the listener:"
{ $subsection .s }
"Note that calls to " { $link .s } " can also be included inside words as a debugging aid, however a more convenient way to achieve this is to use the annotation facility. See " { $link "tools.annotations" } "."
$nl
"You can start a nested listener or exit a listener using the following words:"
{ $subsection listener }
{ $subsection bye }
"The following variables can be rebound inside a nested scope to customize the behavior of a listener; this can be done to create a development tool with a custom interaction loop:"
{ $subsection listener-hook }
"Finally, the multi-line expression reading word can be used independently of the rest of the listener:"
{ $subsection parse-interactive } ;

ABOUT: "listener"

HELP: quit-flag
{ $var-description "Variable set to true by " { $link bye } " word; it forces the next iteration of the " { $link listener } " loop to end." } ;

HELP: listener-hook
{ $var-description "Variable holding a quotation called by the listener before reading an input expression. The UI sets this variable to a quotation which updates the stack display in a listener gadget." } ;

HELP: parse-interactive
{ $values { "stream" "an input stream" } { "quot/f" "a parsed quotation, or " { $link f } " indicating end of file" } }
{ $description "Reads a Factor expression from the stream, possibly spanning more than line. Additional lines of input are read while the parser stack height is greater than one. Since structural parsing words push partial quotations on the stack, this will keep on reading input until all delimited parsing words are terminated." } ;

HELP: listen
{ $description "Prompts for an expression on the " { $link stdio } " stream and evaluates it. On end of file, " { $link quit-flag } " is set to terminate the listener loop." }
{ $errors "If the expression input by the user throws an error, the error is printed to the " { $link stdio } " stream and the word returns normally." } ;

HELP: print-banner
{ $description "Print Factor version, operating system, and CPU architecture." } ;

HELP: listener
{ $description "Prompts for expressions on the " { $link stdio } " stream and evaluates them until end of file is reached." } ;

HELP: bye
{ $description "Exits the current listener." }
{ $notes "This word is for interactive use only. To exit the Factor runtime, use " { $link exit } "." } ;
