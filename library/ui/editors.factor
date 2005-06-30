! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel line-editor lists math matrices namespaces
sdl sequences strings styles vectors ;

! An editor gadget wraps a line editor object and passes
! gestures to the line editor.

TUPLE: editor line caret ;

: editor-text ( editor -- text )
    editor-line [ line-text get ] bind ;

: set-editor-text ( text editor -- )
    editor-line [ set-line-text ] bind ;

: focus-editor ( editor -- )
    dup editor-caret swap add-gadget ;

: unfocus-editor ( editor -- )
    editor-caret unparent ;

: with-editor ( editor quot -- )
    #! Execute a quotation in the line editor scope, then
    #! update the display.
    swap [ editor-line swap bind ] keep relayout ; inline

: run-char-widths ( str -- wlist )
    #! List of x co-ordinates of each character.
    0 swap >list
    [ ch>string shape-w [ + dup ] keep 2 /i - ] map nip ;

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

: set-caret-x ( x editor -- )
    #! Move the caret to a clicked location.
    [ line-text get x>offset caret set ] with-editor ;

: click-editor ( editor -- )
    hand
    2dup relative shape-x pick set-caret-x
    request-focus ;

: editor-actions ( editor -- )
    [
        [[ [ gain-focus ] [ focus-editor ] ]]
        [[ [ lose-focus ] [ unfocus-editor ] ]]
        [[ [ button-down 1 ] [ click-editor ] ]]
        [[ [ "BACKSPACE" ] [ [ backspace ] with-editor ] ]]
        [[ [ "LEFT" ] [ [ left ] with-editor ] ]]
        [[ [ "RIGHT" ] [ [ right ] with-editor ] ]]
        [[ [ "CTRL" "k" ] [ [ line-clear ] with-editor ] ]]
    ] swap add-actions ;

: <caret> ( -- caret )
    <plain-gadget> dup red background set-paint-prop ;

C: editor ( text -- )
    <empty-gadget> over set-delegate
    [ <line-editor> swap set-editor-line ] keep
    [ <caret> swap set-editor-caret ] keep
    [ set-editor-text ] keep
    dup editor-actions ;

: offset>x ( gadget offset str -- x )
    head >r gadget-font r> size-string drop ;

: caret-pos ( editor -- x y )
    dup editor-line [ caret get line-text get ] bind offset>x 0 ;

: caret-size ( editor -- w h )
    1 swap shape-h ;

M: editor user-input* ( ch editor -- ? )
    [ [ insert-char ] with-editor ] keep
    scroll>bottom  t ;

M: editor pref-dim ( editor -- dim )
    dup editor-text label-size { 1 0 0 } v+ ;

M: editor layout* ( editor -- )
    dup editor-caret over caret-size rot resize-gadget
    dup editor-caret swap caret-pos rot move-gadget ;

M: editor draw-shape ( editor -- )
    [ dup gadget-font swap editor-text ] keep
    [ draw-string ] with-trans ;
