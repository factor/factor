USING: help.markup help.syntax math strings words ;
IN: effects

ARTICLE: "effect-declaration" "Stack effect declaration"
"It is good practice to declare the stack effects of words using the following syntax:"
{ $code ": sq ( x -- y ) dup * ;" }
"A stack effect declaration is written in parentheses and lists word inputs and outputs, separated by " { $snippet "--" } ". Stack effect declarations are read in using a parsing word:"
{ $subsection POSTPONE: ( }
"Stack elements in a stack effect are ordered so that the top of the stack is on the right side. Each value can be named by a data type or description. The following are some examples of value names:"
{ $table
    { { { $snippet "?" } } "a boolean" }
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
"The stack effect inferencer verifies stack effect comments to ensure the correct number of inputs and outputs is listed. Value names are ignored; only their number matters. An error is thrown if a word's declared stack effect does not match its inferred stack effect."
$nl
"Recursive words must declare a stack effect in order to compile. This includes all generic words, due to how delegation is implemented." ;

ARTICLE: "effects" "Stack effects"
"A " { $emphasis "stack effect declaration" } ", for example " { $snippet "( x y -- z )" } " denotes that an operation takes two inputs, with " { $snippet "y" } " at the top of the stack, and returns one output."
$nl
"Stack effects are first-class, and words for working with them are found in the " { $vocab-link "effects" } " vocabulary."
{ $subsection effect }
{ $subsection effect? }
"Stack effects of words can be declared."
{ $subsection "effect-declaration" }
"Getting a word's declared stack effect:"
{ $subsection stack-effect }
"Converting a stack effect to a string form:"
{ $subsection effect>string }
"Comparing effects:"
{ $subsection effect-height }
{ $subsection effect<= } ;

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
{ $values { "effect" effect } { "string" string } }
{ $description "Turns a stack effect object into a string mnemonic." }
{ $examples
    { $example "USE: effects" "1 2 <effect> effect>string print" "( object -- object object )" }
} ;

HELP: stack-effect
{ $values { "word" word } { "effect/f" "an " { $link effect } " or " { $link f } } }
{ $description "Outputs the stack effect of a word; either a stack effect declared with " { $link POSTPONE: ( } ", or an inferred stack effect (see " { $link "inference" } "." } ;
