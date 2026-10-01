USING: ui game.input tools.test kernel system threads calendar
combinators.short-circuit continuations locals namespaces opengl ;

! Windows can initialize even when no mouse is attached (#1844).
os { [ windows? ] [ macos? ] } 1|| [
    { } [ [let
        ! The native notification window discovers DPI. Restore it so
        ! running input tests cannot change later text-rendering tests.
        gl-scale-factor get-global :> scale
        [
            open-game-input
            [ 1 seconds sleep ] [ close-game-input ] finally
        ] [ scale gl-scale-factor set-global ] finally
    ] ] unit-test
] when

{ f        } [ t t button-delta ] unit-test
{ pressed  } [ f t button-delta ] unit-test
{ released } [ t f button-delta ] unit-test

{ f        } [ 0.5 1.0 button-delta ] unit-test
{ pressed  } [ f   0.7 button-delta ] unit-test
{ released } [ 0.2 f   button-delta ] unit-test

{  { pressed f f released } } [ { f t f t } { t t f f }      buttons-delta    ] unit-test
{ V{ pressed f f released } } [ { f t f t } { t t f f } V{ } buttons-delta-as ] unit-test
