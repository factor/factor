! Copyright (C) 2009 Joe Groff, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs bit-arrays combinators combinators.short-circuit
destructors game.input game.input.scancodes game.loop images
game.worlds grid-meshes grouping kernel literals math
math.functions math.matrices.simd math.order
math.vectors math.vectors.simd namespaces noise opengl
opengl.capabilities opengl.gl opengl.shaders opengl.textures
sequences specialized-arrays system terrain.generation terrain.shaders
typed ui ui.backend.input-state ui.gadgets.worlds ui.gestures ui.pixel-formats ui.render ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: c:float
IN: terrain

CONSTANT: FOV $[ 2.0 sqrt 1 + ]
CONSTANT: NEAR-PLANE 1/1024.
CONSTANT: FAR-PLANE 2.0
CONSTANT: PLAYER-START-LOCATION float-4{ 0.5 0.51 0.5 1.0 }
CONSTANT: VELOCITY-MODIFIER-NORMAL float-4{ 1.0 1.0 1.0 0.0 }
CONSTANT: VELOCITY-MODIFIER-FAST float-4{ 2.0 1.0 2.0 0.0 }
CONSTANT: BOUNCE float-4{ 1.0 -0.2 1.0 1.0 }
CONSTANT: PLAYER-HEIGHT 1/256.
CONSTANT: GRAVITY float-4{ 0.0 -1/8192. 0.0 0.0 }
CONSTANT: JUMP 1/2048.
CONSTANT: MOUSE-SCALE 1/20.
CONSTANT: MOVEMENT-SPEED 1/32768.
CONSTANT: FRICTION float-4{ 0.97 0.995 0.97 1.0 }
CONSTANT: COMPONENT-SCALE float-4{ 0.5 0.01 0.0005 0.0 }
CONSTANT: SKY-PERIOD 2400
CONSTANT: SKY-SPEED 0.00025

CONSTANT: terrain-vertex-size { 512 512 }

TUPLE: player
    { location float-4 }
    { yaw float }
    { pitch float }
    { velocity float-4 }
    { velocity-modifier float-4 }
    reverse-time ;

TUPLE: terrain-world < game-world
    { player player }
    sky-image sky-texture sky-program
    terrain terrain-segment terrain-texture terrain-program
    terrain-mesh
    history ;

: <player> ( -- player )
    player new
        PLAYER-START-LOCATION >>location
        0.0 >>yaw
        20.0 >>pitch
        float-4{ 0.0 0.0 0.0 1.0 } >>velocity
        VELOCITY-MODIFIER-NORMAL >>velocity-modifier ;

: frustum ( dim -- -x x -y y near far )
    dup first2 min v/n
    NEAR-PLANE FOV / v*n first2 [ [ neg ] keep ] bi@
    NEAR-PLANE FAR-PLANE ;

: set-modelview-matrix ( gadget -- )
    GL_DEPTH_BUFFER_BIT glClear
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    player>>
    [ pitch>> 1.0 0.0 0.0 glRotatef ]
    [ yaw>> 0.0 1.0 0.0 glRotatef ]
    [ location>> vneg first3 glTranslatef ] tri ;

: terrain-projection ( dim -- matrix )
    dup first2 min v/n NEAR-PLANE FOV / v*n first2
    0.0 0.0 float-4-boa NEAR-PLANE FAR-PLANE frustum-matrix4 ;

: terrain-modelview ( player -- matrix )
    [ float-4{ 1.0 0.0 0.0 0.0 } swap pitch>> deg>rad rotation-matrix4 ]
    [ float-4{ 0.0 1.0 0.0 0.0 } swap yaw>> deg>rad rotation-matrix4 m4. ]
    [ location>> vneg translation-matrix4 m4. ] tri ;

:: set-terrain-matrices ( world program -- )
    program "projection" glGetUniformLocation
    1 GL_FALSE world dim>> terrain-projection glUniformMatrix4fv
    program "modelview" glGetUniformLocation
    1 GL_FALSE world player>> terrain-modelview glUniformMatrix4fv ;

: make-terrain-texture ( image -- texture )
    gl3-mode? get-global [ make-texture-gl3 ] [ make-texture ] if ;

: <terrain-core-program> ( -- program )
    terrain-core-vertex-shader <vertex-shader> check-gl-shader
    terrain-core-pixel-shader <fragment-shader> check-gl-shader
    2array [ 0 "position" glBindAttribLocation ] (gl-program) check-gl-program ;

: draw-terrain-sky ( world -- )
    gl3-mode? get-global [
        terrain-mesh>> vertex-array>> [ GL_TRIANGLES 0 3 glDrawArrays ] with-vertex-array
    ] [ drop { -1.0 -1.0 } { 2.0 2.0 } gl-fill-rect ] if ;

TYPED: eye-rotate ( yaw: float pitch: float v: float-4 -- v': float-4 )
    [ float-4{  0.0 -1.0 0.0 0.0 } swap deg>rad rotation-matrix4 ]
    [ float-4{ -1.0  0.0 0.0 0.0 } swap deg>rad rotation-matrix4 m4. ]
    [ m4.v ] tri* float-4{ t t t f } vand ;

: forward-vector ( player -- v )
    yaw>> 0.0
    float-4{ 0.0 0.0 $ MOVEMENT-SPEED 1.0 } vneg eye-rotate ; inline
: rightward-vector ( player -- v )
    yaw>> 0.0
    float-4{ $ MOVEMENT-SPEED 0.0 0.0 1.0 } eye-rotate ; inline
: clamp-pitch ( pitch -- pitch' )
    -90.0 90.0 clamp ; inline

: walk-forward ( player -- )
    dup forward-vector [ v+ ] curry change-velocity drop ; inline
: walk-backward ( player -- )
    dup forward-vector [ v- ] curry change-velocity drop ; inline
: walk-leftward ( player -- )
    dup rightward-vector [ v- ] curry change-velocity drop ; inline
: walk-rightward ( player -- )
    dup rightward-vector [ v+ ] curry change-velocity drop ; inline
: jump ( player -- )
    [ float-4{ 0.0 $ JUMP 0.0 0.0 } v+ ] change-velocity drop ; inline
: rotate-leftward ( player x -- )
    [ - ] curry change-yaw drop ; inline
: rotate-rightward ( player x -- )
    [ + ] curry change-yaw drop ; inline
: look-horizontally ( player x -- )
    [ + ] curry change-yaw drop ; inline
: look-vertically ( player x -- )
    [ + clamp-pitch ] curry change-pitch drop ; inline


: rotate-with-mouse ( player mouse -- )
    [ dx>> MOUSE-SCALE * look-horizontally ]
    [ dy>> MOUSE-SCALE * look-vertically ] 2bi ;


terrain-world H{
    { T{ key-down { mods { A+ } } { sym "RET" } } [ toggle-fullscreen ] }
} set-gestures

! Cocoa virtual keycodes for the demo's physical controls. Window events
! remain available when macOS denies global HID Input Monitoring.
CONSTANT: terrain-cocoa-keys H{
    { 13 $ key-w } { 1 $ key-s } { 0 $ key-a } { 2 $ key-d }
    { 12 $ key-q } { 14 $ key-e }
    { 123 $ key-left-arrow } { 124 $ key-right-arrow }
    { 125 $ key-down-arrow } { 126 $ key-up-arrow }
    { 49 $ key-space } { 53 $ key-escape }
    { 18 $ key-1 } { 19 $ key-2 } { 20 $ key-3 }
    { 21 $ key-4 } { 23 $ key-5 }
    { 56 $ key-left-shift } { 60 $ key-right-shift }
}

:: cocoa-terrain-keys ( keycodes -- keys )
    256 <bit-array> :> keys
    terrain-cocoa-keys [| code hid |
        code keycodes key? [ t hid keys set-nth ] when
    ] assoc-each
    keys ;

: terrain-keys ( -- keys )
    os macos?
    [ current-input-state get-global keycodes>> cocoa-terrain-keys ]
    [ read-keyboard keys>> ] if ;

: terrain-mouse ( -- mouse )
    os macos? [
        current-input-state get-global
        [ motion>> first2 ] [ scroll>> first2 ] [ buttons>> ] tri mouse-state boa
    ] [ read-mouse ] if ;

: reset-terrain-mouse ( -- )
    os macos? [ reset-pointer-deltas ] [ reset-mouse ] if ;

:: handle-input ( world -- )
    world player>> :> player
    terrain-keys :> keys

    key-left-shift keys nth key-right-shift keys nth or
    VELOCITY-MODIFIER-FAST VELOCITY-MODIFIER-NORMAL ? player velocity-modifier<<

    {
        [ key-1 keys nth 1  f ? ]
        [ key-2 keys nth 2  f ? ]
        [ key-3 keys nth 3  f ? ]
        [ key-4 keys nth 4  f ? ]
        [ key-5 keys nth 10000 f ? ]
    } 0|| player reverse-time<<

    key-w keys nth [ player walk-forward ] when
    key-s keys nth [ player walk-backward ] when
    key-a keys nth [ player walk-leftward ] when
    key-d keys nth [ player walk-rightward ] when
    key-q keys nth [ player -1 look-horizontally ] when
    key-e keys nth [ player 1 look-horizontally ] when
    key-left-arrow keys nth [ player -1 look-horizontally ] when
    key-right-arrow keys nth [ player 1 look-horizontally ] when
    key-down-arrow keys nth [ player 1 look-vertically ] when
    key-up-arrow keys nth [ player -1 look-vertically ] when
    key-space keys nth [ player jump ] when
    key-escape keys nth [ world close-window ] when
    player terrain-mouse rotate-with-mouse
    reset-terrain-mouse ;

: apply-friction ( velocity -- velocity' )
    FRICTION v* ;

: apply-gravity ( velocity -- velocity' )
    GRAVITY v+ ;

: clamp-coords ( coords dim -- coords' )
    { 0 0 } swap { 2 2 } v- vclamp ;

:: pixel-indices ( coords dim -- indices )
    coords vfloor v>integer dim clamp-coords :> floor-coords
    floor-coords first2 dim first * + :> base-index
    base-index dim first + :> next-row-index

    base-index
    base-index 1 +
    next-row-index
    next-row-index 1 + 4array ;

:: terrain-height-at ( segment point -- height )
    segment dim>> :> dim
    dim point v* :> pixel
    pixel dup vfloor v- :> pixel-mantissa
    segment bitmap>> 4 <groups> :> pixels
    pixel dim pixel-indices :> indices

    indices [ pixels nth COMPONENT-SCALE vdot 255.0 / ] map
    first4 pixel-mantissa bilerp ;

: (collide) ( segment location -- location' )
    [
        { 0 2 3 3 } vshuffle terrain-height-at PLAYER-HEIGHT +
        -1/0. swap -1/0. -1/0. float-4-boa
    ] keep vmax ; inline

TYPED:: collide ( world: terrain-world player: player -- )
    world terrain-segment>> :> segment
    player location>> :> location
    segment location (collide) :> location'

    location location' = not [
        player
            location' >>location
            [ BOUNCE v* ] change-velocity
            drop
    ] when ;

: scaled-velocity ( player -- velocity )
    [ velocity>> ] [ velocity-modifier>> ] bi v* ;

: save-history ( world player -- )
    clone swap history>> push ;

:: tick-player-reverse ( world player -- )
    player reverse-time>> :> reverse-time
    world history>> :> history
    history length 0 > [
        history length reverse-time 1 - - 1 max history set-length
        history pop world player<<
    ] when ;

: tick-player-forward ( world player -- )
    2dup save-history
    [ apply-friction apply-gravity ] change-velocity
    dup scaled-velocity [ v+ ] curry change-location
    collide ;

: tick-player ( world player -- )
    dup reverse-time>>
    [ tick-player-reverse ]
    [ tick-player-forward ] if ;

M: terrain-world tick-game-world
    [ dup focused?>> [ handle-input ] [ drop ] if ]
    [ dup player>> tick-player ] bi ;

: set-texture-parameters ( texture -- )
    GL_TEXTURE_2D GL_TEXTURE0 bind-texture-unit
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE glTexParameteri ;

: sky-gradient ( world -- t )
    game-loop>> tick#>> SKY-PERIOD mod SKY-PERIOD /f ;
: sky-theta ( world -- theta )
    game-loop>> tick#>> SKY-SPEED * ;

M: terrain-world begin-game-world
    "2.0" { "GL_ARB_vertex_buffer_object" "GL_ARB_shader_objects" }
    require-gl-version-or-extensions
    GL_DEPTH_TEST glEnable
    gl3-mode? get-global [
        GL_TEXTURE_2D glEnable
        GL_VERTEX_ARRAY glEnableClientState
    ] unless
    <player> >>player
    V{ } clone >>history
    <perlin-noise-table> 0.01 float-4-with scale-matrix4 { 512 512 } perlin-noise-image
    gl3-mode? get-global [ R >>component-order ] when
    [ >>sky-image ] keep
    make-terrain-texture [ set-texture-parameters ] keep >>sky-texture
    <terrain> [ >>terrain ] keep
    float-4{ 0.0 0.0 0.0 1.0 } terrain-segment [ >>terrain-segment ] keep
    make-terrain-texture [ set-texture-parameters ] keep >>terrain-texture
    gl3-mode? get-global
    [ sky-core-vertex-shader sky-core-pixel-shader ]
    [ sky-vertex-shader sky-pixel-shader ] if <simple-gl-program>
    >>sky-program
    gl3-mode? get-global [ <terrain-core-program> ]
    [ terrain-vertex-shader terrain-pixel-shader <simple-gl-program> ] if
    >>terrain-program
    terrain-vertex-size <grid-mesh> >>terrain-mesh
    drop ;

M: terrain-world end-game-world
    {
        [ terrain-mesh>> dispose ]
        [ terrain-program>> delete-gl-program ]
        [ terrain-texture>> delete-texture ]
        [ sky-program>> delete-gl-program ]
        [ sky-texture>> delete-texture ]
    } cleave ;

M: terrain-world resize-world
    dim>> dup [ { 0 0 } ] dip gl-viewport
    gl3-mode? get-global [ drop ] [
        GL_PROJECTION glMatrixMode
        glLoadIdentity frustum glFrustum
    ] if ;

M: terrain-world draw-world*
    {
        [ gl3-mode? get-global
            [ drop GL_DEPTH_BUFFER_BIT glClear ] [ set-modelview-matrix ] if ]
        [ terrain-texture>> GL_TEXTURE_2D GL_TEXTURE0 bind-texture-unit ]
        [ sky-texture>> GL_TEXTURE_2D GL_TEXTURE1 bind-texture-unit ]
        [ GL_DEPTH_TEST glDisable dup sky-program>> [
            gl3-mode? get-global [ 2dup set-terrain-matrices ] when
            over [
                [ nip "sky" glGetUniformLocation 1 glUniform1i ]
                [ "sky_gradient" glGetUniformLocation swap sky-gradient glUniform1f ]
                [ "sky_theta" glGetUniformLocation swap sky-theta glUniform1f ] 2tri
            ] dip
            draw-terrain-sky
        ] with-gl-program ]
        [ GL_DEPTH_TEST glEnable dup terrain-program>> [
            gl3-mode? get-global [ 2dup set-terrain-matrices ] when
            [ "heightmap" glGetUniformLocation 0 glUniform1i ]
            [ "component_scale" glGetUniformLocation COMPONENT-SCALE first4 glUniform4f ] bi
            terrain-mesh>> draw-grid-mesh
        ] with-gl-program ]
    } cleave gl-error ;

GAME: terrain-game {
        { world-class terrain-world }
        { title "Terrain" }
        { pixel-format-attributes {
            windowed
            double-buffered
            T{ depth-bits { value 24 } }
        } }
        { use-game-input? $[ os macos? not ] }
        { grab-input? t }
        { pref-dim { 1024 768 } }
        { tick-interval-nanos $[ 60 fps ] }
    } ;
