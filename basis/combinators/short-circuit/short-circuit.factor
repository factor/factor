USING: kernel combinators quotations arrays sequences assocs
locals generalizations macros fry ;
IN: combinators.short-circuit

MACRO:: n&& ( quots n -- quot )
    [let | pairs [
        quots [| q | { [ drop n ndup q dup not ] [ drop n ndrop f ] } ] map
        { [ t ] [ n nnip ] } suffix
    ] |
        [ f pairs cond ]
    ] ;

MACRO: 0&& ( quots -- quot ) '[ _ 0 n&& ] ;
MACRO: 1&& ( quots -- quot ) '[ _ 1 n&& ] ;
MACRO: 2&& ( quots -- quot ) '[ _ 2 n&& ] ;
MACRO: 3&& ( quots -- quot ) '[ _ 3 n&& ] ;

MACRO:: n|| ( quots n -- quot )
    [let | pairs [
        quots
        [| q | { [ drop n ndup q dup ] [ n nnip ] } ] map
        { [ drop n ndrop t ] [ f ] } suffix
    ] |
        [ f pairs cond ]
    ] ;

MACRO: 0|| ( quots -- quot ) '[ _ 0 n|| ] ;
MACRO: 1|| ( quots -- quot ) '[ _ 1 n|| ] ;
MACRO: 2|| ( quots -- quot ) '[ _ 2 n|| ] ;
MACRO: 3|| ( quots -- quot ) '[ _ 3 n|| ] ;
