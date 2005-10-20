! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-editors
USING: arrays freetype gadgets gadgets-labels gadgets-layouts
gadgets-menus gadgets-scrolling gadgets-theme generic kernel
lists math namespaces sequences strings styles threads ;

! A blinking caret
TUPLE: caret ;

C: caret ( -- caret )
    dup delegate>gadget dup caret-theme ;

M: caret tick ( ms caret -- ) nip toggle-visible ;

: caret-blink 500 ;

: add-caret ( caret parent -- )
    dupd add-gadget caret-blink add-timer ;

: unparent-caret ( caret -- )
    dup remove-timer unparent ;

: reset-caret ( caret -- )
    dup restart-timer show-gadget ;

USE: line-editor

! An editor gadget wraps a line editor object and passes
! gestures to the line editor.

TUPLE: editor line caret ;

: scroll>caret ( editor -- ) editor-caret scroll-to ;

: with-editor ( editor quot -- )
    #! Execute a quotation in the line editor scope, then
    #! update the display.
    swap [ editor-line swap bind ] keep
    dup editor-caret reset-caret
    dup relayout scroll>caret ; inline

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
    >array [ char-width ] map-with
    dup 0 [ + ] accumulate swap 2 v/n v+ ;

: x>offset ( x font str -- offset )
    dup >r run-char-widths [ <= ] find-with drop dup -1 =
    [ drop r> length ] [ r> drop ] if ;

: set-caret-x ( x editor -- )
    #! Move the caret to a clicked location.
    dup [
        gadget-font line-text get x>offset set-caret-pos
    ] with-editor ;

: click-editor ( editor -- )
    dup hand get relative first over set-caret-x request-focus ;

: popup-location ( editor -- loc )
    dup screen-loc swap editor-caret rect-extent nip v+ ;

: <completion-item> ( completion editor -- menu-item )
    dupd [ [ complete ] with-editor drop ] curry curry cons ;

: <completion-menu> ( editor completions -- menu )
    [ swap <completion-item> ] map-with <menu> ;

: completion-menu ( editor completions -- )
    over >r <completion-menu> r> popup-location show-menu ;

: do-completion-1 ( editor completions -- )
    swap [ first complete ] with-editor ;

: do-completion ( editor -- )
    dup [ completions ] with-editor @{
        @{ [ dup empty? ] [ 2drop ] }@
        @{ [ dup length 1 = ] [ do-completion-1 ] }@
        @{ [ t ] [ completion-menu ] }@
    }@ cond ;

: editor-actions ( editor -- )
    {{
        [[ [ gain-focus ] [ focus-editor ] ]]
        [[ [ lose-focus ] [ unfocus-editor ] ]]
        [[ [ button-down 1 ] [ click-editor ] ]]
        [[ [ "BACKSPACE" ] [ [ << char-elt >> delete-prev-elt ] with-editor ] ]]
        [[ [ "DELETE" ] [ [ << char-elt >> delete-next-elt ] with-editor ] ]]
        [[ [ "CTRL" "BACKSPACE" ] [ [ << word-elt >> delete-prev-elt ] with-editor ] ]]
        [[ [ "CTRL" "DELETE" ] [ [ << word-elt >> delete-next-elt ] with-editor ] ]]
        [[ [ "ALT" "BACKSPACE" ] [ [ << document-elt >> delete-prev-elt ] with-editor ] ]]
        [[ [ "ALT" "DELETE" ] [ [ << document-elt >> delete-next-elt ] with-editor ] ]]
        [[ [ "LEFT" ] [ [ << char-elt >> prev-elt ] with-editor ] ]]
        [[ [ "RIGHT" ] [ [ << char-elt >> next-elt ] with-editor ] ]]
        [[ [ "CTRL" "LEFT" ] [ [ << word-elt >> prev-elt ] with-editor ] ]]
        [[ [ "CTRL" "RIGHT" ] [ [ << word-elt >> next-elt ] with-editor ] ]]
        [[ [ "HOME" ] [ [ << document-elt >> prev-elt ] with-editor ] ]]
        [[ [ "END" ] [ [ << document-elt >> next-elt ] with-editor ] ]]
        [[ [ "CTRL" "k" ] [ [ line-clear ] with-editor ] ]]
        [[ [ "TAB" ] [ do-completion ] ]]
    }} add-actions ;

C: editor ( text -- )
    dup delegate>gadget
    dup editor-theme
    <line-editor> over set-editor-line
    <caret> over set-editor-caret
    [ set-editor-text ] keep
    dup editor-actions ;

: offset>x ( gadget offset str -- x )
    head-slice >r gadget-font r> string-width ;

: caret-loc ( editor -- x y )
    dup editor-line [ caret-pos line-text get ] bind offset>x
    0 0 3array ;

: caret-dim ( editor -- w h )
    rect-dim @{ 0 1 1 }@ v* @{ 1 0 0 }@ v+ ;

M: editor user-input* ( ch editor -- ? )
    [ insert-char ] with-editor f ;

M: editor pref-dim ( editor -- dim )
    label-size @{ 1 0 0 }@ v+ ;

M: editor layout* ( editor -- )
    dup editor-caret over caret-dim swap set-gadget-dim
    dup editor-caret swap caret-loc swap set-rect-loc ;

M: editor label-text ( editor -- string )
    editor-text ;

M: editor draw-gadget* ( editor -- )
    dup delegate draw-gadget* draw-label ;

: set-possibilities ( possibilities editor -- )
    #! Set completion possibilities.
    [ possibilities set ] with-editor ;
