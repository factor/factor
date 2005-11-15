USING: arrays gadgets generic hashtables io kernel math
namespaces opengl sdl sequences threads ;
IN: factoroids

SYMBOL: player

SYMBOL: actors

: add-actor dup actors get push ;

: remove-actor actors get delete ;

TUPLE: body position velocity acceleration size up angle angle-delta direction ;

GENERIC: tick ( time obj -- )

: update-direction ( body -- )
    dup body-angle deg>rad dup sin swap cos 0 swap 3array
    swap set-body-direction ;

C: body ( position angle size -- )
    [ set-body-size ] keep
    [ set-body-angle ] keep
    [ set-body-position ] keep
    { 0 1 0 } over set-body-up
    0 over set-body-velocity
    0 over set-body-acceleration
    0 over set-body-angle-delta
    dup update-direction ;

: scaled-angle-delta ( time body -- x ) body-angle-delta * ;

: scaled-acceleration ( time body -- x ) body-acceleration * ;

: scaled-velocity ( time body -- x )
    [ body-velocity * ] keep body-direction n*v ;

: friction 0.95 ;

: update-angle ( time body -- )
    [ [ scaled-angle-delta ] keep body-angle + ] keep
    set-body-angle ;

: update-velocity ( time body -- )
    [
        [ scaled-acceleration ] keep body-velocity + friction *
    ] keep set-body-velocity ;

: update-position ( time body -- )
    [ [ scaled-velocity ] keep body-position v+ ] keep
    set-body-position ;

M: body tick ( time body -- )
    [ update-angle ] 2keep
    [ update-velocity ] 2keep
    [ update-position ] keep
    update-direction ;

: camera-position ( player -- vec )
    dup body-position swap body-direction 3 v*n v- { 0 1 0 } v+ ;

: camera-look-at ( player -- vec )
    dup body-position swap body-direction 3 v*n v+ ;

: camera-modelview ( player -- )
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    dup camera-position
    over camera-look-at
    rot body-up
    >r >r first3 r> first3 r> first3
    gluLookAt ;

TUPLE: actor model colors up expiry ;

C: actor ( model colors position angle size -- actor )
    [ >r <body> r> set-delegate ] keep
    [ set-actor-colors ] keep
    [ set-actor-model ] keep ;

M: actor tick ( time actor -- )
    dup actor-expiry [ millis <= [ dup remove-actor ] when ] when*
    delegate tick ;

: draw-actor ( actor -- )
    GL_MODELVIEW [
        dup body-position gl-translate
        dup body-angle over body-up gl-rotate
        dup body-size gl-scale
        dup actor-colors swap actor-model draw-model
    ] do-matrix ;

: init-actors
    V{ } clone actors set
    factoroid { { 1 0 0 1 } } { 25 1/2 25 } 0 { 3/4 1/2 1/2 } <actor> player set
    player get add-actor ;

: draw-actors
    actors get [ draw-actor ] each ;

: tick-actors ( time -- )
    actors get clone [ dupd tick ] each drop ;

: add-expiring-actor ( actor time-to-live -- )
    millis + over set-actor-expiry add-actor ;

: spawn-rocket ( position angle -- rocket )
    >r >r rocket { { 1 1 0 1 } { 1 1 1 1 } } r> r> { 1/2 1/2 5 }
    <actor> 1/2000 over set-body-acceleration 1000 add-expiring-actor ;
