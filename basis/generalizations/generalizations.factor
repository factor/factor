! Copyright (C) 2007, 2009 Chris Double, Doug Coleman, Eduardo
! Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private sequences sequences.private math
combinators macros math.order math.ranges quotations fry effects
memoize.private arrays ;
IN: generalizations

! These words can be inline combinators the word does no math on
! the input parameters, e.g. n. 
! If math is done, the word needs to be a macro so the math can
! be done at compile-time.
<<

ALIAS: n*quot (n*quot)

MACRO: call-n ( n -- )
    [ call ] <repetition> '[ _ cleave ] ;

: repeat ( n obj quot -- ) swapd times ; inline

>>

MACRO: nsum ( n -- )
    1 - [ + ] n*quot ;

ERROR: nonpositive-npick n ;

MACRO: npick ( n -- )
    {
        { [ dup 0 <= ] [ nonpositive-npick ] }
        { [ dup 1 = ] [ drop [ dup ] ] }
        [ 1 - [ dup ] [ '[ _ dip swap ] ] repeat ]
    } cond ;

MACRO: nover ( n -- )
    dup 1 + '[ _ npick ] n*quot ;

: ndup ( n -- )
    [ '[ _ npick ] ] keep call-n ; inline

MACRO: dupn ( n -- )
    [ [ drop ] ]
    [ 1 - [ dup ] n*quot ] if-zero ;

MACRO: nrot ( n -- )
    1 - [ ] [ '[ _ dip swap ] ] repeat ;

MACRO: -nrot ( n -- )
    1 - [ ] [ '[ swap _ dip ] ] repeat ;

: ndrop ( n -- )
    [ drop ] swap call-n ; inline

: nnip ( n -- )
    '[ _ ndrop ] dip ; inline

: ndip ( n -- )
    [ [ dip ] curry ] swap call-n call ; inline

: nkeep ( n -- )
    dup '[ [ _ ndup ] dip _ ndip ] call ; inline

: ncurry ( n -- )
    [ curry ] swap call-n ; inline

: nwith ( n -- )
    [ with ] swap call-n ; inline

: nbi ( quot1 quot2 n -- )
    [ nip nkeep ] [ drop nip call ] 3bi ; inline

MACRO: ncleave ( quots n -- )
    [ '[ _ '[ _ _ nkeep ] ] map [ ] join ] [ '[ _ ndrop ] ] bi
    compose ;

MACRO: nspread ( quots n -- )
    over empty? [ 2drop [ ] ] [
        [ [ but-last ] dip ]
        [ [ last ] dip ] 2bi
        swap
        '[ [ _ _ nspread ] _ ndip @ ]
    ] if ;

MACRO: spread* ( n -- )
    [ [ ] ] [
        [1,b) [ '[ [ [ _ ndip ] curry ] dip compose ] ] map [ ] concat-as
        [ call ] compose
    ] if-zero ;

MACRO: nspread* ( m n -- )
    [ drop [ ] ] [
        [ * 0 ] [ drop neg ] 2bi
        <range> rest >array dup length iota <reversed>
        [
            '[ [ [ _ ndip ] curry ] _ ndip ]
        ] 2map dup rest-slice [ [ compose ] compose ] map! drop
        [ ] concat-as [ call ] compose
    ] if-zero ;

MACRO: cleave* ( n -- )
    [ [ ] ]
    [ 1 - [ [ [ keep ] curry ] dip compose ] n*quot [ call ] compose ]
    if-zero ;

: napply ( quot n -- )
    [ dupn ] [ spread* ] bi ; inline

: mnapply ( quot m n -- )
    [ nip dupn ] [ nspread* ] 2bi ; inline

: apply-curry ( a... quot n -- )
    [ [curry] ] dip napply ; inline

: cleave-curry ( a quot... n -- )
    [ [curry] ] swap [ napply ] [ cleave* ] bi ; inline

: spread-curry ( a... quot... n -- )
    [ [curry] ] swap [ napply ] [ spread* ] bi ; inline

MACRO: mnswap ( m n -- )
    1 + '[ _ -nrot ] swap '[ _ _ napply ] ;

MACRO: nweave ( n -- )
    [ dup iota <reversed> [ '[ _ _ mnswap ] ] with map ] keep
    '[ _ _ ncleave ] ;

: nbi-curry ( n -- )
    [ bi-curry ] swap call-n ; inline
