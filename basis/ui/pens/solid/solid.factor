! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors colors kernel math namespaces opengl ui.pens
ui.pens.caching ui.render ;
IN: ui.pens.solid

TUPLE: solid < caching-pen color interior-vertices boundary-vertices ;

: <solid> ( color -- solid ) solid new swap >>color ;

M: solid recompute-pen
    swap dim>> { 0 0 } swap
    gl3-mode? get-global [
        [ (gl3-fill-rect*-vertices) >>interior-vertices ]
        [ (gl3-rect*-vertices) >>boundary-vertices ] 2bi
    ] [
        [ (fill-rect-vertices) >>interior-vertices ]
        [ (rect-vertices) >>boundary-vertices ] 2bi
    ] if drop ;

<PRIVATE

: (solid) ( gadget pen -- )
    [ compute-pen ] [ color>> gl-color ] bi ;

PRIVATE>

M: solid draw-interior
    [ (solid) ] [ interior-vertices>> ] bi
    gl3-mode? get-global [
        upload-vertices (gl3-fill-rect)
    ] [
        gl-vertex-pointer (gl-fill-rect)
    ] if ;

M: solid draw-boundary
    [ (solid) ] [ boundary-vertices>> ] bi
    gl3-mode? get-global [
        upload-vertices (gl3-rect)
    ] [
        gl-vertex-pointer (gl-rect)
    ] if ;

M: solid pen-background
    nip color>> dup alpha>> 1 number= [ drop transparent ] unless ;
