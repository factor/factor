USING: kernel system combinators parser ;
IN: game-input.backend

<< {
    { [ os macosx? ] [ "game-input.backend.iokit" use+ ] }
    { [ os windows? ] [ "game-input.backend.dinput" use+ ] }
    { [ t ] [ ] }
} cond >>
