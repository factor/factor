! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sdl
USING: alien math namespaces compiler words parser kernel errors
lists prettyprint sdl-event sdl-gfx sdl-keyboard sdl-video
streams strings sdl-ttf hashtables ;

SYMBOL: surface
SYMBOL: width
SYMBOL: height
SYMBOL: bpp
SYMBOL: surface

: init-screen ( width height bpp flags -- )
    >r 3dup bpp set height set width set r>
    SDL_SetVideoMode surface set ;

: with-screen ( width height bpp flags quot -- )
    #! Set up SDL graphics and call the quotation.
    SDL_INIT_EVERYTHING SDL_Init drop  TTF_Init
    1 SDL_EnableUNICODE drop
    SDL_DEFAULT_REPEAT_DELAY SDL_DEFAULT_REPEAT_INTERVAL
    SDL_EnableKeyRepeat drop
    [ >r init-screen r> call SDL_Quit ] with-scope ; inline

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

: clear-surface ( color -- )
    >r surface get 0 0 width get height get r> boxColor ;

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

: event-loop ( event -- )
    dup SDL_WaitEvent [
        dup event-type SDL_QUIT = [
            drop
        ] [
            event-loop
        ] ifte
    ] [
        drop
    ] ifte ;

SYMBOL: fonts

: null? ( alien -- ? )
    dup [ alien-address 0 = ] when ;

: <font> ( name ptsize -- font )
    >r resource-path swap cat2 r> TTF_OpenFont ;

SYMBOL: logical-fonts

: logical-font ( name -- name )
    dup logical-fonts get hash dup [ nip ] [ drop ] ifte ;

global [
    {{
        [[ "Monospaced" "/fonts/VeraMono.ttf" ]]
        [[ "Serif" "/fonts/VeraSe.ttf" ]]
        [[ "Sans Serif" "/fonts/Vera.ttf" ]]
    }} logical-fonts set
] bind

: (lookup-font) ( [[ name ptsize ]] -- font )
    unswons logical-font swons dup get dup alien? [
        dup alien-address 0 = [
            drop f
        ] when
    ] when ;

: lookup-font ( [[ name ptsize ]] -- font )
    fonts get [
        (lookup-font) [
            nip
        ] [
            [ uncons <font> dup ] keep set
        ] ifte*
    ] bind ;

: make-rect ( x y w h -- rect )
    <rect>
    [ set-rect-h ] keep
    [ set-rect-w ] keep
    [ set-rect-y ] keep
    [ set-rect-x ] keep ;

: surface-rect ( x y surface -- rect )
    dup surface-w swap surface-h make-rect ;

: draw-surface ( x y surface -- )
    surface get SDL_UnlockSurface
    [
        [ surface-rect ] keep swap surface get 0 0
    ] keep surface-rect swap rot SDL_UpperBlit drop
    surface get dup must-lock-surface? [
        SDL_LockSurface
    ] when drop ;

: filter-nulls ( str -- str )
    "\0" over string-contains? [
        [ dup CHAR: \0 = [ drop CHAR: \s ] when ] string-map
    ] when ;

: draw-string ( x y font text fg -- width )
    >r filter-nulls r> over string-length 0 = [
        2drop 3drop 0
    ] [
        >r >r lookup-font r> r>
        TTF_RenderUNICODE_Blended
        [ draw-surface ] keep
        [ surface-w ] keep
        SDL_FreeSurface
    ] ifte ;

: size-string ( font text -- w h )
    >r lookup-font r> filter-nulls dup string-length 0 = [
        drop TTF_FontHeight 0 swap
    ] [
        <int-box> <int-box> [ TTF_SizeUNICODE drop ] 2keep
        swap int-box-i swap int-box-i
    ] ifte ;

global [ <namespace> fonts set ] bind
