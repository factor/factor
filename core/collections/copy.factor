! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math errors generic ;
IN: sequences-internals

: ((copy)) ( dst i src j n -- dst i src j n )
    dup -roll [
        + swap nth-unsafe -roll [
            + swap set-nth-unsafe
        ] 3keep drop
    ] 3keep ; inline

: (copy) ( dst i src j n -- dst )
    dup 0 <= [ 2drop 2drop ] [ 1- ((copy)) (copy) ] if ; inline

: prepare-subseq ( from to seq -- dst i src j n )
    [ >r swap - r> new 0 ] 3keep -rot over - ; inline

: check-copy ( src n dst -- )
    over 0 < [ bounds-error ] when
    >r swap length + r> lengthen ;

IN: sequences

: subseq ( from to seq -- subseq )
    3dup check-slice prepare-subseq (copy) ;

: copy ( src n dst -- )
    pick length >r 3dup check-copy swap rot 0 r>
    (copy) drop ; inline

: push-all ( src dest -- ) [ length ] keep copy ;

: ((append)) ( seq1 seq2 accum -- accum )
    [ >r over length r> copy ] keep
    [ 0 swap copy ] keep ; inline

: (append) ( seq1 seq2 exemplar -- newseq )
    [
        >r over length over length + r> new ((append))
    ] keep like ; inline

: (3append) ( seq1 seq2 seq3 exemplar -- newseq )
    [
        >r pick length pick length pick length + + r> new
        [ >r pick length pick length + r> copy ] keep
        ((append))
    ] keep like ; inline

: append ( seq1 seq2 -- newseq ) over (append) ;

: 3append ( seq1 seq2 seq3 -- newseq ) pick (3append) ;

: clone-like ( seq exemplar -- newseq )
    >r dup length r> new [ 0 swap copy ] keep ; inline

TUPLE: groups seq n ;

: check-groups 0 <= [ "Invalid group count" throw ] when ;

C: groups ( seq n -- groups )
    >r dup check-groups r>
    [ set-groups-n ] keep
    [ set-groups-seq ] keep ; inline

M: groups length
    dup groups-seq length swap groups-n [ + 1- ] keep /i ;

M: groups nth
    [ groups-n [ * dup ] keep + ] keep
    groups-seq [ length min ] keep
    subseq ;

M: groups like drop { } like ;
