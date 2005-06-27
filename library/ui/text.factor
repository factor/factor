! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien hashtables kernel lists namespaces sdl sequences
strings styles io ;

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
    filter-nulls dup empty? [
        drop 0 swap TTF_FontHeight
    ] [
        0 <int> 0 <int> [ TTF_SizeUNICODE drop ] 2keep
        swap *int swap *int
    ] ifte ;

: draw-string ( font text -- )
    filter-nulls dup empty? [
        2drop
    ] [
        fg 3unlist make-color
        bg 3unlist make-color
        TTF_RenderUNICODE_Shaded
        [ >r x get y get r> draw-surface ] keep
        SDL_FreeSurface
    ] ifte ;
