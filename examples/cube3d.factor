! Rotating 3d cube.
!
! To run this code, bootstrap Factor like so:
!
! ./f boot.image.le32
!     -libraries:sdl:name=libSDL.so
!     -libraries:sdl-gfx:name=libSDL_gfx.so
!
! (But all on one line)
!
! Then, start Factor as usual (./f factor.image) and enter this
! at the listener:
!
! "examples/cube3d.factor" run-file

IN: cube3d
USING: compiler kernel lists math matrices namespaces sdl
sequences ;

! A 2x2x2 cube.
: points
    [
        [[ { 1 1 1 } { 1 1 -1 } ]]
        [[ { 1 1 1 } { 1 -1 1 } ]]
        [[ { 1 1 1 } { -1 1 1 } ]]
        [[ { -1 1 1 } { -1 1 -1 } ]]
        [[ { -1 1 1 } { -1 -1 1 } ]]
        [[ { 1 -1 1 } { -1 -1 1 } ]]
        [[ { 1 -1 1 } { 1 -1 -1 } ]]
        [[ { 1 1 -1 } { -1 1 -1 } ]]
        [[ { 1 1 -1 } { 1 -1 -1 } ]]
        [[ { -1 1 -1 } { -1 -1 -1 } ]]
        [[ { -1 -1 1 } { -1 -1 -1 } ]]
        [[ { 1 -1 -1 } { -1 -1 -1 } ]]
    ] ;

: 3vector ( x y z -- { x y z } )
    [ rot , swap , , ] make-vector ;

: rotation-matrix-1 ( theta -- )
    [
        dup cos ,     dup sin , 0 ,
        dup sin neg , cos ,     0 ,
        0 ,           0 ,       1 ,
    ] make-vector 3 3 rot <matrix> ;

: rotation-matrix-2 ( theta -- )
    [
        1 , 0 ,           0 ,
        0 , dup cos ,     dup sin ,
        0 , dup sin neg , cos ,
    ] make-vector 3 3 rot <matrix> ;

: rotation-matrix-3 ( theta -- )
    [
        dup cos , 0 , dup sin neg ,
        0 ,       1 , 0 ,
        dup sin , 0 , cos ,
    ] make-vector 3 3 rot <matrix> ;

SYMBOL: theta
SYMBOL: phi
SYMBOL: psi

SYMBOL: rotation

: update-matrix
    theta get rotation-matrix-1
    phi get rotation-matrix-2 m.
    psi get rotation-matrix-3 m. rotation set ;

: >scene ( { x y z } -- { x y z } )
    rotation get swap m.v ;

: >screen ( { x y z } -- x y )
    200 swap n*v width get 2 / height get 2 / 0 3vector v+
    0 over nth 1 rot nth ;

: redraw ( -- )
    surface get 0 0 width get height get black rgb boxColor
    points [
        uncons >r >r surface get
        r> >scene >screen
        r> >scene >screen
        red rgb lineColor
    ] each ;

: event-loop ( event -- )
    theta [ 0.01 + ] change
    phi [ 0.02 + ] change
    psi [ 0.03 + ] change
    update-matrix
    [ redraw ] with-surface
    dup SDL_PollEvent [
        dup event-type SDL_QUIT = [
            drop
        ] [
            event-loop
        ] ifte
    ] [
        event-loop
    ] ifte ;

: cube3d ( -- )
    800 600 0 SDL_HWSURFACE [
        0 theta set
        0 phi set
        0 psi set
        <event> event-loop SDL_Quit
    ] with-screen ;

cube3d
