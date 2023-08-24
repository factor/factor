USING: help.markup help.syntax sequences strings ;
IN: vocabs.metadata

ARTICLE: "vocabs.metadata" "Vocabulary metadata"
"Vocabulary directories can contain text files with metadata:"
{ $table
    { { $snippet "authors.txt" } { "a series of lines, with one author name per line. These are listed under " { $link "vocab-authors" } "." } }
    { { $snippet "platforms.txt" } { "a series of lines, with one operating system name per line." } }
    { { $snippet "resources.txt" } { "a series of lines, with one file glob pattern per line. Files inside the vocabulary directory whose names match any of these glob patterns will be included with the compiled application as " { $link "deploy-resources" } "." } }
    { { $snippet "summary.txt" } { "a one-line description." } }
    { { $snippet "tags.txt" } { "a series of lines, with one tag per line. Tags help classify the vocabulary. Consult " { $link "vocab-tags" } " for a list of existing tags you can reuse." } }
}
"These metadata files can be accessed with the following words:"
{ $subsections
    vocab-authors
    vocab-platforms
    vocab-resources
    vocab-summary
    vocab-tags
}
"Getting and setting arbitrary vocabulary metadata:"
{ $subsections
    vocab-file-lines
    set-vocab-file-lines
} ;

ABOUT: "vocabs.metadata"

HELP: vocab-file-lines
{ $values { "vocab" "a vocabulary specifier" } { "name" string } { "lines/f" { $maybe { $sequence "lines" } } } }
{ $description "Outputs the lines of the file named " { $snippet "name" } " from the vocabulary's directory, or " { $link f } " if the file does not exist." } ;

HELP: set-vocab-file-lines
{ $values { "lines" { $sequence "lines" } } { "vocab" "a vocabulary specifier" } { "name" string } }
{ $description "Stores a sequence of lines to the file named " { $snippet "name" } " from the vocabulary's directory." } ;

HELP: vocab-summary
{ $values { "vocab" "a vocabulary specifier" } { "summary" { $maybe string } } }
{ $description "Outputs a one-line string description of the vocabulary's intended purpose from the " { $snippet "summary.txt" } " file in the vocabulary's directory. Outputs " { $link f } " if the file does not exist." } ;

HELP: vocab-tags
{ $values { "vocab" "a vocabulary specifier" } { "tags" "a sequence of strings" } }
{ $description "Outputs a list of short tags classifying the vocabulary from the " { $snippet "tags.txt" } " file in the vocabulary's directory. Outputs " { $link f } " if the file does not exist." } ;

HELP: vocab-platforms
{ $values { "vocab" "a vocabulary specifier" } { "platforms" "a sequence of operating system symbols" } }
{ $description "Outputs a list of operating systems supported by " { $snippet "vocab" } ", as specified by the " { $snippet "platforms.txt" } " file in the vocabulary's directory. Outputs an empty array if the file doesn't exist." }
{ $notes "Operating system symbols are defined in the " { $vocab-link "system" } " vocabulary." } ;

HELP: vocab-resources
{ $values { "vocab" "a vocabulary specifier" } { "patterns" "a sequence of glob patterns" } }
{ $description "Outputs a list of glob patterns matching files that will be deployed with an application that includes " { $snippet "vocab" } ", as specified by the " { $snippet "resources.txt" } " file in the vocabulary's directory. Outputs an empty array if the file doesn't exist." }
{ $notes "The " { $vocab-link "vocabs.metadata.resources" } " vocabulary contains words that will expand the glob patterns and directory names in " { $snippet "patterns" } " and return all the matching files." } ;
