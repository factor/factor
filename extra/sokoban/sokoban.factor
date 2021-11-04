! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors timers arrays calendar kernel make math math.rectangles
math.parser namespaces sequences system sokoban.game sokoban.gl ui.gadgets
ui.gadgets.labels ui.gadgets.worlds ui.gadgets.status-bar ui.gestures
ui.render ui ;
IN: sokoban

TUPLE: sokoban-gadget < gadget { sokoban sokoban } { timer } ;

: <sokoban-gadget> ( sokoban -- gadget )
    sokoban-gadget new swap >>sokoban ;

M: sokoban-gadget pref-dim* drop { 700 800 } ; ! needs to be changed as well

: update-status ( gadget -- )
    dup sokoban>> [
        [ "Level: " % level # ]
        [ " Score: " % score>> # ]
        [ paused?>> [ " (Paused)" % ] when ] tri
    ] "" make swap show-status ;

M: sokoban-gadget draw-gadget* ( gadget -- )
    [
        [ dim>> first2 ] [ sokoban>> ] bi draw-sokoban
    ] keep update-status ;

: new-sokoban ( gadget -- gadget )
    [ <new-sokoban> ] change-sokoban ;

: unless-paused ( sokoban quot -- )
    over sokoban>> paused?>> [
        2drop
    ] [
        call
    ] if ; inline

sokoban-gadget H{
    { T{ button-down f f 1 }     [ request-focus ] }
    { T{ key-down f f "d" }      [ [ sokoban>> rotate-left ] unless-paused ] }
    { T{ key-down f f "f" }      [ [ sokoban>> rotate-right ] unless-paused ] }
    { T{ key-down f f "e" }      [ [ sokoban>> rotate-left ] unless-paused ] }
    { T{ key-down f f "u" }      [ [ sokoban>> rotate-right ] unless-paused ] }
    { T{ key-down f f "UP" }     [ [ sokoban>> move-up ] unless-paused ] }
    { T{ key-down f f "LEFT" }   [ [ sokoban>> move-left ] unless-paused ] }
    { T{ key-down f f "RIGHT" }  [ [ sokoban>> move-right ] unless-paused ] }
    { T{ key-down f f "DOWN" }   [ [ sokoban>> move-down ] unless-paused ] }
    { T{ key-down f f " " }      [ [ sokoban>> add-walls ] unless-paused ] }
    { T{ key-down f f "p" }      [ sokoban>> toggle-pause ] }
    { T{ key-down f f "n" }      [ new-sokoban drop ] }
} set-gestures

: tick ( gadget -- )
    [ sokoban>> ?update ] [ relayout-1 ] bi ;

M: sokoban-gadget graft* ( gadget -- )
    [ [ tick ] curry 100 milliseconds every ] keep timer<< ;

M: sokoban-gadget ungraft* ( gadget -- )
    [ stop-timer f ] change-timer drop ;

: sokoban-window ( -- )
    [
        <default-sokoban> <sokoban-gadget>
        "sokoban" open-status-window
    ] with-ui ;

MAIN: sokoban-window