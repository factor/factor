! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien arrays errors hashtables io kernel lists namespaces
sdl sequences styles ;

: ttf-name ( font style -- name )
    cons {{
        [[ [[ "Monospaced" plain       ]] "VeraMono" ]]
        [[ [[ "Monospaced" bold        ]] "VeraMoBd" ]]
        [[ [[ "Monospaced" bold-italic ]] "VeraMoBI" ]]
        [[ [[ "Monospaced" italic      ]] "VeraMoIt" ]]
        [[ [[ "Sans Serif" plain       ]] "Vera"     ]]
        [[ [[ "Sans Serif" bold        ]] "VeraBd"   ]]
        [[ [[ "Sans Serif" bold-italic ]] "VeraBI"   ]]
        [[ [[ "Sans Serif" italic      ]] "VeraIt"   ]]
        [[ [[ "Serif" plain            ]] "VeraSe"   ]]
        [[ [[ "Serif" bold             ]] "VeraSeBd" ]]
        [[ [[ "Serif" bold-italic      ]] "VeraBI"   ]]
        [[ [[ "Serif" italic           ]] "VeraIt"   ]]
    }} hash ;

: ttf-path ( name -- string )
    [ "/fonts/" % % ".ttf" % ] "" make resource-path ;

: open-font ( { font style ptsize } -- alien )
    first3 >r ttf-name ttf-path r> TTF_OpenFont
    dup alien-address 0 = [ SDL_GetError throw ] when ;

SYMBOL: open-fonts

: lookup-font ( font style ptsize -- font )
    3array open-fonts get [ open-font ] cache ;

global [ open-fonts nest drop ] bind

: ttf-init ( -- )
    TTF_Init -1 = [ SDL_GetError throw ] when
    global [
        open-fonts [ [ cdr expired? not ] hash-subset ] change
    ] bind ;

: gadget-font ( gadget -- font )
    [ font paint-prop ] keep
    [ font-style paint-prop ] keep
    font-size paint-prop
    lookup-font ;
