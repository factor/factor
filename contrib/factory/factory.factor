
IN: factory

USING: kernel namespaces generic math sequences hashtables io vectors words
       prettyprint
       concurrency xlib x concurrent-widgets simple-error-handler ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: root-menu

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: MouseMask
  [ ButtonPressMask
    ButtonReleaseMask
    PointerMotionMask ] 0 [ execute bitor ] reduce ;

: drag-window-loop ( mouse-position-1 window )
  MouseMask mask-event XAnyEvent-type			! position window type
  { { [ dup MotionNotify = ]	[ drop drag-window-loop ] }
    { [ dup ButtonRelease = ]
      [ drop						! position window
        dup mouse-sensor%				! pos-1 window pos-2
        rot						! window pos-2 pos-1
        v-						! window pos-diff
        over window-position%				! window pos-diff win-pos
        v+						! window new-pos
        over						! window new-pos window
        move-window%					! window
        dup raise-window%
        ungrab-server
        CurrentTime ungrab-pointer
        flush-dpy ] }
    { [ t ] [ "drag-window-loop ignoring event" print drop drop drop ] } }

  cond ;

: drag-window ( window -- )
  MouseMask over grab-pointer%		! window
  grab-server
  dup mouse-sensor%			! window mouse-position-1
  swap					! mouse-position-1 window
  drag-window-loop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: wm-frame-child

: drag-resize-window-loop ( window )
  MouseMask mask-event XAnyEvent-type		! frame type
  { { [ dup MotionNotify = ]
      [ drop drag-resize-window-loop ] }
    { [ dup ButtonRelease = ]
      [ drop					! window
        dup mouse-sensor%			! window pos-2
        over					! win pos-2 win
        window-position%			! win pos-2 win-pos
        v-					! win new-size
        swap					! size win
        tuck					! win size win
        resize-window%				! win
        dup wm-frame-child			! win child
        over					! win child win
        window-size%				! win child size
        { 20 20 } v-				! win child size
        swap					! win size child
	resize-window%				! win
        drop
        ungrab-server
        CurrentTime ungrab-pointer
        flush-dpy ] }
    { [ t ]
      [ drop drop
        "drag-resize-window-loop ignoring event" print ] } }

  cond ;

: drag-resize-window ( window -- )
  MouseMask over grab-pointer%
  grab-server
  drag-resize-window-loop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: move-request-x
GENERIC: move-request-y
GENERIC: move-request-position
GENERIC: execute-move-request
GENERIC: size-request-width
GENERIC: size-request-height
GENERIC: size-request-size
GENERIC: execute-size-request

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! wm-root
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: wm-root ;

: create-wm-root ( window -- )
  >r dpy get r> <window>			! <window>
  <wm-root>					! <window> <wm-root>
  [ set-delegate ] keep				! <wm-root>
  [ add-to-window-table ] keep			! <wm-root>

  [ SubstructureRedirectMask
    SubstructureNotifyMask
    ButtonPressMask
    ButtonReleaseMask
    KeyPressMask
    KeyReleaseMask ] 0 [ execute bitor ] reduce	! <wm-frame> mask

  over select-input% ;				! <wm-frame>

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! M: wm-root handle-map-request-event
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: id>obj ( id -- obj )
  dup			! id id
  window-table get hash	! id obj-or-f
  dup
  [ swap drop ]
  [ drop >r dpy get r> <window> ]
  ifte ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

DEFER: wm-frame?
DEFER: manage-window

M: wm-root handle-map-request-event ( event <wm-root> -- )
  drop XMapRequestEvent-window id>obj				! obj

  { { [ dup wm-frame? ]
      [ map-window% ] }

    { [ dup valid-window?% not ]
      [ "Not a valid window." print drop ] }

    { [ dup window-override-redirect% 1 = ]
      [ "Not reparenting: " print
        "new window has override_redirect attribute set." print
        drop ] }

    { [ t ] [ window-id manage-window ] } }

  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Words for working with an XConfigureRequestEvent
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bit-test ( a b -- t-or-f ) bitand 0 = not ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: move-request-x? ( event -- ) XConfigureRequestEvent-value_mask CWX bit-test ;
: move-request-y? ( event -- ) XConfigureRequestEvent-value_mask CWY bit-test ;

: move-request? ( event -- ? ) dup move-request-x? swap move-request-y? or ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: size-request-width? ( event -- )
  XConfigureRequestEvent-value_mask CWWidth bit-test ;

: size-request-height? ( event -- )
  XConfigureRequestEvent-value_mask CWHeight bit-test ;

: size-request? ( event -- )
  dup size-request-width? swap size-request-height? or ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! M: wm-root handle-configure-request-event
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-root move-request-x ( event wm-root -- x )
  drop
  dup move-request-x?
  [ XConfigureRequestEvent-x ]
  [ XConfigureRequestEvent-window [ window-x ] with-win ]
  ifte ;

M: wm-root move-request-y ( event wm-root -- y )
  drop
  dup move-request-y?
  [ XConfigureRequestEvent-y ]
  [ XConfigureRequestEvent-window [ window-y ] with-win ]
  ifte ;

M: wm-root move-request-position ( event wm-root -- { x y } )
  2dup move-request-x -rot move-request-y 2vector ;

M: wm-root execute-move-request ( event wm-root -- )
  dupd move-request-position swap XConfigureRequestEvent-window move-window+ ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-root size-request-width ( event wm-root -- width )
  drop
  dup size-request-width?
  [ XConfigureRequestEvent-width ]
  [ XConfigureRequestEvent-window [ window-width ] with-win ]
  ifte ;

M: wm-root size-request-height ( event wm-root -- height )
  drop 
  dup size-request-height?
  [ XConfigureRequestEvent-height ]
  [ XConfigureRequestEvent-window [ window-height ] with-win ]
  ifte ;

M: wm-root size-request-size ( event wm-root -- { width height } )
  2dup size-request-width -rot size-request-height 2vector ;

M: wm-root execute-size-request ( event wm-root -- )
  dupd size-request-size swap XConfigureRequestEvent-window resize-window+ ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-root handle-configure-request-event ( event wm-root -- )
  over move-request? [ 2dup execute-move-request ] when
  over size-request? [ 2dup execute-size-request ] when
  drop drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! M: wm-root handle-button-press-event
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-root handle-button-press-event ( event wm-root -- )
  drop						! event

  { { [ dup XButtonEvent-button Button1 = ]
      [ root-menu get window-map-state% IsUnmapped =
        [ XButtonEvent-root-position root-menu get move-window%
          root-menu get raise-window%
          root-menu get map-window% ]
        [ root-menu get unmap-window% ]
        ifte ] }

    { [ dup XButtonEvent-button Button2 = ]
      [ "Button 2 pressed on root window." print drop ] } }

  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! M: wm-root handle-key-press-event
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! M: wm-root handle-key-press-event ( event wm-root -- )
!   drop
!   { { [ dup XKeyEvent-keycode 67 = ]
!       [ workspace-1 get switch-to-workspace ] }
!     { [ dup XKeyEvent-keycode 68 = ]
!       [ workspace-2 get switch-to-workspace ] }
!     { [ dup XKeyEvent-keycode 69 = ]
!       [ workspace-3 get switch-to-workspace ] }
!     { [ dup XKeyEvent-keycode 70 = ]
!       [ workspace-4 get switch-to-workspace ] } }
!   cond ;

M: wm-root handle-key-press-event ( event wm-root -- )
  drop
  { { [ dup XKeyEvent-keycode 67 = ]
      [ "Switch to workspace 1" print drop ] }
    { [ dup XKeyEvent-keycode 68 = ]
      [ "Switch to workspace 2" print drop ] }
    { [ dup XKeyEvent-keycode 69 = ]
      [ "Switch to workspace 3" print drop ] }
    { [ dup XKeyEvent-keycode 70 = ]
      [ "Switch to workspace 4" print drop ] }
    { [ t ]
      [ "wm-root ignoring key press" print drop ] } }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: wm-child ;

: create-wm-child ( id -- <wm-child> )
  >r dpy get r> <window> <wm-child>		! <window> <wm-child>
  [ set-delegate ] keep
  [ add-to-window-table ] keep ;

M: wm-child handle-property-event ( child event -- )
  "A <wm-child> received a property event" print drop drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: wm-frame child ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: create-wm-frame ( child -- <wm-frame> )
  >r create-window-object r>			! <window> child
  <wm-frame>					! <window> <wm-frame>
  [ set-delegate ] keep				! <wm-frame>
  [ add-to-window-table ] keep			! <wm-frame>
  
  [ SubstructureRedirectMask
    SubstructureNotifyMask
    ExposureMask
    ButtonPressMask
    ButtonReleaseMask
    EnterWindowMask ] 0 [ execute bitor ] reduce	! <wm-frame> mask

  over select-input% ;				! <wm-frame>

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: manage-window ( window -- )
  grab-server

  create-wm-child				! child
  create-wm-frame				! frame

  dup "cornflowerblue" lookup-color swap set-window-background%

  dup wm-frame-child add-to-save-set%		! frame

  dup wm-frame-child window-position%		! frame position
  over						! frame position frame
  move-window%
  
  dup wm-frame-child 0 swap set-window-border-width%
  dup dup wm-frame-child			! frame frame child
  reparent-window%

  dup wm-frame-child window-size%		! frame child-size
  { 20 20 } v+					! frame child-size+
  over						! frame child-size+ frame
  resize-window%

  dup wm-frame-child { 10 10 } swap move-window%

  dup map-window%
  dup map-subwindows%

  dup wm-frame-child PropertyChangeMask swap select-input%
  
  flush-dpy 0 sync-dpy ungrab-server ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: destroy-window-event-match? ( event <wm-frame> -- ? )
  window-id swap XDestroyWindowEvent-window = ;

M: wm-frame handle-destroy-window-event ( event <wm-frame> -- )
  2dup destroy-window-event-match?
  [ destroy-window% drop ] [ drop drop ] ifte ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: map-request-event-match? ( event <wm-frame> -- ? )
  window-id swap XMapRequestEvent-window = ;

M: wm-frame handle-map-request-event ( event <wm-frame> -- )
  2dup map-request-event-match?				! event frame ?
  [ dup wm-frame-child map-window% map-window% drop ] [ drop drop ] ifte ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: map-event-match? ( event <wm-frame> -- ? )
  window-id swap XMapEvent-window = ;

M: wm-frame handle-map-event ( event <wm-frame> -- )
  2dup map-event-match?
  [ dup map-window% raise-window% drop ] [ drop drop ] ifte ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! M: wm-frame handle-configure-request-event ( event frame )
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-frame move-request-x ( event frame -- x )
  over move-request-x?
  [ drop XConfigureRequestEvent-x ]
  [ nip window-x% ]
  ifte ;

M: wm-frame move-request-y ( event frame -- y )
  over move-request-y?
  [ drop XConfigureRequestEvent-y ]
  [ nip window-y% ]
  ifte ;

M: wm-frame move-request-position ( event frame -- { x y } )
  2dup move-request-x -rot move-request-y 2vector ;

M: wm-frame execute-move-request ( event frame )
  dup -rot move-request-position swap move-window% ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-frame size-request-width ( event frame -- width )
  over size-request-width?
  [ drop XConfigureRequestEvent-width ]
  [ nip wm-frame-child window-width% ]
  ifte ;

M: wm-frame size-request-height ( event frame -- height )
  over size-request-height?
  [ drop XConfigureRequestEvent-height ]
  [ nip wm-frame-child window-height% ]
  ifte ;

M: wm-frame size-request-size ( event frame -- size )
  2dup size-request-width -rot size-request-height 2vector ;

: execute-size-request/child ( event frame )
  dup wm-frame-child -rot size-request-size swap resize-window% ;

: execute-size-request/frame ( event frame )
  dup -rot size-request-size { 20 20 } v+ swap resize-window% ;

M: wm-frame execute-size-request ( event frame )
  2dup execute-size-request/child execute-size-request/frame ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-frame handle-configure-request-event ( event frame )
  over move-request? [ 2dup execute-move-request ] when
  over size-request? [ 2dup execute-size-request ] when
  drop drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: unmap-event-match? ( event frame -- ? )
  wm-frame-child window-id swap XUnmapEvent-window = ;

M: wm-frame handle-unmap-event ( event frame )
  2dup unmap-event-match? [ unmap-window% drop ] [ drop drop ] ifte ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! M: wm-frame handle-button-press-event ( event frame )
!   swap							! frame event
!   dup XButtonEvent-button Button1 = [ "Button 1 pressed on frame" print ] when
!   dup XButtonEvent-button Button2 = [ "Button 2 pressed on frame" print ] when
!   dup XButtonEvent-button Button3 = [ "Button 3 pressed on frame" print ] when ;

M: wm-frame handle-button-press-event ( event frame )
  over XButtonEvent-button				! event frame button
  { { [ dup Button1 = ] [ drop nip drag-window ] }
    { [ dup Button2 = ] [ drop nip drag-resize-window ] }
    { [ t ] [ drop drop drop ] } }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-frame handle-enter-window-event ( event frame )
  nip dup wm-frame-child valid-window?%
  [ wm-frame-child >r RevertToPointerRoot CurrentTime r> set-input-focus% ]
  [ destroy-window% ]
  ifte ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: wm-frame handle-property-event ( event frame )
  "Inside handle-property-event" print drop drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! f initialize-x set-simple-error-handler manage-existing-windows
! concurrent-event-loop

: start-factory ( dpy-string -- )
  initialize-x
  SetSimpleErrorHandler
  root get create-wm-root

  create-menu root-menu set
  "black" lookup-color root-menu get set-window-background%
  "xterm"  [ "launch program..." print ] root-menu get add-popup-menu-item
  "xlogo"  [ "launch program..." print ] root-menu get add-popup-menu-item
  "xclock" [ "launch program..." print ] root-menu get add-popup-menu-item
  "xload"  [ "launch program..." print ] root-menu get add-popup-menu-item
  "emacs"  [ "launch program..." print ] root-menu get add-popup-menu-item

  [ concurrent-event-loop ] spawn ;