! Copyright (C) 2007, 2009 Chris Double, Doug Coleman, Eduardo
! Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences sequences.private math combinators
macros quotations fry effects memoize.private ;
IN: generalizations

<<

ALIAS: n*quot (n*quot)

: repeat ( n obj quot -- ) swapd times ; inline

>>

MACRO: nsequence ( n seq -- )
    [ [nsequence] ] keep
    '[ @ _ like ] ;

MACRO: narray ( n -- )
    '[ _ { } nsequence ] ;

MACRO: nsum ( n -- )
    1 - [ + ] n*quot ;

MACRO: firstn-unsafe ( n -- )
    [firstn] ;

MACRO: firstn ( n -- )
    dup zero? [ drop [ drop ] ] [
        [ 1 - swap bounds-check 2drop ]
        [ firstn-unsafe ]
        bi-curry '[ _ _ bi ]
    ] if ;

MACRO: npick ( n -- )
    1 - [ dup ] [ '[ _ dip swap ] ] repeat ;

MACRO: nover ( n -- )
    dup 1 + '[ _ npick ] n*quot ;

MACRO: ndup ( n -- )
    dup '[ _ npick ] n*quot ;

MACRO: nrot ( n -- )
    1 - [ ] [ '[ _ dip swap ] ] repeat ;

MACRO: -nrot ( n -- )
    1 - [ ] [ '[ swap _ dip ] ] repeat ;

MACRO: ndrop ( n -- )
    [ drop ] n*quot ;

MACRO: nnip ( n -- )
    '[ [ _ ndrop ] dip ] ;

MACRO: ntuck ( n -- )
    2 + '[ dup _ -nrot ] ;

MACRO: ndip ( quot n -- )
    [ '[ _ dip ] ] times ;

MACRO: nkeep ( quot n -- )
    tuck '[ _ ndup _ _ ndip ] ;

MACRO: ncurry ( n -- )
    [ curry ] n*quot ;

MACRO: nwith ( n -- )
    [ with ] n*quot ;

MACRO: nbi ( n -- )
    '[ [ _ nkeep ] dip call ] ;

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

MACRO: napply ( n -- )
    [ [ drop ] ] dip [ '[ tuck _ 2dip call ] ] times ;

MACRO: mnswap ( m n -- )
    1 + '[ _ -nrot ] swap '[ _ _ napply ] ;

MACRO: nweave ( n -- )
    [ dup iota <reversed> [ '[ _ _ mnswap ] ] with map ] keep
    '[ _ _ ncleave ] ;

MACRO: nbi-curry ( n -- )
    [ bi-curry ] n*quot ;

: nappend-as ( n exemplar -- seq )
    [ narray concat ] dip like ; inline

: nappend ( n -- seq ) narray concat ; inline

MACRO: nspin ( n -- )
    [ [ ] ] swap [ swap [ ] curry compose ] n*quot [ call ] 3append ;
