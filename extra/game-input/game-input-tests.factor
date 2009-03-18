IN: game-input.tests
USING: game-input tools.test kernel system threads ;

os windows? os macosx? or [
    [ ] [ open-game-input ] unit-test
    [ ] [ yield ] unit-test
    [ ] [ close-game-input ] unit-test
] when