USING: help.markup help.syntax math strings words kernel combinators ;
IN: effects

ARTICLE: "effect-declaration" "Stack effect declaration"
"Stack effects of words must be declared, with the exception of words which only push literals on the stack."
$nl
"A stack effect declaration is written in parentheses and lists word inputs and outputs, separated by " { $snippet "--" } ". Here is an example:"
{ $synopsis sq }
"Parameters which are quotations can be declared by suffixing the parameter name with " { $snippet ":" } " and then writing a nested stack effect declaration:"
{ $synopsis while }
"Stack effect declarations are read in using a parsing word:"
{ $subsection POSTPONE: ( }
"Stack elements in a stack effect are ordered so that the top of the stack is on the right side. Each value can be named by a data type or description. The following are some examples of value names:"
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
"The stack effect inferencer verifies stack effect comments to ensure the correct number of inputs and outputs is listed. Value names are ignored; only their number matters. An error is thrown if a word's declared stack effect does not match its inferred stack effect. See " { $link "inference" } "." ;

ARTICLE: "effects" "Stack effects"
"A " { $emphasis "stack effect declaration" } ", for example " { $snippet "( x y -- z )" } " denotes that an operation takes two inputs, with " { $snippet "y" } " at the top of the stack, and returns one output. Stack effects are first-class, and words for working with them are found in the " { $vocab-link "effects" } " vocabulary."
$nl
"Stack effects of words must be declared, and the " { $link "compiler" } " checks that these declarations are correct. Invalid declarations are reported as " { $link "compiler-errors" } ". The " { $link "inference" } " tool can be used to check stack effects interactively."
{ $subsection "effect-declaration" }
"There is a literal syntax for stack objects. It is most often used with " { $link define-declared } ", " { $link call-effect } " and " { $link execute-effect } "."
{ $subsection POSTPONE: (( }
"Getting a word's declared stack effect:"
{ $subsection stack-effect }
"Converting a stack effect to a string form:"
{ $subsection effect>string }
"Comparing effects:"
{ $subsection effect-height }
{ $subsection effect<= }
"The class of stack effects:"
{ $subsection effect }
{ $subsection effect? } ;

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
