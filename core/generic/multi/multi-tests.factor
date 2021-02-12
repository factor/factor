USING: assocs generic.multi kernel math sequences tools.test words ;
IN: generic.multi.tests

TUPLE: A ;
MIXIN: B
TUPLE: C < A ;
MIXIN: D
TUPLE: E < C ;
INSTANCE: E B
INSTANCE: E D
TUPLE: F < C ;
INSTANCE: F D
TUPLE: G < E ;
TUPLE: H < F ;

CONSTANT: m1 { A B B B }
CONSTANT: m2 { C C B B }
CONSTANT: m3 { C D A F }

GENERIC: m ( x x x x -- n )
MM: m ( x: A x: B x: B x: B -- n ) 4drop 1 ;
MM: m ( x: C x: C x: B x: B -- n ) 4drop 2 ;
MM: m ( x: C x: D x: A x: F -- n ) 4drop 3 ;

{ { A B B B } } [ \ m "methods" word-prop values second method-types ] unit-test
{ { C D A F } } [ \ m "methods" word-prop values first method-types ] unit-test


TUPLE: thing ;
TUPLE: rock < thing ;
TUPLE: paper < thing ;
TUPLE: scissors < thing ;
TUPLE: the-rock < rock ;

GENERIC: beats ( x x -- x )
! Specializers are bogus here
! m4(thing, thing)
MM: beats ( x: thing y: thing -- ? ) 2drop f ;
! m2(scissors, rock)
MM: beats ( x: rock y: scissors -- ? ) 2drop t ;
! m1(rock, paper)
MM: beats ( x: paper y: rock -- ? ) 2drop t ;
! m3(paper, scissors)
MM: beats ( x: scissors y: paper -- ? ) 2drop t ;
! m5(thing, the-rock)
MM: beats ( x: the-rock y: thing -- ? ) 2drop t ;

M: fixnum beats ( x y -- ? ) 2drop 42 ;
