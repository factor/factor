! Copyright (C) 2007 Robbert van Dalen.
! See http://factorcode.org/license.txt for BSD license.

! Unifies sequences, integers and objects, following Enchilada semantics.
! Efficiency is achieved through immutable size-balanced binary trees. 

! - An object is an isequence of size 1 containing itself
! - An integer is an isequence of size itself containing empty quotations
! - If a sequence is never modified it is also considered an isequence
! - An isequence can have negative sign

IN: isequences
USING: generic kernel math math-internals sequences errors ;

GENERIC: ## ( s -- n )                        ! monadic size
GENERIC: -- ( s -- -s )                       ! monadic negate
GENERIC: $$ ( s1 -- h )                       ! monadic hash
GENERIC: ++ ( s1 s2 -- s )                    ! dyadic concatenate
G: @@ ( s n -- v ) 1 standard-combination ;   ! dyadic index

: index-error ( -- * )
    "index out of bounds" throw ; foldable

: traversal-error ( -- * )
    "traversal error" throw ; foldable

IN: isequences-internals


! #### internal structures/logic ####
!

DEFER: <ibranch>
DEFER: <ineg>
DEFER: <ileaf>

G: ihead ( s n -- s ) 1 standard-combination ;
G: itail ( s n -- s ) 1 standard-combination ;
GENERIC: ileft ( s -- v )
GENERIC: iright ( s -- v ) 
GENERIC: ipair ( s1 s2 -- s )
    
: <i-branch> <ibranch> ; foldable
: <i-neg> <ineg> ; foldable
: <i-leaf> <ileaf> ; foldable


: PRIME1 ( -- prime1 ) HEX: 58ea12c9 ; foldable
: PRIME2 ( -- prime2 ) HEX: 79af7bc3 ; foldable
    
: hh ( fixnum-h -- fixnum-h )
    PRIME1 * PRIME2 + >fixnum ; foldable

: quick-hash ( fixnum-h1 fixnum-h2 -- fixnum-h )
    [ hh ] 2apply fixnum-bitxor hh ; foldable

: (to-sequence) ( s -- s )
    dup ## 1 =
    [ 0 @@ { } swap add ]
    [ [ ileft (to-sequence) ] keep iright (to-sequence) append ]
    if ;

: neg? ( s -- ? ) ## 0 < ; foldable
    
: twice ( n -- n )
    dup + ; inline

: 2size ( s1 s2 -- s1 s2 size1 size2 )
    2dup [ ## ] 2apply ; inline

: rindex ( s n -- s n )
    swap dup ## rot - ; inline

: <isequence> ( s1 s2 -- s )
    2size + <i-branch> ; inline

: left-right ( s -- left right )
    [ ileft ] keep iright ; inline

: (@@) ( s i -- v )
    ## swap dup ileft dup ## roll 2dup <=
    [ swap - rot iright swap ]
    [ nip ]
    if @@ nip ; inline

: ($$) ( s -- hash )
    left-right [ $$ ] 2apply quick-hash ; inline

: (ihead2) ( s i -- h )
    swap dup ileft dup ## roll 2dup =
    [ 2drop nip ]
    [ 2dup < [ swap - rot iright swap ihead ++ ] [ nip ihead nip ] if ]
    if ; inline
    
: (ihead) ( s i -- h ) 
    dup pick ## = [ drop ] [ (ihead2) ] if ; inline
    
: (itail2) ( s i -- h )
    swap left-right swap dup ## roll 2dup =
    [ 3drop ]
    [ 2dup < [ swap - nip itail ] [ nip itail swap ++ ] if ]
    if ; inline

: (itail) ( s i -- t )
    dup pick ## = [ 2drop 0 ] [ (itail2) ] if ; inline

: (ig1) ( s1 s2 -- s )
    >r left-right 2size <
    [ dup >r ileft ipair r> iright r> ++ ipair ]
    [ r> ++ ipair ] if ; inline

: (ig2) ( s1 s2 -- s )
    left-right 2size >
    [ >r dup >r ileft ++ r> iright r> ipair ipair ]
    [ >r ++ r> ipair ] if ; inline

: (ig3) ( s1 s2 size1 size2 -- s )
    2dup twice >=
    [ 2drop (ig1) ]
    [ swap twice >= [ (ig2) ] [ ipair ] if ] if ; inline

: ++g++ ( s1 s2 -- s )
    dup ## dup 0 = 
    [ 2drop ]
    [ pick ## dup 0 = [ 2drop nip ] [ swap (ig3) ] if ] if ; inline 

: ++g+- ( s1 s2 -- s )
    2size + dup 0 <
    [ neg swap -- swap rindex itail -- nip ]
    [ nip ihead ]
    if ; inline

: ++g-+ ( s1 s2 -- s )
    2size + dup 0 <
    [ nip swap -- swap neg ihead -- ]
    [ rindex itail nip ]
    if ; inline

: ++g-- ( s1 s2 -- s )
    -- swap -- swap ++ -- ; inline

: ++g ( s1 s2 -- s )
    2dup [ neg? ] 2apply [ [ ++g-- ] [ ++g+- ] if ] [ [ ++g-+ ] [ ++g++ ] if ] if ; inline


! #### object isequence ####
!
M: object ++ ++g ; 
M: object ipair <isequence> ;

M: object ## drop 1 ;
M: object -- <i-neg> ;
M: object @@ ## 0 = [ ] [ index-error ] if ;
M: object ileft drop 0 ;
M: object iright drop 0 ;
M: object ihead dup 0 = [ 2drop 0 ] [ 1 = [ ] [ index-error ] if ] if ;
M: object itail dup 0 = [ drop ] [ 1 = [ drop 0 ] [ index-error ] if ] if ;


! #### negative isequence ####
!
TUPLE: ineg sequence ;

M: ineg -- ineg-sequence ;
M: ineg ## ineg-sequence ## neg ;
M: ineg @@ ## dup 0 <= [ neg swap -- swap @@ ] [ index-error ] if ;
M: ineg ileft -- iright -- ;
M: ineg iright -- ileft -- ;
M: ineg ihead [ -- ] 2apply ihead -- ;
M: ineg itail [ -- ] 2apply itail -- ;
M: ineg $$ ineg-sequence $$ neg ;

! #### integer isequence ####
!
! double dispatch integer/++
GENERIC: integer/++ ( s1 s2 -- v )
M: object integer/++ swap ++g ;
M: integer ++ swap integer/++ ;
! double dispatch integer/ipair
GENERIC: integer/ipair ( s1 s2 -- s )
M: object integer/ipair swap <isequence> ;
M: integer ipair swap integer/ipair ;
! integer optimizations
M: integer integer/++ + ;
M: integer integer/ipair + ;

M: integer ## ;
M: integer -- neg ;
M: integer @@ ## dup 0 >= [ > [ [ ] ] [ index-error ] if ] [ index-error ] if ;
M: integer ileft
    dup 0 = [ traversal-error ] [ -1 shift ] if ;
M: integer iright
    dup 0 = [ traversal-error ] [ 1+ -1 shift ] if ;
M: integer ihead swap drop ;
M: integer itail - ;
M: integer $$ >fixnum ;


! #### negative integers ####
!
PREDICATE: integer ninteger 0 < ;

M: ninteger @@ ## dup 0 <= [ < [ [ ] ] [ index-error ] if ] [ index-error ] if ;

! #### sequence -> isequence ####
!
M: sequence ## length ;
M: sequence @@ ## swap nth ;
M: sequence ileft
    dup length dup 0 = [ traversal-error ] [ -1 shift ] if head ;
M: sequence iright
    dup length dup 0 = [ traversal-error ] [ -1 shift ] if tail ;
M: sequence ihead head ;
M: sequence itail tail ;
M: sequence $$ [ $$ ] map unclip [ quick-hash ] reduce ;

! #### single element isequence ####
!
TUPLE: ileaf value ;

M: ileaf @@ ## 0 = [ ileaf-value ] [ index-error ] if ;
M: ileaf $$ 0 @@ $$ ;

IN: isequences

! expose in isequences
: <i> ( v -- s )
    <i-leaf> ; inline

: to-sequence ( s -- s )
    dup ## dup 0 =
    [ 2drop { } ]
    [ 0 < [ -- (to-sequence) reverse ] [ (to-sequence) ] if ] if ; inline

IN: isequences-internals


! #### composite isequence (size-balanced binary tree) ####
!
TUPLE: ibranch left right size ;

M: ibranch ## ibranch-size ;
M: ibranch @@ (@@) ;
M: ibranch iright ibranch-right ;
M: ibranch ileft ibranch-left ;
M: ibranch ihead (ihead) ;
M: ibranch itail (itail) ;
M: ibranch $$ ($$) ;