! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel make math math.order math.vectors sequences shuffle
    splitting vectors ;
IN: math.polynomials

<PRIVATE

: 2pad-left ( p q n -- p q ) [ 0 pad-left ] curry bi@ ;
: 2pad-right ( p q n -- p q ) [ 0 pad-right ] curry bi@ ;
: pextend ( p q -- p q ) 2dup [ length ] bi@ max 2pad-right ;
: pextend-left ( p q -- p q ) 2dup [ length ] bi@ max 2pad-left ;
: unempty ( seq -- seq ) [ { 0 } ] when-empty ;
: 2unempty ( seq seq -- seq seq ) [ unempty ] bi@ ;

PRIVATE>

: powers ( n x -- seq )
    <array> 1 [ * ] accumulate nip ;

: p= ( p q -- ? ) pextend = ;

: ptrim ( p -- p )
    dup length 1 = [ [ zero? ] trim-right ] unless ;

: 2ptrim ( p q -- p q ) [ ptrim ] bi@ ;
: p+ ( p q -- r ) pextend v+ ;
: p- ( p q -- r ) pextend v- ;
: n*p ( n p -- n*p ) n*v ;

: pextend-conv ( p q -- p q )
    2dup [ length ] bi@ + 1- 2pad-right [ >vector ] bi@ ;

: p* ( p q -- r )
    2unempty pextend-conv <reversed> dup length
    [ over length pick <slice> pick [ * ] 2map sum ] map 2nip reverse ;

: p-sq ( p -- p^2 )
    dup p* ;

<PRIVATE

: p/mod-setup ( p p -- p p n )
    2ptrim
    2dup [ length ] bi@ -
    dup 1 < [ drop 1 ] when
    [ over length + 0 pad-left pextend ] keep 1+ ;

: /-last ( seq seq -- a )
    #! divide the last two numbers in the sequences
    [ peek ] bi@ / ;

: (p/mod) ( p p -- p p )
    2dup /-last
    2dup , n*p swapd
    p- >vector
    dup pop* swap rest-slice ;

PRIVATE>

: p/mod ( p q -- z w )
    p/mod-setup [ [ (p/mod) ] times ] V{ } make
    reverse nip swap 2ptrim pextend ;

<PRIVATE

: (pgcd) ( b a y x -- a d )
    dup V{ 0 } clone p= [
        drop nip
    ] [
        tuck p/mod [ pick p* swap [ swapd p- ] dip ] dip (pgcd)
    ] if ;

PRIVATE>

: pgcd ( p q -- a d )
    swap V{ 0 } clone V{ 1 } clone 2swap (pgcd) [ >array ] bi@ ;

: pdiff ( p -- p' )
    dup length v* { 0 } ?head drop ;

: polyval ( p x -- p[x] )
    [ dup length ] dip powers v. ;

