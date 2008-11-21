USING: kernel combinators quotations arrays sequences assocs
locals generalizations macros fry ;
IN: combinators.short-circuit

MACRO:: n&& ( quots n -- quot )
    [ f ]
    quots [| q | { [ drop n ndup q call dup not ] [ drop n ndrop f ] } ] map
    [ n nnip ] suffix 1array
    [ cond ] 3append ;

MACRO: 0&& ( quots -- quot ) '[ _ 0 n&& ] ;
MACRO: 1&& ( quots -- quot ) '[ _ 1 n&& ] ;
MACRO: 2&& ( quots -- quot ) '[ _ 2 n&& ] ;
MACRO: 3&& ( quots -- quot ) '[ _ 3 n&& ] ;

MACRO:: n|| ( quots n -- quot )
    [ f ]
    quots
    [| q | { [ drop n ndup q call dup ] [ n nnip ] } ] map
    { [ drop n ndrop t ] [ f ] } suffix 1array
    [ cond ] 3append ;

MACRO: 0|| ( quots -- quot ) '[ _ 0 n|| ] ;
MACRO: 1|| ( quots -- quot ) '[ _ 1 n|| ] ;
MACRO: 2|| ( quots -- quot ) '[ _ 2 n|| ] ;
MACRO: 3|| ( quots -- quot ) '[ _ 3 n|| ] ;
