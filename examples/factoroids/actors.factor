USING: arrays gadgets generic hashtables io kernel math
namespaces opengl prettyprint sdl sequences threads ;
IN: factoroids

SYMBOL: player
SYMBOL: actors

: add-actor dup actors get push ;

: remove-actor actors get delete ;

: default-priority 0 ;
: projectile-priority 1 ;
: powerup-priority 1 ;

! model: see models.factor
! colors: a sequence to color parts of the model
! up: an orientation vector for rotation
! expiry: f or a time when the actor will cease to exist
! shield: f if invincible, otherwise an integer
! max-shield: shield is set to max-shield when we recharge
! priority: when two actors collide, the one with highest
! priority has its collision generic word called
! ai: object responding to ai-tick generic
TUPLE: actor model colors up expiry shield max-shield priority ai ;

C: actor ( model colors position angle size -- actor )
    [ >r <body> r> set-delegate ] keep
    [ set-actor-colors ] keep
    [ set-actor-model ] keep
    default-priority over set-actor-priority ;

GENERIC: can-collide* ( actor actor -- ? )

M: actor can-collide* ( actor actor -- ) 2drop t ;

GENERIC: collision

M: actor collision ( actor actor -- ) drop remove-actor ;

: can-collide? ( a1 a2 -- ? )
    #! If true, a collision test is performed, and a2's
    #! collision generic is called.
    2dup eq? >r over actor-priority over actor-priority > r> or
    [ 2drop f ] [ can-collide* ] if ;

: collidable ( actor -- seq )
    actors get [ can-collide? ] subset-with ;

: ?collision ( actor actor -- )
    2dup [ body-position ] 2apply v- norm 1 <=
    [ 2dup collision 2dup swap collision ] when 2drop ;

: ?collisions ( actor -- )
    dup collidable [ ?collision ] each-with ;

: ?expire-actor
    dup actor-expiry
    [ millis <= [ dup remove-actor ] when ] when* drop ;

GENERIC: ai-tick

M: f ai-tick ( actor ai -- ) 2drop ;

: actor-tick ( time actor -- )
    dup ?expire-actor dup ?collisions
    dup dup actor-ai ai-tick
    body-tick ;

: draw-actor ( actor -- )
    GL_MODELVIEW [
        dup body-position gl-translate
        dup body-angle over body-up gl-rotate
        dup body-size gl-scale
        dup actor-colors swap actor-model draw-model
    ] do-matrix ;

: spawn-big-block ( position -- )
    >r cube { { 1/2 1/2 1 1 } } r> 360 random-int { 3 3 3 } <actor> add-actor ;

: <player> ( position -- )
    >r factoroid { { 1 0 0 1 } { 2/3 0 0 1 } } r> 0 { 3/4 1/4 2 } <actor> ;

: draw-actors
    actors get [ draw-actor ] each ;

: tick-actors ( time -- )
    actors get clone [ actor-tick ] each-with ;
