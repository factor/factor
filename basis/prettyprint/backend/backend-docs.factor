USING: help.markup help.syntax kernel math prettyprint.config
prettyprint.custom sequences strings words ;
IN: prettyprint.backend

ABOUT: "prettyprint-extension"

HELP: pprint-word
{ $values { "word" word } }
{ $description "Adds a text section for the word. Unlike the " { $link word } " method of " { $link pprint* } ", this does not add a " { $link POSTPONE: POSTPONE: } " prefix to parsing words." }
$prettyprinting-note ;

HELP: ch>ascii-escape
{ $values { "ch" "a character" } { "ch'" "a character" } { "?" boolean } }
{ $description "Converts a character to an escape code." } ;

HELP: unparse-ch
{ $values { "ch" "a character" } }
{ $description "Adds the character to the sequence being constructed (see " { $link "namespaces-make" } "). If the character can appear in a string literal, it is added directly, otherwise an escape code is added." } ;

HELP: do-string-limit
{ $values { "str" string } { "trimmed" "a possibly trimmed string" } }
{ $description "If " { $link string-limit? } " is on, trims the string such that it does not exceed the margin, appending \"...\" if trimming took place." } ;

HELP: pprint-string
{ $values { "obj" object } { "str" string } { "prefix" string } { "suffix" string } }
{ $description "Outputs a text section consisting of the prefix, the string, and a final quote (\")." }
$prettyprinting-note ;

HELP: nesting-limit?
{ $values { "?" boolean } }
{ $description "Tests if the " { $link nesting-limit } " has been reached." }
$prettyprinting-note ;

HELP: check-recursion
{ $values { "obj" object } { "quot" { $quotation ( obj -- ) } } }
{ $description "If the object is already being printed, that is, if the prettyprinter has encountered a cycle in the object graph, or if the maximum nesting depth has been reached, outputs a dummy string. Otherwise applies the quotation to the object." }
$prettyprinting-note ;

HELP: do-length-limit
{ $values { "seq" sequence } { "trimmed" "a trimmed sequence" } { "n/f" { $maybe integer } } }
{ $description "If the " { $link length-limit } " is set and the sequence length exceeds this limit, trims the sequence and outputs a the number of elements which were chopped off the end. Otherwise outputs " { $link f } "." }
$prettyprinting-note ;

HELP: pprint-elements
{ $values { "seq" sequence } }
{ $description "Prettyprints the elements of a sequence, trimming the sequence to " { $link length-limit } " if necessary." }
$prettyprinting-note ;
