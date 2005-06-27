! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: alien hashtables io kernel lists namespaces sdl sequences
styles ;

: ttf-name ( font style -- name )
    cons [
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
    ] assoc ;

: ttf-path ( name -- string )
    [ resource-path % "/fonts/" % % ".ttf" % ] make-string ;

: open-font ( [ font style ptsize ] -- alien )
    3unlist >r ttf-name ttf-path r> TTF_OpenFont ;

SYMBOL: open-fonts

: lookup-font ( font style ptsize -- font )
    3list open-fonts get [ open-font ] cache ;

global [ open-fonts nest drop ] bind

: ttf-init ( -- )
    TTF_Init
    open-fonts [ [ cdr null? not ] hash-subset ] change ;

: gadget-font ( gadget -- font )
    [ font paint-prop ] keep
    [ font-style paint-prop ] keep
    font-size paint-prop
    lookup-font ;
