USING: help help.lint.pedantic help.markup help.syntax kernel
strings words vocabs ;
IN: help.lint.pedantic

ABOUT: "help.lint.pedantic"

ARTICLE: "help.lint.pedantic" "Pedantic help coverage"
"The " { $vocab-link "help.lint.pedantic" } " vocabulary implements a very picky documentation completeness checker. Intended to be used alongside " { $vocab-link "help.lint" } " in writing documenation, the pedantic linter requires all ordinary words to have documentation defining the "
{ $link $example } ", "
{ $link $description } ", and "
{ $link $values }
" sections (see " { $link "element-types" } ")."
$nl
"The following words are provided to aid in writing more complete documentation:"
{ $subsections
    word-pedant
    vocab-pedant
    prefix-pedant
} ;

{ word-pedant vocab-pedant prefix-pedant } related-words

HELP: ordinary-word-missing-section
{ $values { "missing-section" string } { "word-name" string } }
{ $description "Throws an " { $link ordinary-word-missing-section } " error." }
{ $error-description "Thrown when an ordinary word's documentation is missing one of the sections " { $links $values $description $example } "." } ;

HELP: prefix-pedant
{ $values { "prefix" string } { "private?" boolean } }
{ $description "Runs the help coverage checker on every child vocabulary of the given " { $snippet "prefix" } ", including the base vocabulary. If " { $snippet "private?" } " is " { $snippet "f" } ", the prefix's child " { $snippet ".private" } " vocabularies are not checked. If " { $snippet "private?" } " is " { $snippet "t" } ", " { $emphasis "all" } " child vocabularies are checked." }
{ $errors
    { $link empty-examples } " if a word has an empty " { $snippet "$examples" } " section
"
    { $link ordinary-word-missing-section } " if a word is missing a section entirely"
}
{ $examples
  { $example
      "USING: help.lint.pedantic ;"
      "\"help.lint.pedantic\" f prefix-pedant"
      ""
  }
} ;

HELP: word-pedant
{ $values { "word" { $or string word } } }
{ $description "Runs the help coverage checker on the word described by " { $snippet "word-desc" } "." }
{ $errors
    { $link empty-examples } " if a word has an empty " { $snippet "$examples" } " section
"
    { $link ordinary-word-missing-section } " if a word is missing a section entirely"
}
{ $examples
    { $example
        "USING: help.lint.pedantic ;"
        "\\ word-pedant word-pedant"
        ""
    }
} ;

HELP: vocab-pedant
{ $values { "vocab-spec" { $or vocab string } } }
{ $description "Runs the help coverage checker on the vocabulary in the given " { $snippet "vocab-spec" } "." }
{ $errors
    { $link empty-examples } " if a word has an empty " { $snippet "$examples" } " section
"
    { $link ordinary-word-missing-section } " if a word is missing a section entirely"
}
{ $examples
    { $example
      "USING: help.lint.pedantic ;"
      "\"help.lint.pedantic\" vocab-pedant"
      ""
    }
} ;
