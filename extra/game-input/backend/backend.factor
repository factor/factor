USING: eval multiline system combinators ;
IN: game-input.backend

STRING: set-backend-for-macosx
USING: namespaces parser game-input.backend.iokit ;
<< "game-input" (use+) >>
iokit-game-input-backend game-input-backend set-global
;

STRING: set-backend-for-windows
USING: namespaces parser game-input.backend.dinput ;
<< "game-input" (use+) >>
dinput-game-input-backend game-input-backend set-global
;

{
    { [ os macosx? ] [ set-backend-for-macosx eval ] }
    { [ os windows? ] [ set-backend-for-windows eval ] }
    { [ t ] [ ] }
} cond

