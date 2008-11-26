USING: kernel combinators quotations arrays sequences assocs
locals generalizations macros fry ;
IN: combinators.short-circuit

MACRO:: n&& ( quots n -- quot )
    [ f ] quots [| q |
        n
        [ q '[ drop _ ndup @ dup not ] ]
        [ '[ drop _ ndrop f ] ]
        bi 2array
    ] map
    n '[ _ nnip ] suffix 1array
    [ cond ] 3append ;

MACRO: 0&& ( quots -- quot ) '[ _ 0 n&& ] ;
MACRO: 1&& ( quots -- quot ) '[ _ 1 n&& ] ;
MACRO: 2&& ( quots -- quot ) '[ _ 2 n&& ] ;
MACRO: 3&& ( quots -- quot ) '[ _ 3 n&& ] ;

MACRO:: n|| ( quots n -- quot )
    [ f ] quots [| q |
        n
        [ q '[ drop _ ndup @ dup ] ]
        [ '[ _ nnip ] ]
        bi 2array
    ] map
    n '[ drop _ ndrop t ] [ f ] 2array suffix 1array
    [ cond ] 3append ;

MACRO: 0|| ( quots -- quot ) '[ _ 0 n|| ] ;
MACRO: 1|| ( quots -- quot ) '[ _ 1 n|| ] ;
MACRO: 2|| ( quots -- quot ) '[ _ 2 n|| ] ;
MACRO: 3|| ( quots -- quot ) '[ _ 3 n|| ] ;
