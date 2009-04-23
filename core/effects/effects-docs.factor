USING: help.markup help.syntax math strings words kernel combinators ;
IN: effects

ARTICLE: "effects" "Stack effect declarations"
"Word definition words such as " { $link POSTPONE: : } " and " { $link POSTPONE: GENERIC: } " have a " { $emphasis "stack effect declaration" } " as part of their syntax. A stack effect declaration takes the following form:"
{ $code "( input1 input2 ... -- output1 ... )" }
"Stack elements in a stack effect are ordered so that the top of the stack is on the right side. Here is an example:"
{ $synopsis + }
"Parameters which are quotations can be declared by suffixing the parameter name with " { $snippet ":" } " and then writing a nested stack effect declaration:"
{ $synopsis while }
"Only the number of inputs and outputs carries semantic meaning."
$nl
"Nested quotation declaration only has semantic meaning for " { $link POSTPONE: inline } " " { $link POSTPONE: recursive } " words. See " { $link "inference-recursive-combinators" } "."
$nl
"In concatenative code, input and output names are for documentation purposes only and certain conventions have been established to make them more descriptive. For code written with " { $link "locals" } ", stack values are bound to local variables named by the stack effect's input parameters."
$nl
"Inputs and outputs are typically named after some pun on their data type, or a description of the value's purpose if the type is very general. The following are some examples of value names:"
{ $table
    { { { $snippet "?" } } "a boolean" }
    { { { $snippet "<=>" } } { "an ordering sepcifier; see " { $link "order-specifiers" } } }
    { { { $snippet "elt" } } "an object which is an element of a sequence" }
    { { { $snippet "m" } ", " { $snippet "n" } } "an integer" }
    { { { $snippet "obj" } } "an object" }
    { { { $snippet "quot" } } "a quotation" }
    { { { $snippet "seq" } } "a sequence" }
    { { { $snippet "assoc" } } "an associative mapping" }
    { { { $snippet "str" } } "a string" }
    { { { $snippet "x" } ", " { $snippet "y" } ", " { $snippet "z" } } "a number" }
    { { $snippet "loc" } "a screen location specified as a two-element array holding x and y co-ordinates" }
    { { $snippet "dim" } "a screen dimension specified as a two-element array holding width and height values" }
    { { $snippet "*" } "when this symbol appears by itself in the list of outputs, it means the word unconditionally throws an error" }
}
{ $see-also "inference" } ;

ABOUT: "effects"

HELP: effect
{ $class-description "An object representing a stack effect. Holds a sequence of inputs, a sequence of outputs and a flag indicating if an error is thrown unconditionally." } ;

HELP: effect-height
{ $values { "effect" effect } { "n" integer } }
{ $description "Outputs the number of objects added to the data stack by the stack effect. This will be negative if the stack effect only removes objects from the stack." } ;

HELP: effect<=
{ $values { "eff1" effect } { "eff2" effect } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "eff1" } " is substitutable for " { $snippet "eff2" } ". What this means is that both stack effects change the stack height by the same amount, the first takes a smaller or equal number of inputs as the second, and either both or neither one terminate execution by throwing an error." } ;

HELP: effect>string
{ $values { "obj" object } { "str" string } }
{ $description "Turns a stack effect object into a string mnemonic." }
{ $examples
    { $example "USING: effects io ;" "1 2 <effect> effect>string print" "( object -- object object )" }
} ;

HELP: stack-effect
{ $values { "word" word } { "effect/f" { $maybe effect } } }
{ $description "Outputs the stack effect of a word; either a stack effect declared with " { $link POSTPONE: ( } ", or an inferred stack effect (see " { $link "inference" } "." } ;
