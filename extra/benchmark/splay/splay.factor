! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: arrays assocs kernel random sequences
sorting trees.splay ;

IN: benchmark.splay

: initial-alist ( n -- alist )
    <iota> >array randomize dup zip ;

: change-random ( newkeys splay keys -- splay' )
    swapd [ first pick delete-at first2 pick set-at ] 2each ;

: splay-benchmark ( -- )
    100,000 initial-alist 10,000 cut
    [ >splay ] [ randomize 10,000 head ] bi
    change-random keys dup sort assert= ;

MAIN: splay-benchmark
