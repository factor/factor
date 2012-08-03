! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors grouping kernel math sequences
sequences.private splitting.monotonic wrap ;
IN: wrap.words

TUPLE: word key width break? ;
C: <word> word

<PRIVATE

: words-length ( words -- length )
    [ width>> ] map-sum ;

: make-element ( whites blacks -- element )
    [ append ] [ [ words-length ] bi@ ] 2bi <element> ;

: ?first2 ( seq -- first/f second/f )
    dup length dup 1 > [ first2-unsafe ] [
        0 > [ first-unsafe f ] [ drop f f ] if
    ] if ;

: split-words ( seq -- half-elements )
    [ [ break?>> ] same? ] monotonic-split ;

: ?first-break ( seq -- newseq f/element )
    dup first first break?>>
    [ unclip-slice f swap make-element ]
    [ f ] if ;

: make-elements ( seq f/element -- elements )
    [ 2 group [ ?first2 make-element ] map! ] dip
    [ prefix ] when* ;

: words>elements ( seq -- newseq )
    split-words ?first-break make-elements ;

PRIVATE>

: wrap-words ( words line-max line-ideal -- lines )
    [ words>elements ] 2dip wrap [ concat ] map! ;

