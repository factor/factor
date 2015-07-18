! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel accessors opengl math colors ui.pens ui.pens.caching ;
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
    [ (solid) ] [ interior-vertices>> gl-vertex-pointer ] bi
    (gl-fill-rect) ;

M: solid draw-boundary
    [ (solid) ] [ boundary-vertices>> gl-vertex-pointer ] bi
    (gl-rect) ;

M: solid pen-background
    nip color>> dup alpha>> 1 number= [ drop transparent ] unless ;

TUPLE: solid-underlined < solid ;

: <solid-underlined> ( color -- solid-underlined ) 
    solid-underlined new swap >>color ;

<PRIVATE

: bottom-vertices-only ( vertices -- bottom-vertices )
    { 6 7 4 5 4 5 6 7 6 7 } swap nths ;

PRIVATE>

M: solid-underlined boundary-vertices>>
    call-next-method bottom-vertices-only ;
