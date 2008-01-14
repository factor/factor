USING: arrays bunny io io.files kernel
       math math.functions math.vectors
       namespaces
       opengl opengl.gl
       prettyprint
       sequences ui ui.gadgets ui.gestures ui.render ;
IN: cel-shading

: NEAR-PLANE 1.0 64.0 / ; inline
: FAR-PLANE 4.0 ; inline
: FOV 2.0 sqrt 1+ ; inline
: MOUSE-MOTION-SCALE 0.5 ; inline
: MOUSE-DISTANCE-SCALE 1.0 64.0 / ; inline
: KEY-ROTATE-STEP 1.0 ; inline
: KEY-DISTANCE-STEP 1.0 64.0 / ; inline
: DIMS { 640 480 } ; inline

: FOV-RATIO ( -- fov ) DIMS dup first2 min v/n ;

SYMBOL: last-drag-loc

TUPLE: cel-shading-gadget yaw pitch distance model program ;

: <cel-shading-gadget> ( -- cel-shading-gadget )
    cel-shading-gadget construct-gadget
    0.0 over set-cel-shading-gadget-yaw
    0.0 over set-cel-shading-gadget-pitch
    0.375 over set-cel-shading-gadget-distance
    maybe-download read-model over set-cel-shading-gadget-model ;

: yaw-cel-shading-gadget ( yaw gadget -- )
    [ [ cel-shading-gadget-yaw + ] keep set-cel-shading-gadget-yaw ] keep relayout-1 ;

: pitch-cel-shading-gadget ( pitch gadget -- )
    [ [ cel-shading-gadget-pitch + ] keep set-cel-shading-gadget-pitch ] keep relayout-1 ;

: zoom-cel-shading-gadget ( distance gadget -- )
    [ [ cel-shading-gadget-distance + ] keep set-cel-shading-gadget-distance ] keep relayout-1 ;

M: cel-shading-gadget pref-dim* ( gadget -- dim )
    drop DIMS ;

: -+ ( x -- -x x )
    dup neg swap ;

: cel-shading-frustum ( -- -x x -y y near far )
    FOV-RATIO NEAR-PLANE FOV / v*n
    first2 [ -+ ] 2apply NEAR-PLANE FAR-PLANE ;

: cel-shading-vertex-shader-source
    {
        "varying vec3 position, normal;"
        ""
        "void"
        "main()"
        "{"
            "gl_Position = ftransform();"
            ""
            "position = gl_Vertex.xyz;"
            "normal = gl_Normal;"
        "}"
    } "\n" join ;

: cel-shading-fragment-shader-source
    {
        "varying vec3 position, normal;"
        "uniform vec3 light_direction;"
        "uniform vec4 color;"
        "uniform vec4 ambient, diffuse;"
        ""
        "float"
        "smooth_modulate(vec3 direction, vec3 normal)"
        "{"
            "return clamp(dot(direction, normal), 0.0, 1.0);"
        "}"
        ""
        "float"
        "modulate(vec3 direction, vec3 normal)"
        "{"
            "float m = smooth_modulate(direction, normal);"
            "return smoothstep(0.0, 0.01, m) * 0.4 + smoothstep(0.49, 0.5, m) * 0.5;"
        "}"
        ""
        "void"
        "main()"
        "{"
            "vec3 direction = normalize(light_direction - position);"
            "gl_FragColor = ambient + diffuse * color * vec4(vec3(modulate(direction, normal)), 1); "
        "}"
    } "\n" join ;

: cel-shading-program ( -- program )
    cel-shading-vertex-shader-source <vertex-shader> check-gl-shader
    cel-shading-fragment-shader-source <fragment-shader> check-gl-shader
    2array <gl-program> check-gl-program ;

M: cel-shading-gadget graft* ( gadget -- )
    0.0 0.0 0.0 1.0 glClearColor
    GL_CULL_FACE glEnable
    GL_DEPTH_TEST glEnable
    cel-shading-program swap set-cel-shading-gadget-program ;

M: cel-shading-gadget ungraft* ( gadget -- )
    cel-shading-gadget-program delete-gl-program ;

: cel-shading-draw-setup ( gadget -- gadget )
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    cel-shading-frustum glFrustum
    GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT bitor glClear
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    [ >r 0.0 0.0 r> cel-shading-gadget-distance neg glTranslatef ] keep
    [ cel-shading-gadget-pitch 1.0 0.0 0.0 glRotatef ] keep
    [ cel-shading-gadget-yaw   0.0 1.0 0.0 glRotatef ] keep
    [ cel-shading-gadget-program [ "light_direction" glGetUniformLocation -25.0 45.0 80.0 glUniform3f ] keep
                                   [ "color" glGetUniformLocation 0.6 0.5 0.5 1.0 glUniform4f ] keep
                                   [ "ambient" glGetUniformLocation 0.2 0.2 0.2 0.2 glUniform4f ] keep
                                   "diffuse" glGetUniformLocation 0.8 0.8 0.8 0.8 glUniform4f ] keep ;

M: cel-shading-gadget draw-gadget* ( gadget -- )
    dup cel-shading-gadget-program [
        cel-shading-draw-setup
        0.0 -0.12 0.0 glTranslatef
        cel-shading-gadget-model first3 draw-bunny
    ] with-gl-program ;

: reset-last-drag-rel ( -- )
    { 0 0 } last-drag-loc set ;
: last-drag-rel ( -- rel )
    drag-loc [ last-drag-loc get v- ] keep last-drag-loc set ;

: drag-yaw-pitch ( -- yaw pitch )
    last-drag-rel MOUSE-MOTION-SCALE v*n first2 ;

cel-shading-gadget H{
    { T{ key-down f f "LEFT"  } [ KEY-ROTATE-STEP neg swap yaw-cel-shading-gadget ] }
    { T{ key-down f f "RIGHT" } [ KEY-ROTATE-STEP     swap yaw-cel-shading-gadget ] }
    { T{ key-down f f "DOWN"  } [ KEY-ROTATE-STEP neg swap pitch-cel-shading-gadget ] }
    { T{ key-down f f "UP"    } [ KEY-ROTATE-STEP     swap pitch-cel-shading-gadget ] }
    { T{ key-down f f "="     } [ KEY-DISTANCE-STEP neg swap zoom-cel-shading-gadget ] }
    { T{ key-down f f "-"     } [ KEY-DISTANCE-STEP     swap zoom-cel-shading-gadget ] }
    
    { T{ button-down f f 1 }    [ drop reset-last-drag-rel ] }
    { T{ drag f 1 }             [ drag-yaw-pitch rot [ pitch-cel-shading-gadget ] keep yaw-cel-shading-gadget ] }
    { T{ mouse-scroll }         [ scroll-direction get second MOUSE-DISTANCE-SCALE * swap zoom-cel-shading-gadget ] }
} set-gestures

: cel-shading-window ( -- )
    [ <cel-shading-gadget> "Cel Shading" open-window ] with-ui ;
    
MAIN: cel-shading-window
