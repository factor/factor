! A simple space shooter.
!
! To play the game:
!
! ./f factor.image -libraries:sdl=libSDL.so -libraries:sdl-gfx=libSDL_gfx.so
!
! "examples/oop.factor" run-file
! "examples/factoroids.factor" run-file

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
USE: sdl-event
USE: sdl-gfx
USE: sdl-keysym
USE: sdl-video
USE: stack

! Game objects
GENERIC: draw ( actor -- )
#! Draw the actor.

GENERIC: tick ( actor -- ? )
#! Return f if the actor should be removed.

GENERIC: collide ( actor1 actor2 -- )
#! Handle collision of two actors.

! Actor attributes
SYMBOL: position
SYMBOL: radius
SYMBOL: len
SYMBOL: velocity
SYMBOL: color
SYMBOL: active

! The list of actors is divided into layers. Note that an
! actor's tick method can only add actors to layers other than
! the actor's layer. The player layer only has one actor.
SYMBOL: player
SYMBOL: enemies
SYMBOL: player-shots
SYMBOL: enemy-shots

: player-actor ( -- player )
    player get dup [ car ] when ;

: x-in-screen? ( x -- ? ) 0 width get between? ;
: y-in-screen? ( y -- ? ) 0 height get between? ;

: in-screen? ( actor -- ? )
    #! Is the actor in the screen?
    [
        position get >rect y-in-screen? swap x-in-screen? and
    ] bind ;

: move ( -- )
    #! Add velocity vector to current actor's position vector.
    velocity get position +@ ;

: active? ( actor -- ? )
    #! Push f if the actor should be removed.
    [ active get ] bind ;

: deactivate ( actor -- )
    #! Cause the actor to be removed in the next tick cycle.
    [ active off ] bind ;

: screen-xy ( -- x y )
    position get >rect swap >fixnum swap >fixnum ;

: actor-xy ( actor -- )
    #! Copy actor's x/y co-ordinates to this namespace.
    [ position get ] bind position set ;

! Collision detection
: distance ( actor1 actor2 -- x )
    #! Distance between two actor's positions.
    >r [ position get ] bind r> [ position get ] bind - abs ;

: min-distance ( actor1 actor2 -- )
    #! Minimum distance before there is a collision.
    >r [ radius get ] bind r> [ radius get ] bind + ;

: collision? ( actor1 actor2 -- ? )
    2dup distance >r min-distance r> > ;

: check-collision ( actor1 actor2 -- )
    2dup collision? [ collide ] [ 2drop ] ifte ;

: layer-actor-collision ( actor layer -- )
    #! The layer is a list of actors.
    [ dupd check-collision ] each drop ;

: layer-collision ( layer layer -- )
    swap [ over layer-actor-collision ] each drop ;

: collisions ( -- )
    #! Only collisions we allow are player colliding with an
    #! enemy shot, and player shot colliding with enemy.
    player get enemy-shots get layer-collision
    enemies get player-shots get layer-collision ;

! The player's ship

TRAITS: ship
M: ship draw ( actor -- )
    [
        surface get screen-xy radius get color get
        filledCircleColor
    ] bind ;M

M: ship tick ( actor -- ? ) dup [ move ] bind active? ;M

: make-ship ( -- ship )
    <ship> [
        width get 2 /i  height get 50 - rect> position set
        white color set
        10 radius set
        0 velocity set
        active on
    ] extend unit ;

! Projectiles
TRAITS: plasma
M: plasma draw ( actor -- )
    [
        surface get screen-xy dup len get + color get
        vlineColor
    ] bind ;M

M: plasma tick ( actor -- ? )
    dup [ move ] bind dup in-screen? swap active? and ;M

M: plasma collide ( actor1 actor2 -- )
    #! Remove the other actor.
    deactivate deactivate ;M

: make-plasma ( actor dy -- plasma )
    <plasma> [
        velocity set
        actor-xy
        blue color set
        10 len set
        5 radius set
        active on
    ] extend ;

: player-fire ( -- )
    #! Do nothing if player is dead.
    player-actor [
        #{ 0 -6 } make-plasma player-shots cons@
    ] when* ;

: enemy-fire ( actor -- )
    #{ 0 5 } make-plasma enemy-shots cons@ ;

! Background of stars
TRAITS: particle

M: particle draw ( actor -- )
    [ surface get screen-xy color get pixelColor ] bind ;M

: wrap ( -- )
    #! If current actor has gone beyond screen bounds, move it
    #! back.
    position get >rect
    swap >fixnum width get rem
    swap >fixnum height get rem
    rect> position set ;

M: particle tick ( actor -- )
    [ move wrap t ] bind ;M

SYMBOL: stars
: star-count 100 ;

: random-x 0 width get random-int ;
: random-y 0 height get random-int ;
: random-position random-x random-y rect> ;
: random-byte 0 255 random-int ;
: random-color random-byte random-byte random-byte 255 rgba ;
: random-velocity 0 10 20 random-int 10 /f rect> ;

: random-star ( -- star )
    <particle> [
        random-position position set
        random-color color set
        random-velocity velocity set
        active on
    ] extend ;

: init-stars ( -- )
    #! Generate random background of scrolling stars.
    [ ] star-count [ random-star swons ] times stars set ;

: draw-stars ( -- )
    stars get [ draw ] each ;

: tick-stars ( -- )
    stars get [ tick drop ] each ;

! Enemies
: enemy-chance 50 ;

TRAITS: enemy
M: enemy draw ( actor -- )
    [
        surface get screen-xy radius get color get
        filledCircleColor
    ] bind ;M

: attack-chance 30 ;

: attack ( actor -- )
    #! Fire a shot some of the time.
    attack-chance chance [ enemy-fire ] [ drop ] ifte ;

SYMBOL: wiggle-x

: wiggle ( -- )
    #! Wiggle from left to right.
    -3 3 random-int wiggle-x +@
    wiggle-x get sgn 1 rect> velocity set ;

M: enemy tick ( actor -- )
    dup attack
    dup [ wiggle move position get imaginary ] bind
    y-in-screen? swap active? and ;M

: spawn-enemy ( -- )
    <enemy> [
        random-x 10 rect> position set
        red color set
        0 wiggle-x set
        0 velocity set
        10 radius set
        active on
    ] extend ;

: spawn-enemies ( -- )
    enemy-chance chance [ spawn-enemy enemies cons@ ] when ;

! Event handling
SYMBOL: event

: mouse-motion-event ( event -- )
    motion-event-x player-actor dup [
        [ position get imaginary rect> position set ] bind
    ] [
        2drop
    ] ifte ;

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
: init-game ( -- )
    #! Init game objects.
    init-stars
    make-ship player set
    <event> event set ;

: each-layer ( quot -- )
    #! Apply quotation to each layer.
    [ enemies enemy-shots player player-shots ] swap each ;

: draw-actors ( -- )
    [ get [ draw ] each ] each-layer ;

: tick-actors ( -- )
    #! Advance game state by one frame. Actors whose tick word
    #! returns f are removed from the layer.
    [ dup get [ tick ] subset put ] each-layer ;

: render ( -- )
    #! Draw the scene.
    [ black clear-surface draw-stars draw-actors ] with-surface ;

: advance ( -- )
    #! Advance game state by one frame.
    tick-actors tick-stars spawn-enemies ;

: game-loop ( -- )
    #! Render, advance game state, repeat.
    render advance collisions check-event [ game-loop ] when ;

: factoroids ( -- )
    #! Main word.
    640 480 32 SDL_HWSURFACE [
        "Factoroids" "Factoroids" SDL_WM_SetCaption
        init-game game-loop
    ] with-screen ;

factoroids

! Currently the plugin doesn't handle GENERIC: and M:, so we
! disable the parser. too many errors :sidekick.parser=factor:
