USING: accessors compiler.tree.propagation.info
compiler.tree.propagation.known-words kernel kernel.private layouts math
math.intervals math.private random tools.test words ;
IN: compiler.tree.propagation.known-words.tests

{
    fixnum T{ interval { from { -19 t } } { to { 19 t } } }
} [
    fixnum fixnum full-interval 0 20 [a,b] mod-merge-classes/intervals
] unit-test

{
    object T{ interval { from { -20 f } } { to { 20 f } } }
} [
    object object full-interval 0 20 [a,b] mod-merge-classes/intervals
] unit-test

{ fixnum } [
    bignum <class-info>
    fixnum fixnum-interval <class/interval-info>
    \ mod "outputs" word-prop call( x y -- z )
    class>>
] unit-test

! Since 10 >bignum 5 >bignum bignum-mod => fixnum, the output class
! must be integer.
{ integer } [
    bignum <class-info> dup \ bignum-mod "outputs" word-prop call class>>
] unit-test

{ t } [
    100 random 2^ >bignum
    [ { bignum } declare 10 /mod ] call nip fixnum?
] unit-test
