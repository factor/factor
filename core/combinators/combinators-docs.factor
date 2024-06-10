USING: arrays assocs combinators.private effects
generic.standard help.markup help.syntax kernel quotations
generalizations
sequences sequences.private words ;
IN: combinators

ARTICLE: "cleave-combinators" "Cleave combinators"
"The cleave combinators apply multiple quotations to a single value or set of values."
$nl
"Two quotations:"
{ $subsections
    bi
    2bi
    3bi
}
"Three quotations:"
{ $subsections
    tri
    2tri
    3tri
}
"An array of quotations:"
{ $subsections
    cleave
    2cleave
    3cleave
    4cleave
}
"Cleave combinators provide a more readable alternative to repeated applications of the " { $link keep } " combinators. The following example using " { $link keep } ":"
{ $code
    "[ 1 + ] keep"
    "[ 1 - ] keep"
    "2 *"
}
"can be more clearly written using " { $link tri } ":"
{ $code
    "[ 1 + ]"
    "[ 1 - ]"
    "[ 2 * ] tri"
} ;

ARTICLE: "spread-combinators" "Spread combinators"
"The spread combinators apply multiple quotations to multiple values. The asterisk (" { $snippet "*" } ") suffixed to these words' names signifies that they are spread combinators."
$nl
"Two quotations:"
{ $subsections bi* 2bi* }
"Three quotations:"
{ $subsections tri* 2tri* }
"An array of quotations:"
{ $subsections spread }
"Spread combinators provide a more readable alternative to repeated applications of the " { $link dip } " combinators. The following example using " { $link dip } ":"
{ $code
    "[ [ 1 + ] dip 1 - ] dip 2 *"
}
"can be more clearly written using " { $link tri* } ":"
{ $code
    "[ 1 + ] [ 1 - ] [ 2 * ] tri*"
}
"A generalization of the above combinators to any number of quotations can be found in " { $link "combinators" } "." ;

ARTICLE: "apply-combinators" "Apply combinators"
"The apply combinators apply a single quotation to multiple values. The at sign (" { $snippet "@" } ") suffixed to these words' names signifies that they are apply combinators."
{ $subsections bi@ 2bi@ tri@ 2tri@ }
"A pair of condition words built from " { $link bi@ } " to test two values:"
{ $subsections both? either? }
"All of the apply combinators are equivalent to using the corresponding " { $link "spread-combinators" } " with the same quotation supplied for every value." ;

ARTICLE: "dip-keep-combinators" "Preserving combinators"
"Sometimes it is necessary to temporarily hide values on the datastack. The " { $snippet "dip" } " combinators invoke the quotation at the top of the stack, hiding some number of values:"
{ $subsections dip 2dip 3dip 4dip }
"The " { $snippet "keep" } " combinators invoke a quotation and restore some number of values to the top of the stack:"
{ $subsections keep 2keep 3keep } ;

ARTICLE: "curried-dataflow" "Curried dataflow combinators"
"Curried cleave combinators:"
{ $subsections bi-curry tri-curry }
"Curried spread combinators:"
{ $subsections bi-curry* tri-curry* }
"Curried apply combinators:"
{ $subsections bi-curry@ tri-curry@ }
{ $see-also "dataflow-combinators" } ;

ARTICLE: "compositional-examples" "Examples of compositional combinator usage"
"Consider printing the same message ten times:"
{ $code ": print-10 ( -- ) 10 [ \"Hello, world.\" print ] times ;" }
"if we wanted to abstract out the message into a parameter, we could keep it on the stack between iterations:"
{ $code ": print-10 ( message -- ) 10 [ dup print ] times drop ;" }
"However, keeping loop-invariant values on the stack doesn't always work out nicely. For example, a word to subtract a value from each element of a sequence:"
{ $code ": subtract-n ( seq n -- seq' ) swap [ over - ] map nip ;" }
"Three shuffle words are required to pass the value around. Instead, the loop-invariant value can be partially applied to a quotation using " { $link curry } ", yielding a new quotation that is passed to " { $link map } ":"
{ $example
  "USING: sequences prettyprint ;"
  ": subtract-n ( seq n -- seq' ) [ - ] curry map ;"
  "{ 10 20 30 } 5 subtract-n ."
  "{ 5 15 25 }"
}
"Now consider the word that is dual to the one above; instead of subtracting " { $snippet "n" } " from each stack element, it subtracts each element from " { $snippet "n" } "."
$nl
"One way to write this is with a pair of " { $link swap } "s:"
{ $code ": n-subtract ( n seq -- seq' ) swap [ swap - ] curry map ;" }
"Since this pattern comes up often, " { $link with } " encapsulates it:"
{ $example
  ": n-subtract ( n seq -- seq' ) [ - ] with map ;"
  "30 { 10 20 30 } n-subtract ."
  "{ 20 10 0 }"
}
{ $see-also "fry.examples" } ;

ARTICLE: "compositional-combinators" "Compositional combinators"
"Certain combinators transform quotations to produce a new quotation."
{ $subsections "compositional-examples" }
"Fundamental operations:"
{ $subsections curry compose }
"Derived operations:"
{ $subsections 2curry 3curry with prepose }
"These operations run in constant time, and in many cases are optimized out altogether by the " { $link "compiler" } ". " { $link "fry" } " are an abstraction built on top of these operations, and code that uses this abstraction is often clearer than direct calls to the above words."
$nl
"Curried dataflow combinators can be used to build more complex dataflow by combining cleave, spread and apply patterns in various ways."
{ $subsections "curried-dataflow" }
"Quotations also implement the sequence protocol, and can be manipulated with sequence words; see " { $link "quotations" } ". However, such runtime quotation manipulation will not be optimized by the optimizing compiler." ;

ARTICLE: "booleans" "Booleans"
"In Factor, any object that is not " { $link f } " has a true value, and " { $link f } " has a false value. The " { $link t } " object is the canonical true value."
{ $subsections f t }
"A union class of the above:"
{ $subsections boolean }
"There are some logical operations on booleans:"
{ $subsections
    >boolean
    not
    and
    or
    xor
}
"Boolean values are most frequently used for " { $link "conditionals" } "."
{ $heading "The f object and f class" }
"The " { $link f } " object is the unique instance of the " { $link f } " class; the two are distinct objects. The latter is also a parsing word which adds the " { $link f } " object to the parse tree at parse time. To refer to the class itself you must use " { $link POSTPONE: POSTPONE: } " or " { $link POSTPONE: \ } " to prevent the parsing word from executing."
$nl
"Here is the " { $link f } " object:"
{ $example "f ." "f" }
"Here is the " { $link f } " class:"
{ $example "\\ f ." "POSTPONE: f" }
"They are not equal:"
{ $example "f \\ f = ." "f" }
"Here is an array containing the " { $link f } " object:"
{ $example "{ f } ." "{ f }" }
"Here is an array containing the " { $link f } " class:"
{ $example "{ POSTPONE: f } ." "{ POSTPONE: f }" }
"The " { $link f } " object is an instance of the " { $link f } " class:"
{ $example "USE: classes" "f class-of ." "POSTPONE: f" }
"The " { $link f } " class is an instance of " { $link word } ":"
{ $example "USE: classes" "\\ f class-of ." "word" }
"On the other hand, " { $link t } " is just a word, and there is no class which it is a unique instance of."
{ $example "t \\ t eq? ." "t" }
"Many words which search collections confuse the case of no element being present with an element being found equal to " { $link f } ". If this distinction is important, there is usually an alternative word which can be used; for example, compare " { $link at } " with " { $link at* } "." ;

ARTICLE: "conditionals-boolean-equivalence" "Expressing conditionals with boolean logic"
"Certain simple conditional forms can be expressed in a simpler manner using boolean logic."
$nl
"The following three lines are equivalent:"
{ $code "[ drop f ] unless" "swap and" "and*" }
"The following three lines are equivalent:"
{ $code "or? [ ] [ ] ?if" "swap or" "or*" }
"The following two lines are equivalent, where " { $snippet "L" } " is a literal:"
{ $code "[ L ] unless*" "L or" } ;

ARTICLE: "conditionals" "Conditional combinators"
"The basic conditionals:"
{ $subsections if when unless }
"Forms abstracting a common stack shuffle pattern:"
{ $subsections if* when* unless* }
"Another form abstracting a common stack shuffle pattern:"
{ $subsections ?if ?when ?unless }
"Sometimes instead of branching, you just need to pick one of two values:"
{ $subsections ? }
"Two combinators which abstract out nested chains of " { $link if } ":"
{ $subsections cond case }
{ $subsections "conditionals-boolean-equivalence" }
{ $see-also "booleans" "bitwise-arithmetic" both? either? } ;

ARTICLE: "dataflow-combinators" "Dataflow combinators"
"Dataflow combinators express common dataflow patterns such as performing a operation while preserving its inputs, applying multiple operations to a single value, applying a set of operations to a set of values, or applying a single operation to multiple values."
{ $subsections
    "dip-keep-combinators"
    "cleave-combinators"
    "spread-combinators"
    "apply-combinators"
}
"More intricate dataflow can be constructed by composing " { $link "curried-dataflow" } "." ;

ARTICLE: "combinators-quot" "Quotation construction utilities"
"Some words for creating quotations which can be useful for implementing method combinations and compiler transforms:"
{ $subsections cond>quot case>quot alist>quot } ;

ARTICLE: "call-unsafe" "Unsafe combinators"
"Unsafe calls declare an effect statically without any runtime checking:"
{ $subsections call-effect-unsafe execute-effect-unsafe } ;

ARTICLE: "call" "Fundamental combinators"
"The most basic combinators are those that take either a quotation or word, and invoke it immediately. There are two sets of these fundamental combinators. They differ in whether the compiler is expected to determine the stack effect of the expression at compile time or the stack effect is declared and verified at run time."
$nl
{ $heading "Compile-time checked combinators" }
"With these combinators, the compiler attempts to determine the stack effect of the expression at compile time, rejecting the program if the effect cannot be determined. See " { $link "inference-combinators" } "."
{ $subsections call execute }
{ $heading "Run-time checked combinators" }
"With these combinators, the stack effect of the expression is checked at run time."
{ $subsections POSTPONE: call( POSTPONE: execute( }
"Note that the opening parenthesis is actually part of the word name for " { $snippet "call(" } " and " { $snippet "execute(" } "; they are parsing words, and they read a stack effect until the corresponding closing parenthesis. The underlying words are a bit more verbose, but they can be given non-constant stack effects:"
{ $subsections call-effect execute-effect }
{ $heading "Unchecked combinators" }
{ $subsections "call-unsafe" }
{ $see-also "effects" "inference" } ;

ARTICLE: "combinators-connection" "Combinator Connections" 
"Factor provides several convenient implementations of combinators, specifically for simpler " 
"cases with few stack arguments. This page will document combinators that are "
"similar in application, but may be different in effect."
{ $list
  { { $link map } " generalizes " { $link call } " over " { $link sequence } "s of objects." }
  { { $link napply } " generalizes " { $link bi@ } " and " { $link tri@ }
    " for a number of objects on the stack." }
  { { $link cleave } " generalizes " { $link bi } " and " { $link tri }
    " for equal numbers of quotations and objects on the stack." }
  { { $link spread } " generalizes " { $link  bi* } " and "  { $link tri* } " "
    "for performing a set of operations that ignore the top n values of the stack, keeping "
    "them as is." }  
}
;

ARTICLE: "combinators" "Combinators"
"A central concept in Factor is that of a " { $emphasis "combinator" } ", which is a word taking code as input."
{ $subsections
    "call"
    "dataflow-combinators"
    "conditionals"
    "looping-combinators"
    "compositional-combinators"
    "combinators.short-circuit"
    "combinators.smart"
    "combinators-quot"
    "generalizations"
    "combinators-connection"
}
"More combinators are defined for working on data structures, such as " { $link "sequences-combinators" } " and " { $link "assocs-combinators" } "."
{ $see-also "quotations" } ;

ABOUT: "combinators"

HELP: call-effect
{ $values { "quot" quotation } { "effect" effect } }
{ $description "Given a quotation and a stack effect, calls the quotation, asserting at runtime that it has the given stack effect. This is a macro which expands given a literal effect parameter, and an arbitrary quotation which is not required at compile time." }
{ $examples
  "The following two lines are equivalent:"
  { $code
    "call( a b -- c )"
    "( a b -- c ) call-effect"
  }
} ;

HELP: execute-effect
{ $values { "word" word } { "effect" effect } }
{ $description "Given a word and a stack effect, executes the word, asserting at runtime that it has the given stack effect. This is a macro which expands given a literal effect parameter, and an arbitrary word which is not required at compile time." }
{ $examples
  "The following two lines are equivalent:"
  { $code
    "execute( a b -- c )"
    "( a b -- c ) execute-effect"
  }
} ;

HELP: execute-effect-unsafe
{ $values { "word" word } { "effect" effect } }
{ $description "Given a word and a stack effect, executes the word, blindly declaring at runtime that it has the given stack effect. This is a macro which expands given a literal effect parameter, and an arbitrary word which is not required at compile time." }
{ $warning "If the word being executed has an incorrect stack effect, undefined behavior will result. User code should use " { $link POSTPONE: execute( } " instead." } ;

{ call-effect call-effect-unsafe execute-effect execute-effect-unsafe } related-words

HELP: cleave
{ $values { "x" object } { "seq" "a sequence of quotations with stack effect " { $snippet "( x -- ... )" } } }
{ $description "Applies each quotation to the object in turn." }
{ $examples
    "The " { $link bi } " combinator takes one value and two quotations; the " { $link tri } " combinator takes one value and three quotations. The " { $link cleave } " combinator takes one value and any number of quotations, and is essentially equivalent to a chain of " { $link keep } " forms:"
    { $code
        "! Equivalent"
        "{ [ p ] [ q ] [ r ] [ s ] } cleave"
        "[ p ] keep [ q ] keep [ r ] keep s"
    }
} ;

HELP: 2cleave
{ $values { "x" object } { "y" object }
          { "seq" "a sequence of quotations with stack effect " { $snippet "( x y -- ... )" } } }
{ $description "Applies each quotation to the two objects in turn." } ;

HELP: 3cleave
{ $values { "x" object } { "y" object } { "z" object }
          { "seq" "a sequence of quotations with stack effect " { $snippet "( x y z -- ... )" } } }
{ $description "Applies each quotation to the three objects in turn." } ;

{ bi tri cleave } related-words

HELP: spread
{ $values { "objs..." "objects" } { "seq" "a sequence of quotations with stack effect " { $snippet "( x -- ... )" } } }
{ $description "Applies each quotation to the object in turn." }
{ $examples
    "The " { $link bi* } " combinator takes two values and two quotations; the " { $link tri* } " combinator takes three values and three quotations. The " { $link spread } " combinator takes " { $snippet "n" } " values and " { $snippet "n" } " quotations, where " { $snippet "n" } " is the length of the input sequence, and is essentially equivalent to a nested series of " { $link dip } "s:"
    { $code
        "! Equivalent"
        "{ [ p ] [ q ] [ r ] [ s ] } spread"
        "[ [ [ p ] dip q ] dip r ] dip s"
    }
} ;

{ bi* tri* spread } related-words

HELP: to-fixed-point
{ $values { "object" object } { "quot" { $quotation ( ... object(n) -- ... object(n+1) ) } } { "object(n)" object } }
{ $description "Applies the quotation repeatedly with " { $snippet "object" } " as the initial input until the output of the quotation equals the input." }
{ $examples
    { $example
        "USING: combinators kernel math prettyprint sequences ;"
        "IN: scratchpad"
        ": flatten ( sequence -- sequence' )"
        "    \"flatten\" over index"
        "    [ [ 1 + swap nth ] [ nip dup 2 + ] [ drop ] 2tri replace-slice ] when* ;"
        ""
        "{ \"flatten\" { 1 { 2 3 } \"flatten\" { 4 5 } { 6 } } } [ flatten ] to-fixed-point ."
        "{ 1 { 2 3 } 4 5 { 6 } }"
    }
} ;

HELP: alist>quot
{ $values { "default" quotation } { "assoc" "a sequence of quotation pairs" } { "quot" "a new quotation" } }
{ $description "Constructs a quotation which calls the first quotation in each pair of " { $snippet "assoc" } " until one of them outputs a true value, and then calls the second quotation in the corresponding pair. Quotations are called in reverse order, and if no quotation outputs a true value then " { $snippet "default" } " is called." }
{ $notes "This word is used to implement compile-time behavior for " { $link cond } ", and it is also used by the generic word system. Note that unlike " { $link cond } ", the constructed quotation performs the tests starting from the end and not the beginning." } ;

HELP: cond
{ $values { "assoc" "a sequence of quotation pairs and an optional quotation" } }
{ $description
    "Calls the second quotation in the first pair whose first quotation yields a true value. A single quotation will always yield a true value."
    $nl
    "The following two phrases are equivalent:"
    { $code "{ { [ X ] [ Y ] } { [ Z ] [ T ] } } cond" }
    { $code "X [ Y ] [ Z [ T ] [ no-cond ] if ] if" }
}
{ $errors "Throws a " { $link no-cond } " error if none of the test quotations yield a true value." }
{ $examples
    { $example
        "USING: combinators io kernel math ;"
        "0 {"
        "    { [ dup 0 > ] [ drop \"positive\" ] }"
        "    { [ dup 0 < ] [ drop \"negative\" ] }"
        "    [ drop \"zero\" ]"
        "} cond print"
        "zero"
    }
} ;

HELP: no-cond
{ $description "Throws a " { $link no-cond } " error." }
{ $error-description "Thrown by " { $link cond } " if none of the test quotations yield a true value. Some uses of " { $link cond } " include a default case where the test quotation is " { $snippet "[ t ]" } "; such a " { $link cond } " form will never throw this error." } ;

HELP: case
{ $values { "obj" object } { "assoc" "a sequence of object/quotation pairs, with an optional quotation at the end" } }
{ $description
    "Compares " { $snippet "obj" } " against the first element of every " { $link pair } ", evaluating the first element if it is a " { $link callable } ". If a pair matches, " { $snippet "obj" } " is removed from the stack and the second element of that pair (which must be a " { $link quotation } ") is " { $link call } "ed."
    $nl
    "If the last element of the " { $snippet assoc } " is a quotation, that quotation is the default case. The default case is called with the " { $snippet "obj" } " on the stack, if there is no other case matching " { $snippet obj } "."
    $nl
    "If all the cases have failed and there is no default case to execute, a " { $link no-case } " error is raised."
    $nl
    "The following two phrases are equivalent:"
    { $code "{ { X [ Y ] } { Z [ T ] } } case" }
    { $code "dup X = [ drop Y ] [ dup Z = [ drop T ] [ no-case ] if ] if" }
}
{ $errors { $link no-case } " if the input matched none of the options and there was no trailing quotation." }
{ $examples
    { $example
        "USING: combinators io kernel ;"
        "IN: scratchpad"
        "SYMBOLS: yes no maybe ;"
        "maybe {"
        "    { yes [ ] } ! Do nothing"
        "    { no [ \"No way!\" throw ] }"
        "    { maybe [ \"Make up your mind!\" print ] }"
        "    [ drop \"Invalid input; try again.\" print ]"
        "} case"
        "Make up your mind!"
    }
} ;

HELP: no-case
{ $description "Throws a " { $link no-case } " error." }
{ $error-description "Thrown by " { $link case } " if the object at the top of the stack does not match any case, and no default case is given." } ;

HELP: deep-spread>quot
{ $values { "seq" sequence } { "quot" quotation } }
{ $description "Creates a new quotation from a sequence of quotations that applies each quotation to a stack element in turn." }
{ $see-also spread } ;

HELP: cond>quot
{ $values { "assoc" "a sequence of pairs of quotations" } { "quot" quotation } }
{ $description "Creates a quotation that when called, has the same effect as applying " { $link cond } " to " { $snippet "assoc" } "."
$nl
"The generated quotation is more efficient than the naive implementation of " { $link cond } ", though, since it expands into a series of conditionals, and no iteration through " { $snippet "assoc" } " has to be performed." }
{ $notes "This word is used behind the scenes to compile " { $link cond } " forms efficiently; it can also be called directly, which is useful for meta-programming." } ;

HELP: case>quot
{ $values { "default" quotation } { "assoc" "a sequence of pairs of quotations" } { "quot" quotation } }
{ $description "Creates a quotation that when called, has the same effect as applying " { $link case } " to " { $snippet "assoc" } "."
$nl
"This word uses three strategies:"
{ $list
    "If the assoc only has a few keys, a linear search is generated."
    { "If the assoc has a large number of keys which form a contiguous range of integers, a direct dispatch is generated using the " { $link dispatch } " word together with a bounds check." }
    "Otherwise, an open-coded hashtable dispatch is generated."
} } ;

HELP: distribute-buckets
{ $values { "alist" "an alist" } { "initial" object } { "quot" { $quotation ( obj -- assoc ) } } { "buckets" "a new array" } }
{ $description "Sorts the entries of " { $snippet "assoc" } " into buckets, using the quotation to yield a set of keys for each entry. The hashcode of each key is computed, and the entry is placed in all corresponding buckets. Each bucket is initially cloned from " { $snippet "initial" } "; this should either be an empty vector or a one-element vector containing a pair." }
{ $notes "This word is used in the implementation of " { $link hash-case-quot } " and " { $link standard-combination } "." } ;

HELP: dispatch
{ $values { "n" "a fixnum" } { "array" "an array of quotations" } }
{ $description "Calls the " { $snippet "n" } "th quotation in the array." }
{ $warning "This word is an implementation detail used by the generic word system to accelerate method dispatch. It does not perform type or bounds checks, and user code should not need to call it directly." } ;
