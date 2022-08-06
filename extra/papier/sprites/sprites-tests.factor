! (c)2010 Joe Groff bsd license
USING: combinators papier.sprites tools.test ;
IN: papier.sprites.tests

[ 10 10 10 11 11 12 10 ]
[
    {
        T{ animation-frame f 10 3 }
        T{ animation-frame f 11 2 }
        T{ animation-frame f 12 1 }
    } <animation-cursor> {
        [ cursor++ ]
        [ cursor++ ]
        [ cursor++ ]
        [ cursor++ ]
        [ cursor++ ]
        [ cursor++ ]
        [ cursor++ ]
    } cleave
] unit-test
