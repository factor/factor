! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien hashtables io kernel lists math namespaces sdl
sequences strings styles ;

: draw-surface ( x y surface -- )
    surface get SDL_UnlockSurface
    [ [ surface-rect ] keep swap surface get 0 0 ] keep
    surface-rect swap rot SDL_UpperBlit drop
    surface get dup must-lock-surface?
    [ SDL_LockSurface ] when drop ;

: filter-nulls ( str -- str )
    [ dup 0 = [ drop CHAR: \s ] when ] map ;

: size-string ( font text -- w h )
    filter-nulls dup empty? [
        drop 0 swap TTF_FontHeight
    ] [
        0 <int> 0 <int> [ TTF_SizeUNICODE drop ] 2keep
        [ *int ] 2apply
    ] ifte ;

: draw-string ( gadget text -- )
    filter-nulls dup empty? [
        2drop
    ] [
        >r [ gadget-font ] keep r> swap
        fg first3 make-color
        TTF_RenderUNICODE_Blended
        [ >r origin get first2 r> draw-surface ] keep
        SDL_FreeSurface
    ] ifte ;
