USING: namespaces math partial-continuations tools.test
kernel sequences fry ;
IN: partial-continuations.tests

SYMBOL: sum

: range ( r from to -- n )
    over - 1 + rot [
        '[ over + @ drop ] each-integer drop f
    ] bshift 2nip ; inline

{ 55 } [
    0 sum set
    [ 1 10 range sum get + sum set f ] breset drop
    sum get
] unit-test
