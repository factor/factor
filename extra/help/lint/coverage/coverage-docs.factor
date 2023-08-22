USING: help.markup help.syntax io kernel sequences strings
vocabs words ;
IN: help.lint.coverage

<PRIVATE
: $related-subsections ( element -- )
    [ related-words ] [ $subsections ] bi ;
PRIVATE>

ABOUT: "help.lint.coverage"

ARTICLE: "help.lint.coverage" "Help coverage linting"
"The " { $vocab-link "help.lint.coverage" } " vocabulary implements a very pedantic documentation completeness checker."
$nl
"The documentation coverage linter requires most words to have " { $link POSTPONE: HELP: } " declarations defining some of the "
{ $links $values $description $error-description $class-description $examples } " sections (see " { $links "element-types" } ")."
$nl
"This vocabulary is intended to be used alongside and after " { $vocab-link "help.lint" } ", not as a replacement for it."
$nl
"These words are provided to aid in writing more complete documentation:"
{ $related-subsections
    word-help-coverage.
    vocab-help-coverage.
    prefix-help-coverage.
}

"Coverage report objects:"
{ $related-subsections
    word-help-coverage
    help-coverage.
}

"Raw report generation:"
{ $related-subsections
    <word-help-coverage>
    <vocab-help-coverage>
    <prefix-help-coverage>
} ;

{ word-help-coverage word-help-coverage. <word-help-coverage> <vocab-help-coverage> <prefix-help-coverage> }
related-words

HELP: word-help-coverage
{ $class-description "A documentation coverage report for a single word." } ;

HELP: help-coverage.
{ $values { "coverage" word-help-coverage } }
{ $contract "Displays a coverage object." }
{ $examples
    { $example
        "USING: help.lint.coverage ;"
        "\\ <word-help-coverage> <word-help-coverage> help-coverage."
        "[help.lint.coverage] <word-help-coverage>: full help coverage"
    }
} ;

HELP: word-help-coverage.
{ $values { "word-spec" { $or word string } } }
{ $description "Prettyprints a help coverage report of " { $snippet "word-spec" } " to " { $link output-stream } "." }
{ $examples
    { $example
        "USING: sequences help.lint.coverage ;"
        "\\ map word-help-coverage."
        "[sequences] map: needs help section: $examples"
    }
} ;

HELP: vocab-help-coverage.
{ $values { "vocab-spec" { $or vocab string } } }
{ $description "Prettyprints a help coverage report of " { $snippet "vocab-spec" } " to " { $link output-stream } "." }
{ $examples
    { $example
        "USING: help.lint.coverage ;"
        "\"english\" vocab-help-coverage."
"[english] ?plural-article: full help coverage
[english] ?pluralize: full help coverage
[english] a/an: full help coverage
[english] a10n: full help coverage
[english] comma-list: full help coverage
[english] count-of-things: full help coverage
[english] plural?: full help coverage
[english] pluralize: full help coverage
[english] singular?: full help coverage
[english] singularize: full help coverage
[english] vowel?: needs help sections: $values, $description, and $examples
[english] vowels: needs help sections: $values, $description, and $examples

83.3% of words have complete documentation"
    }
} ;

HELP: prefix-help-coverage.
{ $values { "prefix-spec" { $or vocab string } } { "private?" boolean } }
{ $description "Prettyprints a help coverage report of " { $snippet "prefix-spec" } " to " { $link output-stream } "." }
{ $examples
    { $example
        "USING: help.lint.coverage ;"
        "\"english\" t prefix-help-coverage."
"[english] ?plural-article: full help coverage
[english] ?pluralize: full help coverage
[english] a/an: full help coverage
[english] a10n: full help coverage
[english] comma-list: full help coverage
[english] count-of-things: full help coverage
[english] plural?: full help coverage
[english] pluralize: full help coverage
[english] singular?: full help coverage
[english] singularize: full help coverage
[english] vowel?: needs help sections: $values, $description, and $examples
[english] vowels: needs help sections: $values, $description, and $examples
[english.private] $0-plurality: needs help sections: $values, $description, and $examples
[english.private] $keep-case: needs help sections: $values, $description, and $examples
[english.private] match-case: needs help sections: $values, $description, and $examples
[english.private] plural-to-singular: needs help sections: $values, $description, and $examples
[english.private] singular-to-plural: needs help sections: $values, $description, and $examples

58.8% of words have complete documentation"
    }
} ;

HELP: <prefix-help-coverage>
{ $values { "prefix" string } { "private?" boolean } { "coverage" sequence } }
{ $description "Runs the help coverage checker on every child vocabulary of the given " { $snippet "prefix" } ", including the base vocabulary. If " { $snippet "private?" } " is " { $snippet "f" } ", the prefix's child " { $snippet ".private" } " vocabularies are not checked. If " { $snippet "private?" } " is " { $snippet "t" } ", " { $emphasis "all" } " child vocabularies are checked." }
{ $examples
    { $example
        "USING: help.lint.coverage prettyprint ;"
        "\"english\" t <prefix-help-coverage> ..."
"{
    T{ word-help-coverage
        { word-name ?plural-article }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name ?pluralize }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name a/an }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name a10n }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name comma-list }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name count-of-things }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name plural? }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name pluralize }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name singular? }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name singularize }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name vowel? }
        { omitted-sections { $values $description $examples } }
    }
    T{ word-help-coverage
        { word-name vowels }
        { omitted-sections { $values $description $examples } }
    }
    T{ word-help-coverage
        { word-name $0-plurality }
        { omitted-sections { $values $description $examples } }
    }
    T{ word-help-coverage
        { word-name $keep-case }
        { omitted-sections { $values $description $examples } }
    }
    T{ word-help-coverage
        { word-name match-case }
        { omitted-sections { $values $description $examples } }
    }
    T{ word-help-coverage
        { word-name plural-to-singular }
        { omitted-sections { $values $description $examples } }
    }
    T{ word-help-coverage
        { word-name singular-to-plural }
        { omitted-sections { $values $description $examples } }
    }
}"
    }
} ;

HELP: <word-help-coverage>
{ $values { "word" { $or string word } } { "coverage" word-help-coverage } }
{ $contract "Looks up a word in the current scope and generates a documentation coverage report for it." }
{ $examples
    { $example
        "USING: help.lint.coverage prettyprint ;"
        "\\ <word-help-coverage> <word-help-coverage> ..."
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
        "\"english\" <vocab-help-coverage> ..."
"{
    T{ word-help-coverage
        { word-name ?plural-article }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name ?pluralize }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name a/an }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name a10n }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name comma-list }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name count-of-things }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name plural? }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name pluralize }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name singular? }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name singularize }
        { 100%-coverage? t }
    }
    T{ word-help-coverage
        { word-name vowel? }
        { omitted-sections { $values $description $examples } }
    }
    T{ word-help-coverage
        { word-name vowels }
        { omitted-sections { $values $description $examples } }
    }
}"
    }
} ;
