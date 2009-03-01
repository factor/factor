! Copyright (C) 2007, 2008 Slava Pestov, Chris Double,
!                          Doug Coleman, Eduardo Cavazos,
!                          Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel combinators fry namespaces make quotations hashtables
sequences assocs arrays stack-checker effects math math.ranges
generalizations macros continuations random locals accessors ;

IN: combinators.lib

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Currying cleave combinators
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bi, ( obj quot quot -- quot' quot' )
    [ [ curry ] curry ] bi@ bi ; inline
: tri, ( obj quot quot quot -- quot' quot' quot' )
    [ [ curry ] curry ] tri@ tri ; inline

: bi*, ( obj obj quot quot -- quot' quot' )
    [ [ curry ] curry ] bi@ bi* ; inline
: tri*, ( obj obj obj quot quot quot -- quot' quot' quot' )
    [ [ curry ] curry ] tri@ tri* ; inline

: bi@, ( obj obj quot -- quot' quot' )
    [ curry ] curry bi@ ; inline
: tri@, ( obj obj obj quot -- quot' quot' quot' )
    [ curry ] curry tri@ ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Generalized versions of core combinators
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: quad ( x p q r s -- ) [ keep ] 3dip [ keep ] 2dip [ keep ] dip call ; inline

: 4slip ( quot a b c d -- a b c d ) 4 nslip ; inline

: 4keep ( w x y z quot -- w x y z ) 4 nkeep ; inline 

: 2with ( param1 param2 obj quot -- obj curry )
    with with ; inline

: 3with ( param1 param2 param3 obj quot -- obj curry )
    with with with ; inline

: with* ( obj assoc quot -- assoc curry )
    swapd [ [ -rot ] dip call ] 2curry ; inline

: 2with* ( obj1 obj2 assoc quot -- assoc curry )
    with* with* ; inline

: 3with* ( obj1 obj2 obj3 assoc quot -- assoc curry )
    with* with* with* ; inline

: assoc-each-with ( obj assoc quot -- )
    with* assoc-each ; inline

: assoc-map-with ( obj assoc quot -- assoc )
    with* assoc-map ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! ifte
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: preserving ( predicate -- quot )
    dup infer in>>
    dup 1+
    '[ _ _ nkeep _ nrot ] ;

MACRO: ifte ( quot quot quot -- )
    '[ _ preserving _ _ if ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! switch
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: switch ( quot -- )
    [ [ [ preserving ] curry ] dip ] assoc-map
    [ cond ] curry ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Conceptual implementation:

! : pcall ( seq quots -- seq ) [ call ] 2map ;

MACRO: parallel-call ( quots -- )
    [ '[ [ unclip @ ] dip [ push ] keep ] ] map concat
    '[ V{ } clone @ nip >array ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! map-call and friends
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (make-call-with) ( quots -- quot ) 
    [ [ keep ] curry ] map concat [ drop ] append ;

MACRO: map-call-with ( quots -- )
    [ (make-call-with) ] keep length [ narray ] curry compose ;

: (make-call-with2) ( quots -- quot )
    [ [ 2dup >r >r ] prepend [ r> r> ] append ] map concat
    [ 2drop ] append ;

MACRO: map-call-with2 ( quots -- )
    [
        [ [ 2dup >r >r ] prepend [ r> r> ] append ] map concat
        [ 2drop ] append    
    ] keep length [ narray ] curry append ;

MACRO: map-exec-with ( words -- )
    [ 1quotation ] map [ map-call-with ] curry ;

MACRO: construct-slots ( assoc tuple-class -- tuple ) 
    [ new ] curry swap [
        [ dip ] curry swap 1quotation [ keep ] curry compose
    ] { } assoc>map concat compose ;

: 2quot-with ( obj seq quot1 quot2 -- seq quot1 quot2 )
    >r pick >r with r> r> swapd with ;

MACRO: multikeep ( word out-indexes -- ... )
    [
        dup >r [ \ npick \ >r 3array % ] each
        %
        r> [ drop \ r> , ] each
    ] [ ] make ;

: generate ( generator predicate -- obj )
    '[ dup @ dup [ nip ] unless ]
    swap do until ;

MACRO: predicates ( seq -- quot/f )
    dup [ 1quotation [ drop ] prepend ] map
    [ [ [ dup ] prepend ] map ] dip zip [ drop f ] suffix
    [ cond ] curry ;

: %chance ( quot n -- ) 100 random > swap when ; inline
