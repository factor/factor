! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: parser
USING: arrays errors generic hashtables io kernel math
namespaces sequences words ;

SYMBOL: source-files

TUPLE: source-file path modified definitions ;

: source-file-modified* ( source-file -- n )
    source-file-path ?resource-path
    file-modified [ 0 ] unless* ;

: record-modified ( file -- )
    dup source-file-modified* swap set-source-file-modified ;

: reset-modified ( -- )
    source-files get hash-values [ record-modified ] each ;

C: source-file ( path -- source-file )
    [ set-source-file-path ] keep
    V{ } clone over set-source-file-definitions
    dup record-modified ;

: source-modified? ( file -- ? )
    source-files get hash [
        dup source-file-modified swap source-file-modified*
        [ < ] [ drop f ] if*
    ] [
        t
    ] if* ;

: file-vocabs ( -- )
    "scratchpad" set-in { "syntax" "scratchpad" } set-use ;

: with-parser ( quot -- )
    [
        [
            dup [ parse-error? ] is? [ <parse-error> ] unless
            rethrow
        ] recover
    ] with-scope ;

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

: parsing-file ( file -- )
    "Loading " write write-pathname terpri flush ;

: record-file ( file -- )
    [ <source-file> ] keep source-files get set-hash ;

: parse-file-restarts ( file -- restarts )
    "Load " swap " again" append3 t 2array 1array ;

: parse-file ( file -- quot )
    [
        dup parsing-file dup record-file
        [ ?resource-path <file-reader> ] keep parse-stream
    ] [
        over parse-file-restarts condition drop parse-file
    ] recover ;

: run-file ( file -- ) parse-file call ;

: no-parse-hook ( quot -- )
    [ parse-hook off call ] with-scope ; inline

: ?run-file ( file -- )
    dup exists? [ [ [ run-file ] keep ] try ] when drop ;

: eval>string ( str -- str )
    [ [ [ eval ] keep ] try drop ] string-out ;
