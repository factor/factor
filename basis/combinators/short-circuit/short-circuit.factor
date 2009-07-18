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

: 0&& ( quots -- ? ) [ call ] all? ;
: 1&& ( obj quots -- ? ) [ call ] with all? ;
: 2&& ( obj quots -- ? ) [ call ] with with all? ;
: 3&& ( obj quots -- ? ) [ call ] with with with all? ;

MACRO:: n|| ( quots n -- quot )
    [ f ] quots [| q |
        n
        [ q '[ drop _ ndup @ dup ] ]
        [ '[ _ nnip ] ]
        bi 2array
    ] map
    n '[ drop _ ndrop t ] [ f ] 2array suffix 1array
    [ cond ] 3append ;

: 0|| ( quots -- ? ) [ call ] any? ;
: 1|| ( obj quots -- ? ) [ call ] with any? ;
: 2|| ( obj quots -- ? ) [ call ] with with any? ;
: 3|| ( obj quots -- ? ) [ call ] with with with any? ;

