! Copyright (C) 2018 Cat Stevens
USING: arrays assocs help.markup help.syntax kernel math
sequences strings ;
IN: english

<PRIVATE
: $0-plurality ( children -- )
    drop {
        "Due to the unique way in which the English language is structured, the number "
        { $snippet "0" }
        " is considered plural; "
        { $snippet "1" }
        " is the only singular quantity."
    } print-element ;

: $keep-case ( children -- )
    drop
    "This word attempts to preserve the letter case style of the input." print-element ;
PRIVATE>

ABOUT: "english"

ARTICLE: "english" "English natural language transformations"

"The " { $vocab-link "english" } " vocabulary implements a few simple ways of interacting with text in the English language, for improving generated text."
$nl
"Plural and singular forms:"
{ $subsections plural? pluralize ?pluralize count-of-things singular? singularize }

"Toy grammatical words:"
{ $subsections a/an ?plural-article a10n comma-list }
;

{ pluralize ?pluralize plural? count-of-things singularize singular? } related-words
{ a/an ?plural-article a10n comma-list } related-words

HELP: singularize
{ $values { "word" string } { "singular" string } }
{ $description "Determine the singular form of the input English word. If the input is already singular, it is returned unchanged." }
{ $notes $keep-case  }
{ $examples
    { $example
        "USING: english io ;"
        "\"CATS\" singularize print"
        "CAT"
    }
    { $example
        "USING: english io ;"
        "\"Octopi\" singularize print"
        "Octopus"
    }
} ;

HELP: singular?
{ $values { "word" string } { "?" boolean } }
{ $description "Attempt to determine whether the word is in singular form." }
{ $examples
    { $example
        "USING: english prettyprint ;"
        "\"octopi\" plural? ."
        "t"
    }
} ;

HELP: pluralize
{ $values { "word" string } { "plural" string } }
{ $description "Determine the plural form of the input English word. If the input is already plural, it " { $emphasis "might" } " be returned unchanged." }
{ $notes { $list { "If the input is already in plural form, an invaid construct such as " { $emphasis "friendses" } " may be generated. This is difficult to avoid due to the unpredictable structure of the English language." } $keep-case } }
{ $examples
    { $example
        "USING: english io ;"
        "\"CAT\" pluralize print"
        "CATS"
    }
    { $example
        "USING: english io ;"
        "\"Octopus\" pluralize print"
        "Octopi"
    }
} ;

HELP: plural?
{ $values { "word" string } { "?" boolean } }
{ $description "Attempt to determine whether the word is in plural form." }
{ $examples
    { $example
        "USING: english prettyprint ;"
        "\"octopus\" singular? ."
        "t"
    }
} ;

HELP: count-of-things
{ $values { "count" number } { "word" string } { "str" string } }
{ $description "Transform a quantity and a word into a construct consisting of the quantity, and the correct plural or singular form of the word. " { $snippet "word" } " is expected to be in singular form." }
{ $notes { $list $keep-case $0-plurality } }
{ $examples
    { $example
        "USING: english io ;"
        "10 \"baby\" count-of-things print"
        "10 babies"
    }
    { $example
        "USING: english io ;"
        "2.5 \"FISH\" count-of-things print"
        "2.5 FISH"
    }
} ;

HELP: ?pluralize
{ $values { "count" number } { "singular" string } { "singular/plural" string } }
{ $description "A simpler variant of " { $link count-of-things } " which omits its input value from the output. As with " { $link count-of-things } ", " { $snippet "word" } " is expected to be in singular form." }
{ $notes { $list $keep-case $0-plurality } }
{ $examples
    { $example
        "USING: english io ;"
        "14 \"criterion\" ?pluralize print"
        "criteria"
    }
} ;

HELP: a10n
{ $values { "word" string } { "numeronym" string } }
{ $description "Abbreviates a word of more than three characters, by replacing the inner part of the word with the number of omitted letters. The result is an abbreviation (called a " { $emphasis "numeronym" } ") which is pronounced like the original word." }
{ $notes { $list
    $keep-case
    "When the input is too short, it is returned unchanged."
    { "The name of this word is " { $snippet "abbreviation" } ", abbreviated by its own strategy." }
    { "This style of abbreviation originated with " { $snippet "i18n" } " (the word " { $emphasis "internationalization" } ") in the 1980s." }
} }
{ $examples
    { $example
        "USING: english io ;"
        "\"dup\" a10n print"
        "dup"
    }
    { $example
        "USING: english io ;"
        "\"abbreviationalism\" a10n print"
        "a15m"
    }
} ;

HELP: a/an
{ $values { "word" string } { "article" { $or "\"a\"" "\"an\"" } } }
{ $description "Gives the proper indefinite singular article (" { $emphasis "a" } " or " { $emphasis "an" } ") for the word. For words which begin with a vowel sound, " { $emphasis "an" } " is used, whereas " { $emphasis "a" } " is used for words which begin with a consonant sound." }
{ $notes "The output does not contain the input. The output of this word is always a singular article, regardless of the plurality of the input." }
{ $examples
    { $example
        "USING: english kernel combinators sequences io ;"
        "\"object\" [ a/an ] keep \" \" glue print"
        "an object"
    }
} ;

HELP: ?plural-article
{ $values { "word" string } { "article" { $or "\"a\"" "\"an\"" "\"the\"" } } }
{ $description "Output the proper article given the plurality and first letter of the input. Unlike " { $link a/an } " this word handles plural inputs by outputting the definite " { $emphasis "\"the\"" } ". If the input is singular as determined by " { $link singular? } " this word operates like " { $link a/an } "." }
{ $notes { $list "English lacks a plural indefinite article, so the plural definite is used here instead." $keep-case $0-plurality } }
{ $examples
    { $example
        "USING: english sequences kernel io ;"
        "\"cat\" [ ?plural-article ] keep \" \" glue print"
        "a cat"
    }
    { $example
        "USING: english sequences kernel io ;"
        "\"cats\" [ ?plural-article ] keep \" \" glue print"
        "the cats"
    }
} ;

HELP: comma-list
{ $values
    { "parts" sequence }
    { "conjunction" string }
    { "clause-seq" sequence }
}
{ $description "Generate a comma-separated list of things, emplacing " { $snippet "conjunction" } " before the last " { $snippet "part" } " if there are two or more elements in " { $snippet "parts" } "." }
{ $notes $keep-case }
{ $examples
    { $example
        "USING: english io sequences ;"
        "{ \"a cat\" \"a peach\" \"an object\" } \"or\" comma-list concat print"
        "a cat, a peach, or an object"
    }
} ;
