USING: accessors arrays combinators game-input game-loop
game-input.scancodes grouping kernel literals locals
math math.constants math.functions math.matrices math.order
math.vectors opengl opengl.capabilities opengl.gl
opengl.shaders opengl.textures opengl.textures.private
sequences sequences.product specialized-arrays.float
terrain.generation terrain.shaders ui ui.gadgets
ui.gadgets.worlds ui.pixel-formats game-worlds method-chains
math.affine-transforms noise ui.gestures combinators.short-circuit ;
IN: terrain

CONSTANT: FOV $[ 2.0 sqrt 1+ ]
CONSTANT: NEAR-PLANE $[ 1.0 1024.0 / ]
CONSTANT: FAR-PLANE 2.0
CONSTANT: PLAYER-START-LOCATION { 0.5 0.51 0.5 }
CONSTANT: VELOCITY-MODIFIER-NORMAL { 1.0 1.0 1.0 }
CONSTANT: VELOCITY-MODIFIER-FAST { 2.0 1.0 2.0 }
CONSTANT: PLAYER-HEIGHT $[ 1.0 256.0 / ]
CONSTANT: GRAVITY $[ 1.0 4096.0 / ]
CONSTANT: JUMP $[ 1.0 1024.0 / ]
CONSTANT: MOUSE-SCALE $[ 1.0 10.0 / ]
CONSTANT: MOVEMENT-SPEED $[ 1.0 16384.0 / ]
CONSTANT: FRICTION { 0.95 0.99 0.95 }
CONSTANT: COMPONENT-SCALE { 0.5 0.01 0.0005 0.0 }
CONSTANT: SKY-PERIOD 1200
CONSTANT: SKY-SPEED 0.0005

CONSTANT: terrain-vertex-size { 512 512 }
CONSTANT: terrain-vertex-distance { $[ 1.0 512.0 / ] $[ 1.0 512.0 / ] }
CONSTANT: terrain-vertex-row-length $[ 512 1 + 2 * ]

TUPLE: player
    location yaw pitch velocity velocity-modifier
    reverse-time ;

TUPLE: terrain-world < game-world
    player
    sky-image sky-texture sky-program
    terrain terrain-segment terrain-texture terrain-program
    terrain-vertex-buffer
    history ;

: <player> ( -- player )
    player new
        PLAYER-START-LOCATION >>location
        0.0 >>yaw
        0.0 >>pitch
        { 0.0 0.0 0.0 } >>velocity
        VELOCITY-MODIFIER-NORMAL >>velocity-modifier ;

M: terrain-world tick-length
    drop 1000 30 /i ;

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

: vertex-array-vertex ( x z -- vertex )
    [ terrain-vertex-distance first * ]
    [ terrain-vertex-distance second * ] bi*
    [ 0 ] dip float-array{ } 3sequence ;

: vertex-array-row ( z -- vertices )
    dup 1 + 2array
    terrain-vertex-size first 1 + iota
    2array [ first2 swap vertex-array-vertex ] product-map
    concat ;

: vertex-array ( -- vertices )
    terrain-vertex-size second iota
    [ vertex-array-row ] map concat ;

: >vertex-buffer ( bytes -- buffer )
    [ GL_ARRAY_BUFFER ] dip GL_STATIC_DRAW <gl-buffer> ;

: draw-vertex-buffer-row ( i -- )
    [ GL_TRIANGLE_STRIP ] dip
    terrain-vertex-row-length * terrain-vertex-row-length
    glDrawArrays ;

: draw-vertex-buffer ( buffer -- )
    [ GL_ARRAY_BUFFER ] dip [
        3 GL_FLOAT 0 f glVertexPointer
        terrain-vertex-size second iota [ draw-vertex-buffer-row ] each
    ] with-gl-buffer ;

: degrees ( deg -- rad )
    pi 180.0 / * ;

:: eye-rotate ( yaw pitch v -- v' )
    yaw degrees neg :> y
    pitch degrees neg :> p
    y cos :> cosy
    y sin :> siny
    p cos :> cosp
    p sin :> sinp

    cosy         0.0       siny        neg  3array
    siny sinp *  cosp      cosy sinp *      3array
    siny cosp *  sinp neg  cosy cosp *      3array 3array
    v swap v.m ;

: forward-vector ( player -- v )
    yaw>> 0.0
    ${ 0.0 0.0 MOVEMENT-SPEED } vneg eye-rotate ;
: rightward-vector ( player -- v )
    yaw>> 0.0
    ${ MOVEMENT-SPEED 0.0 0.0 } eye-rotate ;
: clamp-pitch ( pitch -- pitch' )
    90.0 min -90.0 max ;


: walk-forward ( player -- )
    dup forward-vector [ v+ ] curry change-velocity drop ;
: walk-backward ( player -- )
    dup forward-vector [ v- ] curry change-velocity drop ;
: walk-leftward ( player -- )
    dup rightward-vector [ v- ] curry change-velocity drop ;
: walk-rightward ( player -- )
    dup rightward-vector [ v+ ] curry change-velocity drop ;
: jump ( player -- )
    [ ${ 0.0 JUMP 0.0 } v+ ] change-velocity drop ;
: rotate-leftward ( player x -- )
    [ - ] curry change-yaw drop ;
: rotate-rightward ( player x -- )
    [ + ] curry change-yaw drop ;
: look-horizontally ( player x -- )
    [ + ] curry change-yaw drop ;
: look-vertically ( player x -- )
    [ + clamp-pitch ] curry change-pitch drop ;


: rotate-with-mouse ( player mouse -- )
    [ dx>> MOUSE-SCALE * look-horizontally ]
    [ dy>> MOUSE-SCALE * look-vertically ] 2bi ;


terrain-world H{
    { T{ key-down { mods { A+ } } { sym "RET" } } [ toggle-fullscreen ] }
} set-gestures

:: handle-input ( world -- )
    world player>> :> player
    read-keyboard keys>> :> keys

    key-left-shift keys nth
    VELOCITY-MODIFIER-FAST VELOCITY-MODIFIER-NORMAL ? player (>>velocity-modifier)

    {
        [ key-1 keys nth 1  f ? ]
        [ key-2 keys nth 2  f ? ]
        [ key-3 keys nth 3  f ? ]
        [ key-4 keys nth 4  f ? ]
        [ key-5 keys nth 10000 f ? ]
    } 0|| player (>>reverse-time)

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
    player read-mouse rotate-with-mouse
    reset-mouse ;

: apply-friction ( velocity -- velocity' )
    FRICTION v* ;

: apply-gravity ( velocity -- velocity' )
    1 over [ GRAVITY - ] change-nth ;

: clamp-coords ( coords dim -- coords' )
    [ { 0 0 } vmax ] dip { 2 2 } v- vmin ;

:: pixel-indices ( coords dim -- indices )
    coords vfloor [ >integer ] map dim clamp-coords :> floor-coords
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
    
    indices [ pixels nth COMPONENT-SCALE v. 255.0 / ] map
    first4 pixel-mantissa bilerp ;

: collide ( segment location -- location' )
    [ [ first ] [ third ] bi 2array terrain-height-at PLAYER-HEIGHT + ]
    [ [ 1 ] 2dip [ max ] with change-nth ]
    [ ] tri ;

: scaled-velocity ( player -- velocity )
    [ velocity>> ] [ velocity-modifier>> ] bi v* ;

: save-history ( world player -- )
    clone swap history>> push ;

:: tick-player-reverse ( world player -- )
    player reverse-time>> :> reverse-time
    world history>> :> history
    history length 0 > [
        history length reverse-time 1 - - 1 max history set-length
        history pop world (>>player)
    ] when ;

: tick-player-forward ( world player -- )
    2dup save-history
    [ apply-friction apply-gravity ] change-velocity
    dup scaled-velocity [ v+ [ terrain-segment>> ] dip collide ] curry with change-location
    drop ;

: tick-player ( world player -- )
    dup reverse-time>> [
        tick-player-reverse
    ] [
        tick-player-forward
    ] if ;

M: terrain-world tick*
    [ dup focused?>> [ handle-input ] [ drop ] if ]
    [ dup player>> tick-player ] bi ;

: set-texture-parameters ( texture -- )
    GL_TEXTURE_2D GL_TEXTURE0 bind-texture-unit
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE glTexParameteri ;

: sky-gradient ( world -- t )
    game-loop>> tick-number>> SKY-PERIOD mod SKY-PERIOD /f ;
: sky-theta ( world -- theta )
    game-loop>> tick-number>> SKY-SPEED * ;

BEFORE: terrain-world begin-world
    "2.0" { "GL_ARB_vertex_buffer_object" "GL_ARB_shader_objects" }
    require-gl-version-or-extensions
    GL_DEPTH_TEST glEnable
    GL_TEXTURE_2D glEnable
    GL_VERTEX_ARRAY glEnableClientState
    <player> >>player
    V{ } clone >>history
    <perlin-noise-table> 0.01 0.01 <scale> { 512 512 } perlin-noise-image
    [ >>sky-image ] keep
    make-texture [ set-texture-parameters ] keep >>sky-texture
    <terrain> [ >>terrain ] keep
    { 0 0 } terrain-segment [ >>terrain-segment ] keep
    make-texture [ set-texture-parameters ] keep >>terrain-texture
    sky-vertex-shader sky-pixel-shader <simple-gl-program>
    >>sky-program
    terrain-vertex-shader terrain-pixel-shader <simple-gl-program>
    >>terrain-program
    vertex-array >vertex-buffer >>terrain-vertex-buffer
    drop ;

AFTER: terrain-world end-world
    {
        [ terrain-vertex-buffer>> delete-gl-buffer ]
        [ terrain-program>> delete-gl-program ]
        [ terrain-texture>> delete-texture ]
        [ sky-program>> delete-gl-program ]
        [ sky-texture>> delete-texture ]
    } cleave ;

M: terrain-world resize-world
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    dim>> [ [ 0 0 ] dip first2 glViewport ]
    [ frustum glFrustum ] bi ;

M: terrain-world draw-world*
    {
        [ set-modelview-matrix ]
        [ terrain-texture>> GL_TEXTURE_2D GL_TEXTURE0 bind-texture-unit ]
        [ sky-texture>> GL_TEXTURE_2D GL_TEXTURE1 bind-texture-unit ]
        [ GL_DEPTH_TEST glDisable dup sky-program>> [
            [ nip "sky" glGetUniformLocation 1 glUniform1i ]
            [ "sky_gradient" glGetUniformLocation swap sky-gradient glUniform1f ]
            [ "sky_theta" glGetUniformLocation swap sky-theta glUniform1f ] 2tri
            { -1.0 -1.0 } { 2.0 2.0 } gl-fill-rect
        ] with-gl-program ]
        [ GL_DEPTH_TEST glEnable dup terrain-program>> [
            [ "heightmap" glGetUniformLocation 0 glUniform1i ]
            [ "component_scale" glGetUniformLocation COMPONENT-SCALE first4 glUniform4f ] bi
            terrain-vertex-buffer>> draw-vertex-buffer
        ] with-gl-program ]
    } cleave gl-error ;

M: terrain-world pref-dim* drop { 640 480 } ;

: terrain-window ( -- )
    [
        f T{ world-attributes
            { world-class terrain-world }
            { title "Terrain" }
            { pixel-format-attributes {
                windowed
                double-buffered
                T{ depth-bits { value 24 } }
            } }
            { grab-input? t }
        } open-window
    ] with-ui ;

MAIN: terrain-window
