USING: help.markup help.syntax math strings words kernel combinators sequences ;
IN: effects

ARTICLE: "effects" "Stack effect declarations"
"Word definition words such as " { $link POSTPONE: : } " and " { $link POSTPONE: GENERIC: } " have a " { $emphasis "stack effect declaration" } " as part of their syntax. A stack effect declaration takes the following form:"
{ $code "( input1 input2 ... -- output1 ... )" }
"Stack elements in a stack effect are ordered so that the top of the stack is on the right side. Here is an example:"
{ $synopsis + }
"Parameters which are quotations can be declared by suffixing the parameter name with " { $snippet ":" } " and then writing a nested stack effect declaration. If the number of inputs or outputs depends on the stack effects of quotation parameters, " { $link "effects-variables" } " can be used to declare this:"
{ $synopsis while }
"For words that are not " { $link POSTPONE: inline } ", only the number of inputs and outputs carries semantic meaning, and effect variables are ignored. However, nested quotation declarations are enforced for inline words. Nested quotation declarations are optional for non-recursive inline combinators and only provide better error messages. However, quotation inputs to " { $link POSTPONE: recursive } " combinators must have an effect declared. See " { $link "inference-recursive-combinators" } "."
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
    { { $snippet ".." } { "indicates " { $link "effects-variables" } ". only valid as the first input or first output" } }
}
{ $see-also "inference" } ;

ARTICLE: "effects-variables" "Stack effect variables"
{ $link POSTPONE: inline } " combinators can have variable stack effects, depending on the effect of the quotation they call. For example, while " { $link each } " inputs elements of its sequence to its quotation, the quotation can also manipulate values on the stack below the element, as long as it leaves the same number of elements on the stack. This ability is used to implement " { $link reduce } " in terms of " { $snippet "each" } ". This variable stack effect is indicated by starting the list of inputs and outputs with a name starting with " { $snippet ".." } ":"
{ $synopsis each }
"In combinators with multiple quotation inputs, the number of inputs or outputs represented by a particular " { $snippet ".." } " name must match. For example, the predicate for a " { $link while } " loop can take an arbitrary number of inputs and leave an arbitrary number of outputs on the stack in addition to the predicate result; however, for the loop to leave the stack balanced, the body of the while loop must consume all of the predicate's outputs and leave a number of its own outputs equal to the initial number of stack values before the predicate was called. This is expressed with the following stack effect:"
{ $synopsis while }
"Stack effect variables can only occur as the first input or first output of a stack effect; names starting in " { $snippet ".." } " cause a syntax error if they occur elsewhere in the effect. For words that are not " { $link POSTPONE: inline } ", effect variables are currently ignored by the stack checker." ;

ABOUT: "effects"

HELP: effect
{ $class-description "An object representing a stack effect. Holds a sequence of inputs, a sequence of outputs and a flag indicating if an error is thrown unconditionally." } ;

HELP: effect-height
{ $values { "effect" effect } { "n" integer } }
{ $description "Outputs the number of objects added to the data stack by the stack effect. This will be negative if the stack effect only removes objects from the stack." } ;

HELP: effect<=
{ $values { "effect1" effect } { "effect2" effect } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "effect1" } " is substitutable for " { $snippet "effect2" } ". What this means is that both stack effects change the stack height by the same amount, the first takes a smaller or equal number of inputs as the second, and either both or neither one terminate execution by throwing an error." } ;

HELP: effect=
{ $values { "effect1" effect } { "effect2" effect } { "?" "a boolean" } }
{ $description "Tests if " { $snippet "effect1" } " and " { $snippet "effect2" } " represent the same stack transformation, without looking parameter names." }
{ $examples
  { $example "USING: effects prettyprint ;" "(( a -- b )) (( x -- y )) effect= ." "t" }
} ;

HELP: effect>string
{ $values { "obj" object } { "str" string } }
{ $description "Turns a stack effect object into a string mnemonic." }
{ $examples
    { $example "USING: effects io ;" "{ \"x\" } { \"y\" \"z\" } <effect> effect>string print" "( x -- y z )" }
} ;

HELP: stack-effect
{ $values { "word" word } { "effect/f" { $maybe effect } } }
{ $description "Outputs the stack effect of a word; either a stack effect declared with " { $link POSTPONE: ( } ", or an inferred stack effect (see " { $link "inference" } "." } ;
