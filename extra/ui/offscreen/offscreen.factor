! (c) 2008 Joe Groff, see license for details
USING: accessors continuations images.bitmap kernel math
sequences ui.gadgets ui.gadgets.worlds ui ui.backend
destructors ;
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
    "" f <offscreen-world>
    [ open-world-window dup relayout-1 ] keep
    notify-queued ;

: close-offscreen ( world -- )
    ungraft notify-queued ;

: offscreen-world>bitmap ( world -- bitmap )
    offscreen-pixels bgra>bitmap ;

: do-offscreen ( gadget quot: ( offscreen-world -- ) -- )
    [ open-offscreen ] dip
    over [ slip ] [ close-offscreen ] [ ] cleanup ; inline

: gadget>bitmap ( gadget -- bitmap )
    [ offscreen-world>bitmap ] do-offscreen ;
