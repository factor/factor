USING: kernel io io.files splitting strings
       hashtables sequences assocs math namespaces prettyprint
       math.parser combinators arrays sorting ;

IN: benchmark.knucleotide

: float>string ( float places -- string )
    swap >float number>string
    "." split1 rot
    over length over <
    [ CHAR: 0 pad-right ] 
    [ head ] if "." swap 3append
;

: discard-lines ( -- )
    readln
    [ ">THREE" head? [ discard-lines ] unless ] when*
;

: read-input ( -- input )
    discard-lines
    ">" read-until drop
    CHAR: \n swap remove >upper
;

: tally ( x exemplar -- b )
    clone tuck
    [
      [ [ 1+ ] [ 1 ] if* ] change-at
    ] curry each
;

: small-groups ( x n -- b )
    swap
    [ length swap - 1+ ] 2keep
    [ >r over + r> subseq ] 2curry map
;

: handle-table ( inputs n -- )
    small-groups
    [ length ] keep
    H{ } tally >alist
    sort-values reverse
    [
      dup first write bl
      second 100 * over / 3 float>string print
    ] each
    drop
;

: handle-n ( inputs x -- )
    tuck length
    small-groups H{ } tally
    at [ 0 ] unless*
    number>string 8 CHAR: \s pad-right write
;

: process-input ( input -- )
    dup 1 handle-table nl
    dup 2 handle-table nl
    { "GGT" "GGTA" "GGTATT" "GGTATTTTAATT" "GGTATTTTAATTTATAGT" }
    [ [ dupd handle-n ] keep print ] each
    drop
;

: knucleotide ( -- )
    "extra/benchmark/knucleotide/knucleotide-input.txt" resource-path
    <file-reader>
    [ read-input ] with-stream
    process-input
;

MAIN: knucleotide
