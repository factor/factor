! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: parser
USING: arrays errors generic hashtables io kernel math
namespaces sequences words crc32 ;

SYMBOL: source-files

TUPLE: source-file path modified checksum ;

: file-modified* ( source-file -- n )
    file-modified [ 0 ] unless* ;

C: source-file ( path -- source-file )
    [ set-source-file-path ] keep ;

: (source-modified?) ( path modified checksum -- ? )
    pick file-modified* rot >
    [ swap file-crc32 number= not ] [ 2drop f ] if ;

: source-modified? ( file -- ? )
    dup source-files get hash [
        dup source-file-path ?resource-path
        over source-file-modified
        rot source-file-checksum
        (source-modified?)
    ] [
        ?resource-path exists?
    ] ?if ;

: file-vocabs ( -- )
    "scratchpad" set-in { "syntax" "scratchpad" } set-use ;

: with-parser ( quot -- )
    0 line-number set [ <parse-error> rethrow ] recover ;

: parse-lines ( lines -- quot )
    [ f [ (parse) ] reduce >quotation ] with-parser ;

SYMBOL: parse-hook

: do-parse-hook ( -- ) parse-hook get call ;

: parsing-file ( file -- )
    "quiet" get [
        drop
    ] [
        "Loading " write write-pathname terpri flush
    ] if ;

: record-checksum ( contents path source-file -- )
    swap ?resource-path file-modified*
    over set-source-file-modified
    swap crc32 swap set-source-file-checksum ;

: record-file ( contents path -- )
    [ dup <source-file> [ record-checksum ] keep ] keep
    source-files get set-hash ;

: parse-stream ( stream name -- quot )
    [
        file-vocabs [
            file set
            contents [
                string-lines parse-lines do-parse-hook
            ] keep
        ] keep record-file
    ] with-scope ;

: parse-file-restarts ( file -- restarts )
    "Load " swap " again" 3append t 2array 1array ;

: parse-file ( file -- quot )
    [
        [ parsing-file ] keep
        [ ?resource-path <file-reader> ] keep
        parse-stream
    ] [
        over parse-file-restarts condition drop parse-file
    ] recover ;

: run-file ( file -- )
    [ [ parse-file call ] keep ] assert-depth drop ;

: no-parse-hook ( quot -- )
    [ parse-hook off call ] with-scope ; inline

: bootstrap-file ( path -- )
    bootstrapping? get [ parse-file % ] [ run-file ] if ;

: bootstrap-files ( seq -- )
    [ [ bootstrap-file ] each ] no-parse-hook ;

: run-files ( seq -- )
    [ [ run-file ] each ] no-parse-hook ;

: reset-checksums ( -- )
    source-files get [
        drop dup ?resource-path exists? [
            [ ?resource-path <file-reader> contents ] keep
            record-file
        ] [
            drop
        ] if
    ] hash-each ;

: parse ( str -- quot ) string-lines parse-lines ;

: eval ( str -- ) parse call ;

: eval>string ( str -- str )
    [ [ [ eval ] keep ] try drop ] string-out ;
