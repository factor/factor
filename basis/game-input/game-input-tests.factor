IN: game-input.tests
USING: ui game-input tools.test kernel system threads calendar ;

os windows? os macosx? or [
    [ ] [ open-game-input ] unit-test
    [ ] [ 1 seconds sleep ] unit-test
    [ ] [ close-game-input ] unit-test
] when