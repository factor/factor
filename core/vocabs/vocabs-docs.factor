USING: help.markup help.syntax strings words compiler.units
vocabs.loader assocs ;
IN: vocabs

ARTICLE: "vocabularies" "Vocabularies"
"A " { $emphasis "vocabulary" } " is a named collection of " { $link "words" } ". Vocabularies are defined in the " { $vocab-link "vocabs" } " vocabulary."
$nl
"Vocabularies are stored in a global hashtable:"
{ $subsections dictionary }
"Vocabularies form a class."
{ $subsections
    vocab
    vocab?
}
"Various vocabulary words are overloaded to accept a " { $emphasis "vocabulary specifier" } ", which is a string naming the vocabulary, the " { $link vocab } " instance itself, or a " { $link vocab-link } ":"
{ $subsections
    vocab-link
    >vocab-link
}
"Looking up vocabularies by name:"
{ $subsections vocab }
"Accessors for various vocabulary attributes:"
{ $subsections
    vocab-name
    vocab-main
    vocab-help
}
"Looking up existing vocabularies and creating new vocabularies:"
{ $subsections
    lookup-vocab
    loaded-child-vocab-names
    create-vocab
}
"Getting words from a vocabulary:"
{ $subsections
    vocab-words-assoc
    vocab-words
    all-words
    words-named
}
"Removing a vocabulary:"
{ $subsections forget-vocab }
{ $see-also "words" "vocabs.loader" "word-search" } ;

ABOUT: "vocabularies"

HELP: dictionary
{ $var-description "Holds a hashtable mapping vocabulary names to vocabularies." } ;

HELP: loaded-vocab-names
{ $values { "seq" { $sequence string } } }
{ $description "Outputs a sequence of all defined vocabulary names." } ;

HELP: lookup-vocab
{ $values { "vocab-spec" "a vocabulary specifier" } { "vocab" vocab } }
{ $description "Outputs a named vocabulary, or " { $link f } " if no vocabulary with this name exists." } ;

HELP: vocab
{ $class-description "Instances represent vocabularies." } ;

HELP: vocab-name
{ $values { "vocab-spec" "a vocabulary specifier" } { "name" string } }
{ $description "Outputs the name of a vocabulary." } ;

HELP: vocab-words-assoc
{ $values { "vocab-spec" "a vocabulary specifier" } { "assoc/f" { $maybe assoc } } }
{ $description "Outputs the words defined in a vocabulary." } ;

HELP: vocab-words
{ $values { "vocab-spec" vocab-spec } { "seq" { $sequence word } } }
{ $description "Outputs a sequence of words defined in the vocabulary, or " { $link f } " if no vocabulary with this name exists." } ;

HELP: all-words
{ $values { "seq" { $sequence word } } }
{ $description "Outputs a sequence of all words in the dictionary." } ;

HELP: forget-vocab
{ $values { "vocab" string } }
{ $description "Removes a vocabulary. All words in the vocabulary are forgotten." }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." } ;

HELP: require-hook
{ $var-description { $quotation ( name -- ) } " which loads a vocabulary. This quotation is called by " { $link require } ". The default value should not need to be changed; this functionality is implemented via a hook stored in a variable to break a circular dependency which would otherwise exist from " { $vocab-link "vocabs" } " to " { $vocab-link "vocabs.loader" } " to " { $vocab-link "parser" } " back to " { $vocab-link "vocabs" } "." } ;

HELP: require
{ $values { "object" "a vocabulary specifier" } }
{ $description "Loads a vocabulary if it has not already been loaded. Throws an error if the vocabulary does not exist on disk or in the dictionary." }
{ $notes "To unconditionally reload a vocabulary, use " { $link reload } ". To reload changed source files only, use the words in " { $link "vocabs.refresh" } "." } ;

HELP: words-named
{ $values { "str" string } { "seq" { $sequence word } } }
{ $description "Outputs a sequence of all words named " { $snippet "str" } " from the set of currently-loaded vocabularies." } ;

HELP: create-vocab
{ $values { "name" string } { "vocab" vocab } }
{ $description "Creates a new vocabulary if one does not exist with the given name, otherwise outputs an existing vocabulary." } ;

HELP: loaded-child-vocab-names
{ $values { "vocab-spec" "a vocabulary specifier" } { "seq" { $sequence string } } }
{ $description "Outputs all vocabularies which are conceptually under " { $snippet "vocab" } " in the hierarchy." }
{ $examples
    { $unchecked-example
        "\"io.streams\" loaded-child-vocab-names ."
        "{ \"io.streams.c\" \"io.streams.duplex\" \"io.streams.lines\" \"io.streams.nested\" \"io.streams.plain\" \"io.streams.string\" }"
    }
} ;

HELP: vocab-link
{ $class-description "Instances of this class identify vocabularies which are potentially not loaded. The " { $link vocab-name } " slot is the vocabulary name."
$nl
"Vocabulary links are created by calling " { $link >vocab-link } "."
} ;

HELP: >vocab-link
{ $values { "name" string } { "vocab" "a vocabulary specifier" } }
{ $description "If the vocabulary is loaded, outputs the corresponding " { $link vocab } " instance, otherwise creates a new " { $link vocab-link } "." } ;

HELP: runnable-vocab
{ $class-description "The class of vocabularies with a " { $slot "main" } " word." } ;
