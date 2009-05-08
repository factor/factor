USING: accessors arrays combinators game-input
game-input.scancodes game-loop kernel literals locals math
math.constants math.functions math.matrices math.order
math.vectors opengl opengl.capabilities opengl.gl
opengl.shaders opengl.textures opengl.textures.private
sequences sequences.product specialized-arrays.float
terrain.generation terrain.shaders ui ui.gadgets
ui.gadgets.worlds ui.pixel-formats ;
IN: terrain

CONSTANT: FOV $[ 2.0 sqrt 1+ ]
CONSTANT: NEAR-PLANE $[ 1.0 1024.0 / ]
CONSTANT: FAR-PLANE 1.0
CONSTANT: EYE-START { 0.5 0.5 1.2 }
CONSTANT: TICK-LENGTH $[ 1000 30 /i ]
CONSTANT: MOUSE-SCALE $[ 1.0 10.0 / ]
CONSTANT: MOVEMENT-SPEED $[ 1.0 512.0 / ]

CONSTANT: terrain-vertex-size { 512 512 }
CONSTANT: terrain-vertex-distance { $[ 1.0 512.0 / ] $[ 1.0 512.0 / ] }
CONSTANT: terrain-vertex-row-length $[ 512 1 + 2 * ]

TUPLE: terrain-world < world
    eye yaw pitch
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
    [ pitch>> 1.0 0.0 0.0 glRotatef ]
    [ yaw>> 0.0 1.0 0.0 glRotatef ]
    [ eye>> vneg first3 glTranslatef ] tri ;

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

    cosy         0.0       siny        neg 3array
    siny sinp *  cosp      cosy sinp *     3array
    siny cosp *  sinp neg  cosy cosp *     3array 3array
    v swap v.m ;

: forward-vector ( world -- v )
    [ yaw>> ] [ pitch>> ] bi
    { 0.0 0.0 $ MOVEMENT-SPEED } vneg eye-rotate ;
: rightward-vector ( world -- v )
    [ yaw>> ] [ pitch>> ] bi
    { $ MOVEMENT-SPEED 0.0 0.0 } eye-rotate ;

: move-forward ( world -- )
    dup forward-vector [ v+ ] curry change-eye drop ;
: move-backward ( world -- )
    dup forward-vector [ v- ] curry change-eye drop ;
: move-leftward ( world -- )
    dup rightward-vector [ v- ] curry change-eye drop ;
: move-rightward ( world -- )
    dup rightward-vector [ v+ ] curry change-eye drop ;

: rotate-with-mouse ( world mouse -- )
    [ dx>> MOUSE-SCALE * [ + ] curry change-yaw ]
    [ dy>> MOUSE-SCALE * [ + ] curry change-pitch ] bi
    drop ;

:: handle-input ( world -- )
    read-keyboard keys>> :> keys
    key-w keys nth [ world move-forward ] when 
    key-s keys nth [ world move-backward ] when 
    key-a keys nth [ world move-leftward ] when 
    key-d keys nth [ world move-rightward ] when 
    world read-mouse rotate-with-mouse
    reset-mouse ;

M: terrain-world tick*
    [ handle-input ] keep
    ! [ eye>> ] [ yaw>> ] [ pitch>> ] tri 3array P ! debug
    drop ;

M: terrain-world draw*
    nip draw-world ;

: set-heightmap-texture-parameters ( texture -- )
    GL_TEXTURE_2D GL_TEXTURE0 bind-texture-unit
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_LINEAR glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP glTexParameteri ;

M: terrain-world begin-world
    "2.0" { "GL_ARB_vertex_buffer_object" "GL_ARB_shader_objects" }
    require-gl-version-or-extensions
    GL_DEPTH_TEST glEnable
    GL_TEXTURE_2D glEnable
    GL_VERTEX_ARRAY glEnableClientState
    0.5 0.5 0.5 1.0 glClearColor
    EYE-START >>eye
    0.0 >>yaw
    0.0 >>pitch
    <terrain> [ >>terrain ] keep
    { 0 0 } terrain-segment [ >>terrain-segment ] keep
    make-texture [ set-heightmap-texture-parameters ] keep >>terrain-texture
    terrain-vertex-shader terrain-pixel-shader <simple-gl-program>
    >>terrain-program
    vertex-array >vertex-buffer >>terrain-vertex-buffer
    TICK-LENGTH over <game-loop> [ >>game-loop ] keep start-loop
    reset-mouse
    drop ;

M: terrain-world end-world
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
        "heightmap" glGetUniformLocation 0 glUniform1i
        terrain-vertex-buffer>> draw-vertex-buffer
    ] with-gl-program ]
    tri gl-error ;

M: terrain-world focusable-child* drop t ;
M: terrain-world pref-dim* drop { 640 480 } ;

: terrain-window ( -- )
    [
        open-game-input
        f T{ world-attributes
            { world-class terrain-world }
            { title "Terrain" }
            { pixel-format-attributes {
                windowed
                double-buffered
                T{ depth-bits { value 24 } }
            } }
        } open-window
    ] with-ui ;
