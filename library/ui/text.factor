! Strings are shapes too. This is somewhat of a hack and strings
! do not have x/y co-ordinates.
IN: gadgets
USING: alien hashtables kernel lists namespaces sdl sequences
streams strings ;

SYMBOL: fonts

: <font> ( name ptsize -- font )
    >r resource-path swap append r> TTF_OpenFont ;

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
    0 over contains? [
        [ dup 0 = [ drop CHAR: \s ] when ] map
    ] when ;

: size-string ( font text -- w h )
    >r lookup-font r> filter-nulls dup empty? [
        drop TTF_FontHeight 0 swap
    ] [
        0 <int> 0 <int> [ TTF_SizeUNICODE drop ] 2keep
        swap *int swap *int
    ] ifte ;

: draw-string ( text -- )
    dup empty? [
        drop
    ] [
        filter-nulls font get lookup-font swap
        fg 3unlist make-color
        bg 3unlist make-color
        TTF_RenderUNICODE_Shaded
        [ >r x get y get r> draw-surface ] keep
        SDL_FreeSurface
    ] ifte ;

global [ <namespace> fonts set ] bind
