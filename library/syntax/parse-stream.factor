! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: parser
USING: errors generic io kernel math namespaces sequences
words ;

: file-vocabs ( -- )
    "scratchpad" set-in { "syntax" "scratchpad" } set-use ;

: with-parser ( quot -- ) [ <parse-error> rethrow ] recover ;

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

: parse-resource ( path -- quot )
    dup parsing-file
    [ <resource-stream> "resource:" ] keep append parse-stream ;

: run-resource ( file -- ) parse-resource call ;

: word-file ( word -- file )
    "file" word-prop dup
    [ "resource:/" ?head [ resource-path ] when ] when ;

: reload ( word -- ) word-file run-file ;
