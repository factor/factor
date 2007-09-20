
USING: kernel combinators namespaces math.vectors x11.xlib x11.constants 
       mortar slot-accessors geom.rect x x.gc x.widgets.wm.frame.drag ;

IN: x.widgets.wm.frame.drag.size

SYMBOL: <wm-frame-drag-size>

<wm-frame-drag-size> <wm-frame-drag> { } define-simple-class

<wm-frame-drag-size> "create" !( event frame <wfds> -- ) [ 
  new-empty swap >>frame swap >>event
  dup $frame $dpy >>dpy

  <gc> new*
    IncludeInferiors <-- set-subwindow-mode
    GXxor <-- set-function
    "white" <-- set-foreground
  >>gc

  dup $event XButtonEvent-root-position >>push
  dup $event XButtonEvent-root-position >>posn
  <- draw-size-outline <- loop
] add-class-method

<wm-frame-drag-size> {

"size-outline" !( wfds -- rect )
  [ dup $frame <- position swap $posn over v- <rect> new ]

"draw-size-outline" !( wfdm -- wfdm )
  [ dup $dpy $default-root over $gc pick <- size-outline <--- draw-rect ]

"loop" !( wfdm -- ) [
  <- next-event
  { { [ <- event-type MotionNotify = ]
      [ <- draw-size-outline <- update-posn <- draw-size-outline <- loop ] }
    { [ <- event-type ButtonRelease = ]
      [ <- draw-size-outline
      	dup $frame over $posn pick $frame <- position v- <-- resize
	<- adjust-child drop ] }
    { [ t ] [ <- loop ] } }
  cond ]

} add-methods