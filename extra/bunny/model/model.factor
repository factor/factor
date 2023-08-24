USING: accessors alien.c-types alien.data arrays combinators
destructors http.client io io.encodings.ascii io.files
io.files.temp kernel math math.parser math.vectors opengl
opengl.capabilities opengl.demo-support opengl.gl sequences
specialized-arrays splitting vectors ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAY: c:float
SPECIALIZED-ARRAY: c:uint
IN: bunny.model

: numbers ( str -- seq )
    split-words [ string>number ] map sift ;

: (parse-model) ( vs is -- vs is )
    readln [
        numbers {
            { [ dup length 5 = ] [ 3 head pick push ] }
            { [ dup first 3 = ] [ rest over push ] }
            [ drop ]
        } cond (parse-model)
    ] when* ;

: parse-model ( -- vs is )
    100000 <vector> 100000 <vector> (parse-model) ;

: n ( vs triple -- n )
    swap [ nth ] curry map
    [ [ second ] [ first ] bi v- ] [ [ third ] [ first ] bi v- ] bi cross
    vneg normalize ;

: normal ( ns vs triple -- )
    [ n ] keep [ rot [ v+ ] change-nth ] 2with each ;

: normals ( vs is -- ns )
    [ [ length { 0.0 0.0 0.0 } <array> ] keep ] dip
    [ [ 2dup ] dip normal ] each drop
    [ normalize ] map ;

: read-model ( stream -- model )
    ascii [ parse-model ] with-file-reader
    [ normals ] 2keep 3array ;

: model-path ( -- path ) "bun_zipper.ply" cache-file ;

CONSTANT: model-url
"https://downloads.factorcode.org/misc/bun_zipper.ply"

: download-bunny ( -- path )
    model-url model-path [ ?download-to ] keep ;

:: (draw-triangle) ( ns vs triple -- )
    triple [| elt |
        elt ns nth gl-normal
        elt vs nth gl-vertex
    ] each ;

: draw-triangles ( ns vs is -- )
    GL_TRIANGLES [ [ (draw-triangle) ] 2with each ] do-state ;

TUPLE: bunny-dlist list ;
TUPLE: bunny-buffers array element-array nv ni ;

: <bunny-dlist> ( model -- geom )
    GL_COMPILE [ first3 draw-triangles ] make-dlist
    bunny-dlist boa ;

: <bunny-buffers> ( model -- geom )
    {
        [
            [ first concat ] [ second concat ] bi
            append c:float >c-array underlying>>
            GL_ARRAY_BUFFER swap GL_STATIC_DRAW <gl-buffer>
        ]
        [
            third concat c:uint >c-array underlying>>
            GL_ELEMENT_ARRAY_BUFFER swap GL_STATIC_DRAW <gl-buffer>
        ]
        [ first length 3 * ]
        [ third length 3 * ]
    } cleave bunny-buffers boa ;

GENERIC: bunny-geom ( geom -- )
GENERIC: draw-bunny ( geom draw -- )

M: bunny-dlist bunny-geom
    list>> glCallList ;

M: bunny-buffers bunny-geom
    dup [ array>> ] [ element-array>> ] bi [
        { GL_VERTEX_ARRAY GL_NORMAL_ARRAY } [
            GL_FLOAT 0 0 buffer-offset glNormalPointer
            [
                nv>> c:float heap-size * buffer-offset
                [ 3 GL_FLOAT 0 ] dip glVertexPointer
            ] [
                ni>>
                GL_TRIANGLES swap GL_UNSIGNED_INT 0 buffer-offset glDrawElements
            ] bi
        ] all-enabled-client-state
    ] with-array-element-buffers ;

M: bunny-dlist dispose
    list>> delete-dlist ;

M: bunny-buffers dispose
    [ array>> ] [ element-array>> ] bi
    delete-gl-buffer delete-gl-buffer ;

: <bunny-geom> ( model -- geom )
    "1.5" { "GL_ARB_vertex_buffer_object" }
    has-gl-version-or-extensions?
    [ <bunny-buffers> ] [ <bunny-dlist> ] if ;
