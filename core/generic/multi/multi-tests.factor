USING: accessors classes.algebra compiler.test generic.multi kernel literals
math math.combinatorics random sequences tools.dispatch tools.test tools.time
words ;
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

CONSTANT: thing1 T{ thing f }
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
{ t } [ [ rock1 scissors1 beats ] compile-call ] unit-test
{ t } [ [ scissors1 paper1 beats ] compile-call ] unit-test
{ t } [ [ paper1 rock1 beats ] compile-call ] unit-test
{ t } [ [ paper1 the-rock1 beats ] compile-call ] unit-test
{ t } [ [ the-rock1 paper1 beats ] compile-call ] unit-test
{ 42 } [ [ the-rock1 1 beats ] compile-call ] unit-test

{ { thing thing } } [ { rock rock } <covariant-tuple> \ beats
        multi-method-for-class "method-class" word-prop
        classes>>
      ] unit-test

: make-test-input ( n -- seq )
    ${ rock1 scissors1 paper1 the-rock1 } 2 all-selections
    [ clone randomize ] curry replicate concat ;

: play1 ( x x -- ? ) beats ;

: play ( n -- )
    make-test-input [ [ first2 play1 drop ] each ] curry time
    dispatch-stats.
    ;

{  } [ 1000 play ] unit-test


GENERIC: broken ( x x -- x )
MM: broken ( x: thing y: paper -- x ) 2drop 1 ;
MM: broken ( x: paper y: thing -- x ) 2drop 2 ;

{ 1 } [ [ thing1 paper1 broken ] compile-call ] unit-test
{ 2 } [ [ paper1 thing1 broken ] compile-call ] unit-test
[ [ paper1 paper1 broken ] compile-call ] [ ambiguous-multi-dispatch? ] must-fail-with
