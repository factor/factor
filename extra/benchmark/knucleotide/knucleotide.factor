! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: ascii assocs formatting grouping io io.encodings.ascii
io.files kernel math math.statistics sequences ;
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
    [ sorted-histogram reverse ] [ length ] bi
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
