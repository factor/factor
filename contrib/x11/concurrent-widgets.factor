USING: io namespaces kernel hashtables math generic threads concurrency
lists sequences arrays xlib x ;

IN: concurrent-widgets

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: window display id ;

! dpy get create-window <window>

! window-object [ { 100 100 } move-window ] with-window-object

: create-window-object
  dpy get create-window <window> ;

: with-window-object ( <window> quot -- )
[ swap dup window-display dpy set window-id win set call ] with-scope ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! window-table add-to-window-table
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: window-table

10 <hashtable> window-table set-global

: add-to-window-table ( <window> -- )
dup window-id window-table get set-hash ;

: clean-window-table ( -- )
window-table get
[ drop dup valid-window?+ [ drop ] [ window-table get remove-hash ] if ]
hash-each ;

! The window-table is keyed on window ids. If support is added for
! multiple displays, then perhaps there should be a window table for
! each open display.

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! handle-event
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: handle-key-press-event
GENERIC: handle-key-release-event
GENERIC: handle-button-press-event
GENERIC: handle-button-release-event
GENERIC: handle-expose-event
GENERIC: handle-configure-event
GENERIC: handle-enter-window-event
GENERIC: handle-leave-window-event
GENERIC: handle-destroy-window-event
GENERIC: handle-map-request-event
GENERIC: handle-map-event
GENERIC: handle-configure-request-event
GENERIC: handle-unmap-event
GENERIC: handle-property-event

: handle-event ( event obj -- )
  over XAnyEvent-type
  { { [ dup Expose = ]		 [ drop handle-expose-event ] }
    { [ dup KeyPress = ]	 [ drop handle-key-press-event ] }
    { [ dup KeyRelease = ]	 [ drop handle-key-release-event ] }
    { [ dup ButtonPress = ]	 [ drop handle-button-press-event ] }
    { [ dup ButtonRelease = ]	 [ drop handle-button-release-event ] }
    { [ dup ConfigureNotify = ]	 [ drop handle-configure-event ] }
    { [ dup EnterNotify = ]	 [ drop handle-enter-window-event ] }
    { [ dup LeaveNotify = ]	 [ drop handle-leave-window-event ] }
    { [ dup DestroyNotify = ]	 [ drop handle-destroy-window-event ] }
    { [ dup MapRequest = ]	 [ drop handle-map-request-event ] }
    { [ dup MapNotify = ]	 [ drop handle-map-event ] }
    { [ dup ConfigureRequest = ] [ drop handle-configure-request-event ] }
    { [ dup UnmapNotify = ]      [ drop handle-unmap-event ] }
    { [ dup PropertyNotify = ]   [ drop handle-property-event ] }
    { [ t ] [ "handle-event ignoring event" print flush 3drop ] } }
  cond ;

M: window handle-configure-event ( event obj -- )
  "Basic handle-configure-event called" print flush drop drop ;

M: window handle-destroy-window-event ( event obj -- )
  "Basic handle-destroy-window-event called" print flush drop drop ;

M: window handle-map-event ( event obj -- )
  "Basic handle-map-event called" print flush drop drop ;

M: window handle-expose-event ( event obj -- )
  "Basic handle-expose-event called" print flush drop drop ;

M: window handle-button-release-event ( event obj -- )
  "Basic handle-button-release-event called" print flush drop drop ;

M: window handle-unmap-event ( event obj -- )
  "Basic handle-unmap-event called" print flush drop drop ;

M: window handle-key-press-event ( event obj -- )
  "Basic handle-key-press-event called" print flush drop drop ;

M: window handle-key-release-event ( event obj -- )
  "Basic handle-key-release-event called" print flush drop drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! <label>
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: label text ;

: create-label ( text -- <label> )
  >r create-window-object r> <label> dup >r set-delegate r>
  dup add-to-window-table
  dup >r
  >r ExposureMask r> [ select-input ] with-window-object
  r> ;

DEFER: draw-string%
DEFER: window-size%
DEFER: window-children%
DEFER: set-window-width%
DEFER: set-window-height%
DEFER: vertical-layout%
DEFER: map-subwindows%
DEFER: reparent-window%
DEFER: unmap-window%

! M: label handle-expose-event ( event <label> -- )
!   nip dup window-size% { 1/2 1/2 } v* swap
!   dup label-text swap
!   [ draw-string-middle-center ] with-window-object ;

M: label handle-expose-event ( event <label> -- )
  nip
  [ window-size% { 1/2 1/2 } v* ] keep
  [ label-text ] keep
  [ draw-string-middle-center ] with-window-object ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! <button>
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: button action ;

: create-button ( text action -- <button> )
swap create-label swap <button> dup >r set-delegate r>
dup add-to-window-table
>r ExposureMask ButtonPressMask bitor r>
dup >r [ select-input ] with-window-object
r> ;

M: button handle-button-press-event ( event <button> -- )
nip button-action call ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! <menu>
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: menu item-width item-height space ;

: create-menu ( -- <menu> )
  create-window-object 100 20 1 <menu> [ set-delegate ] keep ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-menu-children-height ( menu -- )
  dup menu-item-height swap window-children%
  [ set-window-height+ ]
  each-with ;

: set-menu-children-width ( menu -- )
  dup menu-item-width swap window-children%
  [ set-window-width+ ]
  each-with ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: center-menu-items ( menu -- )
  window-children% [ center-window-horizontally+ ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-menu-width ( menu -- )
  dup menu-space 2 *
  over menu-item-width +
  swap set-window-width% ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: menu-items-height ( menu -- height )
  dup window-children% length swap menu-item-height * ;

: menu-space-height ( menu -- height )
  dup window-children% length 1 - 2 +
  swap menu-space * ;

: menu-height ( menu -- height )
  dup menu-items-height swap menu-space-height + ;

: set-menu-height ( menu -- )
  dup menu-height swap set-window-height% ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: refresh-menu ( menu -- )
  dup set-menu-children-height
  dup set-menu-children-width
  dup set-menu-width
  dup set-menu-height
  dup menu-space over vertical-layout%
  dup center-menu-items
  map-subwindows% ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: add-menu-item ( text action menu -- )
  -rot create-button dupd reparent-window%
  refresh-menu ;

: modify-action-to-unmap ( action menu -- action )
  [ unmap-window% ] cons append ;

: add-popup-menu-item ( text action menu -- )
  tuck modify-action-to-unmap
  swap add-menu-item ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! <pwindow>
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! window with parameterizable responses to events

TUPLE: pwindow resize-action last-size move-action last-position
key-action button-action motion-action expose-action ;

! resize-action ( { width height } <pwindow> -- )
! move-action ( { x y } <pwindow> -- )

: create-pwindow ( -- <pwindow> )
create-window-object f f f f f f f f <pwindow> dup >r set-delegate r>
dup add-to-window-table ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: XConfigureEvent-size ( event -- { width height } )
dup XConfigureEvent-width swap XConfigureEvent-height 2array ;

: XConfigureEvent-position ( event -- { x y } )
dup XConfigureEvent-x swap XConfigureEvent-y 2array ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: size-changed? ( event obj -- ? )
pwindow-last-size swap XConfigureEvent-size = not ;

: update-last-size ( event obj -- )
swap XConfigureEvent-size swap set-pwindow-last-size ;

: call-resize-action ( event obj -- ? )
swap XConfigureEvent-size swap dup pwindow-resize-action call ;

: maybe-handle-resize ( event obj -- )
2dup size-changed? [ 2dup update-last-size call-resize-action ] [ 2drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: position-changed? ( event obj -- ? )
pwindow-last-position swap XConfigureEvent-position = not ;

: update-last-position ( event obj -- )
swap XConfigureEvent-position swap set-pwindow-last-position ;

: call-move-action ( event obj -- ? )
swap XConfigureEvent-position swap dup pwindow-move-action call ;

: maybe-handle-move ( event obj )
2dup position-changed?
[ 2dup update-last-position call-move-action ] [ 2drop ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: pwindow handle-configure-event ( event obj -- )
2dup maybe-handle-resize maybe-handle-move ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: pwindow handle-key-press-event ( event obj -- )
dup pwindow-key-action call ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: pwindow handle-button-press-event ( event obj -- )
dup pwindow-button-action call ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: pwindow handle-expose-event ( event obj -- )
dup pwindow-expose-action call ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! event-loop
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : event-loop ( -- )
! next-event		! event
! dup			! event event
! XAnyEvent-window	! event window
! window-table get	! event window table
! hash			! event obj-or-f
! dup			! event obj-or-f obj-or-f
! [ handle-event ]	
! [ drop drop ]		! event obj-or-f obj-or-f [ handle-event ] [ drop drop ]
! if
! event-loop ;

! It's possible to have multiple displays open simultaneously.
! Maybe there can be an event loop for each display. Each event loop
! would run in it's own thread.

: concurrent-next-event ( -- event )
  ! QueuedAlready events-queued 0 >
  QueuedAfterFlush events-queued 0 >
  [ next-event ]
  [ 100 sleep concurrent-next-event ]
  if ;

: concurrent-event-loop ( -- )
  concurrent-next-event	! event
  dup			! event event
  XAnyEvent-window	! event window
  window-table get	! event window table
  hash			! event obj-or-f
  dup			! event obj-or-f obj-or-f
  [ handle-event ]	
  [ drop drop ]		! event obj-or-f obj-or-f [ handle-event ] [ drop drop ]
  if
  concurrent-event-loop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Not categorized
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-window-width%		[ set-window-width ] with-window-object ;
: set-window-height%		[ set-window-height ] with-window-object ;

: select-input% 		[ select-input ] with-window-object ;
: set-input-focus%		[ set-input-focus ] with-window-object ;
: move-window% 			[ move-window ] with-window-object ;
: resize-window% 		[ resize-window ] with-window-object ;
: set-window-border-width%	[ set-window-border-width ] with-window-object ;
: map-window%			[ map-window ] with-window-object ;
: map-subwindows%		[ map-subwindows ] with-window-object ;
: valid-window?%		[ valid-window? ] with-window-object ;
: window-position%		[ window-position ] with-window-object ;
: window-size%			[ window-size ] with-window-object ;
: window-map-state%		[ window-map-state ] with-window-object ;

: reparent-window% ( parent window -- )
  >r window-id r> [ reparent-window ] with-window-object ;

: destroy-window% 		[ destroy-window ] with-window-object ;
: raise-window%			[ raise-window ] with-window-object ;
: window-override-redirect%	[ window-override-redirect ] with-window-object ;
: add-to-save-set%		[ add-to-save-set ] with-window-object ;
: window-x%			[ window-x ] with-window-object ;
: window-y%			[ window-y ] with-window-object ;
: window-width%			[ window-width ] with-window-object ;
: window-height%		[ window-height ] with-window-object ;
: unmap-window%			[ unmap-window ] with-window-object ;
: set-window-background%	[ set-window-background ] with-window-object ;
: grab-pointer%			[ grab-pointer ] with-window-object ;
: mouse-sensor%			[ mouse-sensor ] with-window-object ;
: window-children%		[ window-children ] with-window-object ;

: vertical-layout%		[ vertical-layout ] with-window-object ;

: draw-string%			[ draw-string ] with-window-object ;

: get-transient-for-hint% [ get-transient-for-hint ] with-window-object ;

: fetch-name%			[ fetch-name ] with-window-object ;