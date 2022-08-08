USING: arrays combinators generalizations kernel math sequences ;
IN: combinators.short-circuit

<PRIVATE

MACRO: keeping ( n quot -- quot' )
    swap dup 1 + '[ _ _ nkeep _ nrot ] ;

PRIVATE>

MACRO: n&& ( quots n -- quot )
    [
        [ [ f ] ] 2dip swap [
            [ '[ drop _ _ keeping dup not ] ]
            [ drop '[ drop _ ndrop f ] ]
            2bi 2array
        ] with map
    ] [ '[ _ nnip ] suffix 1array ] bi
    [ cond ] 3append ;

: 0&& ( quots -- ? ) 0 n&& ;
: 1&& ( obj quots -- ? ) 1 n&& ;
: 2&& ( obj1 obj2 quots -- ? ) 2 n&& ;
: 3&& ( obj1 obj2 obj3 quots -- ? ) 3 n&& ;

MACRO: n|| ( quots n -- quot )
    [
        [ [ f ] ] 2dip swap [
            [ '[ drop _ _ keeping dup ] ]
            [ drop '[ _ nnip ] ]
            2bi 2array
        ] with map
    ] [ '[ drop _ ndrop t ] [ f ] 2array suffix 1array ] bi
    [ cond ] 3append ;

: 0|| ( quots -- ? ) 0 n|| ;
: 1|| ( obj quots -- ? ) 1 n|| ;
: 2|| ( obj1 obj2 quots -- ? ) 2 n|| ;
: 3|| ( obj1 obj2 obj3 quots -- ? ) 3 n|| ;
