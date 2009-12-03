! (c)2009 Joe Groff bsd license
USING: accessors alien.data.map arrays destructors fry grouping
kernel math math.ranges math.vectors.simd opengl opengl.gl sequences
sequences.product specialized-arrays ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float-4
IN: grid-meshes

TUPLE: grid-mesh dim buffer row-length ;

<PRIVATE

: vertex-array-row ( range z0 z1 -- vertices )
    '[ _ _ [ 0.0 swap 1.0 float-4-boa ] bi-curry@ bi ]
    data-map( object -- float-4[2] ) ; inline

: vertex-array ( dim -- vertices )
    first2 [ [ 0.0 1.0 1.0 ] dip /f <range> ] bi@
    2 <sliced-clumps> [ first2 vertex-array-row ] with map concat ;

: >vertex-buffer ( bytes -- buffer )
    [ GL_ARRAY_BUFFER ] dip GL_STATIC_DRAW <gl-buffer> ; inline

: draw-vertex-buffer-row ( grid-mesh i -- )
    swap [ GL_TRIANGLE_STRIP ] 2dip
    row-length>> [ * ] keep
    glDrawArrays ;

PRIVATE>

: draw-grid-mesh ( grid-mesh -- )
    GL_ARRAY_BUFFER over buffer>> [
        [ 4 GL_FLOAT 0 f glVertexPointer ] dip
        dup dim>> second iota [ draw-vertex-buffer-row ] with each
    ] with-gl-buffer ;

: <grid-mesh> ( dim -- grid-mesh )
    [ ] [ vertex-array >vertex-buffer ] [ first 1 + 2 * ] tri
    grid-mesh boa ;

M: grid-mesh dispose
    [ [ delete-gl-buffer ] when* f ] change-buffer
    drop ;

