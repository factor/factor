USING: arrays help.markup help.syntax strings sbufs vectors
kernel quotations generic generic.standard classes
math assocs sequences sequences.private ;
IN: combinators

ARTICLE: "combinators-quot" "Quotation construction utilities"
"Some words for creating quotations which can be useful for implementing method combinations and compiler transforms:"
{ $subsection cond>quot }
{ $subsection case>quot }
{ $subsection alist>quot } ;

ARTICLE: "combinators" "Additional combinators"
"The " { $vocab-link "combinators" } " vocabulary provides a few useful combinators."
$nl
"Generalization of " { $link bi } " and " { $link tri } ":"
{ $subsection cleave }
"Generalization of " { $link 2bi } " and " { $link 2tri } ":"
{ $subsection 2cleave }
"Generalization of " { $link 3bi } " and " { $link 3tri }  ":"
{ $subsection 3cleave }
"Generalization of " { $link bi* } " and " { $link tri* } ":"
{ $subsection spread }
"Two combinators which abstract out nested chains of " { $link if } ":"
{ $subsection cond }
{ $subsection case }
"The " { $vocab-link "combinators" } " also provides some less frequently-used features."
$nl
"A combinator which can help with implementing methods on " { $link hashcode* } ":"
{ $subsection recursive-hashcode }
{ $subsection "combinators-quot" }
{ $see-also "quotations" "dataflow" } ;

ABOUT: "combinators"

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
