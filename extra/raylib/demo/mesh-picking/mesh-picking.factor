! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.enums arrays combinators.short-circuit
continuations destructors formatting grouping io.backend io.pathnames
kernel math math.functions.private math.vectors namespaces raylib
sequences vocabs.metadata ;

IN: raylib.demo.mesh-picking

CONSTANT: screen-width 800
CONSTANT: screen-height 800
: make-window ( -- )
    screen-width screen-height "raylib [models] example - mesh-picking" init-window ;

: make-camera ( -- camera )
    Camera3D new
    20 30 20 <Vector3> >>position
    0 10 0 <Vector3> >>target
    0 1.6 0 <Vector3> >>up
    45 >>fovy
    CAMERA_PERSPECTIVE >>projection ;

: resource ( fname -- path )
    "raylib.demo.mesh-picking" "_resources" vocab-file-path swap append-path normalize-path ;

! TODO: raymath?
:: vector3-barycenter ( p a b c -- v3 )
    b a v- :> v0
    c a v- :> v1
    p a v- :> v2
    v0 dup vdot :> d00
    v0 v1 vdot :> d01
    v1 v1 vdot :> d11
    v2 v0 vdot :> d20
    v2 v1 vdot :> d21
    d00 d11 * d01 d01 * - :> denom

    d11 d20 * d01 d21 * - denom / :> y
    d00 d21 * d01 d20 * - denom / :> z
    1 z y + - :> x
    x y z <Vector3> ; inline

: update-hit? ( nearest-hit-info hit-info -- nearest-hit-info ? )
    2dup { [ nip hit>> ] [ swap [ distance>> ] bi@ < ] } 2&&
    [ nip t ] [ drop f ] if ;

TUPLE: hit-state name color nearest-hit ;
: <hit-state> ( -- obj )
    "None" WHITE
    RayCollision new
    most-positive-finite-float >>distance
    f >>hit
    hit-state boa ;

: reset-hit-state ( hit-state -- )
    nearest-hit>>
    most-positive-finite-float >>distance
    f >>hit drop ;

: handle-ground-hit ( hit-state ray -- hit-state )
    0 get-ray-collision-ground
    over nearest-hit>> swap update-hit?
    [ >>nearest-hit ] dip
    [ GREEN >>color "Ground" >>name ] when ;

: handle-triangle-hit ( hit-state ray ta tb tc -- hit-state ? )
    get-ray-collision-triangle
    over nearest-hit>> swap update-hit?
    [ [ >>nearest-hit ] dip
    [ PURPLE >>color "Triangle" >>name ] when ] keep ;

: handle-mesh-hit ( hit-state ray model bbox -- hit-state ? )
    pick swap get-ray-collision-box
    [
      get-ray-collision-model
      over nearest-hit>> swap update-hit?
      [ >>nearest-hit ] dip
      [ ORANGE >>color "Mesh" >>name ] when
      t
    ]
    [ 2drop f ] if ;

TUPLE: tower model bbox position ;
: <tower> ( -- obj )
    "turret.obj" resource load-model &unload-model
    "turret_diffuse.png" resource load-texture &unload-texture
    over materials>> first maps>> MATERIAL_MAP_DIFFUSE enum>number swap nth texture<<
    dup meshes>> first get-mesh-bounding-box
    0 0 0 <Vector3> tower boa ;

: init-assets ( -- tower triangle )
    <tower>
    -25 0.5 0 <Vector3>
    -4 2.5 1 <Vector3>
    -8 6.5 0 <Vector3> 3array ;

: draw-objects ( bbox? tower triangle -- )
    2 <circular-clumps> [ first2 PURPLE draw-line-3d ] each
    [ [ model>> ] [ position>> ] bi 1.0 WHITE draw-model ] keep
    swap [ bbox>> LIME draw-bounding-box ] [ drop ] if ;

: draw-cursor ( hit-state -- )
    dup nearest-hit>> hit>> [
        [
            [ nearest-hit>> point>> ] [ color>> ] bi
            '[ 0.3 0.3 0.3 _ draw-cube ]
            [ 0.3 0.3 0.3 RED draw-cube-wires ] bi
        ]
        [
            nearest-hit>>
            [ point>> dup ] [ normal>> ] bi v+ RED draw-line-3d
        ] bi

    ]
    [ drop ] if ;

: while-raylib-window ( quot -- )
    [ window-should-close not ] swap while ; inline

: with-window ( quot -- )
    [ make-window ] prepose [ with-destructors ] curry
    [ close-window ] [ ] cleanup ; inline

SYMBOL: mesh-picking-frame
:: main ( -- )
    ! LOG_ALL set-trace-log-level
    [
        make-camera :> camera
        Ray new :> ray
        init-assets :> ( tower triangle )

        f :> bary!
        camera CAMERA_FREE update-camera

        60 set-target-fps
        0 mesh-picking-frame set-global
        <hit-state> :> the-hit-state
        f :> hit-mesh-bbox!
        [
            ! NOTE: This doesn't work, probably because GL context is not handled correctly for switching?
            ! mesh-picking-frame counter 100 mod 0 = [ yield ] when

            camera CAMERA_FREE update-camera

            get-mouse-position camera get-mouse-ray :> ray

            the-hit-state dup reset-hit-state
            ray handle-ground-hit

            ray triangle first3 handle-triangle-hit
            [ dup nearest-hit>> point>> triangle first3 vector3-barycenter bary! ] [ f bary! ] if

            ray tower [ model>> ] [ bbox>> ] bi handle-mesh-hit hit-mesh-bbox!

            ! Drawing
            begin-drawing
            RAYWHITE clear-background
            camera begin-mode-3d
            hit-mesh-bbox tower triangle draw-objects

            dup draw-cursor

            ray MAROON draw-ray

            10 10 draw-grid
            end-mode-3d

            ! Debug Gui Text
            dup name>> "Hit Object: %s" sprintf 10 30 10 BLACK draw-text
            nearest-hit>> dup hit>> [
                70 :> ypos
                [ distance>> "Distance: %3.2f" sprintf 10 ypos 10 BLACK draw-text ]
                [ point>> first3 "Hit Pos: %3.2f %3.2f %3.2f" sprintf 10 ypos 15 + 10 BLACK draw-text ]
                [ normal>> first3 "Hit Norm: %3.2f %3.2f %3.2f" sprintf 10 ypos 30 + 10 BLACK draw-text ]
                tri
                bary [ first3
                       "Barycenter: %3.2f %3.2f %3.2f" sprintf 10 ypos 45 + 10 BLACK draw-text
                    ] when*
            ] [ drop ] if

            "Use Mouse to Move Camera" 10 screen-height 20 - 10 GRAY draw-text
            "(c) Turret 3D model by Alberto Cano" screen-width 200 - screen-height 20 - 10 GRAY draw-text

            10 10 draw-fps
            end-drawing
        ] while-raylib-window
    ] with-window ;

MAIN: main
