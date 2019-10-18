USING: help.markup help.syntax quotations io.pathnames ;
IN: io.directories.hierarchy

HELP: directory-tree-files
{ $values { "path" "a pathname string" } { "seq" "a sequence of filenames" } }
{ $description "Outputs a sequence of all files and subdirectories inside the directory named by " { $snippet "path" } " or recursively inside its subdirectories." } ;

HELP: with-directory-tree-files
{ $values { "path" "a pathname string" } { "quot" quotation } }
{ $description "Calls the quotation with the recursive directory file names on the stack and with the directory set as the " { $link current-directory } ". Restores the current directory after the quotation is called." } ;

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
"There is a naming scheme used by " { $vocab-link "io.directories" } " and " { $vocab-link "io.directories.hierarchy" } ". Operations for deleting and copying files come in two forms:"
{ $list
    { "Words named " { $snippet { $emphasis "operation" } "-file" } " which work on regular files only." }
    { "Words named " { $snippet { $emphasis "operation" } "-tree" } " works on directory trees recursively, and also accepts regular files." }
}
"Listing directory trees recursively:"
{ $subsections
    directory-tree-files
    with-directory-tree-files
}
"Deleting directory trees recursively:"
{ $subsections delete-tree }
"Copying directory trees recursively:"
{ $subsections
    copy-tree
    copy-tree-into
    copy-trees-into
} ;

ABOUT: "io.directories.hierarchy"
