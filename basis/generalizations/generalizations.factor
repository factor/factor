! Copyright (C) 2007, 2009 Chris Double, Doug Coleman, Eduardo
! Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences sequences.private math combinators
macros quotations fry effects ;
IN: generalizations

<<

: n*quot ( n quot -- seq' ) <repetition> concat >quotation ;

: repeat ( n obj quot -- ) swapd times ; inline

>>

MACRO: nsequence ( n seq -- )
    [
        [ drop <reversed> ] [ '[ _ _ new-sequence ] ] 2bi
        [ '[ @ [ _ swap set-nth-unsafe ] keep ] ] reduce
    ] keep
    '[ @ _ like ] ;

MACRO: narray ( n -- )
    '[ _ { } nsequence ] ;

MACRO: nsum ( n -- )
    1- [ + ] n*quot ;

MACRO: firstn ( n -- )
    dup zero? [ drop [ drop ] ] [
        [ [ '[ [ _ ] dip nth-unsafe ] ] map ]
        [ 1- '[ [ _ ] dip bounds-check 2drop ] ]
        bi prefix '[ _ cleave ]
    ] if ;

MACRO: npick ( n -- )
    1- [ dup ] [ '[ _ dip swap ] ] repeat ;

MACRO: ndup ( n -- )
    dup '[ _ npick ] n*quot ;

MACRO: nrot ( n -- )
    1- [ ] [ '[ _ dip swap ] ] repeat ;

MACRO: -nrot ( n -- )
    1- [ ] [ '[ swap _ dip ] ] repeat ;

MACRO: ndrop ( n -- )
    [ drop ] n*quot ;

MACRO: nnip ( n -- )
    '[ [ _ ndrop ] dip ] ;

MACRO: ntuck ( n -- )
    2 + '[ dup _ -nrot ] ;

MACRO: ndip ( quot n -- )
    [ '[ _ dip ] ] times ;

MACRO: nslip ( n -- )
    '[ [ call ] _ ndip ] ;

MACRO: nkeep ( quot n -- )
    tuck '[ _ ndup _ _ ndip ] ;

MACRO: ncurry ( n -- )
    [ curry ] n*quot ;

MACRO: nwith ( n -- )
    [ with ] n*quot ;

MACRO: ncleave ( quots n -- )
    [ '[ _ '[ _ _ nkeep ] ] map [ ] join ] [ '[ _ ndrop ] ] bi
    compose ;

MACRO: nspread ( quots n -- )
    over empty? [ 2drop [ ] ] [
        [ [ but-last ] dip ]
        [ [ peek ] dip ] 2bi
        swap
        '[ [ _ _ nspread ] _ ndip @ ]
    ] if ;

MACRO: napply ( quot n -- )
    swap <repetition> spread>quot ;

MACRO: mnswap ( m n -- )
    1+ '[ _ -nrot ] swap '[ _ _ napply ] ;

MACRO: nweave ( n -- )
    [ dup <reversed> [ '[ _ _ mnswap ] ] with map ] keep
    '[ _ _ ncleave ] ;

: nappend-as ( n exemplar -- seq )
    [ narray concat ] dip like ; inline

: nappend ( n -- seq ) narray concat ; inline
