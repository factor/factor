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

! dharmatech's stuff

! The most popular guides to programming the X Window System are the
! series from Oreilly. For programming with Xlib, there is the
! reference manual and the programmers guide. However, a lesser known
! manual is the free Xlib manual that comes with the MIT X
! distribution. The arrangement and order of these bindings follows
! the structure of the free Xlib manual. If you add to this library
! and are wondering what part of the file to modify, just find the
! function or data structure in the manual and note the section.

!
! 2 - Display Functions
!

FUNCTION: Display* XOpenDisplay ( char* display_name ) ;

! 2.2 Obtaining Information about the Display, Image Formats, or Screens

FUNCTION: ulong XBlackPixel ( Display* display, int screen_number ) ;
FUNCTION: ulong XWhitePixel ( Display* display, int screen_number ) ;
FUNCTION: Colormap XDefaultColormap ( Display* display, int screen_number ) ;
FUNCTION: int XDefaultDepth ( Display* display, int screen_number ) ;
FUNCTION: GC XDefaultGC ( Display* display, int screen_number ) ;
FUNCTION: int XDefaultScreen ( Display* display ) ;
FUNCTION: Window XRootWindow ( Display* display, int screen_number ) ;
FUNCTION: Window XDefaultRootWindow ( Display* display ) ;
FUNCTION: int XProtocolVersion ( Display* display ) ;
FUNCTION: int XProtocolRevision ( Display* display ) ;
FUNCTION: int XQLength ( Display* display ) ;
FUNCTION: int XScreenCount ( Display* display ) ;
FUNCTION: int XConnectionNumber ( Display* display ) ;

!
! 3 - Window Functions
!

FUNCTION: Window XCreateSimpleWindow ( Display* display, Window parent, int x, int y, uint width, uint height, uint border_width, ulong border, ulong background ) ;
FUNCTION: Status XDestroyWindow ( Display* display, Window w ) ;
FUNCTION: Status XMapWindow ( Display* display, Window window ) ;
FUNCTION: Status XMapSubwindows ( Display* display, Window window ) ;
FUNCTION: Status XUnmapWindow ( Display* display, Window w ) ;
FUNCTION: Status XUnmapSubwindows ( Display* display, Window w ) ;
FUNCTION: Status XConfigureWindow ( Display* display, Window w, uint value_mask, XWindowChanges* values ) ;
FUNCTION: Status XMoveWindow ( Display* display, Window w, int x, int y ) ;
FUNCTION: Status XResizeWindow ( Display* display, Window w, uint width, uint height ) ;
FUNCTION: Status XSetWindowBorderWidth ( Display* display, ulong w, uint width ) ;
FUNCTION: Status XRaiseWindow ( Display* display, Window w ) ;
FUNCTION: Status XLowerWindow ( Display* display, Window w ) ;
FUNCTION: Status XChangeWindowAttributes ( Display* display, Window w, ulong valuemask, XSetWindowAttributes* attr ) ;
FUNCTION: Status XSetWindowBackground ( Display* display, Window w, ulong background_pixel ) ;
FUNCTION: Status XDefineCursor ( Display* display, Window w, Cursor cursor ) ;
FUNCTION: Status XUndefineCursor ( Display* display, Window w ) ;

!
! 4 - Window Information Functions
!

FUNCTION: Status XQueryTree ( Display* display, Window w, Window* root_return, Window* parent_return, Window** children_return, uint* nchildren_return ) ;
FUNCTION: Status XGetWindowAttributes ( Display* display, Window w, XWindowAttributes* attr ) ;
FUNCTION: bool XQueryPointer ( Display* display, Window w, Window* root_return, Window* child_return, int* root_x_return, int* root_y_return, int* win_x_return, int* win_y_return, uint* mask_return ) ;

!
! 6 - Color Management Functions
!

FUNCTION: Status XLookupColor ( Display* display, Colormap colormap, char* color_name, XColor* exact_def_return, XColor* screen_def_return ) ;
FUNCTION: Status XAllocColor ( Display* display, Colormap colormap, XColor* screen_in_out ) ;
FUNCTION: Status XQueryColor ( Display* display, Colormap colormap, XColor* def_in_out ) ;

!
! 7 - Graphics Context Functions
!

FUNCTION: GC XCreateGC ( Display* display, Window d, ulong valuemask, XGCValues* values ) ;
FUNCTION: int XChangeGC ( Display* display, GC gc, ulong valuemask, XGCValues* values ) ;
FUNCTION: Status XGetGCValues ( Display* display, GC gc, ulong valuemask, XGCValues* values_return ) ;
FUNCTION: Status XSetForeground ( Display* display, GC gc, ulong foreground ) ;
FUNCTION: Status XSetBackground ( Display* display, GC gc, ulong background ) ;
FUNCTION: Status XSetFunction ( Display* display, GC gc, int function ) ;
FUNCTION: Status XSetSubwindowMode ( Display* display, GC gc, int subwindow_mode ) ;
FUNCTION: Status XSetFont ( Display* display, GC gc, Font font ) ;

!
! 8 - Graphics Functions
!

FUNCTION: Status XClearWindow ( Display* display, Window w ) ;
FUNCTION: Status XDrawPoint ( Display* display, Drawable d, GC gc, int x, int y ) ;
FUNCTION: Status XDrawLine ( Display* display, Drawable d, GC gc, int x1, int y1, int x2, int y2 ) ;
FUNCTION: Status XDrawArc ( Display* display, Drawable d, GC gc, int x, int y, uint width, uint height, int angle1, int angle2 ) ;
FUNCTION: Status XFillArc ( Display* display, Drawable d, GC gc, int x, int y, uint width, uint height, int angle1, int angle2 ) ;
FUNCTION: Font XLoadFont ( Display* display, char* name ) ;
FUNCTION: XFontStruct* XLoadQueryFont ( Display* display, char* name ) ;
FUNCTION: int XTextWidth ( XFontStruct* font_struct, char* string, int count ) ;
FUNCTION: Status XDrawString ( Display* display, Drawable d, GC gc, int x, int y, char* string, int length ) ;

!
! 9 - Window and Session Manager Functions
!

FUNCTION: Status XReparentWindow ( Display* display, Window w, Window parent, int x, int y ) ;
FUNCTION: Status XAddToSaveSet ( Display* display, Window w ) ;
FUNCTION: Status XRemoveFromSaveSet ( Display* display, Window w ) ;
FUNCTION: Status XGrabServer ( Display* display ) ;
FUNCTION: Status XUngrabServer ( Display* display ) ;
FUNCTION: Status XKillClient ( Display* display, XID resource ) ;

!
! 11 - Event Handling Functions
!

FUNCTION: Status XSelectInput ( Display* display, Window w, long event_mask ) ;
FUNCTION: Status XFlush ( Display* display ) ;
FUNCTION: Status XSync ( Display* display, int discard ) ;
FUNCTION: int XPending ( Display* display ) ;
FUNCTION: Status XNextEvent ( Display* display, XEvent* event ) ;
FUNCTION: Status XMaskEvent ( Display* display, long event_mask, XEvent* event_return ) ;

!
! 12 - Input Device Functions
!

FUNCTION: int XGrabPointer ( Display* display, Window grab_window, bool owner_events, uint event_mask, int pointer_mode, int keyboard_mode, Window confine_to, Cursor cursor, Time time ) ;
FUNCTION: Status XUngrabPointer ( Display* display, Time time ) ;
FUNCTION: Status XChangeActivePointerGrab ( Display* display, uint event_mask, Cursor cursor, Time time ) ;
FUNCTION: Status XGrabKey ( Display* display, int keycode, uint modifiers, Window grab_window, bool owner_events, int pointer_mode, int keyboard_mode ) ;
FUNCTION: Status XSetInputFocus ( Display* display, Window focus, int revert_to, Time time ) ;
FUNCTION: Status XWarpPointer ( Display* display, Window src_w, Window dest_w, int src_x, int src_y, uint src_width, uint src_height, int dest_x, int dest_y ) ;
!
! 14 - Inter-Client Communication Functions
!

FUNCTION: Status XFetchName ( Display* display, Window w, char** window_name_return ) ;
FUNCTION: Status XGetTransientForHint ( Display* display, Window w, Window* prop_window_return ) ;

!
! 16 - Application Utility Functions
!

FUNCTION: int XLookupString ( XKeyEvent* event_struct, char* buffer_return, int bytes_buffer, KeySym* keysym_return, XComposeStatus* status_in_out ) ;

