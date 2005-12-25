IN: factoroids
USING: alien generic hashtables io kernel math namespaces sdl
sequences ;

: fire ( -- )
    player get [
        dup body-position over body-direction 3 v*n v+
        swap body-angle
    ] keep spawn-rocket ;

: turn-left ( ? actor -- )
    swap [ 1 ] [ dup body-angle-delta 0 < -1 0 ? ] if 30 /f
    swap set-body-angle-delta ;

: turn-right ( ? actor -- )
    swap [ -1 ] [ dup body-angle-delta 0 > 1 0 ? ] if 30 /f
    swap set-body-angle-delta ;

: forward ( ? actor -- )
    swap [ 1 ] [ dup body-acceleration 0 < -1 0 ? ] if 6000 /f
    swap set-body-acceleration ;

: backward ( ? actor -- )
    swap [ -1 ] [ dup body-acceleration 0 > 1 0 ? ] if 60000 /f
    swap set-body-acceleration ;

: binding ( binding -- { down up } )
    keyboard-event>binding H{
        [[ [ "SPACE" ] { [ fire ] [ ] } ]]
        [[ [ "LEFT" ] { [ t player get turn-left ] [ f player get turn-left ] } ]]
        [[ [ "RIGHT" ] { [ t player get turn-right ] [ f player get turn-right ] } ]]
        [[ [ "UP" ] { [ t player get forward ] [ f player get forward ] } ]]
        [[ [ "DOWN" ] { [ t player get backward ] [ f player get backward ] } ]]
    } hash ;

GENERIC: handle-event ( event -- quit? )

M: object handle-event ( event -- quit? )
  drop f ;

M: quit-event handle-event ( event -- quit? )
  drop t ;

M: key-down-event handle-event ( event -- quit? )
    binding first call f ;

M: key-up-event handle-event ( event -- quit? )
    binding second call f ;

: check-event ( -- ? )
    "event" <c-object> dup SDL_PollEvent
    [ handle-event ] [ drop f ] if ;
