! (c)2010 Joe Groff bsd license
USING: help.markup help.syntax kernel ;
IN: vocabs.metadata.resources

HELP: expand-vocab-resource-files
{ $values
    { "vocab" "a vocabulary specifier" } { "resource-glob-strings" "a sequence of glob patterns" }
    { "filenames" "a sequence of filenames" }
}
{ $description "Matches all the glob patterns in " { $snippet "resource-glob-strings" } " to the set of files inside " { $snippet "vocab" } "'s directory and outputs a sequence containing the individual files and directories that match. Any matching directories will also have their contents recursively included in the output. The paths in the output will be relative to " { $snippet "vocab" } "'s directory." } ;

HELP: vocab-resource-files
{ $values
    { "vocab" "a vocabulary specifier" }
    { "filenames" "a sequence of filenames" }
}
{ $description "Outputs a sequence containing the individual resource files and directories that match the patterns specified in " { $snippet "vocab" } "'s " { $snippet "resources.txt" } " file. Any matching directories will also have their contents recursively included in the output. The paths in the output will be relative to " { $snippet "vocab" } "'s directory." } ;

ARTICLE: "vocabs.metadata.resources" "Vocabulary resource metadata"
"The " { $vocab-link "vocabs.metadata.resources" } " vocabulary contains words to retrieve the full list of files that match the patterns specified in a vocabulary's " { $snippet "resources.txt" } " file."
{ $subsections
    vocab-resource-files
    expand-vocab-resource-files
} ;

ABOUT: "vocabs.metadata.resources"
