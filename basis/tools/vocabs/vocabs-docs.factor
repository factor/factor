USING: help.markup help.syntax strings ;
IN: tools.vocabs

ARTICLE: "tools.vocabs" "Vocabulary tools"
"Reloading source files changed on disk:"
{ $subsection refresh }
{ $subsection refresh-all }
"Vocabulary summaries:"
{ $subsection vocab-summary }
{ $subsection set-vocab-summary }
"Vocabulary tags:"
{ $subsection vocab-tags }
{ $subsection set-vocab-tags }
{ $subsection add-vocab-tags }
"Getting and setting vocabulary meta-data:"
{ $subsection vocab-file-contents }
{ $subsection set-vocab-file-contents }
"Global meta-data:"
{ $subsection all-vocabs }
{ $subsection all-vocabs-seq }
{ $subsection all-tags }
{ $subsection all-authors }
"Because loading the above data is expensive, it is cached. The cache is flushed by the " { $vocab-link "tools.vocabs.monitor" } " vocabulary. It can also be flushed manually when file system change monitors are not available:"
{ $subsection reset-cache } ;

ABOUT: "tools.vocabs"

HELP: vocab-files
{ $values { "vocab" "a vocabulary specifier" } { "seq" "a sequence of pathname strings" } }
{ $description "Outputs a sequence of files comprising this vocabulary, or " { $link f } " if the vocabulary does not have a directory on disk." } ;

HELP: vocab-tests
{ $values { "vocab" "a vocabulary specifier" } { "tests" "a sequence of pathname strings" } }
{ $description "Outputs a sequence of pathnames where the unit tests for " { $snippet "vocab" } " are located." } ;

HELP: source-modified?
{ $values { "path" "a pathname string" } { "?" "a boolean" } }
{ $description "Tests if the source file has been modified since it was last loaded. This compares the file's CRC32 checksum of the file's contents against the previously-recorded value." } ;

HELP: refresh
{ $values { "prefix" string } }
{ $description "Reloads source files and documentation belonging to loaded vocabularies whose names are prefixed by " { $snippet "prefix" } " which have been modified on disk." } ;

HELP: refresh-all
{ $description "Reloads source files and documentation for all loaded vocabularies which have been modified on disk." } ;

{ refresh refresh-all } related-words

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

HELP: load-all-under
{ $values { "prefix" string } }
{ $description "Load all vocabularies that match the provided prefix." } ;

HELP: all-vocabs-under
{ $values { "prefix" string } }
{ $description "Return a sequence of vocab or vocab-links for each vocab matching the provided prefix. Unlike " { $link all-child-vocabs } " this word will return both loaded and unloaded vocabularies." } ;
