! Copyright (C) 2007, 2009 Chris Double, Doug Coleman, Eduardo
! Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays combinators kernel kernel.private math ranges
sequences ;
IN: generalizations

! These words can be inline combinators when the word does no math
! on the input parameters, e.g. n.
! If math is done, the word needs to be a macro so the math can
! be done at compile-time.
<<

: n*quot ( n quot -- quotquot )
    <repetition> [ ] concat-as ;

MACRO: call-n ( n -- quot )
    [ call ] <repetition> '[ _ cleave ] ;

>>

MACRO: nsum ( n -- quot )
    1 - [ + ] n*quot ;

MACRO: npick ( n -- quot )
    {
        { [ dup 0 <= ] [ positive-number-expected ] }
        { [ dup 1 = ] [ drop [ dup ] ] }
        [ 1 - [ dup ] [ '[ _ dip swap ] ] swapd times ]
    } cond ;

: ndup ( n -- )
    [ '[ _ npick ] ] keep call-n ; inline

MACRO: dupn ( n -- quot )
    [ [ drop ] ]
    [ 1 - [ dup ] n*quot ] if-zero ;

MACRO: nrot ( n -- quot )
    1 - [ ] [ '[ _ dip swap ] ] swapd times ;

MACRO: -nrot ( n -- quot )
    1 - [ ] [ '[ swap _ dip ] ] swapd times ;

: ndip ( n -- )
    [ [ dip ] curry ] swap call-n call ; inline

: ndrop ( n -- )
    [ drop ] swap call-n ; inline

: nnip ( n -- )
    '[ _ ndrop ] dip ; inline

DEFER: -nrotd
MACRO: nrotd ( n d -- quot )
    over 0 < [
        [ neg ] dip '[ _ _ -nrotd ]
    ] [
        [ 1 - [ ] [ '[ _ dip swap ] ] swapd times ] dip '[ _ _ ndip ]
    ] if ;

MACRO: -nrotd ( n d -- quot )
    over 0 < [
        [ neg ] dip '[ _ _ nrotd ]
    ] [
        [ 1 - [ ] [ '[ swap _ dip ] ] swapd times ] dip '[ _ _ ndip ]
    ] if ;

MACRO: nrotated ( nrots depth dip -- quot )
    [ '[ [ _ nrot ] ] replicate [ ] concat-as ] dip '[ _ _ ndip ] ;

MACRO: -nrotated ( -nrots depth dip -- quot )
    [ '[ [ _ -nrot ] ] replicate [ ] concat-as ] dip '[ _ _ ndip ] ;

MACRO: nrotate-heightd ( n height dip -- quot )
    [ '[ [ _ nrot ] ] replicate concat ] dip '[ _ _ ndip ] ;

MACRO: -nrotate-heightd ( n height dip -- quot )
    [
        '[ [ _ -nrot ] ] replicate concat
    ] dip '[ _ _ ndip ] ;

: ndupd ( n dip -- ) '[ [ _ ndup ] _ ndip ] call ; inline

MACRO: ntuckd ( ntuck ndip -- quot )
    [ 1 + ] dip '[ [ dup _ -nrot ] _ ndip ] ;

MACRO: nover ( n -- quot )
    dup 1 + '[ _ npick ] n*quot ;

MACRO: noverd ( n depth dip -- quot' )
    [ + ] [ 2drop ] [ [ + ] dip ] 3tri
    '[ _ _ ndupd _ _ _ nrotated ] ;

MACRO: mntuckd ( ndup depth ndip -- quot )
    { [ nip ] [ 2drop ] [ drop + ] [ 2nip ] } 3cleave
    '[ _ _ ndupd _ _ _ -nrotated ] ;

: nkeep ( n -- )
    dup '[ [ _ ndup ] dip _ ndip ] call ; inline

: ncurry ( n -- )
    [ curry ] swap call-n ; inline

: nwith ( n -- )
    [ with ] swap call-n ; inline

: nbi ( quot1 quot2 n -- )
    [ nip nkeep ] [ drop nip call ] 3bi ; inline

MACRO: ncleave ( quots n -- quot )
    [ '[ _ '[ _ _ nkeep ] ] map [ ] join ] [ '[ _ ndrop ] ] bi
    compose ;

MACRO: nspread ( quots n -- quot )
    over empty? [ 2drop [ ] ] [
        [ [ but-last ] dip ]
        [ [ last ] dip ] 2bi
        swap
        '[ [ _ _ nspread ] _ ndip @ ]
    ] if ;

MACRO: spread* ( n -- quot )
    [ [ ] ] [
        [1..b) [ '[ [ [ _ ndip ] curry ] dip compose ] ] map [ ] concat-as
        [ call ] compose
    ] if-zero ;

MACRO: nspread* ( m n -- quot )
    [ drop [ ] ] [
        [ * 0 ] [ drop neg ] 2bi
        <range> rest >array dup length <iota> <reversed>
        [ '[ [ [ _ ndip ] curry ] _ ndip ] ] 2map
        [ [ ] concat-as ]
        [ length 1 - [ compose ] <array> concat append ] bi
        [ call ] compose
    ] if-zero ;

MACRO: cleave* ( n -- quot )
    [ [ ] ]
    [ 1 - [ [ [ keep ] curry ] dip compose ] n*quot [ call ] compose ]
    if-zero ;

: napply ( quot n -- )
    [ dupn ] [ spread* ] bi ; inline

: mnapply ( quot m n -- )
    [ nip dupn ] [ nspread* ] 2bi ; inline

: apply-curry ( a... quot n -- )
    [ currier ] dip napply ; inline

: cleave-curry ( a quot... n -- )
    [ currier ] swap [ napply ] [ cleave* ] bi ; inline

: spread-curry ( a... quot... n -- )
    [ currier ] swap [ napply ] [ spread* ] bi ; inline

MACRO: mnswap ( m n -- quot )
    1 + '[ _ -nrot ] swap '[ _ _ napply ] ;

MACRO: nweave ( n -- quot )
    [ dup <iota> <reversed> [ '[ _ _ mnswap ] ] with map ] keep
    '[ _ _ ncleave ] ;

: nbi-curry ( n -- )
    [ bi-curry ] swap call-n ; inline

MACRO: map-compose ( quots quot -- quot' )
    '[ _ compose ] map '[ _ ] ;
