
USING: accessors calendar kernel logging.syslog make math.parser
pg.game pg.gl sequences syslog timers ui ui.gadgets
ui.gadgets.status-bar ui.gadgets.worlds ui.gestures ui.render ;

FROM: pg.game => level>> ;
IN: pg

TUPLE: pg-gadget < gadget { pg pg } { timer } ;

: <pg-gadget> ( pg -- gadget )
    pg-gadget new swap >>pg ;

M: pg-gadget pref-dim* drop { 400 400 } ;

: update-status ( gadget -- )
    dup SYSLOG_OBJECT
    dup pg>> [
        [ "Level: " % level>> # ]
        [ " Score: " % score>> # ]
        [ paused?>> [ " (Paused)" % ] when ] tri
    ] "" make swap show-status ;

M: pg-gadget draw-gadget* ( gadget -- )
    [
        [ dim>> first2 ] [ pg>> ] bi draw-pg
    ] keep update-status ;

: new-pg ( gadget -- gadget )
    [ <new-pg> ] change-pg ;

: unless-paused ( pg quot -- )
    over pg>> paused?>> [
        2drop
    ] [
        call
    ] if ; inline

pg-gadget H{
    ! { T{ button-down f f 1 }     [ request-focus ] }
    { T{ button-down f f 1 }     [ [ pg>> rotate-right ] unless-paused ] }
    { T{ button-down f f 3 }     [ [ pg>> rotate-left ] unless-paused ] }
    { T{ key-down f f "UP" }     [ [ pg>> rotate-right ] unless-paused ] }
    { T{ key-down f f "d" }      [ [ pg>> rotate-left ] unless-paused ] }
    { T{ key-down f f "f" }      [ [ pg>> rotate-right ] unless-paused ] }
    { T{ key-down f f "e" }      [ [ pg>> rotate-left ] unless-paused ] }
    { T{ key-down f f "u" }      [ [ pg>> rotate-right ] unless-paused ] }
    { T{ key-down f f "LEFT" }   [ [ pg>> move-left ] unless-paused ] }
    { T{ key-down f f "RIGHT" }  [ [ pg>> move-right ] unless-paused ] }
    { T{ key-down f f "DOWN" }   [ [ pg>> move-down ] unless-paused ] }
    { T{ key-down f f " " }      [ [ pg>> move-drop ] unless-paused ] }
    { T{ key-down f f "p" }      [ pg>> toggle-pause ] }
    { T{ key-down f f "n" }      [ new-pg drop ] }
} set-gestures

: tick ( gadget -- )
    [ pg>> ?update ] [ relayout-1 ] bi ;

M: pg-gadget graft* ( gadget -- )
    [ [ tick ] curry 100 milliseconds every ] keep timer<< ;

M: pg-gadget ungraft* ( gadget -- )
    [ stop-timer f ] change-timer drop ;

: pg-window ( -- )
    [
        <default-pg> <pg-gadget>
        "Pg" open-status-window
    ] with-ui ;

MAIN: pg-window
