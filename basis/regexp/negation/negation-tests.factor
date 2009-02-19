! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test regexp.negation regexp.transition-tables regexp.classes ;
IN: regexp.negation.tests

[
    ! R/ |[^a]|.+/
    T{ transition-table
        { transitions H{
            { 0 H{ { CHAR: a 1 } { T{ not-class f T{ or-class f { CHAR: a } } } -1 } } }
            { 1 H{ { T{ not-class f T{ or-class f { } } } -1 } } }
            { -1 H{ { any-char -1 } } }
        } } 
        { start-state 0 }
        { final-states H{ { 0 0 } { -1 -1 } } }
    }
] [
    ! R/ a/
    T{ transition-table
        { transitions H{
            { 0 H{ { CHAR: a 1 } } }
            { 1 H{ } } 
        } }
        { start-state 0 }
        { final-states H{ { 1 1 } } }
    } negate-table
] unit-test
