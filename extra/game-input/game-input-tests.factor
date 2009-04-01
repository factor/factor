IN: game-input.tests
USING: ui game-input tools.test kernel system threads
combinators.short-circuit calendar ;

{
    [ os windows? ui-running? and ]
    [ os macosx? ]
} 0|| [
    [ ] [ open-game-input ] unit-test
    [ ] [ 1 seconds sleep ] unit-test
    [ ] [ close-game-input ] unit-test
] when