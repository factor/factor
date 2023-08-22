! Copyright (C) 2006, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: ascii grouping hints io io.encodings.ascii io.files
io.files.temp kernel sequences strings tr vectors ;
IN: benchmark.reverse-complement

TR: trans-map ch>upper "ACGTUMRYKVHDB" "TGCAAKYRMBDHV" ;

: translate-seq ( seq -- str )
    concat reverse! dup trans-map-fast ;

: show-seq ( seq -- )
    translate-seq 60 group [ print ] each ;

: do-line ( seq line -- seq )
    dup first ">;" member-eq?
    [ over show-seq print dup delete-all ] [ suffix! ] if ;

HINTS: do-line vector string ;

: reverse-complement ( infile outfile -- )
    ascii [
        ascii [
            500,000 <vector>
            [ do-line ] each-line
            show-seq
        ] with-file-reader
    ] with-file-writer ;

: reverse-complement-in ( -- path )
    "reverse-complement-in.txt" temp-file ;

: reverse-complement-out ( -- path )
    "reverse-complement-out.txt" temp-file ;

: reverse-complement-benchmark ( -- )
    reverse-complement-in
    reverse-complement-out
    reverse-complement ;

MAIN: reverse-complement-benchmark
