IN: game-input.tests
USING: game-input tools.test kernel system ;

os windows? os macosx? or [
    [ ] [ open-game-input ] unit-test
    [ ] [ close-game-input ] unit-test
] when