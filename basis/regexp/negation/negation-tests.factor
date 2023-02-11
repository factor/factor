! Copyright (C) 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test regexp.negation regexp.transition-tables regexp.classes ;
IN: regexp.negation.tests

{
    ! R/ |[^a]|.+/
    T{ transition-table
        { transitions H{
            { 0 H{ { CHAR: a 1 } { T{ not-class f CHAR: a } -1 } } }
            { 1 H{ { t -1 } } }
            { -1 H{ { t -1 } } }
        } }
        { start-state 0 }
        { final-states HS{ 0 -1 } }
    }
} [
    ! R/ a/
    T{ transition-table
        { transitions H{
            { 0 H{ { CHAR: a 1 } } }
            { 1 H{ } }
        } }
        { start-state 0 }
        { final-states HS{ 1 } }
    } negate-table
] unit-test
