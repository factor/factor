! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: parser
USING: errors generic hashtables io kernel math namespaces
sequences words ;

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

: parse-stream ( stream name -- quot )
    [
        file set file-vocabs
        lines parse-lines
        parse-hook get call
    ] with-scope ;

: parsing-file ( file -- ) "Loading " write print flush ;

: parse-file ( file -- quot )
    dup parsing-file [ <file-reader> ] keep parse-stream ;

: run-file ( file -- ) parse-file call ;

: no-parse-hook ( quot -- )
    [ parse-hook off call ] with-scope ; inline

: ?run-file ( file -- )
    dup exists? [ [ [ run-file ] keep ] try ] when drop ;

: eval>string ( str -- str )
    [ [ [ eval ] keep ] try drop ] string-out ;

: parse-resource ( path -- quot )
    dup parsing-file
    [ <resource-reader> "resource:" ] keep append parse-stream ;

: run-resource ( file -- )
    parse-resource call ;
