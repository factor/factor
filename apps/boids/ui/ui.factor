
USING: kernel namespaces math hashtables sequences threads
       opengl gadgets-theme gadgets
       hashtables.lib vars rewrite-closures slate handler boids ;

IN: boids.ui

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! draw-boid
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: boid-point-a ( boid -- a ) boid-pos ;

: boid-point-b ( boid -- b ) dup boid-pos swap boid-vel normalize 20 v*n v+ ;

: boid-points ( boid -- point-a point-b ) dup boid-point-a swap boid-point-b ;

: draw-line ( a b -- )
GL_LINES glBegin first2 glVertex2d first2 glVertex2d glEnd ;

: draw-boid ( boid -- ) boid-points draw-line ;

: draw-boids ( -- ) boids> [ draw-boid ] each ;

: display ( -- ) black gl-color draw-boids ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: slate

VAR: loop

: run ( -- )
slate> rect-dim >world-size
iterate-boids slate> relayout-1 1 sleep
loop> [ run ] [ ] if ;

: boids-window* ( -- )
init-variables init-world-size init-boids loop on
[ display ] closed-quot <slate> >slate

H{ } clone
T{ key-down f f "1" } [ drop init-boids ] closed-quot put-hash
<handler>

slate> over set-gadget-delegate "Boids" open-window

1000 sleep [ run ] in-thread ;

: boids-window ( -- ) [ boids-window* ] with-scope ;