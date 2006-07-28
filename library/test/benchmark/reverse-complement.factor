IN: temporary
USING: compiler hashtables io kernel math math namespaces
sequences strings vectors words words ;

DEFER: trans-map

: add-translation \ trans-map get set-nth ;

[
    256 0 <string> \ trans-map set
    26 [ CHAR: A + dup add-translation ] each
    26 [ dup CHAR: A + swap CHAR: a + add-translation ] each

    "TGCAAKYRMBDHV"
    "ACGTUMRYKVHDB"
    2dup
    [ add-translation ] 2each
    [ ch>lower add-translation ] 2each
    
    \ trans-map get
] with-scope

\ trans-map swap unit define-compound
\ trans-map t "inline" set-word-prop

: translate-seq ( seq -- sbuf )
    [
        30000000 <sbuf> building set
        <reversed> [ <reversed> % ] each
        building get dup [ trans-map nth ] inject
    ] with-scope ;

SYMBOL: out

: seg ( sbuf n -- str )
    60 * dup 60 + pick length min rot <slice> >string ;

: show-seq ( seq -- )
    translate-seq dup length 59 + 60 /i
    [ seg out get stream-print ] each-with ;

: clear-seq ( seq -- ) 0 swap set-length ;

: do-line ( seq line -- seq )
    dup first ">;" memq? [
        over show-seq out get stream-print dup clear-seq
    ] [
        over push
    ] if ;

: (reverse-complement) ( seq -- )
    readln [ do-line (reverse-complement) ] [ show-seq ] if* ;

: reverse-complement ( infile outfile -- )
    <file-writer> [
        stdio get out set
        <file-reader> [
            500000 <vector> (reverse-complement)
        ] with-stream
    ] with-stream ;

{ translate-seq seg clear-seq } [ compile ] each
