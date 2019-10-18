! Copyright (C) 2006, 2007 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel generic gadgets gadgets-labels tetris tetris-gl sequences threads arrays math namespaces timers ;
IN: tetris-gadget

TUPLE: tetris-gadget tetris ;

C: tetris-gadget ( tetris -- gadget )
    [ set-tetris-gadget-tetris ] keep [ delegate>gadget ] keep ;

M: tetris-gadget pref-dim* drop { 200 400 } ;

: update-status ( gadget -- )
    dup tetris-gadget-tetris [
        "Level: " % dup tetris-level number>string %
        " Score: " % tetris-score number>string %
    ] "" make swap show-status ;

M: tetris-gadget draw-gadget* ( gadget -- )
    [
        dup rect-dim dup first swap second rot tetris-gadget-tetris draw-tetris
    ] keep update-status ;

: new-tetris ( gadget -- )
    dup tetris-gadget-tetris <new-tetris> swap set-tetris-gadget-tetris ;

tetris-gadget H{
    { T{ key-down f f "UP" }     [ tetris-gadget-tetris rotate-right ] }
    { T{ key-down f f "d" }      [ tetris-gadget-tetris rotate-left ] }
    { T{ key-down f f "f" }      [ tetris-gadget-tetris rotate-right ] }
    { T{ key-down f f "e" }      [ tetris-gadget-tetris rotate-left ] } ! dvorak d
    { T{ key-down f f "u" }      [ tetris-gadget-tetris rotate-right ] } ! dvorak f
    { T{ key-down f f "LEFT" }   [ tetris-gadget-tetris move-left ] }
    { T{ key-down f f "RIGHT" }  [ tetris-gadget-tetris move-right ] }
    { T{ key-down f f "DOWN" }   [ tetris-gadget-tetris move-down ] }
    { T{ key-down f f " " }      [ tetris-gadget-tetris move-drop ] }
    { T{ key-down f f "p" }      [ tetris-gadget-tetris toggle-pause ] }
    { T{ key-down f f "n" }      [ new-tetris ] }
} set-gestures

M: tetris-gadget tick ( object -- )
    dup tetris-gadget-tetris maybe-update relayout-1 ;

M: tetris-gadget graft* ( gadget -- )
    100 1 add-timer ;

M: tetris-gadget ungraft* ( gadget -- )
    remove-timer ;

: tetris-window ( -- ) <default-tetris> <tetris-gadget> "Tetris" open-window ;

