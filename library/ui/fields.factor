! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl line-editor
strings ;

TUPLE: field active? editor delegate ;

TUPLE: editor line caret delegate ;

: editor-text ( editor -- text )
    editor-line [ line-text get ] bind ;

: set-editor-text ( text editor -- )
    editor-line [ set-line-text ] bind ;

: <caret> ( -- caret )
    0 0 0 0 <plain-rect> <gadget>
    dup red background set-paint-property ;

C: editor ( text -- )
    0 0 0 0 <line> <gadget> over set-editor-delegate
    [ <line-editor> swap set-editor-line ] keep
    [ <caret> swap set-editor-caret ] keep
    [ set-editor-text ] keep ;

: focus-editor ( editor -- )
    dup editor-caret over add-gadget
    dup blue foreground set-paint-property relayout ;

: unfocus-editor ( editor -- )
    dup editor-caret unparent
    dup black foreground set-paint-property relayout ;

: offset>x ( offset editor -- x )
    editor-line [ line-text get ] bind str-head
    font get swap
    size-string drop ;

: caret-pos ( editor -- x y )
    dup editor-line [ caret get ] bind swap offset>x 0 ;

: caret-size ( editor -- w h )
    0 swap shape-h ;

M: editor layout* ( field -- )
    dup [ editor-text dup shape-w swap shape-h ] keep resize-gadget
    dup editor-caret over caret-size rot resize-gadget
    dup editor-caret swap caret-pos rot move-gadget ;

M: editor draw-shape ( label -- )
    dup [ editor-text draw-shape ] with-translation ;

: field-border ( gadget -- border )
    bevel-border dup f bevel-up? set-paint-property ;

: with-field-editor ( field quot -- )
    swap field-editor [ editor-line swap bind ] keep relayout ;

M: field user-input* ( ch field -- ? )
    [ insert-char ] with-field-editor f ;

: click-field ( field -- )
    my-hand request-focus ;

: field-gestures ( -- hash )
    {{
        [[ [ gain-focus ] [ field-editor focus-editor ] ]]
        [[ [ lose-focus ] [ field-editor unfocus-editor ] ]]
        [[ [ button-down 1 ] [ click-field ] ]]
        [[ [ "BACKSPACE" ] [ [ backspace ] with-field-editor ] ]]
        [[ [ "LEFT" ] [ [ left ] with-field-editor ] ]]
        [[ [ "RIGHT" ] [ [ right ] with-field-editor ] ]]
        [[ [ "CTRL" "k" ] [ [ line-clear ] with-field-editor ] ]]
    }} ;

C: field ( text -- field )
    #! Note that we want the editor's parent to be the field,
    #! not the border.
    [ f field-border swap set-field-delegate ] keep
    [ >r <editor> dup r> set-field-editor ] keep
    [ add-gadget ] keep
    [ field-gestures swap set-gadget-gestures ] keep ;
