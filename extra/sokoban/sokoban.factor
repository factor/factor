! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors timers arrays calendar kernel make math math.rectangles
math.parser namespaces sequences system sokoban.game sokoban.tetromino sokoban.gl ui.gadgets
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

:: get-dim ( sokoban level -- level w h )
    level component get first states>> nth :> new_board
    level
    new_board [ first ] map supremum 1 +
    new_board [ second ] map supremum 1 + ;

: new-sokoban ( gadget -- gadget )
    [ dup level>> get-dim <sokoban> ] change-sokoban ;

: update-sokoban ( gadget -- gadget )
    [ dup level>> 1 + get-dim <sokoban> ] change-sokoban ;

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
    { T{ key-down f f "p" }      [ sokoban>> toggle-pause ] }
    { T{ key-down f f "n" }      [ new-sokoban drop ] }
} set-gestures

: tick ( gadget -- )
    dup sokoban>> update-level? [
        update-sokoban
    ] [ ] if 
    relayout-1 ;

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