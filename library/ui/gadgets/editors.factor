! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-editors
USING: arrays freetype gadgets gadgets-labels gadgets-scrolling
gadgets-theme generic kernel math namespaces sequences strings
styles threads ;

! A caret
TUPLE: caret ;

C: caret ( -- caret )
    dup delegate>gadget
    dup caret-theme
    f over set-gadget-visible? ;

USE: line-editor

! An editor gadget wraps a line editor object and passes
! gestures to the line editor.

TUPLE: editor line caret font color ;

: scroll>caret ( editor -- ) editor-caret scroll-to ;

: with-editor ( editor quot -- )
    #! Execute a quotation in the line editor scope, then
    #! update the display.
    swap [ editor-line swap bind ] keep
    dup relayout scroll>caret ; inline

: editor-text ( editor -- text )
    editor-line [ line-text get ] bind ;

: set-editor-text ( text editor -- )
    [ set-line-text ] with-editor ;

: commit-editor-text ( editor -- line )
    #! Add current line to the history, and clear the editor.
    [ commit-history line-text get line-clear ] with-editor ;

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
        label-font* line-text get x>offset set-caret-pos
    ] with-editor ;

: click-editor ( editor -- )
    dup hand-click-rel first over set-caret-x request-focus ;

M: editor gadget-gestures
    drop H{
        { T{ button-down } [ click-editor ] }
        { T{ gain-focus } [ editor-caret show-gadget ] }
        { T{ lose-focus } [ editor-caret hide-gadget ] }
        { T{ key-down f f "BACKSPACE" } [ [ T{ char-elt } delete-prev-elt ] with-editor ] }
        { T{ key-down f f "DELETE" } [ [ T{ char-elt } delete-next-elt ] with-editor ] }
        { T{ key-down f { C+ } "BACKSPACE" } [ [ T{ word-elt } delete-prev-elt ] with-editor ] }
        { T{ key-down f { C+ } "DELETE" } [ [ T{ word-elt } delete-next-elt ] with-editor ] }
        { T{ key-down f { A+ } "BACKSPACE" } [ [ T{ document-elt } delete-prev-elt ] with-editor ] }
        { T{ key-down f { A+ } "DELETE" } [ [ T{ document-elt } delete-next-elt ] with-editor ] }
        { T{ key-down f f "LEFT" } [ [ T{ char-elt } prev-elt ] with-editor ] }
        { T{ key-down f f "RIGHT" } [ [ T{ char-elt } next-elt ] with-editor ] }
        { T{ key-down f { C+ } "LEFT" } [ [ T{ word-elt } prev-elt ] with-editor ] }
        { T{ key-down f { C+ } "RIGHT" } [ [ T{ word-elt } next-elt ] with-editor ] }
        { T{ key-down f f "HOME" } [ [ T{ document-elt } prev-elt ] with-editor ] }
        { T{ key-down f f "END" } [ [ T{ document-elt } next-elt ] with-editor ] }
        { T{ key-down f { C+ } "k" } [ [ line-clear ] with-editor ] }
        { T{ button-up f 2 } [ dup click-editor selection get paste-clipboard ] }
        { T{ paste-action } [ clipboard get paste-clipboard ] }
    } ;

: add-editor-caret 2dup set-editor-caret add-gadget ;

C: editor ( text -- )
    dup delegate>gadget
    dup editor-theme
    <line-editor> over set-editor-line
    <caret> over add-editor-caret
    [ set-editor-text ] keep ;

: offset>x ( gadget offset str -- x )
    head-slice >r label-font* r> string-width ;

: caret-loc ( editor -- x y )
    dup editor-line [ caret-pos line-text get ] bind offset>x
    0 0 3array ;

: caret-dim ( editor -- w h )
    rect-dim { 0 1 1 } v* { 1 0 0 } v+ ;

M: editor user-input* ( str editor -- ? )
    [ insert-string ] with-editor f ;

M: editor pref-dim* ( editor -- dim )
    label-size { 1 0 0 } v+ ;

M: editor layout* ( editor -- )
    dup editor-caret over caret-dim swap set-gadget-dim
    dup editor-caret swap caret-loc swap set-rect-loc ;

M: editor label-text editor-text ;

M: editor label-color editor-color ;

M: editor label-font editor-font ;

M: editor set-label-text set-editor-text ;

M: editor set-label-color set-editor-color ;

M: editor set-label-font set-editor-font ;

M: editor draw-gadget* ( editor -- ) draw-label ;

: set-possibilities ( possibilities editor -- )
    #! Set completion possibilities.
    [ possibilities set ] with-editor ;
