! Currently the plugin doesn't handle GENERIC: and M:, so we
! disable the parser. too many errors :sidekick.parser=none:
IN: factoroids

USE: combinators
USE: errors
USE: hashtables
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: oop
USE: random
USE: sdl
USE: stack

! Game objects
GENERIC: draw ( -- )
#! Draw the actor.

GENERIC: tick ( -- ? )
#! Return f if the actor should be removed.

! Actor attributes
SYMBOL: x
SYMBOL: y
SYMBOL: radius
SYMBOL: len
SYMBOL: dx
SYMBOL: dy
SYMBOL: color

! The list of actors is divided into layers. Note that an
! actor's tick method can only add actors to layers other than
! the actor's layer. The player layer only has one actor.
SYMBOL: player
SYMBOL: enemies
SYMBOL: player-shots
SYMBOL: enemy-shots

: player-actor ( -- actor )
    player get car ;

: y-in-screen? ( -- ? ) y get 0 height get between? ;
: x-in-screen? ( -- ? ) x get 0 width get between? ;

: in-screen? ( -- ? )
    #! Is the current actor in the screen?
    x-in-screen? y-in-screen? and ;

: velocity ( -- )
    #! Add velocity vector to current actor's position vector.
    dx get x +@  dy get y +@ ;

: actor-tick ( actor -- ? )
    #! Default tick behavior of an actor. Move actor according
    #! to velocity, and remove it if it is not in the screen.
    #! Player's ship always returns t.
    [
        velocity
        namespace player-actor = [ t ] [ in-screen? ] ifte
    ] bind ;

: screen-xy ( -- x y )
    x get >fixnum y get >fixnum ;

: actor-xy ( actor -- )
    #! Copy actor's x/y co-ordinates to this namespace.
    [ x get y get ] bind y set x set ;

! The player's ship
TRAITS: ship
M: ship draw ( -- )
    [
        surface get screen-xy radius get color get
        filledCircleColor
    ] bind ;M

M: ship tick ( -- ) actor-tick ;M

! Projectiles
TRAITS: plasma
M: plasma draw ( -- )
    [
        surface get screen-xy dup len get + color get
        vlineColor
    ] bind ;M

M: plasma tick ( -- ) actor-tick ;M

: make-plasma ( actor dy -- plasma )
    <plasma> [
        dy set
        0 dx set
        actor-xy
        blue color set
        10 len set
    ] extend ;

: player-fire ( -- )
    player-actor -6 make-plasma player-shots cons@ ;

: enemy-fire ( actor -- )
    5 make-plasma enemy-shots cons@ ;

! Background of stars
TRAITS: particle

M: particle draw ( -- )
    [ surface get screen-xy color get pixelColor ] bind ;M

: wrap ( -- )
    #! If current actor has gone beyond screen bounds, move it
    #! back.
    width get x rem@  height get y rem@ ;

M: particle tick ( -- )
    [ velocity wrap t ] bind ;M

SYMBOL: stars
: star-count 100 ;

: random-x 0 width get random-int ;
: random-y 0 height get random-int ;
: random-byte 0 255 random-int ;
: random-color random-byte random-byte random-byte 255 rgba ;

: random-star ( -- star )
    <particle> [
        random-x x set
        random-y y set
        random-color color set
        2 4 random-int dy set
        0 dx set
    ] extend ;

: init-stars ( -- )
    [ ] star-count [ random-star swons ] times stars set ;

: draw-stars ( -- )
    stars get [ draw ] each ;

: tick-stars ( -- )
    stars get [ tick drop ] each ;

! Enemies
: enemy-chance 50 ;

TRAITS: enemy
M: enemy draw ( -- )
    [
        surface get screen-xy radius get color get
        filledCircleColor
    ] bind ;M

: attack-chance 30 ;

: attack ( -- ) attack-chance chance [ enemy-fire ] when ;

SYMBOL: wiggle-x

: wiggle ( -- )
    #! Wiggle from left to right.
    -3 3 random-int wiggle-x +@
    wiggle-x get sgn dx set ;

M: enemy tick ( -- )
    dup attack [ wiggle velocity y-in-screen? ] bind ;M

: spawn-enemy ( -- )
    <enemy> [
        10 y set
        random-x x set
        red color set
        0 wiggle-x set
        0 dx set
        1 dy set
        10 radius set
    ] extend ;

: spawn-enemies ( -- )
    enemy-chance chance [ spawn-enemy enemies cons@ ] when ;

! Event handling
SYMBOL: event

: mouse-motion-event ( event -- )
    motion-event-x player-actor [ x set ] bind ; 

: mouse-down-event ( event -- )
    drop player-fire ;

: handle-event ( event -- ? )
    #! Return if we should continue or stop.
    [
        [ event-type SDL_MOUSEBUTTONDOWN = ] [ mouse-down-event t ]
        [ event-type SDL_MOUSEMOTION = ] [ mouse-motion-event t ]
        [ event-type SDL_QUIT = ] [ drop f ]
        [ drop t ] [ drop t ]
    ] cond ;

: check-event ( -- ? )
    #! Check if there is a pending event.
    #! Return if we should continue or stop.
    event get dup SDL_PollEvent [
        handle-event [ check-event ] [ f ] ifte
    ] [
        drop t
    ] ifte ;

! Game loop
: init-player ( -- )
    <ship> [
        height get 50 - y set
        width get 2 /i x set
        white color set
        10 radius set
        0 dx set
        0 dy set
    ] extend unit player set ;

: init-events ( -- ) <event> event set ;

: init-game ( -- )
    #! Init game objects.
    init-player init-stars init-events ;

: each-layer ( quot -- )
    #! Apply quotation to each layer.
    [ enemies enemy-shots player player-shots ] swap each ;

: draw-layer ( layer -- )
    get [ draw ] each ;

: draw-actors ( -- )
    [ draw-layer ] each-layer ;

: tick-layer ( layer -- )
    dup get [ tick ] subset put ;

: tick-actors ( -- )
    #! Advance game state by one frame.
    [ tick-layer ] each-layer ;

: render ( -- )
    #! Draw the scene.
    [
        black clear-surface
        draw-stars
        draw-actors
    ] with-surface ;

: advance ( -- )
    #! Advance game state by one frame.
    tick-actors tick-stars spawn-enemies ;

: game-loop ( -- )
    #! Render, advance game state, repeat.
    render advance check-event [ game-loop ] when ;

: factoroids ( -- )
    #! Main word.
    640 480 32 SDL_HWSURFACE [
        "Factoroids" "Factoroids" SDL_WM_SetCaption
        init-game game-loop
    ] with-screen ;

factoroids
