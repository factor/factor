USING: help help.lint.pedantic help.lint.pedantic.private help.markup help.syntax kernel
sequences strings vocabs words ;
IN: help.lint.pedantic

ABOUT: "help.lint.pedantic"

ARTICLE: "help.lint.pedantic" "Pedantic help coverage"
"pedant, " { $emphasis "n." } " one who pays more attention to formal rules and book learning than they merit."
$nl
"The " { $vocab-link "help.lint.pedantic" } " vocabulary implements a very picky documentation completeness checker -- your very own documentation pedant."
$nl
"The pedantic linter requires most words to have documentation defining the "
{ $links $values $description $error-description $class-description $examples } " sections (see " { $links "element-types" } ")."
$nl
"This vocabulary is intended to be used alongside and after " { $vocab-link "help.lint" } ", not as a replacement for it."
$nl
"These words are provided to aid in writing more complete documentation:"
{ $subsections
    word-pedant
    vocab-pedant
    prefix-pedant
} ;

{ word-pedant vocab-pedant prefix-pedant } related-words
{ missing-sections empty-examples } related-words

HELP: missing-sections
{ $values { "missing-sections" sequence } { "word-name" word } }
{ $description "Throws an " { $link missing-sections } " error." }
{ $error-description "Thrown when a word's documentation is missing one or more sections required for it by " { $link should-define } "." } ;

HELP: empty-examples
{ $values { "word-name" word } }
{ $description "Throws an " { $link empty-examples } " error." }
{ $error-description "Thrown when a word's " { $link $examples } " section is missing or empty." } ;

HELP: prefix-pedant
{ $values { "prefix" string } { "private?" boolean } }
{ $description "Runs the help coverage checker on every child vocabulary of the given " { $snippet "prefix" } ", including the base vocabulary. If " { $snippet "private?" } " is " { $snippet "f" } ", the prefix's child " { $snippet ".private" } " vocabularies are not checked. If " { $snippet "private?" } " is " { $snippet "t" } ", " { $emphasis "all" } " child vocabularies are checked." }
{ $errors
    { $link empty-examples } " if a word has an empty " { $snippet "$examples" } " section
"
    { $link missing-sections } " if a word is missing a section entirely"
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
    { $link missing-sections } " if a word is missing a section entirely"
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
    { $link missing-sections } " if a word is missing a section entirely"
}
{ $examples
    { $example
      "USING: help.lint.pedantic ;"
      "\"help.lint.pedantic\" vocab-pedant"
      ""
    }
} ;
