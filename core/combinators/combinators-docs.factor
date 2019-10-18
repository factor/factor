USING: arrays help.markup help.syntax strings sbufs vectors
kernel quotations generic generic.standard classes
math assocs sequences combinators.private ;
IN: combinators

ARTICLE: "combinators-quot" "Quotation construction utilities"
"Some words for creating quotations which can be useful for implementing method combinations and compiler transforms:"
{ $subsection cond>quot }
{ $subsection case>quot }
{ $subsection alist>quot }
"A powerful tool used to optimize code in several places is open-coded hashtable dispatch:"
{ $subsection hash-case>quot }
{ $subsection distribute-buckets }
{ $subsection hash-dispatch-quot } ;

ARTICLE: "combinators" "Additional combinators"
"The " { $vocab-link "combinators" } " vocabulary is usually used because it provides two combinators which abstract out nested chains of " { $link if } ":"
{ $subsection cond }
{ $subsection case }
"A combinator which can help with implementing methods on " { $link hashcode* } ":"
{ $subsection recursive-hashcode }
"An oddball combinator:"
{ $subsection with-datastack }
{ $subsection "combinators-quot" }
{ $see-also "quotations" "basic-combinators" } ;

ABOUT: "combinators"

HELP: alist>quot
{ $values { "default" "a quotation" } { "assoc" "a sequence of quotation pairs" } { "quot" "a new quotation" } }
{ $description "Constructs a quotation which calls the first quotation in each pair of " { $snippet "assoc" } " until one of them outputs a true value, and then calls the second quotation in the corresponding pair. Quotations are called in reverse order, and if no quotation outputs a true value then " { $snippet "default" } " is called." }
{ $notes "This word is used to implement compile-time behavior for " { $link cond } ", and it is also used by the generic word system. Note that unlike " { $link cond } ", the constructed quotation performs the tests starting from the end and not the beginning." } ;

HELP: cond
{ $values { "assoc" "a sequence of quotation pairs" } }
{ $description
    "Calls the second quotation in the first pair whose first quotation yields a true value."
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
        "    { [ dup zero? ] [ \"zero\" ] }"
        "} cond"
    }
} ;

HELP: no-cond
{ $description "Throws a " { $link no-cond } " error." }
{ $error-description "Thrown by " { $link cond } " if none of the test quotations yield a true value. Some uses of " { $link cond } " include a default case where the test quotation is " { $snippet "[ t ]" } "; such a " { $link cond } " form will never throw this error." } ;

HELP: case
{ $values { "obj" object } { "assoc" "a sequence of object/quotation pairs, with an optional quotation at the end" } }
{ $description
    "Compares " { $snippet "obj" } " against the first element of every pair. If some pair matches, removes " { $snippet "obj" } " from the stack and calls the second element of that pair, which must be a quotation."
    $nl
    "If there is no case matching " { $snippet "obj" } ", the default case is taken. If the last element of " { $snippet "cases" } " is a quotation, the quotation is called with " { $snippet "obj" } " on the stack. Otherwise, a " { $link no-cond } " error is rasied."
    $nl
    "The following two phrases are equivalent:"
    { $code "{ { X [ Y ] } { Y [ T ] } } case" }
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

HELP: with-datastack
{ $values { "stack" sequence } { "quot" quotation } { "newstack" sequence } }
{ $description "Executes the quotation with the given data stack contents, and outputs the new data stack after the word returns. The input sequence is not modified. Does not affect the data stack in surrounding code, other than consuming the two inputs and pushing the output." }
{ $examples
    { $example "{ 3 7 } [ + ] with-datastack ." "{ 10 }" }
} ;

HELP: recursive-hashcode
{ $values { "n" integer } { "obj" object } { "quot" "a quotation with stack effect " { $snippet "( n obj -- code )" } } { "code" integer } }
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
"The quotation actually tests each possible case in order;" { $link hash-case>quot } " produces more efficient code." } ;

HELP: distribute-buckets
{ $values { "assoc" "an alist" } { "initial" object } { "quot" "a quotation with stack effect " { $snippet "( obj -- assoc )" } } { "buckets" "a new array" } }
{ $description "Sorts the entries of " { $snippet "assoc" } " into buckets, using the quotation to yield a set of keys for each entry. The hashcode of each key is computed, and the entry is placed in all corresponding buckets. Each bucket is initially cloned from " { $snippet "initial" } "; this should either be an empty vector or a one-element vector containing a pair." }
{ $notes "This word is used in the implemention of " { $link hash-case>quot } " and " { $link standard-combination } "." } ;

HELP: hash-case>quot
{ $values { "default" quotation } { "assoc" "an association list mapping quotations to quotations" } { "quot" quotation } }
{ $description "Creates a quotation that when called, has the same effect as applying " { $link case } " to " { $snippet "assoc" } "."
$nl
"The quotation uses an efficient hash-based search to avoid testing the object against all possible keys." }
{ $notes "This word is used behind the scenes to compile " { $link case } " forms efficiently; it can also be called directly,  which is useful for meta-programming." } ;

HELP: dispatch ( n array -- )
{ $values { "n" "a fixnum" } { "array" "an array of quotations" } }
{ $description "Calls the " { $snippet "n" } "th quotation in the array." }
{ $warning "This word is in the " { $vocab-link "kernel.private" } " vocabulary because it is an implementation detail used by the generic word system to accelerate method dispatch. It does not perform type or bounds checks, and user code should not need to call it directly." } ;
