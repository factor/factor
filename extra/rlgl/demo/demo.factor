! Copyright (C) 2023 CapitalEx.
! See https:!factorcode.org/license.txt for BSD license.
! A port of https://github.com/raysan5/raylib/blob/master/examples/models/models_rlgl_solar_system.c
USING: accessors classes.struct kernel math math.functions
math.trig ranges raylib rlgl sequences combinators.extras ;
IN: rlgl.demo

! Some raylib combinators
: with-drawing ( clear-color quot -- )
    swap begin-drawing clear-background
    call end-drawing ; inline

: with-matrix ( quot -- )
    rl-push-matrix call rl-pop-matrix ; inline

: while-window-open ( quot -- )
    [ window-should-close not ] swap while ; inline

: with-camera-3d ( camera quot -- )
    swap begin-mode-3d call end-mode-3d ; inline

CONSTANT:      screenWidth 800
CONSTANT:     screenHeight 450
CONSTANT:        sunRadius 4.0
CONSTANT:      earthRadius 0.6
CONSTANT: earthOrbitRadius 8.0
CONSTANT:       moonRadius 0.16
CONSTANT:  moonOrbitRadius 1.5
CONSTANT:    rotationSpeed 0.2

:: draw-sphere-basic ( color -- )
    16 16 :> ( rings slices )
    rings 2 + slices 6 * * rl-check-render-batch-limit drop

    RL_TRIANGLES rl-begin
        color [ r>> ] [ g>> ] [ b>> ] [ a>> ] quad rl-color4ub
        rings 2 + [0..b) slices [0..b) [| i j |
            270 180 rings 1 + / i * + deg>rad cos j 360 * slices / deg>rad sin *
            270 180 rings 1 + / i * + deg>rad sin
            270 180 rings 1 + / i * + deg>rad cos j 360 * slices / deg>rad cos *
                        rl-vertex3f

            270 180 rings 1 + / i 1 + * + deg>rad cos j 1 + 360 * slices / deg>rad sin *
            270 180 rings 1 + / i 1 + * + deg>rad sin
            270 180 rings 1 + / i 1 + * + deg>rad cos j 1 + 360 * slices / deg>rad cos *
                        rl-vertex3f

            270 180 rings 1 + / i 1 + * + deg>rad cos j 360 * slices / deg>rad sin *
            270 180 rings 1 + / i 1 + * + deg>rad sin
            270 180 rings 1 + / i 1 + * + deg>rad cos j 360 * slices / deg>rad cos *
                        rl-vertex3f

            270 180 rings 1 + / i * + deg>rad cos j 360 * slices / deg>rad sin *
            270 180 rings 1 + / i * + deg>rad sin
            270 180 rings 1 + / i * + deg>rad cos j 360 * slices / deg>rad cos *
                        rl-vertex3f

            270 180 rings 1 + / i * + deg>rad cos j 1 + 360 * slices / deg>rad sin *
            270 180 rings 1 + / i * + deg>rad sin
            270 180 rings 1 + / i * + deg>rad cos j 1 + 360 * slices / deg>rad cos *
                        rl-vertex3f

            270 180 rings 1 + / i 1 + * + deg>rad cos j 1 + 360 * slices / deg>rad sin *
            270 180 rings 1 + / i 1 + * + deg>rad sin
            270 180 rings 1 + / i 1 + * + deg>rad cos j 1 + 360 * slices / deg>rad cos *
                        rl-vertex3f
        ] cartesian-each
    rl-end ;

: draw-sun ( scale -- )
    dup dup rl-scalef GOLD draw-sphere-basic ;

: draw-moon ( radius rotation orbit-radius orbit-rotation -- )
    0.0 1.0 0.0 rl-rotatef
        0.0 0.0 rl-translatef
    0.0 1.0 0.0 rl-rotatef
    dup dup rl-scalef
    LIGHTGRAY draw-sphere-basic ;

: draw-earth ( radius rotation -- )
    0.25 1.0 0.0 rl-rotatef dup dup rl-scalef
    BLUE draw-sphere-basic ;

: draw-earth-and-moon ( moonRadius       moonRotation
                        moonOrbitRadius  moonOrbitRotation
                        earthRadius      earthRotation
                        earthOrbitRadius earthOrbitRotation -- )
    0.0 1.0 0.0 rl-rotatef 0.0 0.0 rl-translatef
    [ draw-earth ] with-matrix draw-moon ;

: draw-solar-system ( moonRadius       moonRotation
                      moonOrbitRadius  moonOrbitRotation
                      earthRadius      earthRotation
                      earthOrbitRadius earthOrbitRotation 
                      sunRadius -- )
    [ draw-sun ] [ draw-earth-and-moon ] [ with-matrix ] bi@ ;

:: main ( -- )
    screenWidth screenHeight "raylib [models] example - rlgl module usage with push/pop matrix transformations"
        init-window

    Camera3D <struct>
            16.0 16.0 16.0 <Vector3> >>position
             0.0  0.0  0.0 <Vector3> >>target
             0.0  1.0  0.0 <Vector3> >>up
                      45.0           >>fovy
        CAMERA_PERSPECTIVE           >>projection
    :> camera

    0.0 0.0 :> ( earthRotation! earthOrbitRotation! )
    0.0 0.0 :> ( moonRotation!  moonOrbitRotation!  )

    60 set-target-fps [
        camera CAMERA_ORBITAL update-camera

        5.0 rotationSpeed * earthRotation + earthRotation!
        365.0 360.0 / 5.0 rotationSpeed * * rotationSpeed * earthOrbitRotation + earthOrbitRotation!
        rotationSpeed 2.0 * moonRotation + moonRotation!
        rotationSpeed 8.0 * moonOrbitRotation + moonOrbitRotation!

        RAYWHITE [
            camera [
                moonRadius  moonRotation  moonOrbitRadius  moonOrbitRotation
                earthRadius earthRotation earthOrbitRadius earthOrbitRotation
                sunRadius   draw-solar-system

                0.0 0.0 0.0 <Vector3> earthOrbitRadius 1 0 0 <Vector3> 90.0 RED 0.5 fade
                    draw-circle-3d

                20 1.0 draw-grid
            ] with-camera-3d

            "EARTH ORBITING AROUND THE SUN!" 400 10 20 MAROON draw-text
            "Using Factor!"                  400 40 20 GOLD   draw-text
            10 10 draw-fps
        ] with-drawing
    ] while-window-open

    close-window ;

MAIN: main