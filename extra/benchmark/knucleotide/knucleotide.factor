USING: kernel locals io io.files splitting strings io.encodings.ascii
       hashtables sequences assocs math namespaces prettyprint
       math.parser combinators arrays sorting unicode.case ;

IN: benchmark.knucleotide

: float>string ( float places -- string )
    swap >float number>string
    "." split1 rot
    over length over <
    [ CHAR: 0 pad-tail ] 
    [ head ] if "." glue ;

: discard-lines ( -- )
    readln
    [ ">THREE" head? [ discard-lines ] unless ] when* ;

: read-input ( -- input )
    discard-lines
    ">" read-until drop
    CHAR: \n swap remove >upper ;

: tally ( x exemplar -- b )
    clone [ [ inc-at ] curry each ] keep ;

: small-groups ( x n -- b )
    swap
    [ length swap - 1 + ] 2keep
    [ [ over + ] dip subseq ] 2curry map ;

: handle-table ( inputs n -- )
    small-groups
    [ length ] keep
    H{ } tally >alist
    sort-values reverse
    [
      dup first write bl
      second 100 * over / 3 float>string print
    ] each
    drop ;

:: handle-n ( inputs x -- )
    inputs x length small-groups :> groups
    groups H{ } tally :> b
    x b at [ 0 ] unless*
    number>string 8 CHAR: \s pad-tail write ;

: process-input ( input -- )
    dup 1 handle-table nl
    dup 2 handle-table nl
    { "GGT" "GGTA" "GGTATT" "GGTATTTTAATT" "GGTATTTTAATTTATAGT" }
    [ [ dupd handle-n ] keep print ] each
    drop ;

: knucleotide ( -- )
    "resource:extra/benchmark/knucleotide/knucleotide-input.txt"
    ascii [ read-input ] with-file-reader
    process-input ;

MAIN: knucleotide
