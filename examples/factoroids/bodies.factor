USING: arrays gadgets generic hashtables io kernel math
namespaces opengl sdl sequences threads ;
IN: factoroids

TUPLE: body position velocity acceleration size up angle
angle-delta direction ;

GENERIC: tick ( time obj -- )

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

: update-direction ( body -- )
    dup body-angle deg>rad dup sin swap cos 0 swap 3array
    swap set-body-direction ;

: body-tick ( time body -- )
    [ update-angle ] 2keep
    [ update-velocity ] 2keep
    [ update-position ] keep
    update-direction ;

: camera-position ( player -- vec )
    dup body-position swap body-direction 3 v*n v- { 0 1 0 } v+ ;

: camera-look-at ( player -- vec )
    dup body-position swap body-direction 2 v*n v+ ;

: camera-modelview ( player -- )
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    dup camera-position
    over camera-look-at
    rot body-up
    >r >r first3 r> first3 r> first3
    gluLookAt ;

: body-perp ( v -- v )
    #! Return a vector perpendicular to the direction vector
    #! and also perpendicular to the y axis.
    body-direction first3 swap >r neg swap r> swap 3array ;
