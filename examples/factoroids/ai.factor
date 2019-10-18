USING: arrays gadgets generic hashtables io kernel math
namespaces opengl prettyprint sdl sequences threads ;
IN: factoroids

! The approach AI moves the player towards a certain point
TUPLE: approach point ;

: turn-toward ( point actor -- )
    [ body-perp v. sgn 30 /f ] keep set-body-angle-delta ;

: approached? ( actor ai -- ? )
    approach-point >r body-position r> v- norm-sq 4 <= ;

M: approach ai-tick ( actor ai -- )
    2dup approached? [
        drop
        0 over set-body-acceleration
        0 swap set-body-angle-delta
    ] [
        approach-point over turn-toward
        drop
        ! 1 60000 /f swap set-body-acceleration
    ] if ;

! The dumbass just wanders around, approaching random points
TUPLE: dumbass ;

C: dumbass ( -- dumbass ) f <approach> over set-delegate ;

: init-dumbass ( actor ai -- )
    swap body-position
    10 random-int 5 - 10 random-int 5 - 0 3array v+
    swap set-approach-point ;

M: dumbass ai-tick ( actor ai -- )
    dup approach-point [
        2dup approached?
        [ init-dumbass ] [ delegate ai-tick ] if
    ] [
        init-dumbass
    ] if ;

! The follower follows an actor
TUPLE: follower actor ;

C: follower ( actor -- follower )
    [ set-follower-actor ] keep
    f <approach> over set-delegate ;

M: follower ai-tick ( actor ai -- )
    dup follower-actor body-position over set-approach-point
    delegate ai-tick ;
