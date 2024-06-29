USING: ui game.input tools.test kernel system threads calendar
combinators.short-circuit ;

! os { [ windows? ] [ macos? ] } 1|| [
! This test only works if a mouse is present. Issue #1844
os { [ macos? ] } 1|| [
    [ ] [ open-game-input ] unit-test
    [ ] [ 1 seconds sleep ] unit-test
    [ ] [ close-game-input ] unit-test
] when

{ f        } [ t t button-delta ] unit-test
{ pressed  } [ f t button-delta ] unit-test
{ released } [ t f button-delta ] unit-test

{ f        } [ 0.5 1.0 button-delta ] unit-test
{ pressed  } [ f   0.7 button-delta ] unit-test
{ released } [ 0.2 f   button-delta ] unit-test

{  { pressed f f released } } [ { f t f t } { t t f f }      buttons-delta    ] unit-test
{ V{ pressed f f released } } [ { f t f t } { t t f f } V{ } buttons-delta-as ] unit-test
