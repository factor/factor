! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data.map destructors grouping kernel math
math.vectors.simd namespaces opengl opengl.gl ranges sequences
specialized-arrays ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float-4
IN: grid-meshes

TUPLE: grid-mesh dim buffer row-length vertex-array ;

<PRIVATE

: vertex-array-row ( range z0 z1 -- vertices )
    '[ _ _ [ 0.0 swap 1.0 float-4-boa ] bi-curry@ bi ]
    data-map( object -- float-4[2] ) ; inline

: vertex-array ( dim -- vertices )
    first2 [ [ 0.0 1.0 1.0 ] dip /f <range> ] bi@
    2 <clumps> [ first2 vertex-array-row ] with map concat ;

: >vertex-buffer ( bytes -- buffer )
    [ GL_ARRAY_BUFFER ] dip GL_STATIC_DRAW <gl-buffer> ; inline

: draw-vertex-buffer-row ( grid-mesh i -- )
    swap [ GL_TRIANGLE_STRIP ] 2dip
    row-length>> [ * ] keep
    glDrawArrays ;

PRIVATE>

: draw-grid-mesh-rows ( grid-mesh -- )
    dup dim>> second <iota> [ draw-vertex-buffer-row ] with each ;

: draw-grid-mesh-legacy ( grid-mesh -- )
    GL_ARRAY_BUFFER over buffer>> [
        [ 4 GL_FLOAT 0 f glVertexPointer ] dip
        draw-grid-mesh-rows
    ] with-gl-buffer ;

: draw-grid-mesh ( grid-mesh -- )
    dup vertex-array>>
    [ [ draw-grid-mesh-rows ] with-vertex-array ]
    [ draw-grid-mesh-legacy ] if* ;

: init-grid-mesh-vertex-array ( grid-mesh -- grid-mesh )
    gen-vertex-array >>vertex-array
    dup vertex-array>> [
        GL_ARRAY_BUFFER over buffer>> [
            0 4 GL_FLOAT GL_FALSE 0 f glVertexAttribPointer
            0 glEnableVertexAttribArray
        ] with-gl-buffer
    ] with-vertex-array ;

: <grid-mesh> ( dim -- grid-mesh )
    [ ] [ vertex-array >vertex-buffer ] [ first 1 + 2 * ] tri
    f grid-mesh boa
    gl3-mode? get-global [ init-grid-mesh-vertex-array ] when ;

M: grid-mesh dispose
    [ [ delete-vertex-array ] when* f ] change-vertex-array
    [ [ delete-gl-buffer ] when* f ] change-buffer
    drop ;
