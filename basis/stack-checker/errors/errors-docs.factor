USING: help.markup help.syntax kernel effects sequences
sequences.private words ;
IN: stack-checker.errors

HELP: literal-expected
{ $error-description "Thrown when inference encounters a " { $link call } " or " { $link if } " being applied to a value which is not known to be a literal. Such a form can have an arbitrary stack effect, and does not compile." }
{ $notes "This error will be thrown when compiling any combinator, such as " { $link each } ". However, words calling combinators can compile if the combinator is declared " { $link POSTPONE: inline } " and the quotation being passed in is a literal." }
{ $examples
    "In this example, words calling " { $snippet "literal-expected-example" } " will compile, even if " { $snippet "literal-expected-example" } " does not compile itself:"
    { $code
        ": literal-expected-example ( quot -- )"
        "    [ call ] [ call ] bi ; inline"
    }
} ;

HELP: unbalanced-branches-error
{ $values { "in" "a sequence of integers" } { "out" "a sequence of integers" } }
{ $description "Throws an " { $link unbalanced-branches-error } "." }
{ $error-description "Thrown when inference encounters an " { $link if } " or " { $link dispatch } " where the branches do not all exit with the same stack height." }
{ $notes "Conditionals with variable stack effects are considered to be bad style and should be avoided since they do not compile."
$nl
"If this error comes up when inferring the stack effect of a recursive word, check the word's stack effect declaration; it might be wrong." }
{ $examples
    { $code
        ": unbalanced-branches-example ( a b c -- )"
        "    [ + ] [ dup ] if ;"
    }
} ;

HELP: too-many->r
{ $error-description "Thrown if inference notices a quotation pushing elements on the retain stack without popping them at the end." } ;

HELP: too-many-r>
{ $error-description "Thrown if inference notices a quotation popping elements from the return stack it did not place there." } ;

HELP: missing-effect
{ $error-description "Thrown when inference encounters a word lacking a stack effect declaration. Stack effects of words must be declared, with the exception of words which only push literals on the stack." }
{ $examples
    { $code
        ": missing-effect-example"
        "    + * ;"
    }
} ;

HELP: effect-error
{ $values { "word" word } { "effect" "an instance of " { $link effect } } }
{ $description "Throws an " { $link effect-error } "." }
{ $error-description "Thrown when a word's inferred stack effect does not match its declared stack effect." } ;

HELP: recursive-quotation-error
{ $error-description "Thrown when a quotation calls itself, directly or indirectly, within the same word. Stack effect inference becomes equivalent to the halting problem if quotation recursion has to be taken into account, hence it is not permitted." }
{ $examples
    "Here is an example of quotation recursion:"
    { $code "[ [ dup call ] dup call ] infer." }
} ;

HELP: undeclared-recursion-error
{ $error-description "Thrown when an " { $link POSTPONE: inline } " word which is not declared " { $link POSTPONE: recursive } " calls itself, directly or indirectly. The " { $link POSTPONE: recursive } " declaration is mandatory for such words." } ;

HELP: diverging-recursion-error
{ $error-description "Thrown when stack effect inference determines that a recursive word might take an arbitrary number of values from the stack." }
{ $notes "Such words do not have a static stack effect and most likely indicate programmer error." }
{ $examples
    { $code
        ": diverging-recursion-example ( -- )"
        "    [ diverging-recursion-example f ] when ; inline recursive"
    }
} ;

HELP: unbalanced-recursion-error
{ $error-description "Thrown when stack effect inference determines that an inline recursive word has an incorrect stack effect declaration." }
{ $examples
    { $code
        ": unbalanced-recursion-example ( quot: ( -- ? ) -- b )"
        "    dup call [ unbalanced-recursion-example ] [ drop ] if ;"
        "    inline recursive"
    }
} ;

HELP: inconsistent-recursive-call-error
{ $error-description "Thrown when stack effect inference determines that an inline recursive word calls itself with a different set of quotation parameters than were input." }
{ $examples
    { $code
        ": inconsistent-recursive-call-example ( quot: ( -- ? ) -- b )"
        "    [ not ] compose inconsistent-recursive-call-example ; inline recursive"
    }
} ;

ARTICLE: "inference-errors" "Inference warnings and errors"
"These conditions are thrown by " { $link "inference" } ", as well as the " { $link "compiler" } "."
$nl
"Main wrapper for all inference warnings and errors:"
{ $subsection inference-error }
"Inference warnings:"
{ $subsection literal-expected }
"Inference errors:"
{ $subsection recursive-quotation-error }
{ $subsection unbalanced-branches-error }
{ $subsection effect-error }
{ $subsection missing-effect }
"Inference errors for inline recursive words:"
{ $subsection undeclared-recursion-error }
{ $subsection diverging-recursion-error }
{ $subsection unbalanced-recursion-error }
{ $subsection inconsistent-recursive-call-error }
"Retain stack usage errors:"
{ $subsection too-many->r }
{ $subsection too-many-r> } ;

ABOUT: "inference-errors"
