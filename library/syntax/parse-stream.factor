! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: parser
USING: arrays errors generic hashtables io kernel math
namespaces sequences words ;

: file-vocabs ( -- )
    "scratchpad" set-in { "syntax" "scratchpad" } set-use ;

: with-parser ( quot -- )
    [ [ <parse-error> rethrow ] recover ] with-scope ;

: parse-lines ( lines -- quot )
    [
        dup length f [ 1+ line-number set (parse) ] 2reduce
        >quotation
    ] with-parser ;

: parse ( str -- quot ) <string-reader> lines parse-lines ;

: eval ( str -- ) parse call ;

SYMBOL: parse-hook

: do-parse-hook ( -- ) parse-hook get call ;

: parse-stream ( stream name -- quot )
    [
        file set file-vocabs
        lines parse-lines
        do-parse-hook
    ] with-scope ;

: parsing-file ( file -- ) "Loading " write print flush ;

: parse-file-restarts ( file -- restarts )
    "Load " swap " again" append3 t 2array 1array ;

: (parse-file) ( file ident -- quot )
    [ dup parsing-file >r <file-reader> r> parse-stream ]
    [ pick parse-file-restarts condition drop (parse-file) ]
    recover ;

: parse-file ( file -- quot ) dup (parse-file) ;

: run-file ( file -- ) parse-file call ;

: no-parse-hook ( quot -- )
    [ parse-hook off call ] with-scope ; inline

: ?run-file ( file -- )
    dup exists? [ [ [ run-file ] keep ] try ] when drop ;

: eval>string ( str -- str )
    [ [ [ eval ] keep ] try drop ] string-out ;

: parse-resource ( path -- quot )
    [ resource-path "resource:" ] keep append (parse-file) ;

: run-resource ( file -- )
    parse-resource call ;
