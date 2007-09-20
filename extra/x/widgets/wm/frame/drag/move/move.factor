
USING: kernel combinators namespaces math.vectors x11.xlib x11.constants 
       mortar slot-accessors x x.gc x.widgets.wm.frame.drag ;

IN: x.widgets.wm.frame.drag.move

SYMBOL: <wm-frame-drag-move>

<wm-frame-drag-move> <wm-frame-drag> { } define-simple-class

<wm-frame-drag-move> "create" !( event frame <wm-frame-drag-move> -- ) [
  new-empty swap >>frame swap >>event dup $frame $dpy >>dpy

  <gc> new*
    IncludeInferiors <-- set-subwindow-mode
    GXxor            <-- set-function
    "white"          <-- set-foreground
  >>gc

  dup $event XButtonEvent-root-position >>push
  dup $event XButtonEvent-root-position >>posn
  <- draw-move-outline
  <- loop
] add-class-method

<wm-frame-drag-move> {

"move-outline" !( wfdm -- rect )
  [ dup $frame <- as-rect swap <- drag-offset <-- move-by ]

"draw-move-outline" !( wfdm -- wfdm )
  [ dpy get $default-root over $gc pick <- move-outline <--- draw-rect ]

"loop" !( wfdm -- wfdm ) [ 
  <- next-event
  { { [ <- event-type MotionNotify = ]
      [ <- draw-move-outline <- update-posn <- draw-move-outline <- loop ] }
    { [ <- event-type ButtonRelease = ]
      [ <- draw-move-outline
      	dup $frame <- position over <- drag-offset v+ >r
	dup $frame r> <-- move drop
	dup $frame <- raise drop drop ] }
    { [ t ] [ <- loop ] } }
  cond ]

} add-methods
