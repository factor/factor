USING: help.markup help.syntax strings words compiler.units ;
IN: vocabs

ARTICLE: "vocabularies" "Vocabularies"
"A " { $emphasis "vocabulary" } " is a named collection of words. Vocabularies are defined in the " { $vocab-link "vocabs" } " vocabulary."
$nl
"Vocabularies are stored in a global hashtable:"
{ $subsection dictionary }
"Vocabularies form a class."
{ $subsection vocab }
{ $subsection vocab? }
"Various vocabulary words are overloaded to accept a " { $emphasis "vocabulary specifier" } ", which is a string naming the vocabulary, the " { $link vocab } " instance itself, or a " { $link vocab-link } ":"
{ $subsection vocab-link }
{ $subsection >vocab-link }
"Looking up vocabularies by name:"
{ $subsection vocab }
"Accessors for various vocabulary attributes:"
{ $subsection vocab-name }
{ $subsection vocab-main }
{ $subsection vocab-help }
"Looking up existing vocabularies and creating new vocabularies:"
{ $subsection vocab }
{ $subsection child-vocabs }
{ $subsection create-vocab }
"Getting words from a vocabulary:"
{ $subsection vocab-words }
{ $subsection words }
{ $subsection all-words }
{ $subsection words-named }
"Removing a vocabulary:"
{ $subsection forget-vocab }
{ $see-also "words" "vocabs.loader" } ;

ABOUT: "vocabularies"

HELP: dictionary
{ $var-description "Holds a hashtable mapping vocabulary names to vocabularies." } ;

HELP: vocabs
{ $values { "seq" "a sequence of strings" } }
{ $description "Outputs a sequence of all defined vocabulary names." } ;

HELP: vocab
{ $values { "vocab-spec" "a vocabulary specifier" } { "vocab" vocab } }
{ $description "Outputs a named vocabulary, or " { $link f } " if no vocabulary with this name exists." }
{ $class-description "Instances represent vocabularies." } ;

HELP: vocab-name
{ $values { "vocab-spec" "a vocabulary specifier" } { "name" string } }
{ $description "Outputs the name of a vocabulary." } ;

HELP: vocab-words
{ $values { "vocab-spec" "a vocabulary specifier" } { "words" "an assoc mapping strings to words" } }
{ $description "Outputs the words defined in a vocabulary." } ;

HELP: words
{ $values { "vocab" string } { "seq" "a sequence of words" } }
{ $description "Outputs a sequence of words defined in the vocabulary, or " { $link f } " if no vocabulary with this name exists." } ;

HELP: all-words
{ $values { "seq" "a sequence of words" } }
{ $description "Outputs a sequence of all words in the dictionary." } ;

HELP: forget-vocab
{ $values { "vocab" string } }
{ $description "Removes a vocabulary. All words in the vocabulary are forgotten." }
{ $notes "This word must be called from inside " { $link with-compilation-unit } "." } ;

HELP: load-vocab-hook
{ $var-description { $quotation "( name -- vocab )" } " which loads a vocabulary. This quotation is called by " { $link load-vocab } ". The default value should not need to be changed; this functinality is implemented via a hook stored in a variable to break a circular dependency which would otherwise exist from " { $vocab-link "vocabs" } " to " { $vocab-link "vocabs.loader" } " to " { $vocab-link "parser" } " back to " { $vocab-link "vocabs" } "." } ;

HELP: words-named
{ $values { "str" string } { "seq" "a sequence of words" } }
{ $description "Outputs a sequence of all words named " { $snippet "str" } " from the set of currently-loaded vocabularies." } ;

HELP: create-vocab
{ $values { "name" string } { "vocab" vocab } }
{ $description "Creates a new vocabulary if one does not exist with the given name, otherwise outputs an existing vocabulary." } ;

HELP: child-vocabs
{ $values { "vocab" "a vocabulary specifier" } { "seq" "a sequence of strings" } }
{ $description "Outputs all vocabularies which are conceptually under " { $snippet "vocab" } " in the hierarchy." }
{ $examples
    { $unchecked-example
        "\"io.streams\" child-vocabs ."
        "{\n    \"io.streams.c\"\n    \"io.streams.duplex\"\n    \"io.streams.lines\"\n    \"io.streams.nested\"\n    \"io.streams.plain\"\n    \"io.streams.string\"\n}"
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