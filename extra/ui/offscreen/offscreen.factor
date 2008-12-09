USING: accessors graphics.bitmap kernel math sequences
ui.gadgets ui.gadgets.worlds ui ui.backend ;
IN: ui.offscreen

TUPLE: offscreen-world < world ;

: <offscreen-world> ( gadget title status -- world )
    offscreen-world new-world ;

M: offscreen-world graft*
    (open-offscreen-buffer) ;

M: offscreen-world ungraft*
    [ (ungraft-world) ]
    [ handle>> (close-offscreen-buffer) ]
    [ reset-world ] tri ;

: open-offscreen ( gadget -- world )
    "" f <offscreen-world> [ open-world-window ] keep ;

: offscreen-world>bitmap ( world -- bitmap )
    [ handle>> offscreen-pixels ] [ dim>> first2 neg ] bi
    bgra>bitmap ;
    
