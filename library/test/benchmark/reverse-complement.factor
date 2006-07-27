IN: temporary
USING: compiler hashtables io kernel math math namespaces
sequences strings vectors words words ;

! Instead of a variable, we define an inline word which pushes
! the hash on the stack, for performance.
DEFER: trans-hash

[
    26 [ CHAR: A + dup set ] each
    26 [ CHAR: a + dup set ] each

    "TGCAAKYRMBDHV"
    "ACGTUMRYKVHDB"
    2dup
    [ set ] 2each
    [ ch>lower set ] 2each
] make-hash

\ trans-hash swap unit define-compound
\ trans-hash t "inline" set-word-prop

: translate-seq ( seq -- sbuf )
    [
        2000000 <sbuf> building set
        <reversed> [ <reversed> % ] each
        building get dup [ trans-hash hash ] inject
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
