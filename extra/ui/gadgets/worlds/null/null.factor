USING: accessors kernel ui ui.backend ui.gadgets
ui.gadgets.worlds ui.pixel-formats ;
IN: ui.gadgets.worlds.null

TUPLE: null-world < world ;
M: null-world begin-world drop ;
M: null-world end-world drop ;
M: null-world draw-world* drop ;
M: null-world resize-world drop ;

: null-window ( title -- world )
    <world-attributes>
        swap >>title
        null-world >>world-class
        {
            windowed
            double-buffered
            backing-store
            T{ depth-bits f 24 }
        } >>pixel-format-attributes
        { 512 512 } >>pref-dim
    f swap open-window* ;

: into-window ( world quot -- world )
    dupd with-gl-context ; inline
