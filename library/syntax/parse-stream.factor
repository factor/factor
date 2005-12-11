! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: parser
USING: errors io kernel lists math namespaces sequences words ;

: file-vocabs ( -- )
    "scratchpad" "in" set
    [ "syntax" "scratchpad" ] "use" set ;

: parse-lines ( lines -- quot )
    [
        dup length [ ]
        [ 1+ line-number set (parse) ] 2reduce
        reverse
    ] with-parser ;

: parse-stream ( stream name -- quot )
    [ file set file-vocabs lines parse-lines ] with-scope ;

: parsing-file ( file -- ) "! " write dup print ;

: parse-file ( file -- quot )
    parsing-file
    [ <file-reader> ] keep parse-stream ;

: run-file ( file -- )
    parse-file call ;

: parse-resource ( path -- quot )
    #! Resources are loaded from the resource-path variable, or
    #! the current directory if it is not set. Words defined in
    #! resources have a definition source path starting with
    #! resource:. This allows words that operate on source
    #! files, like "jedit", to use a different resource path
    #! at run time than was used at parse time.
    parsing-file
    [ <resource-stream> "resource:" ] keep append parse-stream ;

: run-resource ( file -- )
    parse-resource call ;

: word-file ( word -- file )
    "file" word-prop dup
    [ "resource:/" ?head [ resource-path ] when ] when ;

: reload ( word -- )
    #! Reload the source file the word originated from.
    word-file run-file ;
