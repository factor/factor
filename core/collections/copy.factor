! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math errors generic ;
IN: sequences-internals

: keep-copying? pick over < ; inline
: read-src >r >r 2dup nth-unsafe r> r> ; inline
: write-dest 2dup >r >r set-nth-unsafe r> r> ; inline
: inc-counters >r 1+ >r >r 1+ r> r> r> ; inline
: return-dest drop >r 3drop r> ; inline

: (copy) ( i src j dest n -- dest )
    keep-copying?
    [ >r read-src write-dest inc-counters r> (copy) ]
    [ return-dest ] if ; inline

: check-copy ( src start dest -- )
    over 0 < [ bounds-error ] when
    >r swap length + r> lengthen ;

: prepare-subseq ( from to seq -- i src j dest n )
    swap pick - 2dup swap new swap 0 -rot ; inline

IN: sequences

: subseq ( from to seq -- subseq )
    3dup check-slice prepare-subseq (copy) ;

: copy ( src n dest -- )
    pick length pick + >r 3dup check-copy 0 -roll r>
    (copy) drop ; inline

: nappend ( src dest -- ) [ length ] keep copy ;

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
    over type over type eq? [
        drop clone
    ] [
        >r dup length 0 swap r> new [ copy ] keep
    ] if ; inline

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
