! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays effects help.markup help.syntax locals math quotations words ;
IN: typed

HELP: TYPED:
{ $syntax
"TYPED: word ( a b: class ... -- x: class y ... )
    body ;" }
{ $description "Like " { $link POSTPONE: : } ", defines a new word with a given stack effect in the current vocabulary. The inputs and outputs of the stack effect can additionally be given type annotations in the form " { $snippet "a: class" } ". When invoked, the word will attempt to coerce its input values to the declared input types before executing the body, throwing an " { $link input-mismatch-error } " if the types cannot be made to match. The word will likewise attempt to coerce its outputs to their declared types and throw an " { $link output-mismatch-error } " if the types cannot be made to match." }
{ $notes "The aforementioned type conversions and checks are structured in such a way that they will be eliminated by the compiler if it can statically determine that the types of the inputs at a call site or of the outputs in the word definition are always correct." }
{ $examples
"A version of " { $link + } " specialized for floats, converting other real number types:"
{ $example
"USING: math prettyprint typed ;
IN: scratchpad

TYPED: add-floats ( a: float b: float -- c: float )
    + ;

1 2+1/2 add-floats ."
"3.5" } } ;

HELP: TYPED::
{ $syntax
"TYPED:: word ( a b: class ... -- x: class y ... )
    body ;" }
{ $description "Like " { $link POSTPONE: :: } ", defines a new word with named inputs in the current vocabulary. The inputs and outputs of the stack effect can additionally be given type annotations in the form " { $snippet "a: class" } ". When invoked, the word will attempt to coerce its input values to the declared input types before executing the body, throwing an " { $link input-mismatch-error } " if the types cannot be made to match. The word will likewise attempt to coerce its outputs to their declared types and throw an " { $link output-mismatch-error } " if the types cannot be made to match." }
{ $notes "The aforementioned type conversions and checks are structured in such a way that they will be eliminated by the compiler if it can statically determine that the types of the inputs at a call site or of the outputs in the word definition are always correct." }
{ $examples
"A version of the quadratic formula specialized for floats, converting other real number types:"
{ $example
"USING: kernel math math.libm prettyprint typed ;
IN: scratchpad
<<
TYPED:: quadratic-roots ( a: float b: float c: float -- q1: float q2: float )
    b neg
    b sq 4.0 a * c * - fsqrt
    [ + ] [ - ] 2bi
    [ 2.0 a * / ] bi@ ;
>>
1 0 -9/4 quadratic-roots [ . ] bi@"
"1.5
-1.5" } } ;

HELP: define-typed
{ $values { "word" word } { "def" quotation } { "effect" effect } }
{ $description "The runtime equivalent to " { $link POSTPONE: TYPED: } " and " { $link POSTPONE: TYPED:: } ". Defines " { $snippet "word" } " with " { $snippet "def" } " as its body and " { $snippet "effect" } " as its stack effect. The word will check that its inputs and outputs correspond to the types specified in " { $snippet "effect" } " as described in the " { $link POSTPONE: TYPED: } " documentation." } ;

HELP: input-mismatch-error
{ $values { "word" word } { "expected-types" array } }
{ $class-description "Errors of this class are raised at runtime by " { $link POSTPONE: TYPED: } " words when they are invoked with input values that do not match their type annotations. The " { $snippet "word" } " slot indicates the word that failed, and the " { $snippet "expected-types" } " slot specifies the input types expected." } ;

HELP: output-mismatch-error
{ $values { "word" word } { "expected-types" array } }
{ $class-description "Errors of this class are raised at runtime by " { $link POSTPONE: TYPED: } " words when they attempt to output values that do not match their type annotations. The " { $snippet "word" } " slot indicates the word that failed, and the " { $snippet "expected-types" } " slot specifies the output types expected." } ;

{ POSTPONE: TYPED: POSTPONE: TYPED:: define-typed } related-words

ARTICLE: "typed" "Strongly-typed word definitions"
"The Factor compiler supports advanced compiler optimizations that take advantage of the type information it can glean from source code. The " { $vocab-link "typed" } " vocabulary provides syntax that allows words to provide checked type information about their inputs and outputs and improve the performance of compiled code."
$nl
"Parameters and return values of typed words where the type is declared to be a " { $link POSTPONE: final } " tuple class with all slots " { $link read-only } " are passed by value."
{ $subsections
    POSTPONE: TYPED:
    POSTPONE: TYPED::
}
"Defining typed words at run time:"
{ $subsections
    define-typed
}
"Errors:"
{ $subsections
    input-mismatch-error
    output-mismatch-error
} ;

ABOUT: "typed"
