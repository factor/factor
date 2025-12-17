! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.data arrays colors combinators kernel
locals math math.vectors namespaces opengl opengl.gl sequences
specialized-arrays ui.pens ui.pens.caching ui.render ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
IN: ui.pens.gradient

! Gradient pen
TUPLE: gradient < caching-pen colors last-vertices last-colors ;

: <gradient> ( colors -- gradient ) gradient new swap >>colors ;

<PRIVATE

:: gradient-vertices ( direction dim colors -- seq )
    direction dim v* dim over v- swap
    colors length [ <iota> ] [ 1 - ] bi v/n [ v*n ] with map
    swap [ over v+ 2array ] curry map
    concat concat float >c-array ;

: gradient-colors ( colors -- seq )
    [ >rgba-components 4array dup 2array ] map concat concat
    float >c-array ;

:: quad-strip-to-triangles ( vertices colors -- float-array )
    ! vertices is a flat array of x,y coordinates (4 floats per color stripe: 2 vertices * 2 coords)
    ! colors is a flat array of r,g,b,a components (8 floats per color: 4 components * 2 vertices)
    ! Convert quad strip to triangles: each quad becomes 2 triangles
    ! Quad strip with N colors has 2*N vertices arranged as pairs:
    !   (left0, right0), (left1, right1), ...
    ! Each quad from stripe i to i+1 becomes triangles

    ! Calculate num-colors from vertices (4 floats per color stripe)
    vertices length 4 / >integer :> num-colors
    num-colors 1 - :> num-quads
    num-quads 6 * 6 * <float-array> :> result  ! 6 vertices per quad, 6 floats per vertex (x,y,r,g,b,a)

    num-quads <iota> [| i |
        ! For quad i, get the 4 vertices
        i 2 * 2 * :> v0-idx  ! top-left vertex index in vertices array
        v0-idx 2 + :> v2-idx  ! top-right
        v0-idx 2 + :> v1-idx-offset
        v0-idx 2 + 2 + :> v3-idx  ! bottom-right (offset by 2 from v2)

        ! Actual indices in the vertices array
        i 2 * 2 * :> v0-pos
        i 2 * 1 + 2 * :> v1-pos
        i 1 + 2 * 2 * :> v2-pos
        i 1 + 2 * 1 + 2 * :> v3-pos

        ! Color indices (8 floats per color stripe: 4 components * 2 vertices)
        i 8 * :> c0-idx
        i 1 + 8 * :> c1-idx

        ! Triangle 1: v0, v1, v2
        ! Triangle 2: v2, v1, v3
        i 36 * :> base-idx  ! 36 floats per quad (6 vertices * 6 floats)

        ! Vertex 0 (x, y, r, g, b, a)
        v0-pos vertices nth base-idx 0 + result set-nth
        v0-pos 1 + vertices nth base-idx 1 + result set-nth
        c0-idx colors nth base-idx 2 + result set-nth
        c0-idx 1 + colors nth base-idx 3 + result set-nth
        c0-idx 2 + colors nth base-idx 4 + result set-nth
        c0-idx 3 + colors nth base-idx 5 + result set-nth

        ! Vertex 1 (x, y, r, g, b, a)
        v1-pos vertices nth base-idx 6 + result set-nth
        v1-pos 1 + vertices nth base-idx 7 + result set-nth
        c0-idx colors nth base-idx 8 + result set-nth
        c0-idx 1 + colors nth base-idx 9 + result set-nth
        c0-idx 2 + colors nth base-idx 10 + result set-nth
        c0-idx 3 + colors nth base-idx 11 + result set-nth

        ! Vertex 2 (x, y, r, g, b, a)
        v2-pos vertices nth base-idx 12 + result set-nth
        v2-pos 1 + vertices nth base-idx 13 + result set-nth
        c1-idx colors nth base-idx 14 + result set-nth
        c1-idx 1 + colors nth base-idx 15 + result set-nth
        c1-idx 2 + colors nth base-idx 16 + result set-nth
        c1-idx 3 + colors nth base-idx 17 + result set-nth

        ! Vertex 2 again (x, y, r, g, b, a)
        v2-pos vertices nth base-idx 18 + result set-nth
        v2-pos 1 + vertices nth base-idx 19 + result set-nth
        c1-idx colors nth base-idx 20 + result set-nth
        c1-idx 1 + colors nth base-idx 21 + result set-nth
        c1-idx 2 + colors nth base-idx 22 + result set-nth
        c1-idx 3 + colors nth base-idx 23 + result set-nth

        ! Vertex 1 again (x, y, r, g, b, a)
        v1-pos vertices nth base-idx 24 + result set-nth
        v1-pos 1 + vertices nth base-idx 25 + result set-nth
        c0-idx colors nth base-idx 26 + result set-nth
        c0-idx 1 + colors nth base-idx 27 + result set-nth
        c0-idx 2 + colors nth base-idx 28 + result set-nth
        c0-idx 3 + colors nth base-idx 29 + result set-nth

        ! Vertex 3 (x, y, r, g, b, a)
        v3-pos vertices nth base-idx 30 + result set-nth
        v3-pos 1 + vertices nth base-idx 31 + result set-nth
        c1-idx colors nth base-idx 32 + result set-nth
        c1-idx 1 + colors nth base-idx 33 + result set-nth
        c1-idx 2 + colors nth base-idx 34 + result set-nth
        c1-idx 3 + colors nth base-idx 35 + result set-nth
    ] each

    result ;

M: gradient recompute-pen
    [ nip ] [ [ [ orientation>> ] [ dim>> ] bi ] [ colors>> ] bi* ] 2bi
    [ gradient-vertices >>last-vertices ]
    [ gradient-colors >>last-colors ]
    bi gl3-mode? get-global [
        dup [ last-vertices>> ] [ last-colors>> ] bi
        quad-strip-to-triangles >>last-vertices
    ] when drop ;

: draw-gradient ( colors -- )
    GL_COLOR_ARRAY [
        [ GL_QUAD_STRIP 0 ] dip length 2 * glDrawArrays
    ] do-enabled-client-state ;

PRIVATE>

M: gradient draw-interior
    {
        [ compute-pen ]
        [ last-vertices>> ]
        [ last-colors>> ]
        [ colors>> ]
    } cleave
    gl3-mode? get-global [
        2drop use-vertex-colors [ upload-vertices ] [ length 6 /i ] bi
        GL_TRIANGLES 0 rot glDrawArrays
    ] [
        [ gl-vertex-pointer ] [ gl-color-pointer ] [ draw-gradient ] tri*
    ] if ;

M: gradient pen-background 2drop transparent ;
