USING: arrays gadgets generic hashtables io kernel math
namespaces opengl prettyprint sdl sequences threads ;
IN: factoroids

SYMBOL: player
SYMBOL: actors

: add-actor dup actors get push ;

: remove-actor actors get delete ;

TUPLE: actor model colors up expiry ;

C: actor ( model colors position angle size -- actor )
    [ >r <body> r> set-delegate ] keep
    [ set-actor-colors ] keep
    [ set-actor-model ] keep ;

TUPLE: projectile owner ;

C: projectile ( actor owner -- projectile )
    [ set-projectile-owner ] keep
    [ set-delegate ] keep ;

GENERIC: can-collide* ( actor actor -- ? )

M: projectile can-collide* ( actor actor -- ? )
    over projectile? >r projectile-owner eq? r> or not ;

M: actor can-collide* ( actor actor -- ) 2drop t ;

GENERIC: collision

M: actor collision ( actor actor -- ) drop remove-actor ;

: can-collide? ( actor actor -- ? )
    2dup eq? [
        2drop f
    ] [
        2dup can-collide* >r swap can-collide* r> and
    ] if ;

: collidable ( actor -- seq )
    actors get [ can-collide? ] subset-with ;

: ?collision ( actor actor -- )
    2dup [ body-position ] 2apply v- norm 2 <=
    [ 2dup collision 2dup swap collision ] when 2drop ;

: ?collisions ( actor -- )
    dup collidable [ ?collision ] each-with ;

: ?expire-actor
    dup actor-expiry
    [ millis <= [ dup remove-actor ] when ] when* drop ;

: actor-tick ( time actor -- )
    dup ?expire-actor dup ?collisions body-tick ;

: draw-actor ( actor -- )
    GL_MODELVIEW [
        dup body-position gl-translate
        dup body-angle over body-up gl-rotate
        dup body-size gl-scale
        dup actor-colors swap actor-model draw-model
    ] do-matrix ;

: spawn-big-block ( position -- )
    >r cube { { 1/2 1/2 1 1 } } r> 360 random-int { 3 3 3 } <actor> add-actor ;

: init-actors
    V{ } clone actors set
    { 15 3 25 } spawn-big-block
    { 20 2 25 } spawn-big-block
    { 30 1 20 } spawn-big-block
    { 30 1/2 15 } spawn-big-block
    factoroid { { 1 0 0 1 } { 2/3 0 0 1 } } { 25 1/2 25 } 0 { 3/4 1/4 2 } <actor> player set
    player get add-actor ;

: draw-actors
    actors get [ draw-actor ] each ;

: tick-actors ( time -- )
    actors get clone [ actor-tick ] each-with ;

: add-expiring-actor ( actor time-to-live -- )
    millis + over set-actor-expiry add-actor ;

: <rocket> ( position angle owner -- rocket )
    >r >r >r rocket { { 1 1 0 1 } { 1 1 1 1 } } r> r> { 1/2 1/2 5 }
    <actor> r> <projectile> 1/2000 over set-body-acceleration ;

: spawn-rocket ( position angle owner -- )
    <rocket> 1000 add-expiring-actor ;
