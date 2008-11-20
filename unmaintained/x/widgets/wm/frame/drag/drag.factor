
USING: kernel namespaces arrays sequences combinators math.vectors
       x11.xlib x11.constants
       mortar slot-accessors x x.gc geom.rect ;

IN: x.widgets.wm.frame.drag

SYMBOL: <wm-frame-drag>

<wm-frame-drag>
  { "dpy" "gc" "frame" "event" "push" "posn" } accessors
define-independent-class

<wm-frame-drag> {

"next-event" !( wfdm -- wfdm ) [ dup $dpy over $event <-- next-event 2drop ]

"event-type" !( wfdm -- wfdm event-type ) [ dup $event XAnyEvent-type ]

"drag-offset" !( wfdm -- offset ) [ dup $posn swap $push v- ]

"update-posn" !( wfd -- wfd ) [ dup $event XMotionEvent-root-position >>posn ]

} add-methods
