! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl line-editor ;

TUPLE: field active? delegate ;

: field-border ( gadget -- border )
    bevel-border dup f bevel-up? set-paint-property ;

C: field ( delegate -- field )
    [ >r field-border r> set-field-delegate ] keep
    {{
        [[ [ gain-focus ] [ dup blue foreground set-paint-property redraw ] ]]
        [[ [ lose-focus ] [ dup black foreground set-paint-property redraw ] ]]
        [[ [ button-down 1 ] [ my-hand request-focus ] ]]
        [[ [ "RETURN" ] [ drop "foo!" USE: stdio print ] ]]
    }} over set-gadget-gestures ;

TUPLE: editor line delegate ;

C: editor ( -- )
    0 0 0 0 <rectangle> <gadget> over set-editor-delegate
    [ <line-editor> set-editor-line ] keep ;

: editor-text ( editor -- text )
    editor-line [ line-text get ] bind ;

M: editor layout* ( label -- )
    [ editor-text dup shape-w swap shape-h ] keep resize-gadget ;

M: editor draw-shape ( label -- )
    dup [ editor-text draw-shape ] with-translation ;
