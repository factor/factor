USING: help.markup help.syntax strings vocabs.loader ;
IN: vocabs.hierarchy

ARTICLE: "vocabs.hierarchy" "Vocabulary hierarchy tools"
"These tools operate on all vocabularies found in the current set of " { $link vocab-roots } ", loaded or not."
$nl
"Loading vocabulary hierarchies:"
{ $subsection load }
{ $subsection load-all }
"Getting all vocabularies on disk:"
{ $subsection all-vocabs }
{ $subsection all-vocabs-seq }
"Getting " { $link "vocabs.metadata" } " for all vocabularies on disk:"
{ $subsection all-tags }
{ $subsection all-authors } ;

ABOUT: "vocabs.hierarchy"

HELP: all-vocabs
{ $values { "assoc" "an association list mapping vocabulary roots to sequences of vocabulary specifiers" } }
{ $description "Outputs an association list of all vocabularies which have been loaded or are available for loading." } ;

HELP: load
{ $values { "prefix" string } }
{ $description "Load all vocabularies that match the provided prefix." }
{ $notes "This word differs from " { $link require } " in that it loads all subvocabularies, not just the given one." } ;

HELP: load-all
{ $description "Load all vocabularies in the source tree." } ;

HELP: all-vocabs-under
{ $values { "prefix" string } }
{ $description "Return a sequence of vocab or vocab-links for each vocab matching the provided prefix. Unlike " { $link all-child-vocabs } " this word will return both loaded and unloaded vocabularies." } ;
