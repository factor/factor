! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test regexp.minimize assocs regexp
accessors regexp.transition-tables ;
IN: regexp.minimize.tests

[ t ] [ 1 2 H{ { { 1 2 } t } } same-partition? ] unit-test
[ t ] [ 2 1 H{ { { 1 2 } t } } same-partition? ] unit-test
[ f ] [ 2 3 H{ { { 1 2 } t } } same-partition? ] unit-test

[ H{ { 1 1 } { 2 1 } { 3 3 } { 4 3 } } ]
[ { { 1 1 } { 1 2 } { 2 2 } { 3 3 } { 3 4 } { 4 4 } } [ t ] H{ } map>assoc partition>classes ] unit-test

[ { { 1 2 } { 3 4 } } ] [ H{ { "elephant" 1 } { "tiger" 3 } } H{ { "elephant" 2 } { "tiger" 4 } } assemble-values ] unit-test

[ 3 ] [ R/ ab|ac/ dfa>> transitions>> assoc-size ] unit-test
[ 3 ] [ R/ a(b|c)/ dfa>> transitions>> assoc-size ] unit-test
[ 1 ] [ R/ ((aa*)*)*/ dfa>> transitions>> assoc-size ] unit-test
[ 1 ] [ R/ a|((aa*)*)*/ dfa>> transitions>> assoc-size ] unit-test
[ 2 ] [ R/ ab|((aa*)*)*b/ dfa>> transitions>> assoc-size ] unit-test
[ 4 ] [ R/ ab|cd/ dfa>> transitions>> assoc-size ] unit-test
[ 1 ] [ R/ [a-z]*|[A-Z]*/i dfa>> transitions>> assoc-size ] unit-test

[
    T{ transition-table
        { transitions H{
            { 0 H{ { CHAR: a 1 } { CHAR: b 1 } } }
            { 1 H{ { CHAR: a 2 } { CHAR: b 2 } } }
            { 2 H{ { CHAR: c 3 } } }
            { 3 H{ } }
        } }
        { start-state 0 }
        { final-states H{ { 3 3 } } }
    }
] [ 
    T{ transition-table
        { transitions H{
            { 0 H{ { CHAR: a 1 } { CHAR: b 4 } } }
            { 1 H{ { CHAR: a 2 } { CHAR: b 5 } } }
            { 2 H{ { CHAR: c 3 } } }
            { 3 H{ } }
            { 4 H{ { CHAR: a 2 } { CHAR: b 5 } } }
            { 5 H{ { CHAR: c 6 } } }
            { 6 H{ } }
        } }
        { start-state 0 }
        { final-states H{ { 3 3 } { 6 6 } } }
    } combine-states
] unit-test

[ [ ] [ ] while-changes ] must-infer
