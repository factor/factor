! Copyright (C) 2024 Keldan Chapman.
! See https://factorcode.org/license.txt for BSD license.
USING: bend tools.test kernel math variants ;
IN: bend.tests

VARIANT: tree
    leaf: { value }
    branch: { { left maybe{ tree } } { right maybe{ tree } } }
    ;

{ t } [
    4 0 BEND[ swap
        [ <leaf> ]
        [ 1 - swap 2 * [ fork ] [ 1 + fork ] 2bi <branch> ]
        if-zero
    ] tree? ] unit-test

{ 120 } [
    4 0 BEND[ swap
        [ <leaf> ]
        [ 1 - swap 2 * [ fork ] [ 1 + fork ] 2bi <branch> ]
        if-zero
    ] {
        { leaf [ ] }
        { branch [ + ] }
    } fold ] unit-test
