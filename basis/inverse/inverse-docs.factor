USING: help.markup help.syntax kernel quotations words ;
IN: inverse

HELP: [undo]
{ $values { "quot" quotation } { "undo" "the inverse of the quotation" } }
{ $description "Creates the inverse of the given quotation" }
{ $see-also undo } ;

HELP: undo
{ $values { "quot" quotation } }
{ $description "Executes the inverse of the given quotation" }
{ $see-also [undo] } ;

HELP: define-inverse
{ $values { "word" word } { "quot" "the inverse" } }
{ $description "Defines the inverse of a given word, taking no arguments from the quotation, only the stack." }
{ $see-also define-dual define-involution define-pop-inverse } ;

HELP: define-dual
{ $values { "word1" word } { "word2" word } }
{ $description "Defines the inverse of each word as being the other one." }
{ $see-also define-inverse define-involution } ;

HELP: define-involution
{ $values { "word" word } }
{ $description "Defines a word as being its own inverse." }
{ $see-also define-dual define-inverse } ;

HELP: define-pop-inverse
{ $values { "word" word } { "n" "number of arguments to be taken from the inverted quotation" } { "quot" quotation } }
{ $description "Defines the inverse of the given word, taking the given number of arguments from the inverted quotation. The quotation given should generate an inverse quotation." }
{ $see-also define-inverse } ;

HELP: matches?
{ $values { "quot" quotation } { "?" boolean } }
{ $description "Tests if the stack can match the given quotation. The quotation is inverted, and if the inverse can run without a unification failure, then t is returned. Else f is returned. If a different error is encountered (such as stack underflow), this will be propagated." } ;

HELP: switch
{ $values { "quot-alist" "an alist from inverse quots to quots" } }
{ $description "The equivalent of a case expression in a programming language with buitlin pattern matchining. It attempts to match the stack with each of the patterns, in order, by treating them as inverse quotations. Failure causes the next pattern to be tested." }
{ $code
"TUPLE: cons car cdr ;"
"C: <cons> cons"
": sum ( list -- sum )"
"    {"
"        { [ <cons> ] [ sum + ] }"
"        { [ f ] [ 0 ] }"
"    } switch ;" }
{ $see-also undo } ;

HELP: under
{ $values { "invertible-quot" quotation } { "quot" quotation } }
{ $description "Applies " { $snippet "invertible-quot" } ", then " { $snippet "quot" } " and finally the inverse of " { $snippet "invertible-quot" } "." }
{ $examples
    "Round a decimal number to two decimals:"
    { $example
        "USING: inverse math math.functions prettyprint ;"
        "123.456 [ 100 * ] [ round ] under ."
        "123.46"
    }
} ;

ARTICLE: { "inverse" "intro" } "Invertible quotations"
"The inverse vocab defines a way to 'undo' quotations, and builds a pattern matching framework on that basis. A quotation can be inverted by reversing it and inverting each word. To define the inverse for particular word, use"
{ $subsections
    define-inverse
    define-pop-inverse
}
"To build an inverse quotation"
{ $subsections [undo] }
"To use the inverse quotation for pattern matching"
{ $subsections
    undo
    matches?
    switch
} ;

IN: inverse
ABOUT: { "inverse" "intro" }
