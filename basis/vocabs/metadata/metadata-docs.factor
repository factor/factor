USING: help.markup help.syntax strings ;
IN: vocabs.metadata

ARTICLE: "vocabs.metadata" "Vocabulary metadata"
"Vocabulary summaries:"
{ $subsection vocab-summary }
{ $subsection set-vocab-summary }
"Vocabulary authors:"
{ $subsection vocab-authors }
{ $subsection set-vocab-authors }
"Vocabulary tags:"
{ $subsection vocab-tags }
{ $subsection set-vocab-tags }
{ $subsection add-vocab-tags }
"Getting and setting arbitrary vocabulary metadata:"
{ $subsection vocab-file-contents }
{ $subsection set-vocab-file-contents } ;

ABOUT: "vocabs.metadata"

HELP: vocab-file-contents
{ $values { "vocab" "a vocabulary specifier" } { "name" string } { "seq" "a sequence of lines, or " { $link f } } }
{ $description "Outputs the contents of the file named " { $snippet "name" } " from the vocabulary's directory, or " { $link f } " if the file does not exist." } ;

HELP: set-vocab-file-contents
{ $values { "seq" "a sequence of lines" } { "vocab" "a vocabulary specifier" } { "name" string } }
{ $description "Stores a sequence of lines to the file named " { $snippet "name" } " from the vocabulary's directory." } ;

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

