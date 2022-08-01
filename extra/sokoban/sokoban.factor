! Copyright (C) 2006, 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors timers arrays calendar destructors kernel make math math.rectangles
math.parser namespaces sequences system sokoban.game sokoban.layout sokoban.gl sokoban.sound ui.gadgets
ui.gadgets.labels ui.gadgets.worlds ui.gadgets.status-bar ui.gestures
ui.render ui ;
IN: sokoban

TUPLE: sokoban-gadget < gadget { sokoban sokoban } { timer } { window-dims array initial: { 700 800 } } ;

: <sokoban-gadget> ( sokoban -- gadget )
    create-engine >>engine
    sokoban-gadget new swap >>sokoban ;

:: get-dim ( sokoban level -- level w h )
    ! Look for maximum height and width of wall layout to determine size of board
    level component get first states>> nth :> new_board
    level
    new_board [ first ] map supremum 1 +
    new_board [ second ] map supremum 1 + ;

: new-sokoban ( gadget -- gadget )
    ! Restarts sokoban without changing levels
    dup sokoban>> engine>> swap
    [ dup level>> get-dim <sokoban> ] change-sokoban
    swap over sokoban>> swap >>engine >>sokoban ;

:: window-size ( sokoban -- window-size )
    sokoban level>> :> level
    sokoban level get-dim :> ( lev w h )
    100 w * :> xpix
    100 h * :> ypix
    { xpix ypix } ;


: update-sokoban ( gadget -- gadget )
    ! Changes to the next level of sokoban
    dup sokoban>> engine>> swap
    [ dup level>> 1 + get-dim <sokoban> ] change-sokoban 
    dup sokoban>> window-size >>window-dims 
    swap over sokoban>> swap >>engine >>sokoban ;

M: sokoban-gadget pref-dim* ( gadget -- dim ) 
    sokoban>> window-size ;
    ! drop { 700 800 } ; ! needs to be changed as well

: update-status ( gadget -- )
    dup sokoban>> [
        [ "Level: " % level>> # ]
        [ paused?>> [ " (Paused)" % ] when ] bi
    ] "" make swap show-status ;

M: sokoban-gadget draw-gadget* ( gadget -- )
    [
        [ dim>> first2 ] [ sokoban>> ] bi draw-sokoban
    ] keep update-status ;

: unless-paused ( sokoban quot -- )
    over sokoban>> paused?>> [
        2drop
    ] [
        call
    ] if ; inline

sokoban-gadget H{
    { T{ button-down f f 1 }     [ request-focus ] }
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
        relayout-window
    ] [ 
        relayout-1
    ] if 
     ;

M: sokoban-gadget graft* ( gadget -- )
    [ [ tick ] curry 100 milliseconds every ] keep timer<< ;

M: sokoban-gadget ungraft* ( gadget -- )
    dup sokoban>> engine>> dispose
    [ stop-timer f ] change-timer drop ;

: sokoban-window ( -- )
    [
        <default-sokoban> <sokoban-gadget>
        "sokoban" open-status-window
    ] with-ui ;

MAIN: sokoban-window
