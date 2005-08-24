! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien hashtables kernel lists namespaces sdl sequences
strings styles io ;

: draw-surface ( x y surface -- )
    surface get SDL_UnlockSurface
    [
        [ sdl-surface-rect ] keep swap surface get 0 0
    ] keep sdl-surface-rect swap rot SDL_UpperBlit drop
    surface get dup must-lock-surface? [
        SDL_LockSurface
    ] when drop ;

: filter-nulls ( str -- str )
    [ dup 0 = [ drop CHAR: \s ] when ] map ;

: size-string ( font text -- w h )
    filter-nulls dup empty? [
        drop 0 swap TTF_FontHeight
    ] [
        0 <int> 0 <int> [ TTF_SizeUNICODE drop ] 2keep
        swap *int swap *int
    ] ifte ;

: draw-string ( gadget text -- )
    filter-nulls dup empty? [
        2drop
    ] [
        >r [ gadget-font ] keep r> swap
        fg 3unseq make-color
        TTF_RenderUNICODE_Blended
        [ >r origin get 2unseq r> draw-surface ] keep
        SDL_FreeSurface
    ] ifte ;
