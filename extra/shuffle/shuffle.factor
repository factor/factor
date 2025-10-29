! Copyright (C) 2007 Chris Double, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors assocs combinators combinators.short-circuit
definitions effects effects.parser generalizations help
help.markup kernel math parser ranges sequences
sequences.generalizations stack-checker.backend
stack-checker.known-words stack-checker.values words ;

IN: shuffle

MACRO: shuffle-effect ( effect -- quot )
    [ in>> H{ } zip-index-as ] [ out>> ] bi
    [ drop assoc-size '[ _ narray ] ]
    [ [ of '[ _ swap nth ] ] with map ] 2bi
    '[ @ _ cleave ] ;

: infer-shuffle-effect ( -- )
    1 ensure-d first literal value>> add-effect-input infer-shuffle ;

\ shuffle-effect [ infer-shuffle-effect ] "special" set-word-prop

SYNTAX: shuffle( \ shuffle-effect parse-call-paren ;

SYNTAX: SHUFFLE:
    scan-new-word scan-effect {
        [ [ '[ _ shuffle-effect ] ] keep define-declared ]
        [ "shuffle" set-word-prop ]
        [ drop { $shuffle } swap set-word-help ]
    } 2cleave ;

PREDICATE: shuffle-word < word
    def>> {
        [ length 2 = ] [ first effect? ] [ last \ shuffle-effect = ]
    } 1&& ;

M: shuffle-word definer drop \ SHUFFLE: f ;

M: shuffle-word definition drop f ;

: 2swap ( x y z t -- z t x y ) 2 2 mnswap ; inline

: 2pick ( x y z t -- x y z t x y ) reach reach ; inline

: 5roll ( a b c d e -- b c d e a ) [ roll ] dip swap ; inline

: 6roll ( a b c d e f -- b c d e f a ) [ roll ] 2dip rot ; inline

: 7roll ( a b c d e f g -- b c d e f g a ) [ roll ] 3dip roll ; inline

: 8roll ( a b c d e f g h -- b c d e f g h a ) [ roll ] 4dip 5roll ; inline

: 2reach ( v w x y z -- v w x y z v w ) 5 npick 5 npick ; inline

: dupdd ( x y z -- x x y z ) [ dupd ] dip ; inline

: nipdd ( w x y z -- x y z ) roll drop ; inline

: spind ( w x y z -- y x w z ) [ spin ] dip ; inline

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

MACRO: noverd ( n depth dip -- quot' )
    [ + ] [ 2drop ] [ [ + ] dip ] 3tri
    '[ _ _ ndupd _ _ _ nrotated ] ;

MACRO: mntuckd ( ndup depth ndip -- quot )
    { [ nip ] [ 2drop ] [ drop + ] [ 2nip ] } 3cleave
    '[ _ _ ndupd _ _ _ -nrotated ] ;

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

MACRO: nreverse ( n -- quot )
    0 [a..b) [ '[ _ -nrot ] ] map [ ] concat-as ;
