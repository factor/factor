! (c)2009 Joe Groff bsd license
USING: accessors arrays destructors kernel math opengl
opengl.gl sequences sequences.product specialized-arrays ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
IN: grid-meshes

TUPLE: grid-mesh dim buffer row-length ;

<PRIVATE

: vertex-array-vertex ( dim x z -- vertex )
    [ swap first /f ]
    [ swap second /f ] bi-curry* bi
    [ 0 ] dip float-array{ } 3sequence ;

: vertex-array-row ( dim z -- vertices )
    dup 1 + 2array
    over first 1 + iota
    2array [ first2 swap vertex-array-vertex ] with product-map
    concat ;

: vertex-array ( dim -- vertices )
    dup second iota
    [ vertex-array-row ] with map concat ;

: >vertex-buffer ( bytes -- buffer )
    [ GL_ARRAY_BUFFER ] dip GL_STATIC_DRAW <gl-buffer> ;

: draw-vertex-buffer-row ( grid-mesh i -- )
    swap [ GL_TRIANGLE_STRIP ] 2dip
    row-length>> [ * ] keep
    glDrawArrays ;

PRIVATE>

: draw-grid-mesh ( grid-mesh -- )
    GL_ARRAY_BUFFER over buffer>> [
        [ 3 GL_FLOAT 0 f glVertexPointer ] dip
        dup dim>> second iota [ draw-vertex-buffer-row ] with each
    ] with-gl-buffer ;

: <grid-mesh> ( dim -- grid-mesh )
    [ ] [ vertex-array >vertex-buffer ] [ first 1 + 2 * ] tri
    grid-mesh boa ;

M: grid-mesh dispose
    [ [ delete-gl-buffer ] when* f ] change-buffer
    drop ;

