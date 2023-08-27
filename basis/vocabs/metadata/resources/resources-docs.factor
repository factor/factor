! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax strings ;
IN: vocabs.metadata.resources

HELP: copy-vocab-resources
{ $values { "dir" string } { "vocab" string } }
{ $description "Copies all the vocabs resource files to the given directory." } ;

HELP: match-patterns
{ $values
  { "patterns" "a sequence of glob patterns" }
  { "filenames" "a sequence of filenames" }
  { "filenames'" "a filtered sequence of filenames" }
}
{ $description "Matches all the glob patterns in " { $snippet "patterns" } " to the sequence of files in " { $snippet "filenames" } ". If a pattern doesn't match anything, then a " { $link resource-missing } " error will be thrown containing that pattern." } ;

HELP: vocab-resource-files
{ $values
    { "vocab" "a vocabulary specifier" }
    { "filenames" "a sequence of filenames" }
}
{ $description "Outputs a sequence containing the individual resource files and directories that match the patterns specified in " { $snippet "vocab" } "'s " { $snippet "resources.txt" } " file. Any matching directories will also have their contents recursively included in the output. The paths in the output will be relative to " { $snippet "vocab" } "'s directory." } ;

ARTICLE: "vocabs.metadata.resources" "Vocabulary resource metadata"
"The " { $vocab-link "vocabs.metadata.resources" } " vocabulary contains words to retrieve the full list of files that match the patterns specified in a vocabulary's " { $snippet "resources.txt" } " file."
{ $subsections
  match-patterns
  vocab-resource-files
} ;

ABOUT: "vocabs.metadata.resources"
