USING: compiler.tree.propagation.known-words kernel math math.intervals
tools.test ;
IN: compiler.tree.propagation.known-words.tests

{
    fixnum
    T{ interval { from { -19 t } } { to { 19 t } } }
} [
    integer
    T{ interval { from { -19 t } } { to { 19 t } } }
    maybe>fixnum
] unit-test

{
    object
    T{ interval { from { -19 t } } { to { 19 t } } }
} [
    object
    T{ interval { from { -19 t } } { to { 19 t } } }
    maybe>fixnum
] unit-test
