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
    0 line-number set [ <parse-error> rethrow ] recover ;

: parse-lines ( lines -- quot )
    [ f [ (parse) ] reduce >quotation ] with-parser ;

: parse ( str -- quot ) string-lines parse-lines ;

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
    "quiet" get [
        drop
    ] [
        "Loading " write write-pathname terpri flush
    ] if ;

: record-file ( file -- )
    [ <source-file> ] keep source-files get set-hash ;

: parse-file-restarts ( file -- restarts )
    "Load " swap " again" 3append t 2array 1array ;

: parse-file ( file -- quot )
    [
        [ parsing-file ] keep
        [ ?resource-path <file-reader> ] keep
        [ parse-stream ] keep
        record-file
    ] [
        over parse-file-restarts condition drop parse-file
    ] recover ;

: run-file ( file -- ) parse-file call ;

: no-parse-hook ( quot -- )
    [ parse-hook off call ] with-scope ; inline

: run-files ( seq -- )
    [
        bootstrapping? get
        [ parse-file % ] [ run-file ] ? each
    ] no-parse-hook ;

: eval>string ( str -- str )
    [ [ [ eval ] keep ] try drop ] string-out ;
