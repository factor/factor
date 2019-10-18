USING: help.markup help.syntax strings vocabs.loader ;
IN: vocabs.hierarchy

ARTICLE: "vocabs.hierarchy" "Vocabulary hierarchy tools"
"These tools operate on all vocabularies found in the current set of " { $link vocab-roots } ", loaded or not."
$nl
"Loading vocabulary hierarchies:"
{ $subsections
    load
    load-all
}
"Getting all vocabularies from disk:"
{ $subsections
    all-vocabs
    all-vocabs-recursive
}
"Getting all vocabularies from disk whose names which match a string prefix:"
{ $subsections
    child-vocabs
    child-vocabs-recursive
}
"Words for modifying output:"
{ $subsections
    no-roots
    no-prefixes
}
"Getting " { $link "vocabs.metadata" } " for all vocabularies from disk:"
{ $subsections
    all-tags
    all-authors
} ;

ABOUT: "vocabs.hierarchy"

HELP: load
{ $values { "prefix" string } }
{ $description "Load all vocabularies that match the provided prefix." }
{ $notes "This word differs from " { $link require } " in that it loads all subvocabularies, not just the given one." } ;

HELP: load-all
{ $description "Load all vocabularies in the source tree." } ;

