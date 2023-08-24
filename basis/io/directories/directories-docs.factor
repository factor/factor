USING: help.markup help.syntax io.files.private io.pathnames
math quotations sequences ;
IN: io.directories

HELP: cwd
{ $values { "path" "a pathname string" } }
{ $description "Outputs the current working directory of the Factor process." }
{ $notes "User code should use the value of the " { $link current-directory } " variable instead." } ;

HELP: cd
{ $values { "path" "a pathname string" } }
{ $description "Changes the current working directory of the Factor process." }
{ $notes "User code should use " { $link with-directory } " or " { $link set-current-directory } " instead." } ;

{ cd cwd current-directory set-current-directory with-directory } related-words

HELP: current-directory
{ $description "A variable holding the current directory as an absolute path. Words that use the filesystem do so in relation to this variable."
$nl
  "This variable should never be set directly; instead, use " { $link set-current-directory } " or " { $link with-directory } ". This preserves the invariant that the value of this variable is an absolute path." } ;

HELP: make-parent-directories
{ $values { "filename" "a pathname string" } }
{ $description "Creates all parent directories of the path which do not yet exist." }
{ $errors "Throws an error if the directories could not be created." } ;

HELP: set-current-directory
{ $values { "path" "a pathname string" } }
{ $description "Changes the " { $link current-directory } " variable."
$nl
"If " { $snippet "path" } " is relative, it is first resolved relative to the current directory. If " { $snippet "path" } " is absolute, it becomes the new current directory." } ;

HELP: with-directory
{ $values { "path" "a pathname string" } { "quot" quotation } }
{ $description "Calls the quotation in a new dynamic scope with the " { $link current-directory } " variable rebound."
$nl
"If " { $snippet "path" } " is relative, it is first resolved relative to the current directory. If " { $snippet "path" } " is absolute, it becomes the new current directory." } ;

HELP: (directory-entries)
{ $values { "path" "a pathname string" } { "seq" "a sequence of " { $link directory-entry } " objects" } }
{ $description "Outputs the contents of a directory named by " { $snippet "path" } "." }
{ $notes "This is a low-level word, and user code should call one of the related words instead." } ;

HELP: directory-entries
{ $values { "path" "a pathname string" } { "seq" "a sequence of " { $link directory-entry } " objects" } }
{ $description "Outputs the contents of a directory named by " { $snippet "path" } "." } ;

HELP: qualified-directory-entries
{ $values { "path" "a pathname string" } { "seq" "a sequence of " { $link directory-entry } " objects" } }
{ $description "Outputs the contents of a directory named by " { $snippet "path" } " using relative file paths." } ;

HELP: directory-files
{ $values { "path" "a pathname string" } { "seq" "a sequence of filenames" } }
{ $description "Outputs the contents of a directory named by " { $snippet "path" } " as a sequence of filenames." } ;

HELP: qualified-directory-files
{ $values { "path" "a pathname string" } { "seq" "a sequence of filenames" } }
{ $description "Outputs the contents of a directory named by " { $snippet "path" } " as a sequence of relative paths." } ;

HELP: with-directory-files
{ $values { "path" "a pathname string" } { "quot" quotation } }
{ $description "Calls the quotation with the directory file names on the stack and with the directory set as the " { $link current-directory } ". Restores the current directory after the quotation is called." }
{ $examples
    "Print all files in your home directory which are larger than a megabyte:"
    { $code
        "USING: io.directories io.files.info io.pathnames ;
home [
    [
        dup link-info size>> 20 2^ >
        [ print ] [ drop ] if
    ] each
] with-directory-files"
    }
} ;

HELP: with-directory-entries
{ $values { "path" "a pathname string" } { "quot" quotation } }
{ $description "Calls the quotation with the directory entries on the stack and with the directory set as the " { $link current-directory } ". Restores the current directory after the quotation is called." } ;

HELP: delete-file
{ $values { "path" "a pathname string" } }
{ $description "Deletes a file." }
{ $errors "Throws an error if the file could not be deleted." } ;

HELP: ?delete-file
{ $values { "path" "a pathname string" } }
{ $description "Calls " { $link delete-file } " if the " { $snippet "path" } " file exists." } ;

HELP: make-directory
{ $values { "path" "a pathname string" } }
{ $description "Creates a directory." }
{ $errors "Throws an error if the directory could not be created." } ;

HELP: make-directories
{ $values { "path" "a pathname string" } }
{ $description "Creates a directory and any parent directories which do not yet exist." }
{ $errors "Throws an error if the directories could not be created." } ;

HELP: delete-directory
{ $values { "path" "a pathname string" } }
{ $description "Deletes a directory. The directory must be empty." }
{ $errors "Throws an error if the directory could not be deleted." } ;

HELP: touch-file
{ $values { "path" "a pathname string" } }
{ $description "Updates the modification time of a file or directory. If the file does not exist, creates a new, empty file." }
{ $errors "Throws an error if the file could not be touched." } ;

HELP: truncate-file
{ $values { "path" "a pathname string" } { "n" integer } }
{ $description "Set the length of the file to " { $snippet "n" } " bytes. If the file was previously longer, the extra data is lost. If the file was previously shorter, the behavior is platform-dependent on whether the file is extended with zeros (Unix) or the contents of the extended portion are undefined (Windows)." }
{ $errors "Throws an error if the file does not exist or the truncate operation fails." } ;

HELP: move-file
{ $values { "from" "a pathname string" } { "to" "a pathname string" } }
{ $description "Moves or renames a file. This operation is not guaranteed to be atomic. In particular, if you attempt to move a file across volumes, this will copy the file and then delete the original in a nontransactional manner." }
{ $errors "Throws an error if the file does not exist or if the move operation fails." }
{ $see-also move-file-atomically } ;

HELP: ?move-file
{ $values { "from" "a pathname string" } { "to" "a pathname string" } }
{ $description "Calls " { $link move-file } " if the " { $snippet "from" } " file exists." } ;

HELP: move-file-atomically
{ $values { "from" "a pathname string" } { "to" "a pathname string" } }
{ $description "Moves or renames a file as an atomic operation." }
{ $errors "Throws an error if the file does not exist or if the move operation fails." } ;

HELP: move-file-into
{ $values { "from" "a pathname string" } { "to" "a directory pathname string" } }
{ $description "Moves a file to another directory without renaming it." }
{ $errors "Throws an error if the file does not exist or if the move operation fails." } ;

HELP: move-files-into
{ $values { "files" "a sequence of pathname strings" } { "to" "a directory pathname string" } }
{ $description "Moves a set of files to another directory." }
{ $errors "Throws an error if the file does not exist or if the move operation fails." } ;

HELP: copy-file
{ $values { "from" "a pathname string" } { "to" "a pathname string" } }
{ $description "Copies a file." }
{ $notes "This operation attempts to preserve the original file's attributes, however not all attributes may be preserved." }
{ $errors "Throws an error if the file does not exist or if the copy operation fails." } ;

HELP: copy-file-into
{ $values { "from" "a pathname string" } { "to" "a directory pathname string" } }
{ $description "Copies a file to another directory." }
{ $errors "Throws an error if the file does not exist or if the copy operation fails." } ;

HELP: copy-files-into
{ $values { "files" "a sequence of pathname strings" } { "to" "a directory pathname string" } }
{ $description "Copies a set of files to another directory." }
{ $errors "Throws an error if the file does not exist or if the copy operation fails." } ;

ARTICLE: "current-directory" "Current working directory"
"File system I/O operations use the value of a variable to resolve relative pathnames:"
{ $subsections current-directory }
"This variable can be changed with a pair of words:"
{ $subsections
    set-current-directory
    with-directory
}
"This variable is independent of the operating system notion of “current working directory”. While all Factor I/O operations use the variable and not the operating system's value, care must be taken when making FFI calls which expect a pathname. The first option is to resolve relative paths:"
{ $subsections absolute-path }
"The second is to change the working directory of the current process:"
{ $subsections
    cd
    cwd
} ;

ARTICLE: "io.directories.listing" "Directory listing"
"Directory listing:"
{ $subsections
    directory-entries
    directory-files
    with-directory-entries
    with-directory-files
    qualified-directory-entries
    qualified-directory-files
} ;

ARTICLE: "io.directories.create" "Creating directories"
{ $subsections
    make-directory
    make-directories
} ;

ARTICLE: "delete-move-copy" "Deleting, moving, and copying files"
"The operations for moving and copying files come in three flavors:"
{ $list
    { "A word named " { $snippet { $emphasis "operation" } } " which takes a source and destination path." }
    { "A word named " { $snippet { $emphasis "operation" } "-into" } " which takes a source path and destination directory. The destination file will be stored in the destination directory and will have the same file name as the source path." }
    { "A word named " { $snippet { $emphasis "operation" } "s-into" } " which takes a sequence of source paths and destination directory." }
}
"Since both of the above lists apply to copying files, that this means that there are a total of six variations on copying a file."
$nl
"Deleting files:"
{ $subsections
    delete-file
    delete-directory
}
"Moving files:"
{ $subsections
    move-file
    move-file-into
    move-files-into
}
"Copying files:"
{ $subsections
    copy-file
    copy-file-into
    copy-files-into
}
"On most operating systems, files can only be moved within the same file system. To move files between file systems, use " { $link copy-file } " followed by " { $link delete-file } " on the old name." ;

HELP: +depth-first+
{ $description "Method of directory traversal that fully recurses as far as possible before backtracking." } ;

HELP: +breadth-first+
{ $description "Method of directory traversal that explores each level of graph fully before moving to the next level." } ;

HELP: traversal-method
{ $var-description "Determines directory traversal method, either " { $link +depth-first+ } " or " { $link +breadth-first+ } "." } ;

HELP: each-file
{ $values
    { "path" "a pathname string" } { "quot" quotation }
}
{ $description "Traverses a directory path recursively and calls the quotation on the full pathname of each file, in a breadth-first or depth-first " { $link traversal-method } "." }
{ $examples
    { $unchecked-example "USING: sequences io.directories ;"
        "\"resource:misc\" [ . ] each-file"
        "! Recursive directory listing prints here"
    }
} ;

HELP: recursive-directory-files
{ $values
    { "path" "a pathname string" }
    { "paths" { $sequence "pathname strings" } }
}
{ $description "Traverses a directory path recursively and returns a sequence of files, in a breadth-first or depth-first " { $link traversal-method } "." } ;

HELP: recursive-directory-entries
{ $values
    { "path" "a pathname string" }
    { "directory-entries" { $sequence directory-entry } }
}
{ $description "Traverses a directory path recursively and returns a sequence of directory-entries, in a breadth-first or depth-first " { $link traversal-method } "." } ;

HELP: find-file
{ $values
    { "path" "a pathname string" } { "quot" quotation }
    { "path/f" { $maybe "pathname string" } }
}
{ $description "Finds the first file in the input directory matching the predicate quotation, in a breadth-first or depth-first " { $link traversal-method } "." } ;

HELP: find-file-in-directories
{ $values
    { "directories" "a sequence of pathnames" } { "quot" quotation }
    { "path'/f" { $maybe "pathname string" } }
}
{ $description "Finds the first file in the input directories matching the predicate quotation, in a breadth-first or depth-first " { $link traversal-method } "." } ;

HELP: find-files
{ $values
    { "path" "a pathname string" } { "quot" quotation }
    { "paths" { $sequence "pathname strings" } }
}
{ $description "Recursively finds all files in the input directory matching the predicate quotation, in a breadth-first or depth-first " { $link traversal-method } "." } ;

HELP: find-files-in-directories
{ $values
    { "directories" { $sequence "directory paths" } } { "quot" quotation }
    { "paths/f" { $maybe "a sequence of pathname strings" } }
}
{ $description "Finds all files in the input directories matching the predicate quotation, in a breadth-first or depth-first " { $link traversal-method } "." } ;

HELP: find-files-by-extension
{ $values
    { "path" "a pathname string" } { "extension" "a file extension" }
    { "seq" sequence }
}
{ $description "Searches a directory for all files with the given extension. File extension and filenames are converted to lower-case and compared using the " { $link tail? } " word. The file extension should contain the period." }
{ $examples
    { $code
        "USING: io.directories ;"
        "\"/\" \".mp3\" find-by-extension"
    }
} ;

HELP: find-files-by-extensions
{ $values
    { "path" "a pathname string" } { "extensions" { $sequence "file extensions" } }
    { "seq" sequence }
}
{ $description "Searches a directory for all files in the given list of extensions. File extensions and filenames are converted to lower-case and compared using the " { $link tail? } " word. File extensions should contain the period." }
{ $examples
    { $code
        "USING: io.directories ;"
        "\"/\" { \".jpg\" \".gif\" \".tiff\" \".png\" \".bmp\" } find-files-by-extensions"
    }
} ;

{ find-file find-files find-file-in-directories find-files-in-directories } related-words

ARTICLE: "io.directories.search" "Searching directories"
"Traversing directories:"
{ $subsections
    recursive-directory-files
    recursive-directory-entries
    each-file
    each-directory-entry
}
"Finding files by name:"
{ $subsections
    find-file
    find-files
    find-file-in-directories
    find-files-in-directories
}
"Finding files by extension:"
{ $subsections
    find-files-by-extension
    find-files-by-extensions
} ;

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
"There is a naming scheme used by " { $vocab-link "io.directories" } ". Operations for deleting and copying files come in two forms:"
{ $list
    { "Words named " { $snippet { $emphasis "operation" } "-file" } " which work on regular files only." }
    { "Words named " { $snippet { $emphasis "operation" } "-tree" } " works on directory trees recursively, and also accepts regular files." }
}
"Deleting directory trees recursively:"
{ $subsections delete-tree }
"Copying directory trees recursively:"
{ $subsections
    copy-tree
    copy-tree-into
    copy-trees-into
} ;

ARTICLE: "io.directories" "Directory manipulation"
"The " { $vocab-link "io.directories" } " vocabulary defines words for inspecting and manipulating directories."
{ $subsections
    home
    "current-directory"
    "io.directories.listing"
    "io.directories.create"
    "delete-move-copy"
    "io.directories.hierarchy"
    "io.directories.search"
} ;


ABOUT: "io.directories"
