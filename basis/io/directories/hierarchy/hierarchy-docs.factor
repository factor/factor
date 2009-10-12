USING: help.markup help.syntax ;
IN: io.directories.hierarchy

HELP: delete-tree
{ $values { "path" "a pathname string" } }
{ $description "Deletes a file or directory, recursing into subdirectories." }
{ $errors "Throws an error if the deletion fails." } 
{ $warning "Misuse of this word can lead to catastrophic data loss." } ;

HELP: copy-tree
{ $values { "from" "a pathname string" } { "to" "a pathname string" } }
{ $description "Copies a directory tree recursively." }
{ $notes "This operation attempts to preserve original file attributes, however not all attributes may be preserved." }
{ $errors "Throws an error if the copy operation fails." } ;

HELP: copy-tree-into
{ $values { "from" "a pathname string" } { "to" "a directory pathname string" } }
{ $description "Copies a directory tree to another directory, recursively." }
{ $errors "Throws an error if the copy operation fails." } ;

HELP: copy-trees-into
{ $values { "files" "a sequence of pathname strings" } { "to" "a directory pathname string" } }
{ $description "Copies a set of directory trees to another directory, recursively." }
{ $errors "Throws an error if the copy operation fails." } ;

ARTICLE: "io.directories.hierarchy" "Directory hierarchy manipulation"
"The " { $vocab-link "io.directories.hierarchy" } " vocabulary defines words for operating on directory hierarchies recursively."
$nl
"Deleting directory trees recursively:"
{ $subsections delete-tree }
"Copying directory trees recursively:"
{ $subsections
    copy-tree
    copy-tree-into
    copy-trees-into
} ;

ABOUT: "io.directories.hierarchy"
