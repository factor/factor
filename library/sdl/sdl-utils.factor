! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sdl
USING: kernel lists math namespaces ;

: rgb ( [ r g b ] -- n )
    3unlist
    255
    swap 8 shift bitor
    swap 16 shift bitor
    swap 24 shift bitor ;

: make-color ( r g b -- color )
    #! Make an SDL_Color struct. This will go away soon in favor
    #! of pass-by-value support in the FFI.
    255 24 shift
    swap 16 shift bitor
    swap 8 shift bitor
    swap bitor ;

: black [ 0   0   0   ] ;
: gray  [ 128 128 128 ] ;
: white [ 255 255 255 ] ;
: red   [ 255 0   0   ] ;
: green [ 0   255 0   ] ;
: blue  [ 0   0   255 ] ;

: with-pixels ( quot -- )
    width get [
        height get [
            [ rot dup slip swap surface get swap ] 2keep
            [ rot pixelColor ] 2keep
        ] repeat
    ] repeat drop ; inline

: with-surface ( quot -- )
    #! Execute a quotation, locking the current surface if it
    #! is required (eg, hardware surface).
    [
        surface get dup must-lock-surface? [
            dup SDL_LockSurface drop slip dup SDL_UnlockSurface
        ] [
            slip
        ] ifte SDL_Flip drop
    ] with-scope ; inline
