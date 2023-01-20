! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators.smart game.input
game.input.scancodes game.loop game.worlds
gpu.render gpu.state kernel literals
locals math math.constants math.functions math.matrices
math.matrices.extras math.order math.vectors opengl.gl
sequences ui ui.gadgets.worlds specialized-arrays audio.engine ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
IN: gpu.util.wasd

UNIFORM-TUPLE: mvp-uniforms
    { "mv_matrix"  mat4-uniform f }
    { "p_matrix"   mat4-uniform f } ;

CONSTANT: -pi/2 $[ pi -2.0 / ]
CONSTANT:  pi/2 $[ pi  2.0 / ]

TUPLE: wasd-world < game-world location yaw pitch p-matrix ;

GENERIC: wasd-near-plane ( world -- near-plane )
M: wasd-world wasd-near-plane drop 0.25 ;

GENERIC: wasd-far-plane ( world -- far-plane )
M: wasd-world wasd-far-plane drop 1024.0 ;

GENERIC: wasd-movement-speed ( world -- speed )
M: wasd-world wasd-movement-speed drop 1/16. ;

GENERIC: wasd-mouse-scale ( world -- scale )
M: wasd-world wasd-mouse-scale drop 1/600. ;

GENERIC: wasd-pitch-range ( world -- min max )
M: wasd-world wasd-pitch-range drop -pi/2 pi/2 ;

GENERIC: wasd-fly-vertically? ( world -- ? )
M: wasd-world wasd-fly-vertically? drop t ;

: wasd-mv-matrix ( world -- matrix )
    [ { 1.0 0.0 0.0 } swap pitch>> <rotation-matrix4> ]
    [ { 0.0 1.0 0.0 } swap yaw>>   <rotation-matrix4> ]
    [ location>> vneg <translation-matrix4> ] tri mdot mdot ;

: wasd-mv-inv-matrix ( world -- matrix )
    [ location>> <translation-matrix4> ]
    [ {  0.0 -1.0 0.0 } swap yaw>>   <rotation-matrix4> ]
    [ { -1.0  0.0 0.0 } swap pitch>> <rotation-matrix4> ] tri
    mdot mdot ;

: wasd-p-matrix ( world -- matrix )
    p-matrix>> ;

: <mvp-uniforms> ( world -- uniforms )
    [ wasd-mv-matrix ] [ wasd-p-matrix ] bi mvp-uniforms boa ;

CONSTANT: fov 0.7

: wasd-fov-vector ( world -- fov )
    dim>> dup first2 min >float v/n fov v*n ; inline

:: generate-p-matrix ( world -- matrix )
    world wasd-near-plane :> near-plane
    world wasd-far-plane :> far-plane

    world wasd-fov-vector near-plane v*n
    near-plane far-plane <frustum-matrix4> ;

:: wasd-pixel-ray ( world loc -- direction )
    loc world dim>> [ /f 0.5 - 2.0 * ] 2map
    world wasd-fov-vector v*
    first2 neg -1.0 0.0 4array
    world wasd-mv-inv-matrix swap mdotv ;

: set-wasd-view ( world location yaw pitch -- world )
    [ >>location ] [ >>yaw ] [ >>pitch ] tri* ;

:: eye-rotate ( yaw pitch v -- v' )
    yaw neg :> y
    pitch neg :> p
    y cos :> cosy
    y sin :> siny
    p cos :> cosp
    p sin :> sinp

    cosy         0.0       siny        neg  3array
    siny sinp *  cosp      cosy sinp *      3array
    siny cosp *  sinp neg  cosy cosp *      3array 3array
    v swap vdotm ;

: ?pitch ( world -- pitch )
    dup wasd-fly-vertically? [ pitch>> ] [ drop 0.0 ] if ;

: forward-vector ( world -- v )
    [ yaw>> ] [ ?pitch ] [ wasd-movement-speed ] tri
    { 0.0 0.0 -1.0 } n*v eye-rotate ;
: rightward-vector ( world -- v )
    [ yaw>> ] [ ?pitch ] [ wasd-movement-speed ] tri
    { 1.0 0.0 0.0 } n*v eye-rotate ;

M: wasd-world audio-position location>> ; inline
M: wasd-world audio-orientation
    forward-vector { 0.0 1.0 0.0 } <audio-orientation-state> ; inline

: walk-forward ( world -- )
    dup forward-vector [ v+ ] curry change-location drop ;
: walk-backward ( world -- )
    dup forward-vector [ v- ] curry change-location drop ;
: walk-leftward ( world -- )
    dup rightward-vector [ v- ] curry change-location drop ;
: walk-rightward ( world -- )
    dup rightward-vector [ v+ ] curry change-location drop ;
: walk-upward ( world -- )
    dup wasd-movement-speed { 0.0 1.0 0.0 } n*v [ v+ ] curry change-location drop ;
: walk-downward ( world -- )
    dup wasd-movement-speed { 0.0 1.0 0.0 } n*v [ v- ] curry change-location drop ;

: clamp-pitch ( world -- world )
    dup [ wasd-pitch-range clamp ] curry change-pitch ;

: rotate-with-mouse ( world mouse -- )
    [ [ dup wasd-mouse-scale ] [ dx>> ] bi* * [ + ] curry change-yaw ]
    [ [ dup wasd-mouse-scale ] [ dy>> ] bi* * [ + ] curry change-pitch clamp-pitch ] bi
    drop ;

:: wasd-keyboard-input ( world -- )
    read-keyboard keys>> :> keys
    key-w keys nth [ world walk-forward   ] when
    key-s keys nth [ world walk-backward  ] when
    key-a keys nth [ world walk-leftward  ] when
    key-d keys nth [ world walk-rightward ] when
    key-space keys nth [ world walk-upward ] when
    key-c keys nth [ world walk-downward ] when
    key-escape keys nth [ world close-window ] when ;

: wasd-mouse-input ( world -- )
    read-mouse rotate-with-mouse ;

M: wasd-world tick-game-world
    dup focused?>> [
        [ wasd-keyboard-input ] [ wasd-mouse-input ] bi
        reset-mouse
    ] [ drop ] if ;

M: wasd-world resize-world
    [ <viewport-state> set-gpu-state* ]
    [ dup generate-p-matrix >>p-matrix drop ] bi ;
