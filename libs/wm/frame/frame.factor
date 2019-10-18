
USING: kernel namespaces generic math arrays vars x11
       x.geometry x x.gc x.draw-string x.widgets wm.child ;

IN: wm.frame

TUPLE: frame child gc ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: fit-to-child ( frame -- )
GENERIC: position-child ( frame -- )
GENERIC: set-child-size ( size frame -- )
GENERIC: set-child-width ( width frame -- )
GENERIC: set-child-height ( height frame -- )
GENERIC: adjust-child ( frame -- )
GENERIC: update-title ( frame -- )

M: frame fit-to-child ( frame -- )
dup frame-child size { 10 20 } v+ swap resize ;

M: frame position-child ( frame -- ) frame-child { 5 15 } swap move ;

M: frame set-child-size ( size frame -- )
tuck frame-child resize fit-to-child ;

M: frame set-child-width ( width frame -- )
tuck frame-child set-width fit-to-child ;

M: frame set-child-height ( height frame -- )
tuck frame-child set-height fit-to-child ;

M: frame adjust-child ( frame -- )
dup size { 10 20 } v- swap frame-child resize ;

M: frame update-title ( frame -- )
dup clear-window
dup frame-gc { 5 1 } pick frame-child fetch-name draw-string/top-left ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: WM_PROTOCOLS
SYMBOL: WM_DELETE_WINDOW

: init-atoms ( -- )
"WM_PROTOCOLS" False intern-atom WM_PROTOCOLS set
"WM_DELETE_WINDOW" False intern-atom WM_DELETE_WINDOW set ;

GENERIC: delete-child ( frame -- )

M: frame delete-child ( frame -- )
WM_PROTOCOLS get WM_DELETE_WINDOW get rot frame-child send-client-message ;

! M: frame delete ( frame -- )
! WM_PROTOCOLS WM_DELETE_WINDOW rot frame-child send-client-message ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! drag-move and drag-size
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: x.draw x.rect ;

VARS: event frame push posn ;

: event-type ( -- type ) event> XAnyEvent-type ;

: drag-offset ( -- offset ) posn> push> v- ;

: as-rect ( window -- rect ) dup position swap size <rect> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: drag-gc

: init-drag-gc ( -- )
<gc>
IncludeInferiors over set-subwindow-mode
GXxor over set-function
"white" lookup-color over set-foreground-by-pixel
>drag-gc ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: move-outline ( -- rect ) drag-offset frame> as-rect tuck move-by ;

: draw-move-outline ( -- ) root drag-gc> move-outline draw-rect ;

: drag-move-frame-loop ( -- )
event> next-event
{ { [ event-type MotionNotify = ]
    [ draw-move-outline
      event> XMotionEvent-root-position >posn
      draw-move-outline
      drag-move-frame-loop ] }
  { [ event-type ButtonRelease = ]
    [ draw-move-outline
      drag-offset   frame> position   v+   frame> move ] }
  { [ t ] [ drag-move-frame-loop ] } }
cond ;

GENERIC: drag-move

M: frame drag-move ( event frame -- ) [ >frame >event
event> XButtonEvent-root-position >push
event> XButtonEvent-root-position >posn
draw-move-outline  drag-move-frame-loop  frame> raise
] with-scope ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: size-outline ( -- rect ) frame> position posn> over v- <rect> ;

: draw-size-outline ( -- ) root drag-gc> size-outline draw-rect ;

: drag-size-frame-loop ( -- )
event> next-event
{ { [ event-type MotionNotify = ]
    [ draw-size-outline
      event> XMotionEvent-root-position >posn
      draw-size-outline
      drag-size-frame-loop ] }
  { [ event-type ButtonRelease = ]
    [ draw-size-outline
      posn> frame> position v- frame> resize
      frame> adjust-child ] }
  { [ t ] [ drag-size-frame-loop ] } }
cond ;

GENERIC: drag-size

M: frame drag-size ( event frame -- ) [ >frame >event
event> XButtonEvent-root-position >posn
draw-size-outline
drag-size-frame-loop
] with-scope ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: delete-child-button frame ;

VARS: button frame ;

C: delete-child-button ( frame -- button ) [ >button >frame
"" frame> [ delete-child ] curry <button> >button
frame> button> reparent
{ 9 9 } button> resize
frame> width 9 -  5 -   3   2array button> move
NorthEastGravity button> set-gravity
"white" lookup-color button> set-background
button>
] with-scope ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: unmap-button frame ;

C: unmap-button ( frame -- button ) [ >button >frame
"" frame> [ unmap-window ] curry <button> >button
frame> button> reparent
{ 9 9 } button> resize
frame> width 9 - 5 - 9 - 5 -   3   2array button> move
NorthEastGravity button> set-gravity
"white" lookup-color button> set-background
button>
] with-scope ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! constructor
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VARS: child frame ;

: frame-mask ( -- mask )
{
  SubstructureRedirectMask
  ExposureMask
  ButtonPressMask
  ButtonReleaseMask
  ButtonMotionMask
  EnterWindowMask

  ! experimental masks
  SubstructureNotifyMask
  ! ClientMessage  

} ;

C: frame ( window -- frame ) [ >frame <child> >child
child> frame> set-frame-child
<gc> frame> set-frame-gc
"white" lookup-color frame> frame-gc set-foreground-by-pixel

<window> frame> set-delegate
frame> add-to-window-table
frame-mask frame> select-input

"cornflowerblue" lookup-color frame> set-background

child> position frame> move
frame> child> reparent
frame> position-child
frame> fit-to-child

frame> <delete-child-button> drop
frame> <unmap-button> drop

frame> map-subwindows
frame> map-window
] with-scope ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Event handlers
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: frame handle-enter-window ( event frame -- )
nip frame-child RevertToPointerRoot CurrentTime rot set-input-focus ;

M: frame handle-expose ( event frame -- ) nip dup clear-window update-title ;

M: frame handle-button-press ( event frame -- )
over XButtonEvent-button
{ { [ dup Button1 = ] [ drop drag-move ] }
  { [ dup Button2 = ] [ drop drag-size ] }
  { [ t ] [ 3drop ] } }
cond ;

USE: io

M: frame handle-map ( event frame -- )
"frame handle-map ignoring values" print flush 2drop ;

M: frame handle-unmap ( event frame -- ) nip unmap-window ;

M: frame handle-destroy-window ( event frame -- )
nip dup frame-child remove-from-window-table
dup remove-from-window-table
destroy ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! handle-configure-request
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bit-test ( a b -- t-or-f ) bitand 0 = not ;

VARS: event frame ;

: value-mask event> XConfigureRequestEvent-value_mask ;

: event-x event> XConfigureRequestEvent-x ;
: event-y event> XConfigureRequestEvent-y ;

: event-width  event> XConfigureRequestEvent-width ;
: event-height event> XConfigureRequestEvent-height ;

M: frame handle-configure-request ( event frame -- ) [ >frame >event

{ { [ value-mask CWX bit-test   value-mask CWY bit-test   and ]
    [ event-x event-y 2array frame> move ] }
  { [ value-mask CWX bit-test ] [ event-x frame> set-x ] }
  { [ value-mask CWY bit-test ] [ event-y frame> set-y ] }
  { [ t ]
    [ "frame handle-configure-request :: move not requested" print flush ] }
} cond

{ { [ value-mask CWWidth bit-test   value-mask CWHeight bit-test   and ]
    [ event-width event-height 2array frame> set-child-size ] }
  { [ value-mask CWWidth bit-test ] [ event-width frame> set-child-width ] }
  { [ value-mask CWHeight bit-test ] [ event-height frame> set-child-height ] }
  { [ t ]
    [ "frame handle-configure-request :: resize not requested" print flush ] }
} cond

] with-scope ;

