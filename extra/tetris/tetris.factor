! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alarms arrays calendar kernel make math math.rectangles math.parser namespaces sequences system tetris.game tetris.gl ui.gadgets ui.gadgets.labels ui.gadgets.worlds ui.gadgets.status-bar ui.gestures ui.render ui ;
FROM: tetris.game => level>> ;
IN: tetris

TUPLE: tetris-gadget < gadget { tetris tetris } { alarm } ;

: <tetris-gadget> ( tetris -- gadget )
    tetris-gadget new swap >>tetris ;

M: tetris-gadget pref-dim* drop { 200 400 } ;

: update-status ( gadget -- )
    dup tetris>> [
        [ "Level: " % level>> # ]
        [ " Score: " % score>> # ]
        [ paused?>> [ " (Paused)" % ] when ] tri
    ] "" make swap show-status ;

M: tetris-gadget draw-gadget* ( gadget -- )
    [
        [ dim>> first2 ] [ tetris>> ] bi draw-tetris
    ] keep update-status ;

: new-tetris ( gadget -- gadget )
    [ <new-tetris> ] change-tetris ;

: unless-paused ( tetris quot -- )
    over tetris>> paused?>> [
        2drop
    ] [
        call
    ] if ; inline

tetris-gadget H{
    { T{ button-down f f 1 }     [ request-focus ] }
    { T{ key-down f f "UP" }     [ [ tetris>> rotate-right ] unless-paused ] }
    { T{ key-down f f "d" }      [ [ tetris>> rotate-left ] unless-paused ] }
    { T{ key-down f f "f" }      [ [ tetris>> rotate-right ] unless-paused ] }
    { T{ key-down f f "e" }      [ [ tetris>> rotate-left ] unless-paused ] }
    { T{ key-down f f "u" }      [ [ tetris>> rotate-right ] unless-paused ] }
    { T{ key-down f f "LEFT" }   [ [ tetris>> move-left ] unless-paused ] }
    { T{ key-down f f "RIGHT" }  [ [ tetris>> move-right ] unless-paused ] }
    { T{ key-down f f "DOWN" }   [ [ tetris>> move-down ] unless-paused ] }
    { T{ key-down f f " " }      [ [ tetris>> move-drop ] unless-paused ] }
    { T{ key-down f f "p" }      [ tetris>> toggle-pause ] }
    { T{ key-down f f "n" }      [ new-tetris drop ] }
} set-gestures

: tick ( gadget -- )
    [ tetris>> ?update ] [ relayout-1 ] bi ;

M: tetris-gadget graft* ( gadget -- )
    [ [ tick ] curry 100 milliseconds every ] keep alarm<< ;

M: tetris-gadget ungraft* ( gadget -- )
    [ stop-alarm f ] change-alarm drop ;

: tetris-window ( -- ) 
    [
        <default-tetris> <tetris-gadget>
        "Tetris" open-status-window
    ] with-ui ;

MAIN: tetris-window
