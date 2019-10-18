! Binary Min Heap
! Copyright 2007 Ryan Murphy
! See http://factorcode.org/license.txt for BSD license.

USING: kernel math sequences ;
IN: heap

: [comp] ( elt elt -- ? ) <=> 0 > ;

: <heap> ( -- heap ) V{ } clone ;

: left ( index -- index ) ! left child
    2 * 1 + ;

: leftv ( heap index -- value )
    left swap nth ;

: right ( index -- index ) ! right child
    2 * 2 + ;

: rightv ( heap index -- value )
    right swap nth ;

: l-oob ( i heap -- ? ) swap left swap length >= ;
: r-oob ( i heap -- ? ) swap right swap length >= ;

: up ( index -- index ) ! parent node
    1 -  2 /i ;

: upv ( heap index -- value ) ! parent's value
    up swap nth ;

: lasti ( seq -- index ) length 1 - ;

: swapup ( heap index -- ) dup up rot exchange ;

: (farchild) ( heap index -- index ) tuck 2dup leftv -rot rightv [comp] [ right ] [ left ] if ;

: farchild ( heap index -- index ) dup right pick length >= [ nip left ] [ (farchild) ] if ;

: farchildv ( heap index -- value ) dupd farchild swap nth ;

: swapdown ( heap index -- ) 2dup farchild rot exchange ;

: upheap ( heap -- )
    dup dup lasti upv over peek [comp]
    [ dup lasti 2dup swapup up 1 + head-slice upheap ] [ drop ] if ;

: add ( elt heap -- )
    tuck push upheap ;

: add-many ( seq heap -- )
    swap [ swap add ] each-with ;

DEFER: (downheap)

: (downheap2) ( i heap -- )
    2dup nth -rot
    2dup swap farchild dup pick nth 2swap
    >r >r
    swapd [comp]
    [ r> r> tuck swap swapdown (downheap) ] [ drop r> r> 2drop ] if ;

: (downheap) ( i heap -- )
    over left over length >= [ 2drop ] [ (downheap2) ] if ;

: downheap ( heap -- )
    0 swap (downheap) ;

: bump ( heap -- )
    dup peek 0 pick set-nth dup pop* downheap ;

: gbump ( heap -- first )
    dup first swap bump ;