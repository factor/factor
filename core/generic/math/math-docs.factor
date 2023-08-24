USING: kernel generic help.markup help.syntax math classes
quotations generic.math.private ;
IN: generic.math

HELP: math-class-max
{ $values { "class1" class } { "class2" class } { "class" class } }
{ $description "Evaluates which math class is the largest." }
{ $examples
  { $example
    "USING: generic.math math kernel prettyprint ;"
    "integer float math-class-max ."
    "float"
  }
} ;

HELP: math-upgrade
{ $values { "class1" class } { "class2" class } { "quot" { $quotation ( n n -- n n ) } } }
{ $description "Outputs a quotation for upgrading numerical types. It takes two numbers on the stack, an instance of " { $snippet "class1" } ", and an instance of " { $snippet "class2" } ", and converts the one with the lower priority to the higher priority type." }
{ $examples { $example "USING: generic.math math kernel prettyprint ;" "fixnum bignum math-upgrade ." "[ [ >bignum ] dip ]" } } ;

HELP: no-math-method
{ $values { "left" object } { "right" object } { "generic" generic } }
{ $description "Throws a " { $link no-math-method } " error." }
{ $error-description "Thrown by generic words using the " { $link math-combination } " method combination if there is no suitable method defined for the two inputs." } ;

HELP: math-method
{ $values { "word" generic } { "class1" class } { "class2" class } { "quot" quotation } }
{ $description "Generates a definition for " { $snippet "word" } " when the two inputs are instances of " { $snippet "class1" } " and " { $snippet "class2" } ", respectively." }
{ $examples { $example "USING: generic.math math prettyprint ;" "\\ + fixnum float math-method ." "[ { fixnum float } declare [ >float ] dip M\\ float + ]" } } ;

HELP: math-class
{ $class-description "The class of subtypes of " { $link number } " which are not " { $link null } "." } ;

HELP: math-combination
{ $values { "word" generic } { "quot" quotation } }
{ $description "Generates a double-dispatching word definition. Only methods defined on numerical classes and " { $link object } " take effect in the math combination. Methods defined on numerical classes are guaranteed to have their two inputs upgraded to the highest priority type of the two."
$nl
"The math method combination is used for binary operators such as " { $link + } " and " { $link * } "."
$nl
"A method can only be added to a generic word using the math combination if the method specializes on one of the below classes, or a union defined over one or more of the below classes:"
{ $code
    "fixnum"
    "bignum"
    "ratio"
    "float"
    "complex"
    "object"
}
"The math combination performs numerical upgrading as described in " { $link "number-protocol" } "." } ;

HELP: math-generic
{ $class-description "The class of generic words using " { $link math-combination } "." } ;
