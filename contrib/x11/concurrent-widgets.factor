
IN: concurrent-widgets
USING: namespaces kernel hashtables math generic threads concurrency xlib x ;

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

10 <hashtable> window-table set

: add-to-window-table ( <window> -- )
dup window-id window-table get set-hash ;

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

: handle-event ( event obj -- )
over XAnyEvent-type
dup KeyPress		= [ handle-key-press-event ] when
dup KeyRelease		= [ handle-key-release-event ] when
dup ButtonPress		= [ drop handle-button-press-event ] when
dup ButtonRelease	= [ handle-button-release-event ] when
dup Expose 		= [ drop handle-expose-event ] when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: label text ;

: create-label ( text -- <label> )
>r create-window-object r> <label> dup >r set-delegate r>
dup add-to-window-table
dup >r
>r ExposureMask r> [ select-input ] with-window-object
r> ;

M: label handle-expose-event ( event <label> -- )
swap drop >r
gcontext get   { 10 10 }   r> dup >r label-text
r> [ draw-string ] with-window-object ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: button action ;

: create-button ( text action -- <button> )
swap create-label swap <button> dup >r set-delegate r>
dup add-to-window-table
>r ExposureMask ButtonPressMask bitor r>
dup >r [ select-input ] with-window-object
r> ;

M: button handle-button-press-event ( event <button> -- )
  swap drop button-action call ;

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
! ifte
! event-loop ;

! It's possible to have multiple displays open simultaneously.
! Maybe there can be an event loop for each display. Each event loop
! would run in it's own thread.

: concurrent-next-event ( -- event )
  ! QueuedAlready events-queued 0 >
  QueuedAfterFlush events-queued 0 >
  [ next-event ]
  [ 100 sleep concurrent-next-event ]
  ifte ;

: concurrent-event-loop ( -- )
  concurrent-next-event	! event
  dup			! event event
  XAnyEvent-window	! event window
  window-table get	! event window table
  hash			! event obj-or-f
  dup			! event obj-or-f obj-or-f
  [ handle-event ]	
  [ drop drop ]		! event obj-or-f obj-or-f [ handle-event ] [ drop drop ]
  ifte
  concurrent-event-loop ;
