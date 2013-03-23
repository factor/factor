! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ascii kernel io io.files splitting strings
io.encodings.ascii hashtables sequences assocs math
math.statistics namespaces math.parser combinators arrays
sorting formatting grouping fry ;
IN: benchmark.knucleotide

CONSTANT: knucleotide-in "vocab:benchmark/knucleotide/knucleotide-input.txt"

: discard-lines ( -- )
    readln
    [ ">THREE" head? [ discard-lines ] unless ] when* ;

: read-input ( -- input )
    discard-lines
    ">" read-until drop
    CHAR: \n swap remove >upper ;

: handle-table ( inputs n -- )
    clump
    [ histogram sort-values reverse ] [ length ] bi
    '[
        [ first write bl ]
        [ second 100 * _ /f "%.3f" printf nl ] bi
    ] each ;

: handle-n ( input x -- )
    [ nip ] [ length clump histogram ] 2bi at 0 or "%d\t" printf ;

: process-input ( input -- )
    [ 1 handle-table nl ]
    [ 2 handle-table nl ]
    [
        { "GGT" "GGTA" "GGTATT" "GGTATTTTAATT" "GGTATTTTAATTTATAGT" }
        [ [ handle-n ] keep print ] with each
    ]
    tri ;

: knucleotide-benchmark ( -- )
    knucleotide-in
    ascii [ read-input ] with-file-reader
    process-input ;

MAIN: knucleotide-benchmark
