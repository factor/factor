! Copyright (C) 2013 Doug Coleman, John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators combinators.smart
generalizations kernel math math.order namespaces quotations
sequences sequences.generalizations sequences.private
stack-checker.transforms system words ;
IN: combinators.extras

: once ( quot -- ) call ; inline
: twice ( quot -- ) dup [ call ] dip call ; inline
: thrice ( quot -- ) dup dup [ call ] 2dip [ call ] dip call ; inline
: forever ( quot -- ) [ t ] compose loop ; inline

MACRO: cond-case ( assoc -- quot )
    [
        dup callable? not [
            [ first [ dup ] prepose ]
            [ second [ drop ] prepose ] bi 2array
        ] when
    ] map [ cond ] curry ;

MACRO: cleave-array ( quots -- quot )
    [ '[ _ cleave ] ] [ length '[ _ narray ] ] bi compose ;

: 3bi* ( u v w x y z p q -- )
    [ 3dip ] dip call ; inline

: 3bi@ ( u v w x y z quot -- )
    dup 3bi* ; inline

: 4bi ( w x y z p q -- )
    [ 4keep ] dip call ; inline

: 4bi* ( s t u v w x y z p q -- )
    [ 4dip ] dip call ; inline

: 4tri* ( o p q r  s t u v  w x y z  p q r -- )
    [ 8 ndip ] 2dip
    [ 4dip ] dip
    call ; inline

: 4bi@ ( s t u v  w x y z  quot -- )
    dup 4bi* ; inline

: 4tri@ ( a b c d  e f g h  i j k l  quot -- )
    dup dup 4tri* ; inline

: 4tri ( w x y z  p q r -- )
    [ [ 4keep ] dip 4keep ] dip call ; inline

: 4quad ( w x y z  p q r s -- )
    [ [ [ 4keep ] dip 4keep ] dip 4keep ] dip call ; inline

: quad* ( w x y z p q r s -- ) [ [ [ 3dip ] dip 2dip ] dip dip ] dip call ; inline

: quad@ ( w x y z quot -- ) dup dup dup quad* ; inline

: plox ( ... x/f quot: ( ... x -- ... y ) -- ... y/f )
    dupd when ; inline

MACRO: smart-plox ( true -- quot )
    [ inputs [ 1 - [ and ] n*quot ] keep ] keep swap
    '[ _ _ [ _ ndrop f ] smart-if ] ;

: throttle ( quot millis -- quot' )
    1,000,000 * '[
        _ nano-count { 0 } 2dup first-unsafe _ + >=
        [ 0 swap set-nth-unsafe call ] [ 3drop ] if
    ] ; inline

: swap-when ( x y quot: ( x -- n ) quot: ( n n -- ? ) -- x' y' )
    '[ _ _ 2dup _ bi@ @ [ swap ] when ] call ; inline


! ?1arg-result-falsify

: 1falsify ( obj/f -- obj/f ) ; inline
: 2falsify ( obj1 obj2 -- obj1/f obj2/f ) 2dup and [ 2drop f f ] unless ; inline
: 3falsify ( obj1 obj2 obj3 -- obj1/f obj2/f obj3/f ) 3dup and and [ 3drop f f f ] unless ; inline

MACRO: n-and ( n -- quot )
    1 [-] [ and ] n*quot ;

MACRO: n*obj ( n obj -- quot )
    1quotation n*quot ;

MACRO:: n-falsify ( n -- quot )
    [ n ndup n n-and [ n ndrop n f n*obj ] unless ] ;

! plox
: ?1res ( ..a obj/f quot -- ..b )
    dupd when ; inline

! when both args are true, call quot. otherwise dont
: ?2res ( ..a obj1 obj2 quot: ( obj1 obj2 -- ? ) -- ..b )
    [ 2dup and ] dip [ 2drop f ] if ; inline

! try the quot, keep the original arg if quot is true
: ?1arg ( obj quot: ( obj -- ? ) -- obj/f )
    [ ?1res ] keepd '[ _ ] [ f ] if ; inline

: ?2arg ( obj1 obj2 quot: ( obj1 obj2 -- ? ) -- obj1/f obj2/f )
    [ ?2res ] 2keepd '[ _ _ ] [ f f ] if ; inline

<<
: alist>quot* ( default assoc -- quot )
    [ rot \ if* 3array append [ ] like ] assoc-each ;

: cond*>quot ( assoc -- quot )
    [ dup pair? [ [ drop ] prepend [ t ] swap 2array ] unless ] map
    reverse! [ no-cond ] swap alist>quot* ;

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
    over [ get ] curry compose with-variable ; inline

: loop1 ( ..a quot: ( ..a -- ..a obj ? ) -- ..a obj )
    [ call ] keep '[ drop _ loop1 ] when ; inline recursive


: keep-1up ( quot -- quot ) keep 1 2 nrotates ; inline
: keep-2up ( quot -- quot ) keep 2 3 nrotates ; inline
: keep-3up ( quot -- quot ) keep 3 4 nrotates ; inline

: 2keep-1up ( quot -- quot ) 2keep 1 3 nrotates ; inline
: 2keep-2up ( quot -- quot ) 2keep 2 4 nrotates ; inline
: 2keep-3up ( quot -- quot ) 2keep 3 5 nrotates ; inline

: 3keep-1up ( quot -- quot ) 3keep 1 4 nrotates ; inline
: 3keep-2up ( quot -- quot ) 3keep 2 5 nrotates ; inline
: 3keep-3up ( quot -- quot ) 3keep 3 6 nrotates ; inline

! d is dummy, o is object to save notation space
: dip-1up  ( ..a d quot: ( ..a -- ..b o d ) -- ..b d o )
    dip swap ; inline
: dip-2up  ( ..a d quot: ( ..a -- ..b o1 o2 d ) -- ..b d o1 o2 )
    dip rot rot ; inline

: 2dip-1up ( ..a d1 d2 quot: ( ..a -- ..b o d1 d2 ) -- ..b d1 d2 o )
    2dip rot ; inline
: 2dip-2up ( ..a d1 d2 quot: ( ..a -- ..b o1 o2 d1 d2 ) -- ..b d1 d2 o1 o2 )
    2dip roll roll ; inline

: 3dip-1up ( ..a d1 d2 d3 quot: ( ..a -- ..b o d1 d2 d3 ) -- ..b d1 d2 d3 o )
    3dip roll ; inline
: 3dip-2up ( ..a d1 d2 d3 quot: ( ..a -- ..b o1 o2 d1 d2 d3 ) -- ..b d1 d2 d3 o1 o2 )
    3dip 2 5 nrotates ; inline
: 3dip-3up ( ..a d1 d2 d3 quot: ( ..a -- ..b o1 o2 o3 d1 d2 d3 ) -- ..b d1 d2 d3 o1 o2 o3 )
    3dip 3 6 nrotates ; inline


: 2craft-1up ( ..a quot1: ( ..a -- ..b o1 ) quot2: ( ..b -- ..c o2 ) -- ..c o1 o2 )
    [ call ] dip [ dip-1up ] call ; inline

: 3craft-1up ( ..a quot1: ( ..a -- ..b o1 ) quot2: ( ..b -- ..c o2 ) quot3: ( ..c -- ..d o3 ) -- ..d o1 o2 o3 )
    [ call ] 2dip [ dip-1up ] dip [ 2dip-1up ] call ; inline

: 4craft-1up ( ..a quot1: ( ..a -- ..b o1 ) quot2: ( ..b -- ..c o2 ) quot3: ( ..c -- ..d o3 ) quot4: ( ..d -- ..e o4 ) -- ..e o1 o2 o3 o4 )
    [ call ] 3dip [ dip-1up ] 2dip [ 2dip-1up ] dip [ 3dip-1up ] call ; inline

: 3and ( a b c -- ? ) and and ; inline
: 4and ( a b c d -- ? ) and and and ; inline

: 3or ( a b c -- ? ) or or ; inline
: 4or ( a b c d -- ? ) or or or ; inline

! The kept values are on the bottom of the stack
MACRO: keep-under ( quot -- quot' )
    dup outputs 1 + '[ _ keep 1 _ -nrotates ] ;

MACRO: 2keep-under ( quot -- quot' )
    dup outputs 2 + '[ _ 2keep 2 _ -nrotates ] ;

MACRO: 3keep-under ( quot -- quot' )
    dup outputs 3 + '[ _ 3keep 3 _ -nrotates ] ;

MACRO: 4keep-under ( quot -- quot' )
    dup outputs 4 + '[ _ 4keep 4 _ -nrotates ] ;

! for use with assoc-map etc
: 1temp1d ( quot: ( a b c -- d e f ) -- quot ) '[ swap @ swap ] ; inline
: 1temp2d ( quot: ( a b c -- d e f ) -- quot ) '[ rot @ -rot ] ; inline
: 2temp2d ( quot: ( a b c d -- e f g h ) -- quot ) '[ 2 4 nrotates @ 2 4 -nrotates ] ; inline
