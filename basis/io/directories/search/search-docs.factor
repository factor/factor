! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations ;
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

HELP: recursive-directory
{ $values
     { "path" "a pathname string" } { "bfs?" "a boolean, breadth-first or depth-first" }
     { "paths" "a sequence of pathname strings" }
}
{ $description "Traverses a directory path recursively and returns a sequence of files in a breadth-first or depth-first manner." } ;

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
{ $description "Finds all files in the input directory matching the predicate quotation in a breadth-first or depth-first traversal." } ;

HELP: find-all-in-directories
{ $values
     { "directories" "a sequence of directory paths" } { "bfs?" "a boolean, breadth-first or depth-first" } { "quot" quotation }
     { "paths/f" "a sequence of pathname strings or f" }
}
{ $description "Finds all files in the input directories matching the predicate quotation in a breadth-first or depth-first traversal." } ;

{ find-file find-all-files find-in-directories find-all-in-directories } related-words

ARTICLE: "io.directories.search" "Searching directories"
"The " { $vocab-link "io.directories.search" } " vocabulary contains words used for recursively iterating over a directory and for finding files in a directory tree." $nl
"Traversing directories:"
{ $subsection recursive-directory }
{ $subsection each-file }
"Finding files:"
{ $subsection find-file }
{ $subsection find-all-files }
{ $subsection find-in-directories }
{ $subsection find-all-in-directories } ;

ABOUT: "io.directories.search"
