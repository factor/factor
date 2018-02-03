USING: help help.lint.coverage help.lint.coverage.private help.markup help.syntax kernel
sequences strings vocabs words ;
IN: help.lint.coverage

<PRIVATE
: $related-subsections ( element -- )
    [ related-words ] [ $subsections ] bi ;
PRIVATE>

ABOUT: "help.lint.coverage"

ARTICLE: "help.lint.coverage" "Help coverage linting"
"The " { $vocab-link "help.lint.coverage" } " vocabulary implements a very picky documentation completeness checker."
$nl
"The documentation coverage linter requires most words to have " { $link POSTPONE: HELP: } " declarations defining some of the "
{ $links $values $description $error-description $class-description $examples } " sections (see " { $links "element-types" } ")."
$nl
"This vocabulary is intended to be used alongside and after " { $vocab-link "help.lint" } ", not as a replacement for it."
$nl
"These words are provided to aid in writing more complete documentation:"
{ $related-subsections
    <word-help-coverage>
    <vocab-help-coverage>
    <prefix-help-coverage>
}

"Coverage reports:"
{ $related-subsections
    word-help-coverage
    print-coverage
} ;

{ <word-help-coverage> <vocab-help-coverage> <prefix-help-coverage> word-help-coverage }
related-words

HELP: word-help-coverage
{ $class-description "A documentation coverage report for a single word." } ;

HELP: print-coverage
{ $values { "coverage" word-help-coverage } }
{ $contract "Displays a coverage object." }
{ $examples
    { $example
        "USING: help.lint.coverage io ;"
        "\\ <word-help-coverage> <word-help-coverage> print-coverage"
        "Word '<word-help-coverage>' has 100% help coverage"
    }
} ;

HELP: <prefix-help-coverage>
{ $values { "prefix" string } { "private?" boolean } { "coverage" sequence } }
{ $description "Runs the help coverage checker on every child vocabulary of the given " { $snippet "prefix" } ", including the base vocabulary. If " { $snippet "private?" } " is " { $snippet "f" } ", the prefix's child " { $snippet ".private" } " vocabularies are not checked. If " { $snippet "private?" } " is " { $snippet "t" } ", " { $emphasis "all" } " child vocabularies are checked." }
{ $examples
    { $example
        "USING: help.lint.coverage prettyprint ;"
        "\"help.lint.coverage\" f <prefix-help-coverage> ."
"{
    {
        T{ word-help-coverage
            { word-name <prefix-help-coverage> }
            { 100%-coverage? t }
        }
        T{ word-help-coverage
            { word-name <vocab-help-coverage> }
            { 100%-coverage? t }
        }
        T{ word-help-coverage
            { word-name <word-help-coverage> }
            { 100%-coverage? t }
        }
        T{ word-help-coverage
            { word-name print-coverage }
            { 100%-coverage? t }
        }
        T{ word-help-coverage
            { word-name word-help-coverage }
            { 100%-coverage? t }
        }
        T{ word-help-coverage
            { word-name word-help-coverage? }
            { 100%-coverage? t }
        }
    }
    { }
}"
    }
} ;

HELP: <word-help-coverage>
{ $values { "word" { $or string word } } { "coverage" word-help-coverage } }
{ $contract "Looks up a word in the current scope and generates a documentation coverage report for it."}
{ $examples
    { $example
        "USING: help.lint.coverage prettyprint ;"
        "\\ <word-help-coverage> <word-help-coverage> ."
"T{ word-help-coverage
    { word-name <word-help-coverage> }
    { 100%-coverage? t }
}"
    }
} ;

HELP: <vocab-help-coverage>
{ $values { "vocab-spec" { $or vocab string } } { "coverage" sequence } }
{ $description "Runs the help coverage checker on the vocabulary in the given " { $snippet "vocab-spec" } "." }
{ $examples
    { $example
        "USING: help.lint.coverage prettyprint ;"
        "\"help.lint.coverage\" <vocab-help-coverage> ."
"{
    T{ word-help-coverage
        { word-name <prefix-help-coverage> }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name <vocab-help-coverage> }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name <word-help-coverage> }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name print-coverage }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name word-help-coverage }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name word-help-coverage? }
        { 100%-coverage? t }
    }
}"
    }
} ;
