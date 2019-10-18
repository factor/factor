USING: arrays gadgets generic hashtables io kernel math
namespaces opengl sdl sequences styles threads ;
IN: factoroids

: draw-sky
    flat-projection
    { 0 1 0 } { { 0 0 1/3 1 } { 2/3 2/3 1 1 } } { 1 1/2 0 } gl-gradient ;

: make-sky-list ( -- id )
    GL_COMPILE [ draw-sky ] make-dlist ;

: draw-ground
    GL_DEPTH_TEST glDisable
    { 0.0 0.0 0.0 1.0 } gl-color
    GL_QUADS [
        { -1000 0 -1000 } gl-vertex
        { -1000 0 1000 } gl-vertex
        { 1000 0 1000 } gl-vertex
        { 1000 0 -1000 } gl-vertex
    ] do-state
    GL_DEPTH_TEST glEnable ;

: (grid-square) ( -- )
    GL_POINTS [
        5 [ { 1 0 0 } n*v gl-vertex ] each
        5 [ { 0 0 1 } n*v gl-vertex ] each
    ] do-state ;

: grid-square ( w h -- )
    GL_MODELVIEW [
        [ 5 * ] 2apply 0 swap glTranslated
        (grid-square)
    ] do-matrix ;

: draw-grid ( w h -- )
    { 1.0 1.0 1.0 1.0 } gl-color [ swap [ grid-square ] each-with ] each-with ;

: make-ground-list ( -- id )
    GL_COMPILE [ draw-ground 50 50 draw-grid ] make-dlist ;

SYMBOL: sky-list
SYMBOL: ground-list

: init-dlists
    make-sky-list sky-list set
    make-ground-list ground-list set ;

: draw-factoroids
    [
        factoroids-gl
        sky-list get glCallList
        world-projection
        player get camera-modelview
        ground-list get glCallList
        draw-actors
    ] with-gl-surface ;

SYMBOL: last-frame

: advance-clock ( -- time )
    millis last-frame get over last-frame set - 30 min ;

: run-game ( -- )
    advance-clock tick-actors
    draw-factoroids
    2 sleep
    check-event [ run-game ] unless ;

: init-actors
    V{ } clone actors set
    { 25 1/2 25 } <player> player set
    { 30 1/2 30 } <player> player get <follower> over set-actor-ai add-actor
    { 15 1/2 30 } <player> player get <follower> over set-actor-ai add-actor
    { 10 1/2 30 } <player> <dumbass> over set-actor-ai add-actor
    { 5 1/2 30 } <player> <dumbass> over set-actor-ai add-actor
    player get add-actor ;

: factoroids
    init-actors
    800 600 [
        init-dlists millis last-frame set run-game
    ] with-gl-screen ;
