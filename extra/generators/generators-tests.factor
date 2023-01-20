! Copyright (C) 2023 Keldan Chapman.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test generators kernel coroutines ;
IN: generators.tests

{ } [ [ ] assert-no-inputs ] unit-test
{ } [ [ 1 2 3 ] assert-no-inputs ] unit-test
[ [ dup ] assert-no-inputs ] [ has-inputs? ] must-fail-with

{ t } [ [ ] generator new gen-coroutine coroutine? ] unit-test

{ t } [ [ ] <generator> generator? ] unit-test

GEN: no-inp-gen ( -- g ) 1 yield 2 yield 3 yield ;
GEN: inp-gen ( x y -- g ) over yield yield yield ;
GEN:: no-inp-loc-gen ( -- g ) 1 yield 2 yield 3 yield ;
GEN:: inp-loc-gen ( x y -- g ) x yield y yield x yield ;
GEN: next*-gen ( -- g ) 1 yield* yield* yield* ;

{ 1 2 } [ no-inp-gen [ next ] [ next ] bi ] unit-test
{ 1 2 } [ 1 2 inp-gen [ next ] [ next ] bi ] unit-test
{ 1 2 } [ no-inp-loc-gen [ next ] [ next ] bi ] unit-test
{ 1 2 } [ 1 2 inp-loc-gen [ next ] [ next ] bi ] unit-test
{ 1 2 } [ [ 1 yield 2 yield ] <generator> [ next ] [ next ] bi ] unit-test
[ [ ] <generator> next ] [ stop-generator? ] must-fail-with

{ 1 2 3 } [ next*-gen [ next ] [ 2 swap next* ] [ 3 swap next* ] tri ] unit-test

{ 2 } [ no-inp-gen [ skip ] [ next ] bi ] unit-test
{ 1 3 } [ next*-gen [ next ] [ 2 swap skip* ] [ 3 swap next* ] tri ] unit-test

{ t } [ [ [ ] <generator> next ] [ t ] catch-stop-generator ] unit-test
{ t } [ [ no-inp-gen next drop t ] [ f ] catch-stop-generator ] unit-test

{ 1 f } [ no-inp-gen ?next ] unit-test
{ f t } [ [ ] <generator> ?next ] unit-test

{ 1 2 f } [ next*-gen [ next ] [ 2 swap ?next* ] bi ] unit-test
{ f t } [ 2 [ ] <generator> ?next* ] unit-test

{ { } } [ no-inp-gen 0 take ] unit-test
{ { 1 2 } } [ no-inp-gen 2 take ] unit-test
{ { 1 2 3 } } [ no-inp-gen 10 take ] unit-test

{ { 1 2 3 } } [ no-inp-gen take-all ] unit-test
{ { } } [ [ ] <generator> take-all ] unit-test

GEN: yf-test ( -- g ) no-inp-gen yield-from no-inp-gen yield-from ;
{ { 1 2 3 1 2 3 } } [ yf-test take-all ] unit-test

{ t } [ no-inp-gen [ take-all drop ] [ exhausted? ] bi ] unit-test
{ f } [ no-inp-gen exhausted? ] unit-test
