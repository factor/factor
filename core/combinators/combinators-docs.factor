USING: arrays help.markup help.syntax strings sbufs vectors
kernel quotations generic generic.standard classes
math assocs sequences sequences.private combinators.private
effects words ;
IN: combinators

ARTICLE: "cleave-shuffle-equivalence" "Expressing shuffle words with cleave combinators"
"Cleave combinators are defined in terms of shuffle words, and mappings from certain shuffle idioms to cleave combinators are discussed in the documentation for " { $link bi } ", " { $link 2bi } ", " { $link 3bi } ", " { $link tri } ", " { $link 2tri } " and " { $link 3tri } "."
$nl
"Certain shuffle words can also be expressed in terms of the cleave combinators. Internalizing such identities can help with understanding and writing code using cleave combinators:"
{ $code
    ": keep  [ ] bi ;"
    ": 2keep [ ] 2bi ;"
    ": 3keep [ ] 3bi ;"
    ""
    ": dup   [ ] [ ] bi ;"
    ": 2dup  [ ] [ ] 2bi ;"
    ": 3dup  [ ] [ ] 3bi ;"
    ""
    ": tuck  [ nip ] [ ] 2bi ;"
    ": swap  [ nip ] [ drop ] 2bi ;"
    ""
    ": over  [ ] [ drop ] 2bi ;"
    ": pick  [ ] [ 2drop ] 3bi ;"
    ": 2over [ ] [ drop ] 3bi ;"
} ;

ARTICLE: "cleave-combinators" "Cleave combinators"
"The cleave combinators apply multiple quotations to a single value."
$nl
"Two quotations:"
{ $subsection bi }
{ $subsection 2bi }
{ $subsection 3bi }
"Three quotations:"
{ $subsection tri }
{ $subsection 2tri }
{ $subsection 3tri }
"An array of quotations:"
{ $subsection cleave }
{ $subsection 2cleave }
{ $subsection 3cleave }
"Technically, the cleave combinators are redundant because they can be simulated using shuffle words and other combinators, and in addition, they do not reduce token counts by much, if at all. However, they can make code more readable by expressing intention and exploiting any inherent symmetry. For example, a piece of code which performs three operations on the top of the stack can be written in one of two ways:"
{ $code
    "! First alternative; uses keep"
    "[ 1 + ] keep"
    "[ 1 - ] keep"
    "2 *"
    "! Second alternative: uses tri"
    "[ 1 + ]"
    "[ 1 - ]"
    "[ 2 * ] tri"
}
"The latter is more aesthetically pleasing than the former."
{ $subsection "cleave-shuffle-equivalence" } ;

ARTICLE: "spread-shuffle-equivalence" "Expressing shuffle words with spread combinators"
"Spread combinators are defined in terms of shuffle words, and mappings from certain shuffle idioms to spread combinators are discussed in the documentation for " { $link bi* } ", " { $link 2bi* } ", " { $link tri* } ", and " { $link 2tri* } "."
$nl
"Certain shuffle words can also be expressed in terms of the spread combinators. Internalizing such identities can help with understanding and writing code using spread combinators:"
{ $code
    ": dip   [ ] bi* ;"
    ": 2dip  [ ] [ ] tri* ;"
    ""
    ": slip  [ call ] [ ] bi* ;"
    ": 2slip [ call ] [ ] [ ] tri* ;"
    ""
    ": nip   [ drop ] [ ] bi* ;"
    ": 2nip  [ drop ] [ drop ] [ ] tri* ;"
    ""
    ": rot"
    "    [ [ drop ] [      ] [ drop ] tri* ]"
    "    [ [ drop ] [ drop ] [      ] tri* ]"
    "    [ [      ] [ drop ] [ drop ] tri* ]"
    "    3tri ;"
    ""
    ": -rot"
    "    [ [ drop ] [ drop ] [      ] tri* ]"
    "    [ [      ] [ drop ] [ drop ] tri* ]"
    "    [ [ drop ] [      ] [ drop ] tri* ]"
    "    3tri ;"
    ""
    ": spin"
    "    [ [ drop ] [ drop ] [      ] tri* ]"
    "    [ [ drop ] [      ] [ drop ] tri* ]"
    "    [ [      ] [ drop ] [ drop ] tri* ]"
    "    3tri ;"
} ;

ARTICLE: "spread-combinators" "Spread combinators"
"The spread combinators apply multiple quotations to multiple values. The " { $snippet "*" } " suffix signifies spreading."
$nl
"Two quotations:"
{ $subsection bi* }
{ $subsection 2bi* }
"Three quotations:"
{ $subsection tri* }
{ $subsection 2tri* }
"An array of quotations:"
{ $subsection spread }
"Technically, the spread combinators are redundant because they can be simulated using shuffle words and other combinators, and in addition, they do not reduce token counts by much, if at all. However, they can make code more readable by expressing intention and exploiting any inherent symmetry. For example, a piece of code which performs three operations on three related values can be written in one of two ways:"
{ $code
    "! First alternative; uses dip"
    "[ [ 1 + ] dip 1 - ] dip 2 *"
    "! Second alternative: uses tri*"
    "[ 1 + ] [ 1 - ] [ 2 * ] tri*"
}
"A generalization of the above combinators to any number of quotations can be found in " { $link "combinators" } "."
{ $subsection "spread-shuffle-equivalence" } ;

ARTICLE: "apply-combinators" "Apply combinators"
"The apply combinators apply a single quotation to multiple values. The " { $snippet "@" } " suffix signifies application."
$nl
"Two quotations:"
{ $subsection bi@ }
{ $subsection 2bi@ }
"Three quotations:"
{ $subsection tri@ }
{ $subsection 2tri@ }
"A pair of utility words built from " { $link bi@ } ":"
{ $subsection both? }
{ $subsection either? } ;

ARTICLE: "slip-keep-combinators" "Retain stack combinators"
"Sometimes an additional storage area is needed to hold objects. The " { $emphasis "retain stack" } " is an auxilliary stack for this purpose. Objects can be moved between the data and retain stacks using a set of combinators."
$nl
"The dip combinators invoke the quotation at the top of the stack, hiding the values underneath:"
{ $subsection dip }
{ $subsection 2dip }
{ $subsection 3dip }
{ $subsection 4dip }
"The slip combinators invoke a quotation further down on the stack. They are most useful for implementing other combinators:"
{ $subsection slip }
{ $subsection 2slip }
{ $subsection 3slip }
"The keep combinators invoke a quotation which takes a number of values off the stack, and then they restore those values:"
{ $subsection keep }
{ $subsection 2keep }
{ $subsection 3keep } ;

ARTICLE: "curried-dataflow" "Curried dataflow combinators"
"Curried cleave combinators:"
{ $subsection bi-curry }
{ $subsection tri-curry }
"Curried spread combinators:"
{ $subsection bi-curry* }
{ $subsection tri-curry* }
"Curried apply combinators:"
{ $subsection bi-curry@ }
{ $subsection tri-curry@ }
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
  "USING: kernel math prettyprint sequences ;"
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
  "USING: kernel math prettyprint sequences ;"
  ": n-subtract ( n seq -- seq' ) [ - ] with map ;"
  "30 { 10 20 30 } n-subtract ."
  "{ 20 10 0 }"
}
{ $see-also "fry.examples" } ;

ARTICLE: "compositional-combinators" "Compositional combinators"
"Certain combinators transform quotations to produce a new quotation."
{ $subsection "compositional-examples" }
"Fundamental operations:"
{ $subsection curry }
{ $subsection compose }
"Derived operations:"
{ $subsection 2curry }
{ $subsection 3curry }
{ $subsection with }
{ $subsection prepose }
"These operations run in constant time, and in many cases are optimized out altogether by the " { $link "compiler" } ". " { $link "fry" } " are an abstraction built on top of these operations, and code that uses this abstraction is often clearer than direct calls to the below words."
$nl
"Curried dataflow combinators can be used to build more complex dataflow by combining cleave, spread and apply patterns in various ways."
{ $subsection "curried-dataflow" }
"Quotations also implement the sequence protocol, and can be manipulated with sequence words; see " { $link "quotations" } ". However, such runtime quotation manipulation will not be optimized by the optimizing compiler." ;

ARTICLE: "booleans" "Booleans"
"In Factor, any object that is not " { $link f } " has a true value, and " { $link f } " has a false value. The " { $link t } " object is the canonical true value."
{ $subsection f }
{ $subsection t }
"There are some logical operations on booleans:"
{ $subsection >boolean }
{ $subsection not }
{ $subsection and }
{ $subsection or }
{ $subsection xor }
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
{ $example "USE: classes" "f class ." "POSTPONE: f" }
"The " { $link f } " class is an instance of " { $link word } ":"
{ $example "USE: classes" "\\ f class ." "word" }
"On the other hand, " { $link t } " is just a word, and there is no class which it is a unique instance of."
{ $example "t \\ t eq? ." "t" }
"Many words which search collections confuse the case of no element being present with an element being found equal to " { $link f } ". If this distinction is imporant, there is usually an alternative word which can be used; for example, compare " { $link at } " with " { $link at* } "." ;

ARTICLE: "conditionals-boolean-equivalence" "Expressing conditionals with boolean logic"
"Certain simple conditional forms can be expressed in a simpler manner using boolean logic."
$nl
"The following two lines are equivalent:"
{ $code "[ drop f ] unless" "swap and" }
"The following two lines are equivalent:"
{ $code "[ ] [ ] ?if" "swap or" }
"The following two lines are equivalent, where " { $snippet "L" } " is a literal:"
{ $code "[ L ] unless*" "L or" } ;

ARTICLE: "conditionals" "Conditional combinators"
"The basic conditionals:"
{ $subsection if }
{ $subsection when }
{ $subsection unless }
"Forms abstracting a common stack shuffle pattern:"
{ $subsection if* }
{ $subsection when* }
{ $subsection unless* }
"Another form abstracting a common stack shuffle pattern:"
{ $subsection ?if }
"Sometimes instead of branching, you just need to pick one of two values:"
{ $subsection ? }
"Two combinators which abstract out nested chains of " { $link if } ":"
{ $subsection cond }
{ $subsection case }
{ $subsection "conditionals-boolean-equivalence" }
{ $see-also "booleans" "bitwise-arithmetic" both? either? } ;

ARTICLE: "dataflow-combinators" "Data flow combinators"
"Data flow combinators pass values between quotations:"
{ $subsection "slip-keep-combinators" }
{ $subsection "cleave-combinators" }
{ $subsection "spread-combinators" }
{ $subsection "apply-combinators" }
{ $see-also "curried-dataflow" } ;

ARTICLE: "combinators-quot" "Quotation construction utilities"
"Some words for creating quotations which can be useful for implementing method combinations and compiler transforms:"
{ $subsection cond>quot }
{ $subsection case>quot }
{ $subsection alist>quot } ;

ARTICLE: "call-unsafe" "Unsafe combinators"
"Unsafe calls declare an effect statically without any runtime checking:"
{ $subsection call-effect-unsafe }
{ $subsection execute-effect-unsafe } ;

ARTICLE: "call" "Fundamental combinators"
"The most basic combinators are those that take either a quotation or word, and invoke it immediately."
$nl
"There are two sets of combinators; they differ in whether or not the stack effect of the expected code is declared."
$nl
"The simplest combinators do not take an effect declaration. The compiler checks the stack effect at compile time, rejecting the program if this cannot be done:"
{ $subsection call }
{ $subsection execute }
"The second set of combinators takes an effect declaration. The stack effect of the quotation or word is checked at runtime:"
{ $subsection POSTPONE: call( }
{ $subsection POSTPONE: execute( }
"The above are syntax sugar. The underlying words are a bit more verbose but allow non-constant effects to be passed in:"
{ $subsection call-effect }
{ $subsection execute-effect }
{ $subsection "call-unsafe" }
"The combinator variants that do not take an effect declaration can only be used if the compiler is able to infer the stack effect by other means. See " { $link "inference-combinators" } "."
{ $subsection "call-unsafe" }
{ $see-also "effects" "inference" } ;

ARTICLE: "combinators" "Combinators"
"A central concept in Factor is that of a " { $emphasis "combinator" } ", which is a word taking code as input."
{ $subsection "call" }
{ $subsection "dataflow-combinators" }
{ $subsection "conditionals" }
{ $subsection "looping-combinators" }
{ $subsection "compositional-combinators" }
{ $subsection "combinators.short-circuit" }
{ $subsection "combinators.smart" }
"More combinators are defined for working on data structures, such as " { $link "sequences-combinators" } " and " { $link "assocs-combinators" } "."
{ $subsection "combinators-quot" }
{ $see-also "quotations" } ;

ABOUT: "combinators"

HELP: call-effect
{ $values { "quot" quotation } { "effect" effect } }
{ $description "Given a quotation and a stack effect, calls the quotation, asserting at runtime that it has the given stack effect. This is a macro which expands given a literal effect parameter, and an arbitrary quotation which is not required at compile time." } ;

HELP: execute-effect
{ $values { "word" word } { "effect" effect } }
{ $description "Given a word and a stack effect, executes the word, asserting at runtime that it has the given stack effect. This is a macro which expands given a literal effect parameter, and an arbitrary word which is not required at compile time." } ;

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
    "The " { $link bi* } " combinator takes two values and two quotations; the " { $link tri* } " combinator takes three values and three quotations. The " { $link spread } " combinator takes " { $snippet "n" } " values and " { $snippet "n" } " quotations, where " { $snippet "n" } " is the length of the input sequence, and is essentially equivalent to series of retain stack manipulations:"
    { $code
        "! Equivalent"
        "{ [ p ] [ q ] [ r ] [ s ] } spread"
        "[ [ [ p ] dip q ] dip r ] dip s"
    }
} ;

{ bi* tri* spread } related-words

HELP: alist>quot
{ $values { "default" "a quotation" } { "assoc" "a sequence of quotation pairs" } { "quot" "a new quotation" } }
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
    { $code
        "{"
        "    { [ dup 0 > ] [ \"positive\" ] }"
        "    { [ dup 0 < ] [ \"negative\" ] }"
        "    [ \"zero\" ]"
        "} cond"
    }
} ;

HELP: no-cond
{ $description "Throws a " { $link no-cond } " error." }
{ $error-description "Thrown by " { $link cond } " if none of the test quotations yield a true value. Some uses of " { $link cond } " include a default case where the test quotation is " { $snippet "[ t ]" } "; such a " { $link cond } " form will never throw this error." } ;

HELP: case
{ $values { "obj" object } { "assoc" "a sequence of object/word,quotation pairs, with an optional quotation at the end" } }
{ $description
    "Compares " { $snippet "obj" } " against the first element of every pair, first evaluating the first element if it is a word. If some pair matches, removes " { $snippet "obj" } " from the stack and calls the second element of that pair, which must be a quotation."
    $nl
    "If there is no case matching " { $snippet "obj" } ", the default case is taken. If the last element of " { $snippet "cases" } " is a quotation, the quotation is called with " { $snippet "obj" } " on the stack. Otherwise, a " { $link no-cond } " error is rasied."
    $nl
    "The following two phrases are equivalent:"
    { $code "{ { X [ Y ] } { Z [ T ] } } case" }
    { $code "dup X = [ drop Y ] [ dup Z = [ drop T ] [ no-case ] if ] if" }
}
{ $examples
    { $code
        "SYMBOL: yes  SYMBOL: no  SYMBOL: maybe"
        "maybe {"
        "    { yes [ ] } ! Do nothing"
        "    { no [ \"No way!\" throw ] }"
        "    { maybe [ \"Make up your mind!\" print ] }"
        "    [ \"Invalid input; try again.\" print ]"
        "} case"
    }
} ;

HELP: no-case
{ $description "Throws a " { $link no-case } " error." }
{ $error-description "Thrown by " { $link case } " if the object at the top of the stack does not match any case, and no default case is given." } ;

HELP: recursive-hashcode
{ $values { "n" integer } { "obj" object } { "quot" { $quotation "( n obj -- code )" } } { "code" integer } }
{ $description "A combinator used to implement methods for the " { $link hashcode* } " generic word. If " { $snippet "n" } " is less than or equal to zero, outputs 0, otherwise calls the quotation." } ;

HELP: cond>quot
{ $values { "assoc" "a sequence of pairs of quotations" } { "quot" quotation } }
{ $description  "Creates a quotation that when called, has the same effect as applying " { $link cond } " to " { $snippet "assoc" } "."
$nl
"the generated quotation is more efficient than the naive implementation of " { $link cond } ", though, since it expands into a series of conditionals, and no iteration through " { $snippet "assoc" } " has to be performed." }
{ $notes "This word is used behind the scenes to compile " { $link cond } " forms efficiently; it can also be called directly,  which is useful for meta-programming." } ;

HELP: case>quot
{ $values { "assoc" "a sequence of pairs of quotations" } { "default" quotation } { "quot" quotation } }
{ $description "Creates a quotation that when called, has the same effect as applying " { $link case } " to " { $snippet "assoc" } "."
$nl
"This word uses three strategies:"
{ $list
    "If the assoc only has a few keys, a linear search is generated."
    { "If the assoc has a large number of keys which form a contiguous range of integers, a direct dispatch is generated using the " { $link dispatch } " word together with a bounds check." }
    "Otherwise, an open-coded hashtable dispatch is generated."
} } ;

HELP: distribute-buckets
{ $values { "alist" "an alist" } { "initial" object } { "quot" { $quotation "( obj -- assoc )" } } { "buckets" "a new array" } }
{ $description "Sorts the entries of " { $snippet "assoc" } " into buckets, using the quotation to yield a set of keys for each entry. The hashcode of each key is computed, and the entry is placed in all corresponding buckets. Each bucket is initially cloned from " { $snippet "initial" } "; this should either be an empty vector or a one-element vector containing a pair." }
{ $notes "This word is used in the implemention of " { $link hash-case-quot } " and " { $link standard-combination } "." } ;

HELP: dispatch ( n array -- )
{ $values { "n" "a fixnum" } { "array" "an array of quotations" } }
{ $description "Calls the " { $snippet "n" } "th quotation in the array." }
{ $warning "This word is in the " { $vocab-link "kernel.private" } " vocabulary because it is an implementation detail used by the generic word system to accelerate method dispatch. It does not perform type or bounds checks, and user code should not need to call it directly." } ;
