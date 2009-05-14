! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations sequences ;
IN: io.directories.search

HELP: each-file
{ $values
     { "path" "a pathname string" } { "bfs?" "a boolean, breadth-first or depth-first" } { "quot" quotation }
}
{ $description "Performs a directory traversal, breadth-first or depth-first, and calls the quotation on the full pathname of each file." }
{ $examples
    { $unchecked-example "USING: sequences io.directories.search ;"
        "\"resource:misc\" t [ . ] each-file"
        "! Recursive directory listing prints here"
    }
} ;

HELP: recursive-directory-files
{ $values
     { "path" "a pathname string" } { "bfs?" "a boolean, breadth-first or depth-first" }
     { "paths" "a sequence of pathname strings" }
}
{ $description "Traverses a directory path recursively and returns a sequence of files in a breadth-first or depth-first manner." } ;

HELP: recursive-directory-entries
{ $values
     { "path" "a pathname string" } { "bfs?" "a boolean, breadth-first or depth-first" }
     { "directory-entries" "a sequence of directory-entries" }
}
{ $description "Traverses a directory path recursively and returns a sequence of directory-entries in a breadth-first or depth-first manner." } ;

HELP: find-file
{ $values
     { "path" "a pathname string" } { "bfs?" "a boolean, breadth-first or depth-first" } { "quot" quotation }
     { "path/f" "a pathname string or f" }
}
{ $description "Finds the first file in the input directory matching the predicate quotation in a breadth-first or depth-first traversal." } ;

HELP: find-in-directories
{ $values
     { "directories" "a sequence of pathnames" } { "bfs?" "a boolean, breadth-first or depth-first" } { "quot" quotation }
     { "path'/f" "a pathname string or f" }
}
{ $description "Finds the first file in the input directories matching the predicate quotation in a breadth-first or depth-first traversal." } ;

HELP: find-all-files
{ $values
     { "path" "a pathname string" } { "quot" quotation }
     { "paths/f" "a sequence of pathname strings or f" }
}
{ $description "Recursively finds all files in the input directory matching the predicate quotation." } ;

HELP: find-all-in-directories
{ $values
     { "directories" "a sequence of directory paths" } { "quot" quotation }
     { "paths/f" "a sequence of pathname strings or f" }
}
{ $description "Finds all files in the input directories matching the predicate quotation in a breadth-first or depth-first traversal." } ;

HELP: find-by-extension
{ $values
    { "path" "a pathname string" } { "extension" "a file extension" }
    { "seq" sequence }
}
{ $description "Searches a directory for all files with the given extension. File extension and filenames are converted to lower-case and compared using the " { $link tail? } " word. The file extension should contain the period." }
{ $examples
    { $unchecked-example
        "USING: io.directories.search ;"
        "\"/\" \".mp3\" find-by-extension"
    }
} ;

HELP: find-by-extensions
{ $values
    { "path" "a pathname string" } { "extensions" "a sequence of file extensions" }
    { "seq" sequence }
}
{ $description "Searches a directory for all files in the given list of extensions. File extensions and filenames are converted to lower-case and compared using the " { $link tail? } " word. File extensions should contain the period." }
{ $examples
    { $unchecked-example
        "USING: io.directories.search ;"
        "\"/\" { \".jpg\" \".gif\" \".tiff\" \".png\" \".bmp\" } find-by-extensions"
    }
} ;

{ find-file find-all-files find-in-directories find-all-in-directories } related-words

ARTICLE: "io.directories.search" "Searching directories"
"The " { $vocab-link "io.directories.search" } " vocabulary contains words used for recursively iterating over a directory and for finding files in a directory tree." $nl
"Traversing directories:"
{ $subsection recursive-directory-files }
{ $subsection recursive-directory-entries }
{ $subsection each-file }
"Finding files by name:"
{ $subsection find-file }
{ $subsection find-all-files }
{ $subsection find-in-directories }
{ $subsection find-all-in-directories }
"Finding files by extension:"
{ $subsection find-by-extension }
{ $subsection find-by-extensions } ;

ABOUT: "io.directories.search"
