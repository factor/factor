! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
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

: parse ( str -- code ) <string-reader> lines parse-lines ;

: eval ( "X" -- X ) parse call ;

: parse-stream ( stream name -- quot )
    [ file set file-vocabs lines parse-lines ] with-scope ;

: parsing-file ( file -- ) "Loading " write print flush ;

: parse-file ( file -- quot )
    dup parsing-file [ <file-reader> ] keep parse-stream ;

: run-file ( file -- ) parse-file call ;

: try-run-file ( file -- ) [ [ run-file ] keep ] try drop ;

: eval>string ( str -- str )
    [ [ [ eval ] keep ] try drop ] string-out ;

: parse-resource ( path -- quot )
    dup parsing-file
    [ <resource-reader> "resource:" ] keep append parse-stream ;

: run-resource ( file -- ) parse-resource call ;

GENERIC: where ( spec -- loc )

M: word where "loc" word-prop ;

M: method-spec where
    dup first2 "methods" word-prop hash method-loc
    [ ] [ second where ] ?if ;

: ?resource-path ( path -- path )
    "resource:/" ?head [ resource-path ] when ;

: reload ( spec -- )
    where first [ ?resource-path run-file ] when* ;
