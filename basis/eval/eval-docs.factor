IN: eval
USING: help.markup help.syntax strings io effects parser
listener vocabs.parser debugger combinators ;

HELP: (eval)
{ $values { "str" string } { "effect" effect } }
{ $description "Parses Factor source code from a string, and calls the resulting quotation, which must have the given stack effect." }
{ $notes "This word must be wrapped within " { $link with-file-vocabs } " or " { $link with-interactive-vocabs } ", since it assumes that the " { $link manifest } " variable is set in the current dynamic scope." }
{ $errors "Throws an error if the input is malformed, or if the evaluation itself throws an error." } ;

HELP: eval
{ $values { "str" string } { "effect" effect } }
{ $description "Parses Factor source code from a string, and calls the resulting quotation, which must have the given stack effect." }
{ $notes "The code string is parsed and called in a new dynamic scope with an initial vocabulary search path consisting of just the " { $snippet "syntax" } " vocabulary. The evaluated code can use " { $link "word-search-syntax" } " to alter the search path." }
{ $errors "Throws an error if the input is malformed, or if the evaluation itself throws an error." } ;

HELP: eval(
{ $syntax "eval( inputs -- outputs )" }
{ $description "Parses Factor source code from the string at the top of the stack, and calls the resulting quotation, which must have the given stack effect." }
{ $notes
    "This parsing word is just a slightly nicer syntax for " { $link eval } ". The following are equivalent:"
    { $code
        "eval( inputs -- outputs )"
        "( inputs -- outputs ) eval"
    }
}
{ $errors "Throws an error if the input is malformed, or if the evaluation itself throws an error." } ;

HELP: eval-with-stack
{ $values { "str" string } }
{ $description "Parses Factor source code from " { $snippet "str" } ", and then calls the resulting quotation, printing the data stack if any objects are left." } ;

HELP: eval-with-stack>string
{ $values { "str" string } { "output" string } }
{ $description "Evaluates the Factor code in " { $snippet "str" } " with " { $link output-stream } " rebound to a string output stream, printing the data stack if any objects are left, then outputs the resulting string." } ;

HELP: eval>string
{ $values { "str" string } { "output" string } }
{ $description "Evaluates the Factor code in " { $snippet "str" } " with " { $link output-stream } " rebound to a string output stream, then outputs the resulting string. The code in the string must not take or leave any values on the stack." }
{ $errors "If the code throws an error, the error is caught, and the result of calling " { $link print-error } " on the error is returned." } ;

ARTICLE: "eval-vocabs" "Evaluating strings with a different vocabulary search path"
"Strings passed to " { $link eval } " are always evaluated with an initial vocabulary search path consisting of just the " { $snippet "syntax" } " vocabulary. This is the same search path that source files start out with. This behavior can be customized by taking advantage of the fact that " { $link eval } " is composed from two simpler words:"
{ $subsections
    (eval)
    with-file-vocabs
}
"Code in the listener tool starts out with a different initial search path, with more vocabularies available by default. Strings of code can be evaluated in this search path by using " { $link (eval) } " with a different combinator:"
{ $subsections
    with-interactive-vocabs
}
"When using " { $link (eval) } ", the quotation passed to " { $link with-file-vocabs } " and " { $link with-interactive-vocabs } " can also make specific vocabularies available to the evaluated string. This is done by having the quotation change the run-time vocabulary search path prior to calling " { $link (eval) } ". For run-time analogues of the parse-time " { $link "word-search-syntax" } " see " { $link "word-search-parsing" } "."
$nl
"The vocabulary set used by " { $link with-interactive-vocabs } " can be altered by rebinding a dynamic variable:"
{ $subsections interactive-vocabs }
{ $heading "Example" }
"In this example, a string is evaluated with a fictional " { $snippet "cad.objects" } " vocabulary in the search path by default, together with the listener's " { $link interactive-vocabs } "; the quotation is expected to produce a sequence on the stack:"
{ $code
    "USING: eval listener vocabs.parser ;
[
    \"cad.objects\" use-vocab
    ( -- seq ) (eval)
] with-interactive-vocabs"
}
"Note that the search path in the outer code (set by the " { $link POSTPONE: USING: } " form) has no relation to the search path used when parsing the string parameter (this is determined by " { $link with-interactive-vocabs } " and " { $link use-vocab } ")." ;

ARTICLE: "eval" "Evaluating strings at run time"
"The " { $vocab-link "eval" } " vocabulary implements support for evaluating strings of code dynamically."
$nl
"The main entry point is a parsing word, which wraps a library word:"
{ $subsections
    POSTPONE: eval(
    eval
}
"This pairing is analogous to that of " { $link POSTPONE: call( } " with " { $link call-effect } "."
$nl
"Advanced features:"
{ $subsections "eval-vocabs" eval>string }
;

ABOUT: "eval"
