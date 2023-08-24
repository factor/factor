USING: help.markup help.syntax strings vocabs.loader
sequences vocabs ;
IN: vocabs.hierarchy

ARTICLE: "vocabs.hierarchy" "Vocabulary hierarchy tools"
"These tools operate on all vocabularies found in the current set of " { $link vocab-roots } ", loaded or not. A prefix is the first part of a vocabulary name."
$nl
"Loading vocabulary hierarchies:"
{ $subsections
    load
    load-all
    load-root
    load-from-root
}
"Getting all vocabularies from disk:"
{ $subsections
    all-disk-vocabs-by-root
    all-disk-vocabs-recursive
}
"Getting all vocabularies from disk whose names which match a string prefix:"
{ $subsections
    disk-vocabs-for-prefix
    disk-vocabs-recursive-for-prefix
}
"Words for modifying output:"
{ $subsections
    no-roots
    no-prefixes
    filter-vocabs
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

HELP: load-from-root
{ $values
    { "root" "a vocabulary root" } { "prefix" string }
}
{ $description "Attempts to load all of the vocabularies with a certain prefix from a vocabulary root." } ;

HELP: load-root
{ $values
    { "root" "a vocabulary root" }
}
{ $description "Attempts to load all of the vocabularies in a vocabulary root." } ;
