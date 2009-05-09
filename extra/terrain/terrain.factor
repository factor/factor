USING: accessors arrays combinators game-input
game-input.scancodes game-loop grouping kernel literals locals
math math.constants math.functions math.matrices math.order
math.vectors opengl opengl.capabilities opengl.gl
opengl.shaders opengl.textures opengl.textures.private
sequences sequences.product specialized-arrays.float
terrain.generation terrain.shaders ui ui.gadgets
ui.gadgets.worlds ui.pixel-formats ;
IN: terrain

CONSTANT: FOV $[ 2.0 sqrt 1+ ]
CONSTANT: NEAR-PLANE $[ 1.0 2048.0 / ]
CONSTANT: FAR-PLANE 1.0
CONSTANT: PLAYER-START-LOCATION { 0.5 0.51 0.5 }
CONSTANT: PLAYER-HEIGHT $[ 3.0 1024.0 / ]
CONSTANT: GRAVITY $[ 1.0 4096.0 / ]
CONSTANT: JUMP $[ 1.0 1024.0 / ]
CONSTANT: TICK-LENGTH $[ 1000 30 /i ]
CONSTANT: MOUSE-SCALE $[ 1.0 10.0 / ]
CONSTANT: MOVEMENT-SPEED $[ 1.0 16384.0 / ]
CONSTANT: FRICTION 0.95
CONSTANT: COMPONENT-SCALE { 0.5 0.01 0.002 0.0 }

CONSTANT: terrain-vertex-size { 512 512 }
CONSTANT: terrain-vertex-distance { $[ 1.0 512.0 / ] $[ 1.0 512.0 / ] }
CONSTANT: terrain-vertex-row-length $[ 512 1 + 2 * ]

TUPLE: player
    location yaw pitch velocity ;

TUPLE: terrain-world < world
    player
    terrain terrain-segment terrain-texture terrain-program
    terrain-vertex-buffer
    game-loop ;

: frustum ( dim -- -x x -y y near far )
    dup first2 min v/n
    NEAR-PLANE FOV / v*n first2 [ [ neg ] keep ] bi@
    NEAR-PLANE FAR-PLANE ;

: set-modelview-matrix ( gadget -- )
    GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
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
    { 0.0 0.0 $ MOVEMENT-SPEED } vneg eye-rotate ;
: rightward-vector ( player -- v )
    yaw>> 0.0
    { $ MOVEMENT-SPEED 0.0 0.0 } eye-rotate ;

: walk-forward ( player -- )
    dup forward-vector [ v+ ] curry change-velocity drop ;
: walk-backward ( player -- )
    dup forward-vector [ v- ] curry change-velocity drop ;
: walk-leftward ( player -- )
    dup rightward-vector [ v- ] curry change-velocity drop ;
: walk-rightward ( player -- )
    dup rightward-vector [ v+ ] curry change-velocity drop ;
: jump ( player -- )
    [ { 0.0 $ JUMP 0.0 } v+ ] change-velocity drop ;

: clamp-pitch ( pitch -- pitch' )
    90.0 min -90.0 max ;

: rotate-with-mouse ( player mouse -- )
    [ dx>> MOUSE-SCALE * [ + ] curry change-yaw ]
    [ dy>> MOUSE-SCALE * [ + clamp-pitch ] curry change-pitch ] bi
    drop ;

:: handle-input ( world -- )
    world player>> :> player
    read-keyboard keys>> :> keys
    key-w keys nth [ player walk-forward ] when 
    key-s keys nth [ player walk-backward ] when 
    key-a keys nth [ player walk-leftward ] when 
    key-d keys nth [ player walk-rightward ] when 
    key-space keys nth [ player jump ] when 
    key-escape keys nth [ world close-window ] when
    player read-mouse rotate-with-mouse
    reset-mouse ;

: apply-friction ( velocity -- velocity' )
    FRICTION v*n ;

: apply-gravity ( velocity -- velocity' )
    1 over [ GRAVITY - ] change-nth ;

: pixel ( coords dim -- index )
    [ drop first ] [ [ second ] [ first ] bi* * ] 2bi + ;

: terrain-height-at ( segment point -- height )
    over dim>> [ v* vfloor ] [ pixel >integer ] bi
    swap bitmap>> 4 <groups> nth COMPONENT-SCALE v. 255.0 / ;

: collide ( segment location -- location' )
    [ [ first ] [ third ] bi 2array terrain-height-at PLAYER-HEIGHT + ]
    [ [ 1 ] 2dip [ max ] with change-nth ]
    [ ] tri ;

: tick-player ( world player -- )
    [ apply-friction apply-gravity ] change-velocity
    dup velocity>> [ v+ [ terrain-segment>> ] dip collide ] curry with change-location
    P
    drop ;

M: terrain-world tick*
    [ dup focused?>> [ handle-input ] [ drop ] if ]
    [ dup player>> tick-player ] bi ;

M: terrain-world draw*
    nip draw-world ;

: set-heightmap-texture-parameters ( texture -- )
    GL_TEXTURE_2D GL_TEXTURE0 bind-texture-unit
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE glTexParameteri ;

M: terrain-world begin-world
    "2.0" { "GL_ARB_vertex_buffer_object" "GL_ARB_shader_objects" }
    require-gl-version-or-extensions
    GL_DEPTH_TEST glEnable
    GL_TEXTURE_2D glEnable
    GL_VERTEX_ARRAY glEnableClientState
    0.5 0.5 0.5 1.0 glClearColor
    PLAYER-START-LOCATION 0.0 0.0 { 0.0 0.0 0.0 } player boa >>player
    <terrain> [ >>terrain ] keep
    { 0 0 } terrain-segment [ >>terrain-segment ] keep
    make-texture [ set-heightmap-texture-parameters ] keep >>terrain-texture
    terrain-vertex-shader terrain-pixel-shader <simple-gl-program>
    >>terrain-program
    vertex-array >vertex-buffer >>terrain-vertex-buffer
    TICK-LENGTH over <game-loop> [ >>game-loop ] keep start-loop
    open-game-input
    drop ;

M: terrain-world end-world
    close-game-input
    {
        [ game-loop>> stop-loop ]
        [ terrain-vertex-buffer>> delete-gl-buffer ]
        [ terrain-program>> delete-gl-program ]
        [ terrain-texture>> delete-texture ]
    } cleave ;

M: terrain-world resize-world
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    dim>> [ [ 0 0 ] dip first2 glViewport ]
    [ frustum glFrustum ] bi ;

M: terrain-world draw-world*
    [ set-modelview-matrix ]
    [ terrain-texture>> GL_TEXTURE_2D GL_TEXTURE0 bind-texture-unit ]
    [ dup terrain-program>> [
        [ "heightmap" glGetUniformLocation 0 glUniform1i ]
        [ "component_scale" glGetUniformLocation COMPONENT-SCALE first4 glUniform4f ] bi
        terrain-vertex-buffer>> draw-vertex-buffer
    ] with-gl-program ]
    tri gl-error ;

M: terrain-world focusable-child* drop t ;
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
