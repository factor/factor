
USING: kernel io namespaces arrays sequences combinators math x11.xlib
       mortar slot-accessors x ;

IN: x.widgets

SYMBOL: <widget>

<widget> <window> { "mask" } accessors define-simple-class

<widget> {

"init-widget" !( widget -- widget )
  [ <- init-window <- add-to-window-table dup $mask <-- select-input ]

"add-to-window-table" !( window -- window )
  [ dup $dpy over <-- add-to-window-table ]

"remove-from-window-table" !( window -- window )
  [ dup $dpy over <-- remove-from-window-table ]

"handle-event" !( event widget -- ) [ 
  over XAnyEvent-type
  { { [ dup Expose = ]           [ drop <- handle-expose ] }
    { [ dup KeyPress = ]         [ drop <- handle-key-press ] }
    { [ dup ButtonPress = ]      [ drop <- handle-button-press ] }
    { [ dup EnterNotify = ]      [ drop <- handle-enter-window ] }
    { [ dup DestroyNotify = ]    [ drop <- handle-destroy-window ] }
    { [ dup MapRequest = ]       [ drop <- handle-map-request ] }
    { [ dup MapNotify = ]        [ drop <- handle-map ] }
    { [ dup ConfigureRequest = ] [ drop <- handle-configure-request ] }
    { [ dup UnmapNotify = ]      [ drop <- handle-unmap ] }
    { [ dup PropertyNotify = ]   [ drop <- handle-property ] }
    { [ t ]                      [ "handle-event :: ignoring event"
      	    			     print flush 3drop ] }
  } cond ]

} add-methods