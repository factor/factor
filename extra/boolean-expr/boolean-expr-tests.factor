! Copyright (C) 2022 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: boolean-expr literals tools.test ;
IN: boolean-expr.tests

${ P ¬ Q ⋀ } [ P ¬ P Q ⋁ ⋀ ] unit-test
${ P ¬ Q ⋀ } [ P ¬ Q P ⋁ ⋀ ] unit-test
${ P Q ⋀ } [ P P ¬ Q ⋁ ⋀ ] unit-test
${ P Q ⋀ } [ P Q P ¬ ⋁ ⋀ ] unit-test

! The following tests can't pass because only the distributivity of ∧ over ∨ is
! implemented, but not the other way around, to prevent infinite loops.
! ${ P ¬ Q ⋀ } [ P ¬ P Q ⋀ ⋁ ] unit-test
! ${ Q P ¬ ⋀ } [ P ¬ Q P ⋀ ⋁ ] unit-test
! ${ P Q ⋀ } [ P P ¬ Q ⋀ ⋁ ] unit-test
! ${ P Q ⋀ } [ P Q P ¬ ⋀ ⋁ ] unit-test
