! (c) 2008 Joe Groff, see license for details
USING: accessors alien.c-types continuations images kernel math
sequences ui.gadgets ui.gadgets.private ui.gadgets.worlds
ui.private ui ui.backend destructors locals ;
IN: ui.offscreen

TUPLE: offscreen-world < world ;

M: offscreen-world world-pixel-format-attributes
    { offscreen T{ depth-bits { value 16 } } } ;

: <offscreen-world> ( gadget title status -- world )
    offscreen-world new-world ;

M: offscreen-world graft*
    (open-offscreen-buffer) ;

M: offscreen-world ungraft*
    [ (ungraft-world) ]
    [ handle>> (close-offscreen-buffer) ]
    [ reset-world ] tri ;

: open-offscreen ( gadget -- world )
    "" f <offscreen-world>
    [ open-world-window ] [ relayout-1 ] [ ] tri
    notify-queued ;

: close-offscreen ( world -- )
    ungraft notify-queued ;

:: bgrx>bitmap ( alien w h -- image )
    <image>
        { w h } >>dim
        alien w h * 4 * memory>byte-array >>bitmap
        BGRX >>component-order ;

: offscreen-world>bitmap ( world -- image )
    offscreen-pixels bgrx>bitmap ;

: do-offscreen ( gadget quot: ( offscreen-world -- ) -- )
    [ open-offscreen ] dip
    over [ slip ] [ close-offscreen ] [ ] cleanup ; inline

: gadget>bitmap ( gadget -- image )
    [ offscreen-world>bitmap ] do-offscreen ;
