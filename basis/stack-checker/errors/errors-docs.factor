USING: help.markup help.syntax kernel effects sequences
sequences.private words ;
IN: stack-checker.errors

HELP: literal-expected
{ $error-description "Thrown when inference encounters a combinator or macro being applied to a value which is not known to be a literal, or constructed in a manner which can be analyzed statically. Such code needs changes before it can compile and run. See " { $link "inference-combinators" } " and " { $link "inference-escape" } " for details." }
{ $examples
    "In this example, words calling " { $snippet "literal-expected-example" } " will have a static stac keffect, even if " { $snippet "literal-expected-example" } " does not:"
    { $code
        ": literal-expected-example ( quot -- )"
        "    [ call ] [ call ] bi ; inline"
    }
} ;

HELP: unbalanced-branches-error
{ $values { "in" "a sequence of integers" } { "out" "a sequence of integers" } }
{ $description "Throws an " { $link unbalanced-branches-error } "." }
{ $error-description "Thrown when inference encounters an " { $link if } " or " { $link dispatch } " where the branches do not all exit with the same stack height. See " { $link "inference-branches" } " for details." }
{ $notes "If this error comes up when inferring the stack effect of a recursive word, check the word's stack effect declaration; it might be wrong." }
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

ARTICLE: "inference-errors" "Stack checker errors"
"These " { $link "inference" } " failure conditions are reported in one of two ways:"
{ $list
    { { $link "tools.inference" } " throws them as errors" }
    { "The " { $link "compiler" } " reports them via " { $link "tools.errors" } }
}
"Error thrown when insufficient information is available to calculate the stack effect of a combinator call (see " { $link "inference-combinators" } "):"
{ $subsection literal-expected }
"Error thrown when a word's stack effect declaration does not match the composition of the stack effects of its factors:"
{ $subsection effect-error }
"Error thrown when branches have incompatible stack effects (see " { $link "inference-branches" } "):"
{ $subsection unbalanced-branches-error }
"Inference errors for inline recursive words (see " { $link "inference-recursive-combinators" } "):"
{ $subsection undeclared-recursion-error }
{ $subsection diverging-recursion-error }
{ $subsection unbalanced-recursion-error }
{ $subsection inconsistent-recursive-call-error }
"More obscure errors that are unlikely to arise in ordinary code:"
{ $subsection recursive-quotation-error }
{ $subsection too-many->r }
{ $subsection too-many-r> }
{ $subsection missing-effect } ;

ABOUT: "inference-errors"
