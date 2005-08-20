! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: parser
USING: kernel lists namespaces sequences io ;

: file-vocabs ( -- )
    "scratchpad" "in" set
    [ "syntax" "scratchpad" ] "use" set ;

: (parse-stream) ( stream -- quot )
    [
        lines dup length [ ]
        [ line-number set (parse) ] 2reduce
        reverse
    ] with-parser ;

: parse-stream ( name stream -- quot )
    [
        swap file set file-vocabs
        (parse-stream)
        file off line-number off
    ] with-scope ;

: parse-file ( file -- quot )
    dup <file-reader> parse-stream ;

: run-file ( file -- )
    parse-file call ;

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
