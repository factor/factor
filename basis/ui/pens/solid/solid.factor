! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors colors kernel math namespaces opengl ui.pens
ui.pens.caching ui.render ;
IN: ui.pens.solid

TUPLE: solid < caching-pen color interior-vertices boundary-vertices ;

: <solid> ( color -- solid ) solid new swap >>color ;

M: solid recompute-pen
    swap dim>>
    [ [ { 0 0 } ] dip (fill-rect-vertices) >>interior-vertices ]
    [ [ { 0 0 } ] dip (rect-vertices) >>boundary-vertices ]
    bi drop ;

<PRIVATE

: (solid) ( gadget pen -- )
    [ compute-pen ] [ color>> gl-color ] bi ;

PRIVATE>

M: solid draw-interior
    gl3-mode? get-global [
        [ (solid) ] [ drop dim>> { 0 0 } swap gl-fill-rect ] 2bi
    ] [
        [ (solid) ] [ interior-vertices>> gl-vertex-pointer ] bi
        (gl-fill-rect)
    ] if ;

M: solid draw-boundary
    gl3-mode? get-global [
        [ (solid) ] [ drop dim>> { 0 0 } swap gl-rect ] 2bi
    ] [
        [ (solid) ] [ boundary-vertices>> gl-vertex-pointer ] bi
        (gl-rect)
    ] if ;

M: solid pen-background
    nip color>> dup alpha>> 1 number= [ drop transparent ] unless ;
