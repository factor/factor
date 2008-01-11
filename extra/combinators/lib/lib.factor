! Copyright (C) 2007 Slava Pestov, Chris Double, Doug Coleman,
!                    Eduardo Cavazos, Daniel Ehrenberg.
! 
! See http://factorcode.org/license.txt for BSD license.

USING: kernel combinators namespaces quotations hashtables sequences assocs
       arrays inference effects math math.ranges arrays.lib shuffle macros
       bake combinators.cleave ;

IN: combinators.lib

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: generate ( generator predicate -- obj )
    #! Call 'generator' until the result satisfies 'predicate'.
    [ slip over slip ] 2keep
    roll [ 2drop ] [ rot drop generate ] if ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Generalized versions of core combinators
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: ndip ( quot n -- ) dup saver -rot restorer 3append ;

MACRO: nslip ( n -- ) dup saver [ call ] rot restorer 3append ;

: 4slip ( quot a b c d -- a b c d ) 4 nslip ; inline

MACRO: nkeep ( n -- )
  [ ] [ 1+ ] [ ] tri
  [ [ , ndup ] dip , -nrot , nslip ]
  bake ;

: 4keep ( w x y z quot -- w x y z ) 4 nkeep ; inline 

MACRO: ncurry ( n -- ) [ curry ] n*quot ;

MACRO: nwith ( quot n -- )
  tuck 1+ dup
  [ , -nrot [ , nrot , call ] , ncurry ]
  bake ;

MACRO: napply ( n -- )
  2 [a,b]
  [ [ ] [ 1- ] bi
    [ , ntuck , nslip ]
    bake ]
  map concat >quotation [ call ] append ;

: 3apply ( obj obj obj quot -- ) 3 napply ; inline

: dipd ( x y quot -- y ) 2 ndip ; inline

! each-with

: each-withn ( seq quot n -- ) nwith each ; inline

: each-with ( seq quot -- ) with each ; inline

: each-with2 ( obj obj list quot -- ) 2 each-withn ; inline

! map-with

: map-withn ( seq quot n -- newseq ) nwith map ; inline

: map-with ( seq quot -- ) with map ; inline

: map-with2 ( obj obj list quot -- newseq ) 2 map-withn ; inline

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


MACRO: nfirst ( n -- )
    [ [ swap nth ] curry [ keep ] curry ] map concat [ drop ] compose ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: sigma ( seq quot -- n ) [ rot slip + ] curry 0 swap reduce ; inline

: count ( seq quot -- n ) [ 1 0 ? ] compose sigma ; inline

: all-unique? ( seq -- ? ) [ prune ] keep [ length ] 2apply = ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! short circuiting words
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : short-circuit ( quots quot default -- quot )
!   >r { } map>assoc <reversed> r>
!   1quotation swap alist>quot ;

: short-circuit ( quots quot default -- quot )
  1quotation -rot { } map>assoc <reversed> alist>quot ;

! : short-circuit ( quots quot default -- quot )
!   1quotation -rot map>alist <reversed> alist>quot ;

MACRO: && ( quots -- ? ) [ [ not ] append [ f ] ] t short-circuit ;

MACRO: <-&& ( quots -- )
  [ [ dup ] swap append [ not ] append [ f ] ] t short-circuit
  [ nip ] append ;

MACRO: <--&& ( quots -- )
  [ [ 2dup ] swap append [ not ] append [ f ] ] t short-circuit
  [ 2nip ] append ;

MACRO: || ( quots -- ? ) [ [ t ] ] f short-circuit ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! ifte
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: ifte ( quot quot quot -- )
  pick infer effect-in
  dup 1+ swap
  [ >r >r , nkeep , nrot r> r> if ]
  bake ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! switch
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: preserving ( predicate -- quot )
  dup infer effect-in
  dup 1+ spin
  [ , , nkeep , nrot ]
  bake ;

MACRO: switch ( quot -- )
  [ [ preserving ] [ ] bi* ] assoc-map
  [ , cond ]
  bake ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Conceptual implementation:

! : pcall ( seq quots -- seq ) [ call ] 2map ;

MACRO: parallel-call ( quots -- )
  [ [ unclip % r> dup >r push ] bake ] map concat
  [ V{ } clone >r % drop r> >array ] bake ;

! MACRO: parallel-call ( quots -- )
!   [ [ unclip ] swap append ] map
!   [ [ r> swap add >r ] append ] map
!   concat
!   [ { } >r ] swap append ! pre
!   [ drop r> ] append ;   ! post


! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! map-call and friends
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MACRO: map-call-with ( quots -- )
  [ [ [ keep ] curry ] map concat ] keep length [ nip narray ] curry compose ;

MACRO: map-call-with2 ( quots -- )
  dup >r
  [ [ 2dup >r >r ] swap append [ r> r> ] append ] map concat
  [ 2drop ] append
  r> length [ narray ] curry append ;

MACRO: map-exec-with ( words -- ) [ 1quotation ] map [ map-call-with ] curry ;

MACRO: construct-slots ( assoc tuple-class -- tuple ) 
    [ construct-empty ] curry swap [
        [ dip ] curry swap 1quotation [ keep ] curry compose
    ] { } assoc>map concat compose ;

: either ( object first second -- ? )
    >r over slip swap [ r> drop ] [ r> call ] ?if ; inline
