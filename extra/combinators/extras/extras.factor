! Copyright (C) 2013 Doug Coleman, John Benediktsson.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators combinators.smart fry
generalizations kernel macros math quotations sequences locals
math.order sequences.generalizations sequences.private
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

: 4bi@ ( s t u v w x y z quot -- )
    dup 4bi* ; inline

: 4tri ( w x y z p q r -- )
    [ [ 4keep ] dip 4keep ] dip call ; inline

: plox ( ... x/f quot: ( ... x -- ... ) -- ... )
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
