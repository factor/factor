! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel math matrices namespaces sdl sequences
strings styles threads vectors ;

! A blinking caret
TUPLE: caret ;

C: caret ( -- caret )
    <plain-gadget> over set-delegate
    dup red background set-paint-prop ;

: toggle-visible ( gadget -- )
    dup gadget-visible? not over set-gadget-visible?
    relayout ;

M: caret tick ( ms caret -- ) nip toggle-visible ;

: caret-blink 500 ;

: add-caret ( caret parent -- )
    dupd add-gadget caret-blink add-timer ;

: unparent-caret ( caret -- )
    dup remove-timer unparent ;

: reset-caret ( caret -- )
    dup restart-timer t swap set-gadget-visible? ;

USE: line-editor

! An editor gadget wraps a line editor object and passes
! gestures to the line editor.

TUPLE: editor line caret ;

: with-editor ( editor quot -- )
    #! Execute a quotation in the line editor scope, then
    #! update the display.
    swap [ editor-line swap bind ] keep
    dup editor-caret reset-caret
    dup relayout scroll>bottom ; inline

: editor-text ( editor -- text )
    editor-line [ line-text get ] bind ;

: set-editor-text ( text editor -- )
    [ set-line-text ] with-editor ;

: focus-editor ( editor -- )
    dup editor-caret swap add-caret ;

: unfocus-editor ( editor -- )
    editor-caret unparent-caret ;

: run-char-widths ( font str -- wlist )
    #! List of x co-ordinates of each character.
    >vector [ ch>string size-string drop ] map-with
    dup 0 [ + ] accumulate swap 2 v/n v+ ;

: x>offset ( x font str -- offset )
    dup >r run-char-widths [ <= ] find-with drop dup -1 =
    [ drop r> length ] [ r> drop ] ifte ;

: set-caret-x ( x editor -- )
    #! Move the caret to a clicked location.
    dup [
        gadget-font line-text get x>offset caret set
    ] with-editor ;

: click-editor ( editor -- )
    dup hand relative first over set-caret-x request-focus ;

: editor-actions ( editor -- )
    [
        [[ [ gain-focus ] [ focus-editor ] ]]
        [[ [ lose-focus ] [ unfocus-editor ] ]]
        [[ [ button-down 1 ] [ click-editor ] ]]
        [[ [ "BACKSPACE" ] [ [ backspace ] with-editor ] ]]
        [[ [ "LEFT" ] [ [ left ] with-editor ] ]]
        [[ [ "RIGHT" ] [ [ right ] with-editor ] ]]
        [[ [ "CTRL" "k" ] [ [ line-clear ] with-editor ] ]]
        [[ [ "HOME" ] [ [ home ] with-editor ] ]]
        [[ [ "END" ] [ [ end ] with-editor ] ]]
    ] swap add-actions ;

C: editor ( text -- )
    <gadget> over set-delegate
    <line-editor> over set-editor-line
    <caret> over set-editor-caret
    [ set-editor-text ] keep
    dup editor-actions ;

: offset>x ( gadget offset str -- x )
    head >r gadget-font r> size-string drop ;

: caret-loc ( editor -- x y )
    dup editor-line [ caret get line-text get ] bind offset>x
    0 0 3vector ;

: caret-dim ( editor -- w h )
    rect-dim { 0 1 1 } v* { 1 0 0 } v+ ;

M: editor user-input* ( ch editor -- ? )
    [ insert-char ] with-editor  t ;

M: editor pref-dim ( editor -- dim )
    dup editor-text label-size { 1 0 0 } v+ ;

M: editor layout* ( editor -- )
    dup editor-caret over caret-dim swap set-gadget-dim
    dup editor-caret swap caret-loc swap set-rect-loc ;

M: editor draw-gadget* ( editor -- )
    dup delegate draw-gadget*
    dup editor-text draw-string ;
