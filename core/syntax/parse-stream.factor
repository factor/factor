! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: parser
USING: arrays errors generic assocs io kernel math
namespaces sequences words crc32 prettyprint ;

SYMBOL: source-files

TUPLE: source-file path modified checksum form uses ;

: file-modified* ( source-file -- n )
    file-modified [ 0 ] unless* ;

C: source-file ( path -- source-file )
    [ set-source-file-path ] keep ;

: (source-modified?) ( path modified checksum -- ? )
    pick file-modified* rot >
    [ swap file-crc32 number= not ] [ 2drop f ] if ;

: source-modified? ( file -- ? )
    dup source-files get at [
        dup source-file-path ?resource-path
        over source-file-modified
        rot source-file-checksum
        (source-modified?)
    ] [
        ?resource-path exists?
    ] ?if ;

: file-vocabs ( -- )
    "scratchpad" in set { "syntax" "scratchpad" } set-use ;

: parse-fresh ( lines -- )
    [ file-vocabs parse-lines ] with-scope ;

SYMBOL: parse-hook

: do-parse-hook ( -- ) parse-hook get call ;

: parsing-file ( file -- )
    "quiet" get [
        drop
    ] [
        "Loading " write <pathname> . flush
    ] if ;

: record-modified ( path source-file -- )
    >r ?resource-path file-modified* r>
    set-source-file-modified ;

: record-checksum ( contents source-file -- )
    >r crc32 r> set-source-file-checksum ;

: xref-source ( source-file -- )
    dup source-file-form quot-uses
    swap set-source-file-uses ;

: xref-sources ( -- )
    source-files get [ nip xref-source ] assoc-each ;

: record-form ( form source-file -- )
    [ set-source-file-form ] keep xref-source ;

: record-file ( form contents path -- )
    [
        dup <source-file>
        [ record-modified ] keep
        [ record-checksum ] keep
        [ record-form ] keep
    ] keep source-files get set-at ;

: parse-stream ( stream name -- quot )
    [
        file set
        contents dup \ contents set
        string-lines parse-fresh do-parse-hook
        dup \ contents get file get record-file
    ] with-scope ;

: parse-file-restarts ( file -- restarts )
    "Load " swap " again" 3append t 2array 1array ;

: parse-file ( file -- quot )
    [
        [ parsing-file ] keep
        [ ?resource-path <file-reader> ] keep
        parse-stream
    ] [
        over parse-file-restarts rethrow-restarts
        drop parse-file
    ] recover ;

: run-file ( file -- )
    [ [ parse-file call ] keep ] assert-depth drop ;

: no-parse-hook ( quot -- )
    [ parse-hook off call ] with-scope ; inline

: bootstrap-file ( path -- )
    [ parse-file % ] [ run-file ] if-bootstrapping ;

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
    ] assoc-each ;

: parse ( str -- quot ) string-lines parse-lines ;

: eval ( str -- ) parse call ;

: eval>string ( str -- str )
    [
        check-shadowing off
        [ [ eval ] keep ] try drop
    ] string-out ;
