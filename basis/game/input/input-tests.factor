USING: ui game.input tools.test kernel system threads calendar
combinators.short-circuit ;
IN: game.input.tests

os { [ windows? ] [ macosx? ] } 1|| [
    [ ] [ open-game-input ] unit-test
    [ ] [ 1 seconds sleep ] unit-test
    [ ] [ close-game-input ] unit-test
] when
