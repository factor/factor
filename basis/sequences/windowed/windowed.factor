! Copyright (C) 2012 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.order math.statistics
sequences sequences.private ;
IN: sequences.windowed

TUPLE: windowed-sequence
    { sequence sequence read-only }
    { n integer } ;

INSTANCE: windowed-sequence sequence

C: <windowed-sequence> windowed-sequence

M: windowed-sequence nth-unsafe
    [ 1 + ] dip [ n>> dupd [-] swap ] [ sequence>> ] bi <slice> ; inline

M: windowed-sequence length
    sequence>> length ; inline

: in-bound ( n sequence -- n' )
    [ drop 0 ] [ length ] bi clamp ; inline

: in-bounds ( a b sequence -- a' b' sequence )
    [ nip in-bound ] [ nipd in-bound ] [ 2nip ] 3tri ;

:: rolling-map ( ... seq n quot: ( ... slice -- ... elt ) -- ... newseq )
    seq length [
        1 + [ n [-] ] [ seq <slice-unsafe> ] bi quot call
    ] map-integers ; inline

: rolling-sum ( seq n -- newseq )
    [ sum ] rolling-map ;

: rolling-mean ( seq n -- newseq )
    [ mean ] rolling-map ;

: rolling-median ( seq n -- newseq )
    [ median ] rolling-map ;

: rolling-supremum ( seq n -- newseq )
    [ supremum ] rolling-map ;

: rolling-infimum ( seq n -- newseq )
    [ infimum ] rolling-map ;

: rolling-count ( ... u n quot: ( ... elt -- ... ? ) -- ... v )
    '[ _ count ] rolling-map ; inline
