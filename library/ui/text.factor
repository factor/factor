! Strings are shapes too. This is somewhat of a hack and strings
! do not have x/y co-ordinates.
IN: gadgets
USING: alien hashtables kernel lists namespaces sdl
sdl-ttf sdl-video streams strings ;

SYMBOL: fonts

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

: size-string ( font text -- w h )
    >r lookup-font r> filter-nulls dup string-length 0 = [
        drop TTF_FontHeight 0 swap
    ] [
        <int-box> <int-box> [ TTF_SizeUNICODE drop ] 2keep
        swap int-box-i swap int-box-i
    ] ifte ;

global [ <namespace> fonts set ] bind

M: string shape-x drop 0 ;
M: string shape-y drop 0 ;
M: string shape-w
    font get swap size-string ( h -) drop ;

M: string shape-h ( text -- h )
    #! This is just the height of the current font.
    drop font get lookup-font TTF_FontHeight ;

: filter-nulls ( str -- str )
    "\0" over string-contains? [
        [ dup CHAR: \0 = [ drop CHAR: \s ] when ] string-map
    ] when ;

M: string draw-shape ( text -- )
    dup string-length 0 = [
        drop
    ] [
        filter-nulls font get lookup-font swap
        fg 3unlist make-color
        bg 3unlist make-color
        TTF_RenderUNICODE_Shaded
        [ >r x get y get r> draw-surface ] keep
        SDL_FreeSurface
    ] ifte ;
