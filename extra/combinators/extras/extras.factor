! Copyright (C) 2013 Doug Coleman, John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators combinators.smart
generalizations graphs.private kernel kernel.private math
math.order namespaces parser quotations sequences
sequences.generalizations sequences.private sets shuffle
stack-checker.transforms system words ;
IN: combinators.extras

<PRIVATE
: callk ( ..a quot: ( ..a -- ..b ) -- ..b quot )
    dup [ call ] dip ; inline
PRIVATE>

: once ( quot -- ) call ; inline
: twice ( quot -- ) callk call ; inline
: thrice ( quot -- ) callk callk call ; inline
: forever ( quot -- ) '[ @ t ] loop ; inline

MACRO: cond-case ( assoc -- quot )
    [
        dup callable? [
            [ first '[ dup @ ] ]
            [ second '[ drop @ ] ] bi 2array
        ] unless
    ] map '[ _ cond ] ;

MACRO: sequence-case ( assoc -- quot )
    [
        dup callable? [
            [ first dup set? [ in? ] [ = ] ? '[ dup _ @ ] ]
            [ second '[ drop @ ] ] bi 2array
        ] unless
    ] map [ cond ] curry ;

MACRO: cleave-array ( quots -- quot )
    dup length '[ _ cleave _ narray ] ;

: 4bi ( w x y z  p q -- )
    [ 4keep ] dip call ; inline

: 4tri ( w x y z  p q r -- )
    [ [ 4keep ] dip 4keep ] dip call ; inline

: quad ( x  p q r s -- )
    [ [ [ keep ] dip keep ] dip keep ] dip call ; inline

: 2quad ( x y  p q r s -- )
    [ [ [ 2keep ] dip 2keep ] dip 2keep ] dip call ; inline

: 3quad ( x y z  p q r s -- )
    [ [ [ 3keep ] dip 3keep ] dip 3keep ] dip call ; inline

: 4quad ( w x y z  p q r s -- )
    [ [ [ 4keep ] dip 4keep ] dip 4keep ] dip call ; inline

: 3bi* ( u v w  x y z  p q -- )
    [ 3dip ] dip call ; inline

: 4bi* ( s t u v  w x y z  p q -- )
    [ 4dip ] dip call ; inline

: 3tri* ( o s t  u v w  x y z  p q r -- )
    [ 6 ndip ] 2dip [ 3dip ] dip call ; inline

: 4tri* ( l m n o  s t u v  w x y z  p q r -- )
    [ 8 ndip ] 2dip [ 4dip ] dip call ; inline

: quad* ( w  x  y  z  p q r s -- )
    [ [ [ 3dip ] dip 2dip ] dip dip ] dip call ; inline

: 2quad* ( o t  u v  w x  y z  p q r s -- )
    [ [ [ 6 ndip ] dip 4dip ] dip 2dip ] dip call ; inline

: 3quad* ( k l m  n o t  u v w  x y z  p q r s -- )
    [ [ [ 9 ndip ] dip 6 ndip ] dip 3dip ] dip call ; inline

: 4quad* ( g h i j  k l m n  o t u v  w x y z  p q r s -- )
    [ [ [ 12 ndip ] dip 8 ndip ] dip 4dip ] dip call ; inline

: 3bi@ ( u v w  x y z  quot -- ) dup 3bi* ; inline

: 4bi@ ( s t u v  w x y z  quot -- ) dup 4bi* ; inline

: 3tri@ ( r s t  u v w  x y z  quot -- )
    dup dup 3tri* ; inline

: 4tri@ ( o p q r  s t u v  w x y z  quot -- )
    dup dup 4tri* ; inline

: quad@ ( w  x  y  z  quot -- )
    dup dup dup quad* ; inline

: 2quad@ ( s t  u v  w x  y z  quot -- )
    dup dup dup 2quad* ; inline

: 3quad@ ( o p q  r s t  u v w  x y z  quot -- )
    dup dup dup 3quad* ; inline

: 4quad@ ( k l m n  o p q r  s t u v  w x y z  quot -- )
    dup dup dup 4quad* ; inline

: quad-curry ( x  p q r s -- p' q' r' s' )
    [ currier ] quad@ quad ; inline

: quad-curry* ( w x y z  p q r s -- p' q' r' s' )
    [ currier ] quad@ quad* ; inline

: quad-curry@ ( w x y z  q -- p' q' r' s' )
    currier quad@ ; inline

MACRO: smart-plox ( true: ( ... -- x ) -- quot )
    [ inputs [ 1 - [ and ] n*quot ] keep ] 1guard
    '[ _ _ [ _ ndrop f ] smart-if ] ;

: throttle ( quot millis -- quot' )
    1,000,000 * '[
        _ nano-count { 0 } 2dup first-unsafe _ + >=
        [ 0 swap set-nth-unsafe call ] [ 3drop ] if
    ] ; inline

: swap-when ( x y quot: ( x -- n ) quot: ( n n -- ? ) -- x' y' )
    '[ _ _ 2dup _ bi@ @ [ swap ] when ] call ; inline

: >false ( obj -- f ) drop f ; inline
: >2false ( obj1 obj2 -- f f ) 2drop f f ; inline
: >3false ( obj1 obj2 obj3 -- f f f ) 3drop f f f ; inline
: >4false ( obj1 obj2 obj3 obj4 -- f f f f ) 4drop f f f f ; inline

: 2false-unless ( obj1 obj2 ? -- f f )
    [ >2false ] unless ; inline

: 2falsify ( obj1 obj2 -- obj1/f obj2/f )
    2dup and 2false-unless ; inline

: 3false-unless ( obj1 obj2 obj3 ? -- f f f )
    [ >3false ] unless ; inline

: 3falsify ( obj1 obj2 obj3 -- obj1/f obj2/f obj3/f )
    3dup and and 3false-unless ; inline

MACRO: n-and ( n -- quot )
    1 [-] [ and ] n*quot ;

MACRO: n*obj ( n obj -- quot )
    1quotation n*quot ;

MACRO:: n-falsify ( n -- quot )
    [ n ndup n n-and [ n ndrop n f n*obj ] unless ] ;

! when both args are true, call quot. otherwise dont
: ?2res ( ..a obj1 obj2 quot: ( obj1 obj2 -- ? ) -- ..b )
    [ 2dup and ] dip [ 2drop f ] if ; inline

! try the quot, keep the original arg if quot is true
: ?1arg ( obj quot: ( obj -- ? ) -- obj/f )
    [ ?call ] keepd '[ _ ] [ f ] if ; inline

: ?2arg ( obj1 obj2 quot: ( obj1 obj2 -- ? ) -- obj1/f obj2/f )
    [ ?2res ] 2keepd '[ _ _ ] [ f f ] if ; inline

<<
: alist>quot* ( default assoc -- quot )
    [ rot \ if* 3array [ ] append-as ] assoc-each ;

: cond*>quot ( assoc -- quot )
    [
        dup pair? [ [ drop ] prepend [ t ] swap 2array ] unless
    ] map reverse! [ no-cond ] swap alist>quot* ;

DEFER: cond*
\ cond* [ cond*>quot ] 1 define-transform
\ cond* t "no-compile" set-word-prop
>>
: cond* ( assoc -- )
    [ dup callable? [ drop t ] [ first call ] if ] map-find
    [ dup callable? [ nip call ] [ second call ] if ]
    [ no-cond ] if* ;

MACRO: chain ( quots -- quot )
    <reversed> [ ] [ swap '[ [ @ @ ] [ f ] if* ] ] reduce ;

: with-output-variable ( value variable quot -- value )
    over '[ @ _ get ] with-variable ; inline

: with-global-variable ( value key quot -- )
    [ set-global ] dip call ; inline

: with-output-global-variable ( value variable quot -- value )
    over '[ @ _ get-global ] with-global-variable ; inline

: loop1 ( ..a quot: ( ..a -- ..a obj ? ) -- ..a obj )
    [ call ] keep '[ drop _ loop1 ] when ; inline recursive

: keep-1up ( quot -- quot ) keep 1 2 0 nrotated ; inline
: keep-2up ( quot -- quot ) keep 2 3 0 nrotated ; inline
: keep-3up ( quot -- quot ) keep 3 4 0 nrotated ; inline

: 2keep-1up ( quot -- quot ) 2keep 1 3 0 nrotated ; inline
: 2keep-2up ( quot -- quot ) 2keep 2 4 0 nrotated ; inline
: 2keep-3up ( quot -- quot ) 2keep 3 5 0 nrotated ; inline

: 3keep-1up ( quot -- quot ) 3keep 1 4 0 nrotated ; inline
: 3keep-2up ( quot -- quot ) 3keep 2 5 0 nrotated ; inline
: 3keep-3up ( quot -- quot ) 3keep 3 6 0 nrotated ; inline

! d is dummy, o is object to save notation space
: dip-1up  ( ..a d quot: ( ..a -- ..b o ) -- ..b d o )
    dip swap ; inline

: dip-2up  ( ..a d quot: ( ..a -- ..b o1 o2 ) -- ..b d o1 o2 )
    dip rot rot ; inline

: 2dip-1up ( ..a d1 d2 quot: ( ..a -- ..b o ) -- ..b d1 d2 o )
    2dip rot ; inline

: 2dip-2up ( ..a d1 d2 quot: ( ..a -- ..b o1 o2 ) -- ..b d1 d2 o1 o2 )
    2dip roll roll ; inline

: 3dip-1up ( ..a d1 d2 d3 quot: ( ..a -- ..b o ) -- ..b d1 d2 d3 o )
    3dip roll ; inline

: 3dip-2up ( ..a d1 d2 d3 quot: ( ..a -- ..b o1 o2 ) -- ..b d1 d2 d3 o1 o2 )
    3dip 2 5 0 nrotated ; inline

: 3dip-3up ( ..a d1 d2 d3 quot: ( ..a -- ..b o1 o2 o3 ) -- ..b d1 d2 d3 o1 o2 o3 )
    3dip 3 6 0 nrotated ; inline

: 2craft-1up ( ..a quot1: ( ..a -- ..b o1 ) quot2: ( ..b -- ..c o2 ) -- ..c o1 o2 )
    [ call ] dip [ dip-1up ] call ; inline

: 3craft-1up ( ..a quot1: ( ..a -- ..b o1 ) quot2: ( ..b -- ..c o2 ) quot3: ( ..c -- ..d o3 ) -- ..d o1 o2 o3 )
    [ call ] 2dip [ dip-1up ] dip [ 2dip-1up ] call ; inline

: 4craft-1up ( ..a quot1: ( ..a -- ..b o1 ) quot2: ( ..b -- ..c o2 ) quot3: ( ..c -- ..d o3 ) quot4: ( ..d -- ..e o4 ) -- ..e o1 o2 o3 o4 )
    [ call ] 3dip [ dip-1up ] 2dip
    [ 2dip-1up ] dip [ 3dip-1up ] call ; inline

: 3and ( a b c -- ? ) and and ; inline
: 4and ( a b c d -- ? ) and and and ; inline

: 3or ( a b c -- ? ) or or ; inline
: 4or ( a b c d -- ? ) or or or ; inline

! The kept values are on the bottom of the stack
MACRO: keep-under ( quot -- quot' )
    dup outputs 1 + '[ _ keep 1 _ 0 -nrotated ] ;

MACRO: 2keep-under ( quot -- quot' )
    dup outputs 2 + '[ _ 2keep 2 _ 0 -nrotated ] ;

MACRO: 3keep-under ( quot -- quot' )
    dup outputs 3 + '[ _ 3keep 3 _ 0 -nrotated ] ;

MACRO: 4keep-under ( quot -- quot' )
    dup outputs 4 + '[ _ 4keep 4 _ 0 -nrotated ] ;

! for use with assoc-map etc.
: 1temp1d ( quot: ( a b c -- d e f ) -- quot )
    '[ swap @ swap ] ; inline

: 1temp2d ( quot: ( a b c -- d e f ) -- quot )
    '[ rot @ -rot ] ; inline

: 2temp2d ( quot: ( a b c d -- e f g h ) -- quot )
    '[ 2 4 0 nrotated @ 2 4 0 -nrotated ] ; inline

<PRIVATE
: (closure-limit) ( vertex set quot: ( vertex -- edges ) i n -- )
    2dup < [
        [ 1 + ] dip 2reach ?adjoin [
            [ [ dip ] keep ] 2dip
            '[ _ _ _ _ (closure-limit) ] each
        ] [ 5drop ] if
    ] [ 5drop ] if ; inline recursive
PRIVATE>

: closure-limit-as ( vertex quot: ( vertex -- edges ) n exemplar -- set )
    [ 0 ] 2dip
    new-empty-set-like [ -roll (closure-limit) ] keep ; inline

: closure-limit ( vertex quot: ( vertex -- edges ) n -- set )
    HS{ } closure-limit-as ; inline

: 1check ( obj quot -- obj ? )
    over [ call ] dip swap ; inline

: 2check ( obj1 obj2 quot -- obj1 obj2 ? )
    2over [ call ] 2dip rot ; inline

: 1check-when ( ..a obj cond: ( ..a obj -- ? ) true: ( ..a obj -- ..b ) -- ..b )
    [ 1check ] dip when ; inline

: 2check-when ( ..a obj1 obj2 cond: ( ..a obj1 obj2 -- ? ) true: ( ..a obj1 obj2 -- ..b ) -- ..b )
    [ 2check ] dip when ; inline

SYNTAX: ?[ parse-quotation [ ?call ] curry append! ;
