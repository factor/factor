! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic assocs kernel math
namespaces prettyprint sequences strings vectors words
quotations inspector io.styles io combinators sorting
splitting math.parser effects continuations debugger
io.files io.crc32 io.streams.string io.streams.lines vocabs
hashtables graphs ;
IN: source-files

SYMBOL: source-files

TUPLE: source-file
path
modified checksum
uses definitions ;

: (source-modified?) ( path modified checksum -- ? )
    pick file-modified rot [ 0 or ] 2apply >
    [ swap file-crc32 number= not ] [ 2drop f ] if ;

: source-modified? ( path -- ? )
    dup source-files get at [
        dup source-file-path ?resource-path
        over source-file-modified
        rot source-file-checksum
        (source-modified?)
    ] [
        ?resource-path exists?
    ] ?if ;

: record-modified ( source-file -- )
    dup source-file-path ?resource-path file-modified
    swap set-source-file-modified ;

: record-checksum ( source-file contents -- )
    crc32 swap set-source-file-checksum ;

: (xref-source) ( source-file -- pathname uses )
    dup source-file-path <pathname> swap source-file-uses
    [ interned? ] subset ;

: xref-source ( source-file -- )
    (xref-source) crossref get add-vertex ;

: unxref-source ( source-file -- )
    (xref-source) crossref get remove-vertex ;

: xref-sources ( -- )
    source-files get [ nip xref-source ] assoc-each ;

: record-form ( quot source-file -- )
    dup unxref-source
    swap quot-uses keys over set-source-file-uses
    xref-source ;

: <source-file> ( path -- source-file )
    { set-source-file-path } \ source-file construct ;

: source-file ( path -- source-file )
    source-files get [ <source-file> ] cache ;

: reset-checksums ( -- )
    source-files get [
        swap ?resource-path dup exists?
        [ <file-reader> contents record-checksum ] [ 2drop ] if
    ] assoc-each ;

M: pathname where pathname-string 1 2array ;

: forget-source ( path -- )
    dup source-file
    dup unxref-source
    source-file-definitions [ drop forget ] assoc-each
    source-files get delete-at ;

M: pathname forget pathname-string forget-source ;
