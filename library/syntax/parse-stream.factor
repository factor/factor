! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: parser
USING: kernel lists namespaces sequences streams strings ;

: file-vocabs ( -- )
    "file-in" get "in" set
    "file-use" get "use" set ;

: (parse-stream) ( name stream -- quot )
    #! Uses the current namespace for temporary variables.
    [
        >r file set f ( initial parse tree ) r>
        [ (parse) ] read-lines reverse
        file off
        line-number off
    ] with-parser ;

: parse-stream ( name stream -- quot )
    [ file-vocabs (parse-stream) ] with-scope ;

: parse-file ( file -- quot )
    dup <file-reader> parse-stream ;

: run-file ( file -- )
    #! Run a file. The file is read with the default IN:/USE:
    #! for files.
    parse-file call ;

: (parse-file) ( file -- quot )
    dup <file-reader> (parse-stream) ;

: (run-file) ( file -- )
    #! Run a file. The file is read with the same IN:/USE: as
    #! the current interactive interpreter.
    (parse-file) call ;

: parse-resource ( path -- quot )
    #! Resources are loaded from the resource-path variable, or
    #! the current directory if it is not set. Words defined in
    #! resources have a definition source path starting with
    #! resource:. This allows words that operate on source
    #! files, like "jedit", to use a different resource path
    #! at run time than was used at parse time.
    "resource:" over append swap <resource-stream> parse-stream ;

: run-resource ( file -- )
    parse-resource call ;
