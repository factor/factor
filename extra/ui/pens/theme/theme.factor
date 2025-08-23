USING: accessors colors kernel math opengl ui.pens
ui.pens.caching ui.theme ;
IN: ui.pens.theme

TUPLE: theme-pen < caching-pen
    background foreground
    interior-vertices boundary-vertices ;

: <theme-pen> ( -- theme-pen )
    theme-pen new
        [ content-background ] >>background
        [ text-color ] >>foreground ;

M: theme-pen recompute-pen
    swap dim>>
    [ [ { 0 0 } ] dip (fill-rect-vertices) >>interior-vertices ]
    [ [ { 0 0 } ] dip (rect-vertices) >>boundary-vertices ]
    bi drop ;

M: theme-pen draw-interior
    [ compute-pen ]
    [ background>> call( -- color ) gl-color ]
    [ interior-vertices>> gl-vertex-pointer ] tri
    (gl-fill-rect) ;

M: theme-pen draw-boundary
    [ compute-pen ]
    [ background>> call( -- color ) gl-color ]
    [ boundary-vertices>> gl-vertex-pointer ] tri
    (gl-rect) ;

M: theme-pen pen-background
    nip background>> call( -- color )
    dup alpha>> 1 number= [ drop transparent ] unless ;

M: theme-pen pen-foreground
    nip foreground>> call( -- color )
    dup alpha>> 1 number= [ drop transparent ] unless ;

: themed ( gadget -- gadget )
    <theme-pen> [ >>interior ] [ >>boundary ] bi ;
