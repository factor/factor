! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test regexp.minimize assocs regexp
accessors regexp.transition-tables regexp.parser
regexp.classes regexp.negation ;
IN: regexp.minimize.tests

{ t } [ 1 2 HS{ { 1 2 } } same-partition? ] unit-test
{ t } [ 2 1 HS{ { 1 2 } } same-partition? ] unit-test
{ f } [ 2 3 HS{ { 1 2 } } same-partition? ] unit-test

{ H{ { 1 1 } { 2 1 } { 3 3 } { 4 3 } } }
[ HS{ { 1 1 } { 1 2 } { 2 2 } { 3 3 } { 3 4 } { 4 4 } } partition>classes ] unit-test

: regexp-states ( string -- n )
    parse-regexp ast>dfa transitions>> assoc-size ;

{ 3 } [ "ab|ac" regexp-states ] unit-test
{ 3 } [ "a(b|c)" regexp-states ] unit-test
{ 1 } [ "((aa*)*)*" regexp-states ] unit-test
{ 1 } [ "a|((aa*)*)*" regexp-states ] unit-test
{ 2 } [ "ab|((aa*)*)*b" regexp-states ] unit-test
{ 4 } [ "ab|cd" regexp-states ] unit-test
{ 1 } [ "(?i:[a-z]*|[A-Z]*)" regexp-states ] unit-test

{
    T{ transition-table
        { transitions H{
            { 0 H{ { CHAR: a 1 } { CHAR: b 1 } } }
            { 1 H{ { CHAR: a 2 } { CHAR: b 2 } } }
            { 2 H{ { CHAR: c 3 } } }
            { 3 H{ } }
        } }
        { start-state 0 }
        { final-states HS{ 3 } }
    }
} [
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
        { final-states HS{ 3 6 } }
    } combine-states
] unit-test

{ H{ { T{ or-class f { 2 1 } } 3 } { 4 5 } } }
[ H{ { 1 3 } { 2 3 } { 4 5 } } combine-state-transitions ] unit-test
