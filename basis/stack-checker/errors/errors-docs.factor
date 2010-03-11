USING: help.markup help.syntax kernel effects sequences
sequences.private words combinators ;
IN: stack-checker.errors

HELP: do-not-compile
{ $error-description "Thrown when inference encounters a macro being applied to a value which is not known to be a literal. Such code needs changes before it can compile and run. See " { $link "inference-combinators" } " and " { $link "inference-escape" } " for details." }
{ $examples
    "In this example, " { $link cleave } " is being applied to an array that is constructed on the fly. This is not allowed and fails to compile with a " { $link do-not-compile } " error:"
    { $code
        ": cannot-compile-call-example ( x -- y z )"
        "    [ 1 + ] [ 1 - ] 2array cleave ;"
    }
} ;

HELP: unknown-macro-input
{ $error-description "Thrown when inference encounters a combinator or macro being applied to an input parameter of a non-" { $link POSTPONE: inline } " word. The word needs to be declared " { $link POSTPONE: inline } " before its callers can compile and run. See " { $link "inference-combinators" } " and " { $link "inference-escape" } " for details." }
{ $examples
    "In this example, the words being defined cannot be called, because they fail to compile with a " { $link unknown-macro-input } " error:"
    { $code
        ": bad-example ( quot -- )"
        "    [ call ] [ call ] bi ;"
        ""
        ": usage ( -- )"
        "    10 [ 2 * ] bad-example . ;"
    }
    "One fix is to declare the combinator as inline:"
    { $code
        ": good-example ( quot -- )"
        "    [ call ] [ call ] bi ; inline"
        ""
        ": usage ( -- )"
        "    10 [ 2 * ] good-example . ;"
    }
    "Another fix is to use " { $link POSTPONE: call( } ":"
    { $code
        ": good-example ( quot -- )"
        "    [ call( x -- y ) ] [ call( x -- y ) ] bi ;"
        ""
        ": usage ( -- )"
        "    10 [ 2 * ] good-example . ;"
    }
} ;

HELP: bad-macro-input
{ $error-description "Thrown when inference encounters a combinator or macro being applied to a value which is not known at compile time. Such code needs changes before it can compile and run. See " { $link "inference-combinators" } " and " { $link "inference-escape" } " for details." }
{ $examples
    "In this example, the words being defined cannot be called, because they fail to compile with a " { $link bad-macro-input } " error:"
    { $code
        ": bad-example ( quot -- )"
        "    [ . ] append call ; inline"
        ""
        ": usage ( -- )"
        "    2 2 [ + ] bad-example ;"
    }
    "One fix is to use " { $link compose } " instead of " { $link append } ":"
    { $code
        ": good-example ( quot -- )"
        "    [ . ] compose call ; inline"
        ""
        ": usage ( -- )"
        "    2 2 [ + ] good-example ;"
    }
} ;

HELP: unbalanced-branches-error
{ $error-description "Thrown when inference encounters an inline combinator whose input quotations do not match their declared effects, or when it encounters an " { $link if } " or " { $link dispatch } " whose branches do not all exit with the same stack height. See " { $link "inference-combinators" } " and " { $link "inference-branches" } " for details." }
{ $examples
    { $code
        ": if-unbalanced-branches-example ( a b c -- )"
        "    [ + ] [ dup ] if ;"
    }
    { $code
        ": each-unbalanced-branches-example ( x seq -- x' )"
        "    [ 3append ] each ;"
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
"Stack effect checking failure conditions are reported in one of two ways:"
{ $list
    { { $link "tools.inference" } " report them when fed quotations interactively" }
    { "The " { $link "compiler" } " reports them while compiling words, via the " { $link "tools.errors" } " mechanism" }
}
"Errors thrown when insufficient information is available to calculate the stack effect of a call to a combinator or macro (see " { $link "inference-combinators" } "):"
{ $subsections
    do-not-compile
    unknown-macro-input
    bad-macro-input
}
"Error thrown when a word's stack effect declaration does not match the composition of the stack effects of its factors:"
{ $subsections effect-error }
"Error thrown when branches have incompatible stack effects (see " { $link "inference-branches" } "):"
{ $subsections unbalanced-branches-error }
"Inference errors for inline recursive words (see " { $link "inference-recursive-combinators" } "):"
{ $subsections
    undeclared-recursion-error
    diverging-recursion-error
    unbalanced-recursion-error
    inconsistent-recursive-call-error
}
"More obscure errors that are unlikely to arise in ordinary code:"
{ $subsections
    recursive-quotation-error
    too-many->r
    too-many-r>
    missing-effect
} ;

ABOUT: "inference-errors"
