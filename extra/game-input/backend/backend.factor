USING: multiline system parser combinators ;
IN: game-input.backend

STRING: set-backend-for-macosx
USING: namespaces game-input.backend.iokit game-input ;
iokit-game-input-backend game-input-backend set-global
;

STRING: set-backend-for-windows
USING: namespaces game-input.backend.dinput game-input ;
dinput-game-input-backend game-input-backend set-global
;

{
    { [ os macosx? ] [ set-backend-for-macosx eval ] }
    { [ os windows? ] [ set-backend-for-windows eval ] }
    { [ t ] [ ] }
} cond

