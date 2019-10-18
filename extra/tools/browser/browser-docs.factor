USING: help.markup help.syntax io strings ;
IN: tools.browser

ARTICLE: "tools.browser" "Vocabulary browser"
"Getting and setting vocabulary meta-data:"
{ $subsection vocab-summary }
{ $subsection set-vocab-summary }
{ $subsection vocab-tags }
{ $subsection set-vocab-tags }
{ $subsection add-vocab-tags } ;

HELP: vocab-summary
{ $values { "vocab" "a vocabulary specifier" } { "summary" "a string or " { $link f } } }
{ $description "Outputs a one-line string description of the vocabulary's intended purpose from the " { $snippet "summary.txt" } " file in the vocabulary's directory. Outputs " { $link f } " if the file does not exist." } ;

HELP: set-vocab-summary
{ $values { "string" "a string or " { $link f } } { "vocab" "a vocabulary specifier" } }
{ $description "Stores a one-line string description of the vocabulary to the " { $snippet "summary.txt" } " file in the vocabulary's directory." } ;

HELP: vocab-tags
{ $values { "vocab" "a vocabulary specifier" } { "tags" "a sequence of strings" } }
{ $description "Outputs a list of short tags classifying the vocabulary from the " { $snippet "tags.txt" } " file in the vocabulary's directory. Outputs " { $link f } " if the file does not exist." } ;

HELP: set-vocab-tags
{ $values { "tags" "a sequence of strings" } { "vocab" "a vocabulary specifier" } }
{ $description "Stores a list of short tags classifying the vocabulary to the " { $snippet "tags.txt" } " file in the vocabulary's directory." } ;

HELP: all-vocabs
{ $values { "assoc" "an association list mapping vocabulary roots to sequences of vocabulary specifiers" } }
{ $description "Outputs an association list of all vocabularies which have been loaded or are available for loading." } ;
