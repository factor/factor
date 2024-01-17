! Copyright (C) 2024 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays assocs io io.encodings.utf8 io.files
io.files.temp io.launcher io.pathnames kernel math math.parser
prettyprint sequences tools.profiler.sampling ;

IN: flamegraph

<PRIVATE

:: write-flamegraph-node ( word node depth -- )
    depth word unparse-short suffix [
        ";" join write bl node total-time>> 1000 *
        >integer number>string print
    ] [
        node children>> swap
        '[ _ write-flamegraph-node ] assoc-each
    ] bi ;

: write-flamegraph ( -- )
    top-down >alist first second children>>
    [ { } write-flamegraph-node ] assoc-each ;

PRIVATE>

: flamegraph ( -- )
    "output.txt" temp-file
    [ utf8 [ flamegraph. ] with-file-writer ]
    [ "vocab:flamegraph/flamegraph.pl" absolute-path swap 2array process-contents ] bi
    "output.svg" temp-file
    [ utf8 set-file-contents ]
    [ { "open" "-a" "Safari" } swap suffix try-process ] bi ;
