! based on Xlib.h from x.org, incomplete
IN: x11
USING: alien ;

LIBRARY: X11

TYPEDEF: char* XPointer
TYPEDEF: void* Display*
TYPEDEF: void* XExtData*
TYPEDEF: int Status
TYPEDEF: void* GC

BEGIN-STRUCT: XSetWindowAttributes
    FIELD: Pixmap background_pixmap
    FIELD: ulong background_pixel
    FIELD: Pixmap border_pixmap
    FIELD: ulong border_pixel
    FIELD: int bit_gravity
    FIELD: int win_gravity
    FIELD: int backing_store
    FIELD: ulong backing_planes
    FIELD: ulong backing_pixel
    FIELD: bool save_under
    FIELD: long event_mask
    FIELD: long do_not_propagate_mask
    FIELD: bool override_redirect
    FIELD: Colormap colormap
    FIELD: Cursor cursor
END-STRUCT

BEGIN-STRUCT: XColor
    FIELD: ulong pixel
    FIELD: ushort red
    FIELD: ushort green
    FIELD: ushort blue
    FIELD: char flags  ! do_red, do_green, do_blue
    FIELD: char pad
END-STRUCT

BEGIN-STRUCT: XKeyEvent
    FIELD: int type	    ! of event
    FIELD: ulong serial	    ! # of last request processed by server
    FIELD: bool send_event  ! true if this came from a SendEvent request
    FIELD: Display* display ! Display the event was read from
    FIELD: Window window    ! "event" window it is reported relative to
    FIELD: Window root	    ! root window that the event occurred on
    FIELD: Window subwindow ! child window
    FIELD: Time time	    ! milliseconds
    FIELD: int x            ! pointer x, y coordinates in event window
    FIELD: int y		
    FIELD: int x_root       ! coordinates relative to root
    FIELD: int y_root
    FIELD: uint state 	    ! key or button mask
    FIELD: uint keycode     ! detail
    FIELD: bool same_screen ! same screen flag
END-STRUCT

TYPEDEF: XKeyEvent XKeyPressedEvent
TYPEDEF: XKeyEvent XKeyReleasedEvent

BEGIN-STRUCT: XButtonEvent
    FIELD: int type		! of event
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window window	! "event" window it is reported relative to
    FIELD: Window root	        ! root window that the event occurred on
    FIELD: Window subwindow 	! child window
    FIELD: Time time		! milliseconds
    FIELD: int x		! pointer x, y coordinates in event window
    FIELD: int y
    FIELD: int x_root		! coordinates relative to root
    FIELD: int y_root
    FIELD: uint state		! key or button mask
    FIELD: uint button		! detail
    FIELD: bool same_screen	! same screen flag
END-STRUCT

TYPEDEF: XButtonEvent XButtonPressedEvent
TYPEDEF: XButtonEvent XButtonReleasedEvent

BEGIN-STRUCT: XMotionEvent
    FIELD: int type		! of event
    FIELD: ulong serial         ! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window window	! "event" window reported relative to
    FIELD: Window root	        ! root window that the event occurred on
    FIELD: Window subwindow	! child window
    FIELD: Time time		! milliseconds
    FIELD: int x		! pointer x, y coordinates in event window
    FIELD: int y
    FIELD: int x_root	  	! coordinates relative to root
    FIELD: int y_root
    FIELD: uint state		! key or button mask
    FIELD: char is_hint		! detail
    FIELD: bool same_screen	! same screen flag
END-STRUCT

TYPEDEF: XMotionEvent XPointerMovedEvent

BEGIN-STRUCT: XCrossingEvent
    FIELD: int type		 ! of event
    FIELD: ulong serial		 ! # of last request processed by server
    FIELD: bool send_event	 ! true if this came from a SendEvent request
    FIELD: Display* display	 ! Display the event was read from
    FIELD: Window window	 ! "event" window reported relative to
    FIELD: Window root	         ! root window that the event occurred on
    FIELD: Window subwindow	 ! child window
    FIELD: Time time		 ! milliseconds
    FIELD: int x		 ! pointer x, y coordinates in event window
    FIELD: int y
    FIELD: int x_root		 ! coordinates relative to root
    FIELD: int y_root
    FIELD: int mode		 ! NotifyNormal, NotifyGrab, NotifyUngrab
    FIELD: int detail
	    ! NotifyAncestor, NotifyVirtual, NotifyInferior, 
	    ! NotifyNonlinear,NotifyNonlinearVirtual
    FIELD: bool same_screen	! same screen flag
    FIELD: bool focus		! boolean focus
    FIELD: uint state		! key or button mask
END-STRUCT

TYPEDEF: XCrossingEvent XEnterWindowEvent
TYPEDEF: XCrossingEvent XLeaveWindowEvent

BEGIN-STRUCT: XFocusChangeEvent
    FIELD: int type		! FocusIn or FocusOut
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window window	! window of event
    FIELD: int mode		! NotifyNormal, NotifyGrab, NotifyUngrab
    FIELD: int detail
	! NotifyAncestor, NotifyVirtual, NotifyInferior, 
	! NotifyNonlinear,NotifyNonlinearVirtual, NotifyPointer,
	!  NotifyPointerRoot, NotifyDetailNone
END-STRUCT

TYPEDEF: XFocusChangeEvent XFocusInEvent
TYPEDEF: XFocusChangeEvent XFocusOutEvent

! generated on EnterWindow and FocusIn when KeyMapState selected
BEGIN-STRUCT: XKeymapEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window window
    ! char key_vector[32];
    FIELD: int pad ( TODO: get rid of this padding )
    FIELD: int pad
    FIELD: int pad
    FIELD: int pad
    FIELD: int pad
    FIELD: int pad
    FIELD: int pad
    FIELD: int pad
END-STRUCT

BEGIN-STRUCT: XExposeEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server */
    FIELD: bool send_event	! true if this came from a SendEvent request */
    FIELD: Display* display	! Display the event was read from */
    FIELD: Window window
    FIELD: int x
    FIELD: int y
    FIELD: int width
    FIELD: int height
    FIELD: int count		! if non-zero, at least this many more */
END-STRUCT

BEGIN-STRUCT: XGraphicsExposeEvent
    FIELD: int type
    FIELD: ulong serial	  	! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Drawable drawable
    FIELD: int x
    FIELD: int y
    FIELD: int width
    FIELD: int height
    FIELD: int count		! if non-zero, at least this many more
    FIELD: int major_code	! core is CopyArea or CopyPlane
    FIELD: int minor_code	! not defined in the core
END-STRUCT

BEGIN-STRUCT: XNoExposeEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Drawable drawable
    FIELD: int major_code	! core is CopyArea or CopyPlane
    FIELD: int minor_code	! not defined in the core
END-STRUCT

BEGIN-STRUCT: XVisibilityEvent
    FIELD: int type
    FIELD: ulong serial	 	! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window window
    FIELD: int state		! Visibility state
END-STRUCT

BEGIN-STRUCT: XCreateWindowEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window parent	! parent of the window
    FIELD: Window window	! window id of window created
    FIELD: int x		! window location
    FIELD: int y
    FIELD: int width		! size of window
    FIELD: int height
    FIELD: int border_width	! border width
    FIELD: bool override_redirect ! creation should be overridden
END-STRUCT

BEGIN-STRUCT: XDestroyWindowEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window event
    FIELD: Window window
END-STRUCT

BEGIN-STRUCT: XUnmapEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window event
    FIELD: Window window
    FIELD: bool from_configure
END-STRUCT

BEGIN-STRUCT: XMapEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window event
    FIELD: Window window
    FIELD: bool override_redirect ! boolean, is override set...
END-STRUCT

BEGIN-STRUCT: XMapRequestEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window parent
    FIELD: Window window
END-STRUCT

BEGIN-STRUCT: XReparentEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window event
    FIELD: Window window
    FIELD: Window parent
    FIELD: int x
    FIELD: int y
    FIELD: bool override_redirect
END-STRUCT

BEGIN-STRUCT: XConfigureEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window event
    FIELD: Window window
    FIELD: int x
    FIELD: int y
    FIELD: int width
    FIELD: int height
    FIELD: int border_width
    FIELD: Window above
    FIELD: bool override_redirect
END-STRUCT

BEGIN-STRUCT: XGravityEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window event
    FIELD: Window window
    FIELD: int x
    FIELD: int y
END-STRUCT

BEGIN-STRUCT: XResizeRequestEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window window
    FIELD: int width
    FIELD: int height
END-STRUCT

BEGIN-STRUCT: XConfigureRequestEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window parent
    FIELD: Window window
    FIELD: int x
    FIELD: int y
    FIELD: int width
    FIELD: int height
    FIELD: int border_width
    FIELD: Window above
    FIELD: int detail		! Above, Below, TopIf, BottomIf, Opposite
    FIELD: ulong value_mask
END-STRUCT

BEGIN-STRUCT: XCirculateEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window event
    FIELD: Window window
    FIELD: int place		! PlaceOnTop, PlaceOnBottom
END-STRUCT

BEGIN-STRUCT: XCirculateRequestEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window parent
    FIELD: Window window
    FIELD: int place		! PlaceOnTop, PlaceOnBottom
END-STRUCT

BEGIN-STRUCT: XPropertyEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window window
    FIELD: Atom atom
    FIELD: Time time
    FIELD: int state		! NewValue, Deleted
END-STRUCT

BEGIN-STRUCT: XSelectionClearEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window window
    FIELD: Atom selection
    FIELD: Time time
END-STRUCT

BEGIN-STRUCT: XSelectionRequestEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window owner
    FIELD: Window requestor
    FIELD: Atom selection
    FIELD: Atom target
    FIELD: Atom property
    FIELD: Time time
END-STRUCT

BEGIN-STRUCT: XSelectionEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window requestor
    FIELD: Atom selection
    FIELD: Atom target
    FIELD: Atom property	! ATOM or None
    FIELD: Time time
END-STRUCT

BEGIN-STRUCT: XColormapEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window window
    FIELD: Colormap colormap	! COLORMAP or None
! #if defined(__cplusplus) || defined(c_plusplus)
! 	Bool c_new;		/* C++ */
! #else
    FIELD: bool new
! #endif
    FIELD: int state		! ColormapInstalled, ColormapUninstalled
END-STRUCT

BEGIN-STRUCT: XClientMessageEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window window
    FIELD: Atom message_type
    FIELD: int format
    ! union { char b[20]; short s[10]; long l[5]; } data;
    FIELD: int pad ! TODO
    FIELD: int pad
    FIELD: int pad
    FIELD: int pad
    FIELD: int pad
END-STRUCT

BEGIN-STRUCT: XMappingEvent
    FIELD: int type
    FIELD: ulong serial		! # of last request processed by server
    FIELD: bool send_event	! true if this came from a SendEvent request
    FIELD: Display* display	! Display the event was read from
    FIELD: Window window	! unused
    FIELD: int request		! one of MappingModifier, MappingKeyboard, MappingPointer
    FIELD: int first_keycode	! first keycode
    FIELD: int count		! defines range of change w. first_keycod
END-STRUCT

BEGIN-STRUCT: XErrorEvent
    FIELD: int type
    FIELD: Display* display	! Display the event was read from
    FIELD: XID resourceid		! resource id
    FIELD: ulong serial		! serial number of failed request
    FIELD: uchar error_code	! error code of failed request
    FIELD: uchar request_code	! Major op-code of failed request
    FIELD: uchar minor_code	! Minor op-code of failed request
END-STRUCT

BEGIN-STRUCT: XAnyEvent
    FIELD: int type
    FIELD: ulong serial	 ! # of last request processed by server
    FIELD: bool send_event	 ! true if this came from a SendEvent request
    FIELD: Display* display ! Display the event was read from
    FIELD: Window window	 ! window on which event was requested in event mask
END-STRUCT

! this union is defined so Xlib can always use the same sized
! event structure internally, to avoid memory fragmentation.
BEGIN-UNION: XEvent
    MEMBER: int
    MEMBER: XAnyEvent
    MEMBER: XKeyEvent
    MEMBER: XButtonEvent
    MEMBER: XMotionEvent
    MEMBER: XCrossingEvent
    MEMBER: XFocusChangeEvent
    MEMBER: XExposeEvent
    MEMBER: XGraphicsExposeEvent
    MEMBER: XNoExposeEvent
    MEMBER: XVisibilityEvent
    MEMBER: XCreateWindowEvent
    MEMBER: XDestroyWindowEvent
    MEMBER: XUnmapEvent
    MEMBER: XMapEvent
    MEMBER: XMapRequestEvent
    MEMBER: XReparentEvent
    MEMBER: XConfigureEvent
    MEMBER: XGravityEvent
    MEMBER: XResizeRequestEvent
    MEMBER: XConfigureRequestEvent
    MEMBER: XCirculateEvent
    MEMBER: XCirculateRequestEvent
    MEMBER: XPropertyEvent
    MEMBER: XSelectionClearEvent
    MEMBER: XSelectionRequestEvent
    MEMBER: XSelectionEvent
    MEMBER: XColormapEvent
    MEMBER: XClientMessageEvent
    MEMBER: XMappingEvent
    MEMBER: XErrorEvent
    MEMBER: XKeymapEvent
!	long pad[24]
    MEMBER: long ! TODO: fixme
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
    MEMBER: long
END-UNION

BEGIN-STRUCT: Visual
    FIELD: XExtData* ext_data	! hook for extension to hang data
    FIELD: VisualID visualid	! visual id of this visual
! #if defined(__cplusplus) || defined(c_plusplus)
! 	int c_class;		/* C++ class of screen (monochrome, etc.)
! #else
    FIELD: int class		! class of screen (monochrome, etc.)
! #endif
    FIELD: ulong red_mask		! mask values
    FIELD: ulong green_mask
    FIELD: ulong blue_mask
    FIELD: int bits_per_rgb	! log base 2 of distinct color values
    FIELD: int map_entries		! color map entries
END-STRUCT

FUNCTION: int XCloseDisplay ( Display* display ) ;
FUNCTION: Colormap XCreateColormap ( Display* display, Window w, Visual* visual, int alloc ) ;
FUNCTION: Window XCreateWindow ( Display* display, Window parent, int x, int y, uint width, uint height, uint border_width, int depth, uint class, Visual* visual, ulong valuemask, XSetWindowAttributes* attributes ) ;
FUNCTION: Atom XInternAtom ( Display* display, char* atom_name, bool only_if_exists ) ;
FUNCTION: int XMapRaised ( Display* display, Window w ) ;
FUNCTION: Status XGetGeometry ( Display* display, Drawable d, Window* root_return, int* x_return, int* y_return, uint* width_return, uint* height_return, uint* border_width_return, uint* depth_return ) ;
FUNCTION: KeySym XLookupKeysym ( XKeyEvent* key_event, int index ) ;
FUNCTION: char* XGetAtomName ( Display* display, Atom atom ) ;
FUNCTION: Status XSetWMProtocols ( Display* display, Window w, Atom* protocols, int count ) ;

