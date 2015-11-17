USING: accessors compiler.tree compiler.tree.builder
compiler.tree.optimizer compiler.tree.propagation.info
compiler.tree.propagation.recursive kernel kernel.private layouts
literals math math.intervals sequences sequences.private tools.test ;
IN: compiler.tree.propagation.recursive.tests

! counter-class
{
    array-capacity
    fixnum
    integer
    array-capacity
} [
    0 100 [a,b] fixnum counter-class
    -100 100 [a,b] fixnum counter-class
    0 100 [a,b] integer counter-class
    0 10 [a,b] array-capacity counter-class
] unit-test

! generalize-counter-interval
{ T{ interval f { 0 t } { 1/0. t } } } [
    T{ interval f { 1 t } { 1 t } }
    T{ interval f { 0 t } { 0 t } }
    integer generalize-counter-interval
] unit-test

{ T{ interval f { 0 t } { $[ max-array-capacity ] t } } } [
    T{ interval f { 1 t } { 1 t } }
    T{ interval f { 0 t } { 0 t } }
    fixnum generalize-counter-interval
] unit-test

{ T{ interval f { -1/0. t } { 10 t } } } [
    T{ interval f { -1 t } { -1 t } }
    T{ interval f { 10 t } { 10 t } }
    integer generalize-counter-interval
] unit-test

{ T{ interval f { $[ most-negative-fixnum ] t } { 10 t } } } [
    T{ interval f { -1 t } { -1 t } }
    T{ interval f { 10 t } { 10 t } }
    fixnum generalize-counter-interval
] unit-test

{ t } [
    T{ interval f { -268435456 t } { 268435455 t } }
    T{ interval f { 1 t } { 268435455 t } }
    over
    integer generalize-counter-interval =
] unit-test

{ t } [
    T{ interval f { -268435456 t } { 268435455 t } }
    T{ interval f { 1 t } { 268435455 t } }
    over
    fixnum generalize-counter-interval =
] unit-test

{ full-interval } [
    T{ interval f { -5 t } { 3 t } }
    T{ interval f { 2 t } { 11 t } }
    integer generalize-counter-interval
] unit-test

{ $[ fixnum-interval ] } [
    T{ interval f { -5 t } { 3 t } }
    T{ interval f { 2 t } { 11 t } }
    fixnum generalize-counter-interval
] unit-test

! node-output-infos
: integer-loop ( a -- b )
    { integer } declare [ dup 0 > ] [ 1 - ] while ;
{
    V{
        T{ value-info-state
           { class integer }
           { interval
             T{ interval { from { 1 t } } { to { 1/0. t } } }
           }
        }
    }
} [
    \ integer-loop build-tree optimize-tree
    [ #if? ] filter second children>> first first recursive-phi-infos
] unit-test
