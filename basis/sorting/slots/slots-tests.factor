! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors math.order sorting.slots tools.test
sorting.human ;
IN: sorting.literals.tests

TUPLE: sort-test a b c ;

[
    {
        T{ sort-test { a 1 } { b 3 } { c 9 } }
        T{ sort-test { a 1 } { b 1 } { c 10 } }
        T{ sort-test { a 1 } { b 1 } { c 11 } }
        T{ sort-test { a 2 } { b 5 } { c 2 } }
        T{ sort-test { a 2 } { b 5 } { c 3 } }
    }
] [
    {
        T{ sort-test f 1 3 9 }
        T{ sort-test f 1 1 10 }
        T{ sort-test f 1 1 11 }
        T{ sort-test f 2 5 3 }
        T{ sort-test f 2 5 2 }
    } { { a>> <=> } { b>> >=< } { c>> <=> } } sort-by-slots
] unit-test

[
    {
        T{ sort-test { a 1 } { b 3 } { c 9 } }
        T{ sort-test { a 1 } { b 1 } { c 10 } }
        T{ sort-test { a 1 } { b 1 } { c 11 } }
        T{ sort-test { a 2 } { b 5 } { c 2 } }
        T{ sort-test { a 2 } { b 5 } { c 3 } }
    }
] [
    {
        T{ sort-test f 1 3 9 }
        T{ sort-test f 1 1 10 }
        T{ sort-test f 1 1 11 }
        T{ sort-test f 2 5 3 }
        T{ sort-test f 2 5 2 }
    } { { a>> human-<=> } { b>> human->=< } { c>> <=> } } sort-by-slots
] unit-test

[
    { }
] [
    { }
    { { a>> <=> } { b>> >=< } { c>> <=> } } sort-by-slots
] unit-test
