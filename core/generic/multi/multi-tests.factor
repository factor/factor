USING: arrays classes classes.algebra classes.dispatch.covariant-tuples
classes.dispatch.syntax compiler.test generic generic.multi generic.single
kernel kernel.private literals math math.combinatorics random sequences
tools.dispatch tools.test tools.time words ;
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
MM: beats ( x: the-rock y: thing -- ? ) 2drop 47 ;
! tie-breaker
MM: beats ( x: the-rock y: scissors -- ? ) 2drop "tie-breaker" ;

M: fixnum beats ( x y -- ? ) 2drop 42 ;

CONSTANT: thing1 T{ thing f }
CONSTANT: rock1 T{ rock f  }
CONSTANT: paper1 T{ paper f }
CONSTANT: scissors1 T{ scissors f }
CONSTANT: the-rock1 T{ the-rock f }

: test-methods ( -- seq )
    M\ D{ thing thing } beats [ "method-class" word-prop ] keep <method-dispatch>
    M\ D{ rock scissors } beats [ "method-class" word-prop ] keep <method-dispatch>
    2array ;

{ 2 } [ scissors 0 test-methods applicable-methods length ] unit-test
{ 1 } [ thing 0 test-methods applicable-methods length ] unit-test
{ 0 } [ fixnum 0 test-methods applicable-methods length ] unit-test




{ f } [ rock1 rock1 beats ] unit-test
{ t } [ rock1 scissors1 beats ] unit-test
{ t } [ scissors1 paper1 beats ] unit-test
{ t } [ paper1 rock1 beats ] unit-test
{ t } [ paper1 the-rock1 beats ] unit-test
{ 47 } [ the-rock1 paper1 beats ] unit-test
{ 42 } [ the-rock1 1 beats ] unit-test

{ f } [ [ rock1 rock1 beats ] compile-call ] unit-test
{ t } [ [ rock1 scissors1 beats ] compile-call ] unit-test
{ t } [ [ scissors1 paper1 beats ] compile-call ] unit-test
{ t } [ [ paper1 rock1 beats ] compile-call ] unit-test
{ t } [ [ paper1 the-rock1 beats ] compile-call ] unit-test
{ 47 } [ [ the-rock1 paper1 beats ] compile-call ] unit-test
{ 42 } [ [ the-rock1 1 beats ] compile-call ] unit-test

GENERIC: test1 ( x x -- x )
M: rock test1 2drop 11 ;
M: the-rock test1 2drop 22 ;

: call-test1 ( x x -- x ) { rock } declare test1 ;
{ 22 } [ [ { rock } declare test1 ] [ 1 the-rock1 ] dip call ] unit-test
{ 22 } [ 1 the-rock1 call-test1 ] unit-test


: call-beats ( x x -- x ) { rock rock } declare beats ;
{ 47 } [ [ { rock rock } declare beats ] [ the-rock1 paper1 ] dip call ] unit-test
{ 47 } [ the-rock1 paper1 call-beats ] unit-test


! Only most-specific calls can be expanded at call-sites
{ f } [ { rock rock } <covariant-tuple> \ beats
        method-for-class method? ] unit-test
{ t } [ { paper paper } <covariant-tuple> \ beats
        method-for-class method? ] unit-test
{ t } [ { the-rock rock } <covariant-tuple> \ beats
        method-for-class method? ] unit-test
{ t } [ { thing fixnum } <covariant-tuple> \ beats
        method-for-class method? ] unit-test

: make-test-input ( n -- seq )
    ${ rock1 scissors1 paper1 the-rock1 } 2 all-selections
    [ clone randomize ] curry replicate concat ;

: play1 ( x x -- ? ) beats ;

: play ( n -- )
    make-test-input [ [ first2 play1 drop ] each ] curry time
    dispatch-stats.
    ;

{  } [ 1000 play ] unit-test


{ +incomparable+ }
[ { thing paper } <covariant-tuple>
  { paper thing } <covariant-tuple> compare-classes ] unit-test


! TODO: test this in a way to catch the expected compiler error
! GENERIC: broken ( x x -- x )
! MM: broken ( x: thing y: paper -- x ) 2drop 1 ;
! MM: broken ( x: paper y: thing -- x ) 2drop 2 ;

! { 1 } [ [ thing1 paper1 broken ] compile-call ] unit-test
! { 2 } [ [ paper1 thing1 broken ] compile-call ] unit-test

! This should probably fail at definition time already?
! [ [ paper1 paper1 broken ] compile-call ] must-fail


! Testing call-next-method
GENERIC: foo ( x x -- x )
MM: foo ( x: number x: number -- x ) 2drop 42 ;
MM: foo ( x: fixnum x: fixnum -- x ) 2drop 47 ;
MM: foo ( x: float x: number -- x ) call-next-method ;

{ 47 } [ 1 1 foo ] unit-test
{ 47 } [ [ 1 1 foo ] compile-call ] unit-test
{ 42 } [ 1.1 1 foo ] unit-test
{ 42 } [ [ 1.1 1 foo ] compile-call ] unit-test
