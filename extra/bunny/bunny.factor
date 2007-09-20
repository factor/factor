! From http://www.ffconsultancy.com/ocaml/bunny/index.html
USING: alien alien.c-types arrays sequences math
math.vectors math.matrices math.parser io io.files kernel opengl
opengl.gl opengl.glu shuffle http.client vectors timers
namespaces ui.gadgets ui.gadgets.canvas ui.render ui splitting
combinators tools.time system combinators.lib ;
IN: bunny

: numbers ( str -- seq )
    " " split [ string>number ] map [ ] subset ;

: (parse-model) ( vs is -- vs is )
    readln [
        numbers {
            { [ dup length 5 = ] [ 3 head pick push ] }
            { [ dup first 3 = ] [ 1 tail over push ] }
            { [ t ] [ drop ] }
        } cond (parse-model)
    ] when* ;

: parse-model ( stream -- vs is )
    [
        100000 <vector> 100000 <vector> (parse-model)
    ] with-stream
    [
        over length # " vertices, " %
        dup length # " triangles" %
    ] "" make print ;

: n ( vs triple -- n )
    swap [ nth ] curry map
    dup third over first v- >r dup second swap first v- r> cross
    vneg normalize ;

: normal ( ns vs triple -- )
    [ n ] keep [ rot [ v+ ] change-nth ] each-with2 ;

: normals ( vs is -- ns )
    over length { 0.0 0.0 0.0 } <array> -rot
    [ >r 2dup r> normal ] each drop
    [ normalize ] map ;

: read-model ( stream -- model )
    "Reading model" print flush [
        <file-reader> parse-model [ normals ] 2keep 3array
    ] time ;

: model-path "bun_zipper.ply" ;

: model-url "http://factorcode.org/bun_zipper.ply" ;

: maybe-download ( -- path )
    model-path resource-path dup exists? [
        "Downloading bunny from " write
        model-url dup print flush
        over download
    ] unless ;

: draw-triangle ( ns vs triple -- )
    [
        dup roll nth first3 glNormal3d
        swap nth first3 glVertex3d
    ] each-with2 ;

: draw-bunny ( ns vs is -- )
    GL_TRIANGLES [ [ draw-triangle ] each-with2 ] do-state ;

TUPLE: bunny-gadget model ;

: <bunny-gadget> ( model -- gadget )
    <canvas>
    { set-bunny-gadget-model set-delegate }
    bunny-gadget construct ;

M: bunny-gadget graft* 10 10 add-timer ;

M: bunny-gadget ungraft* dup delegate ungraft* remove-timer ;

M: bunny-gadget tick relayout-1 ;

: aspect ( gadget -- x ) rect-dim first2 /f ;

M: bunny-gadget draw-gadget*
    GL_DEPTH_TEST glEnable
    GL_SCISSOR_TEST glDisable
    1.0 glClearDepth
    0.0 0.0 0.0 1.0 glClearColor
    GL_DEPTH_BUFFER_BIT GL_COLOR_BUFFER_BIT bitor glClear
    GL_PROJECTION glMatrixMode
    glLoadIdentity
    45.0 over aspect 0.1 1.0 gluPerspective
    0.0 0.12 -0.25  0.0 0.1 0.0  0.0 1.0 0.0 gluLookAt
    GL_MODELVIEW glMatrixMode
    glLoadIdentity
    GL_LEQUAL glDepthFunc
    GL_LIGHTING glEnable
    GL_LIGHT0 glEnable
    GL_COLOR_MATERIAL glEnable
    GL_LIGHT0 GL_POSITION { 1.0 -1.0 1.0 1.0 } >c-float-array glLightfv
    millis 24000 mod 0.015 * 0.0 1.0 0.0 glRotated
    GL_FRONT_AND_BACK GL_SHININESS 100.0 glMaterialf
    GL_FRONT_AND_BACK GL_SPECULAR glColorMaterial
    GL_FRONT_AND_BACK GL_AMBIENT_AND_DIFFUSE glColorMaterial
    0.6 0.5 0.5 1.0 glColor4d
    [ bunny-gadget-model first3 draw-bunny ] draw-canvas ;

M: bunny-gadget pref-dim* drop { 400 300 } ;

: bunny-window ( -- )
    [
        maybe-download read-model <bunny-gadget>
        "Bunny" open-window
    ] with-ui ;

MAIN: bunny-window
