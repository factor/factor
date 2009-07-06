USING: help.markup help.syntax strings vocabs.loader ;
IN: vocabs.hierarchy

ARTICLE: "vocabs.hierarchy" "Vocabulary hierarchy tools"
"These tools operate on all vocabularies found in the current set of " { $link vocab-roots } ", loaded or not."
$nl
"Loading vocabulary hierarchies:"
{ $subsection load }
{ $subsection load-all }
"Getting all vocabularies from disk:"
{ $subsection all-vocabs }
{ $subsection all-vocabs-recursive }
"Getting all vocabularies from disk whose names which match a string prefix:"
{ $subsection child-vocabs }
{ $subsection child-vocabs-recursive }
"Getting " { $link "vocabs.metadata" } " for all vocabularies from disk:"
{ $subsection all-tags }
{ $subsection all-authors } ;

ABOUT: "vocabs.hierarchy"

HELP: load
{ $values { "prefix" string } }
{ $description "Load all vocabularies that match the provided prefix." }
{ $notes "This word differs from " { $link require } " in that it loads all subvocabularies, not just the given one." } ;

HELP: load-all
{ $description "Load all vocabularies in the source tree." } ;

