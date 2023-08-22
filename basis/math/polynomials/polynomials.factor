! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays combinators kernel make math math.bits
math.vectors sequences vectors ;
IN: math.polynomials

<PRIVATE

: 2pad-head ( p q n -- p q ) [ 0 pad-head ] curry bi@ ;
: 2pad-tail ( p q n -- p q ) [ 0 pad-tail ] curry bi@ ;
: pextend ( p q -- p q ) 2dup max-length 2pad-tail ;
: pextend-left ( p q -- p q ) 2dup max-length 2pad-head ;
: unempty ( seq -- seq ) [ { 0 } ] when-empty ;
: 2unempty ( seq seq -- seq seq ) [ unempty ] bi@ ;

PRIVATE>

: powers ( n x -- seq )
    <repetition> 1 [ * ] accumulate nip ;

: p= ( p q -- ? ) pextend = ;

: ptrim ( p -- q )
    dup length 1 = [ [ zero? ] trim-tail ] unless ;

: 2ptrim ( p q -- p' q' ) [ ptrim ] bi@ ;
: p+ ( p q -- r ) pextend v+ ;
: p- ( p q -- r ) pextend v- ;
ALIAS: n*p n*v

: pextend-conv ( p q -- p' q' )
    2dup 2length + 1 - 2pad-tail ;

: p* ( p q -- r )
    2unempty pextend-conv
    [ drop length [ <iota> ] keep ]
    [ nip <reversed> ]
    [ drop ] 2tri
    '[ _ _ <slice> _ vdot ] map reverse! ;

: p-sq ( p -- p^2 ) dup p* ; inline

ERROR: negative-power-polynomial p n ;

: (p^) ( p n  -- p^n )
    make-bits { 1 } [ [ over p* ] when [ p-sq ] dip ] reduce nip ;

: p^ ( p n -- p^n )
    dup 0 >= [ (p^) ] [ negative-power-polynomial ] if ;

<PRIVATE

: p/mod-setup ( p p -- p p n )
    2ptrim
    2dup 2length -
    dup 1 < [ drop 1 ] when
    [ over length + 0 pad-head pextend ] keep 1 + ;

: /-last ( seq1 seq2 -- x ) [ last ] bi@ / ;

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
    dup V{ 0 } p= [
        drop nip
    ] [
        [ nip ] [ p/mod ] 2bi
        [ pick p* swap [ swapd p- ] dip ] dip (pgcd)
    ] if ;

PRIVATE>

: pgcd ( p q -- a d )
    [ V{ 0 } clone V{ 1 } clone ] 2dip swap (pgcd) [ >array ] bi@ ;

: pdiff ( p -- p' )
    dup length <iota> v* rest ;

: polyval ( x p -- p[x] )
    ! Horner scheme
    [ nip <reversed> unclip-slice swap ]
    [ drop ] 2bi
    '[ [ _ * ] dip + ] each ;

MACRO: polyval* ( p -- quot )
    reverse
    [ rest [ \ * swap \ + [ ] 3sequence ] map ]
    [ first \ drop swap [ ] 2sequence ] bi
    prefix \ cleave [ ] 2sequence ;
