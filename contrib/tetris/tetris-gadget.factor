! Copyright (C) 2006 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: kernel generic gadgets tetris tetris-gl sequences threads arrays ;
IN: tetris-gadget

TUPLE: tetris-gadget tetris quit? ;

C: tetris-gadget ( tetris -- gadget )
    [ set-tetris-gadget-tetris ] keep
    [ f swap set-tetris-gadget-quit? ] keep
    [ delegate>gadget ] keep ;

M: tetris-gadget pref-dim* drop { 200 400 } ;

M: tetris-gadget draw-gadget* ( gadget -- )
    ! TODO: show score, level, etc.
    dup rect-dim dup first swap second rot tetris-gadget-tetris draw-tetris ;

: new-tetris ( gadget -- )
    dup tetris-gadget-tetris <new-tetris> swap set-tetris-gadget-tetris ;

tetris-gadget H{
    { T{ key-down f f "ESCAPE" } [ t swap set-tetris-gadget-quit? ] }
    { T{ key-down f f "q" }      [ t swap set-tetris-gadget-quit? ] }
    { T{ key-down f f "UP" }     [ tetris-gadget-tetris rotate ] }
    { T{ key-down f f "LEFT" }   [ tetris-gadget-tetris move-left ] }
    { T{ key-down f f "RIGHT" }  [ tetris-gadget-tetris move-right ] }
    { T{ key-down f f "DOWN" }   [ tetris-gadget-tetris move-down ] }
    { T{ key-down f f " " }      [ tetris-gadget-tetris move-drop ] }
    { T{ key-down f f "p" }      [ tetris-gadget-tetris toggle-pause ] }
    { T{ key-down f f "n" }      [ new-tetris ] }
} set-gestures

: tetris-process ( gadget -- )
    dup tetris-gadget-quit? [
	10 sleep
	dup tetris-gadget-tetris maybe-update
	[ relayout-1 ] keep
	tetris-process
    ] unless ;

M: tetris-gadget graft* ( gadget -- )
    f over set-tetris-gadget-quit?
    [ tetris-process ] in-thread drop ;

M: tetris-gadget ungraft* ( gadget -- )
    t swap set-tetris-gadget-quit? ;

: tetris-window ( -- ) <default-tetris> <tetris-gadget> dup "Tetris" open-titled-window ;

