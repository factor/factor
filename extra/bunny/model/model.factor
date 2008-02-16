USING: alien alien.c-types arrays sequences math math.vectors math.matrices
    math.parser io io.files kernel opengl opengl.gl opengl.glu
    opengl.capabilities shuffle http.client vectors splitting tools.time system
    combinators combinators.cleave float-arrays continuations namespaces
    sequences.lib ;
IN: bunny.model

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
    100000 <vector> 100000 <vector> (parse-model) ;

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
        [ parse-model ] with-file-reader
        [ normals ] 2keep 3array
    ] time ;

: model-path "bun_zipper.ply" ;

: model-url "http://factorcode.org/bun_zipper.ply" ;

: maybe-download ( -- path )
    model-path resource-path dup exists? [
        "Downloading bunny from " write
        model-url dup print flush
        over download-to
    ] unless ;

: (draw-triangle) ( ns vs triple -- )
    [ dup roll nth gl-normal swap nth gl-vertex ] each-with2 ;

: draw-triangles ( ns vs is -- )
    GL_TRIANGLES [ [ (draw-triangle) ] each-with2 ] do-state ;

TUPLE: bunny-dlist list ;
TUPLE: bunny-buffers array element-array nv ni ;

: <bunny-dlist> ( model -- geom )
    GL_COMPILE [ first3 draw-triangles ] make-dlist
    bunny-dlist construct-boa ;

: <bunny-buffers> ( model -- geom )
    [
        [ first concat ] [ second concat ] bi
        append >float-array
        GL_ARRAY_BUFFER swap GL_STATIC_DRAW <gl-buffer>
    ] [
        third concat >c-uint-array
        GL_ELEMENT_ARRAY_BUFFER swap GL_STATIC_DRAW <gl-buffer>
    ]
    [ first length 3 * ] [ third length 3 * ] tetra
    bunny-buffers construct-boa ;

GENERIC: bunny-geom ( geom -- )
GENERIC: draw-bunny ( geom draw -- )

M: bunny-dlist bunny-geom
    bunny-dlist-list glCallList ;

M: bunny-buffers bunny-geom
    dup {
        bunny-buffers-array
        bunny-buffers-element-array
    } get-slots [
        { GL_VERTEX_ARRAY GL_NORMAL_ARRAY } [
            GL_DOUBLE 0 0 buffer-offset glNormalPointer
            dup bunny-buffers-nv "double" heap-size * buffer-offset
            3 GL_DOUBLE 0 roll glVertexPointer
            bunny-buffers-ni
            GL_TRIANGLES swap GL_UNSIGNED_INT 0 buffer-offset glDrawElements
        ] all-enabled-client-state
    ] with-array-element-buffers ;

M: bunny-dlist dispose
    bunny-dlist-list delete-dlist ;

M: bunny-buffers dispose
    { bunny-buffers-array bunny-buffers-element-array } get-slots
    delete-gl-buffer delete-gl-buffer ;

: <bunny-geom> ( model -- geom )
    "1.5" { "GL_ARB_vertex_buffer_object" }
    has-gl-version-or-extensions?
    [ <bunny-buffers> ] [ <bunny-dlist> ] if ;
