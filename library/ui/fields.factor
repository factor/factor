! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sdl line-editor
strings ;

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

: offset>x ( offset str -- x )
    str-head font get swap size-string drop ;

: run-char-widths ( str -- wlist )
    #! List of x co-ordinates of each character.
    0 swap str>list
    [ ch>str shape-w [ + dup ] keep 2 /i - ] map nip ;

: (x>offset) ( n x wlist -- offset )
    dup [
        uncons >r over > [
            r> 2drop
        ] [
            >r 1 + r> r> (x>offset)
        ] ifte
    ] [
        2drop
    ] ifte ;

: x>offset ( x str -- offset )
    0 -rot run-char-widths (x>offset) ;

: caret-pos ( editor -- x y )
    editor-line [ caret get line-text get ] bind offset>x 0 ;

: caret-size ( editor -- w h )
    0 swap shape-h ;

M: editor layout* ( field -- )
    dup [ editor-text dup shape-w swap shape-h ] keep
    resize-gadget
    dup editor-caret over caret-size rot resize-gadget
    dup editor-caret swap caret-pos rot move-gadget ;

M: editor draw-shape ( label -- )
    dup [ editor-text draw-shape ] with-trans ;

TUPLE: field active? editor delegate ;

: with-editor ( editor quot -- )
    swap [ editor-line swap bind ] keep relayout ; inline

: set-caret-x ( x editor -- )
    #! Move the caret to a clicked location.
    [ line-text get x>offset caret set ] with-editor ;

: click-editor ( editor -- )
    my-hand
    2dup relative shape-x pick set-caret-x
    request-focus ;

: field-border ( gadget -- border )
    bevel-border dup f bevel-up? set-paint-property ;

M: field user-input* ( ch field -- ? )
    field-editor [ insert-char ] with-editor t ;

: field-gestures ( -- hash )
    {{
        [[ [ gain-focus ] [ field-editor focus-editor ] ]]
        [[ [ lose-focus ] [ field-editor unfocus-editor ] ]]
        [[ [ button-down 1 ] [ field-editor click-editor ] ]]
        [[ [ "BACKSPACE" ] [ field-editor [ backspace ] with-editor ] ]]
        [[ [ "LEFT" ] [ field-editor [ left ] with-editor ] ]]
        [[ [ "RIGHT" ] [ field-editor [ right ] with-editor ] ]]
        [[ [ "CTRL" "k" ] [ field-editor [ line-clear ] with-editor ] ]]
    }} ;

C: field ( text -- field )
    #! Note that we want the editor's parent to be the field,
    #! not the border.
    [ f field-border swap set-field-delegate ] keep
    [ >r <editor> dup r> set-field-editor ] keep
    [ add-gadget ] keep
    [ field-gestures swap set-gadget-gestures ] keep ;
