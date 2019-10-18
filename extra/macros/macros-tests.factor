IN: temporary
USING: tools.test macros math kernel arrays
vectors ;

[ t ] [
    3 {
        [ dup number? ] [ dup odd? ] [ dup 0 > ]
    } && nip
] unit-test

[ f ] [
    3 {
        [ dup number? ] [ dup even? ] [ dup 0 > ]
    } && nip
] unit-test

[ t ] [
    4 {
        [ dup array? ] [ dup number? ] [ 3 throw ]
    } || nip
] unit-test

[ f ] [
    4 {
        [ dup array? ] [ dup vector? ] [ dup float? ]
    } || nip
] unit-test
