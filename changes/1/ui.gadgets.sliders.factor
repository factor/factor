USING: accessors combinators kernel math.vectors ui.gadgets
ui.gadgets.sliders.private ui.gadgets.tracks ;
IN: ui.gadgets.sliders

: <slider> ( range orientation -- slider )
    slider new-track
        swap >>model
        16 >>line
        dup orientation>> {
            [ <thumb> >>thumb ]
            [ <elevator> >>elevator ]
            [ drop dup add-thumb-to-elevator 1 track-add ]
        } cleave ;

M: slider pref-dim*
    [ slider-enabled? [ { 16 16 } ] [ { 0 0 } ] if ]
    [ drop { 0 0 } ]
    [ orientation>> ] tri set-axis ;
