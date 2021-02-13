USING: assocs generic.multi kernel math sequences tools.test words
compiler.test ;
IN: generic.multi.tests

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

CONSTANT: rock1 T{ rock f  }
CONSTANT: paper1 T{ paper f }
CONSTANT: scissors1 T{ scissors f }
CONSTANT: the-rock1 T{ the-rock f }


{ f } [ rock1 rock1 beats ] unit-test
{ t } [ rock1 scissors1 beats ] unit-test
{ t } [ scissors1 paper1 beats ] unit-test
{ t } [ paper1 rock1 beats ] unit-test
{ t } [ paper1 the-rock1 beats ] unit-test
{ t } [ the-rock1 paper1 beats ] unit-test
{ 42 } [ the-rock1 1 beats ] unit-test

{ f } [ [ rock1 rock1 beats ] compile-call ] unit-test
