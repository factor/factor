USING: help.markup help.syntax io strings ;
IN: tools.browser

ARTICLE: "vocab-index" "Vocabulary index"
{ $tags }
{ $authors }
{ $describe-vocab "" } ;

ARTICLE: "tools.browser" "Vocabulary browser"
"Getting and setting vocabulary meta-data:"
{ $subsection vocab-file-contents }
{ $subsection set-vocab-file-contents }
{ $subsection vocab-summary }
{ $subsection set-vocab-summary }
{ $subsection vocab-tags }
{ $subsection set-vocab-tags }
{ $subsection add-vocab-tags }
"Global meta-data:"
{ $subsection all-vocabs }
{ $subsection all-vocabs-seq }
{ $subsection all-tags }
{ $subsection all-authors }
"Because loading the above data is expensive, it is cached. The cache is flushed by the " { $vocab-link "vocabs.monitor" } " vocabulary. It can also be flushed manually when file system change monitors are not available:"
{ $subsection reset-cache } ;

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

HELP: all-vocabs
{ $values { "assoc" "an association list mapping vocabulary roots to sequences of vocabulary specifiers" } }
{ $description "Outputs an association list of all vocabularies which have been loaded or are available for loading." } ;
