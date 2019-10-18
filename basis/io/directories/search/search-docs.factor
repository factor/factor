! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io.directories kernel quotations
sequences ;
IN: io.directories.search

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
    { $unchecked-example "USING: sequences io.directories.search ;"
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
        "USING: io.directories.search ;"
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
        "USING: io.directories.search ;"
        "\"/\" { \".jpg\" \".gif\" \".tiff\" \".png\" \".bmp\" } find-files-by-extensions"
    }
} ;

{ find-file find-files find-file-in-directories find-files-in-directories } related-words

ARTICLE: "io.directories.search" "Searching directories"
"The " { $vocab-link "io.directories.search" } " vocabulary contains words used for recursively iterating over a directory and for finding files in a directory tree." $nl
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

ABOUT: "io.directories.search"
