! Copyright (C) 2005, 2006 Eduardo Cavazos
! See http://factorcode.org/license.txt for BSD license.
!
! The most popular guides to programming the X Window System are
! the series from Oreilly. For programming with Xlib, there is
! the reference manual and the programmers guide. However, a
! lesser known manual is the free Xlib manual that comes with
! the MIT X distribution. The arrangement and order of these
! bindings follows the structure of the free Xlib manual. If you
! add to this library and are wondering what part of the file to
! modify, just find the function or data structure in the manual
! and note the section.

USING: kernel arrays alien math words sequences ;
IN: x11

LIBRARY: xlib

TYPEDEF: ulong XID
TYPEDEF: XID Window
TYPEDEF: XID Drawable
TYPEDEF: XID Font
TYPEDEF: XID Pixmap
TYPEDEF: XID Cursor
TYPEDEF: XID Colormap
TYPEDEF: XID GContext
TYPEDEF: XID KeySym

TYPEDEF: ulong Atom

TYPEDEF: char* XPointer
TYPEDEF: void* Display*
TYPEDEF: void* Screen*
TYPEDEF: void* GC
TYPEDEF: void* Visual*
TYPEDEF: void* XExtData*
TYPEDEF: void* XFontProp*
TYPEDEF: void* XComposeStatus*

TYPEDEF: int Status

TYPEDEF: int Bool

TYPEDEF: ulong VisualID
TYPEDEF: ulong Time

TYPEDEF: void* Window**
TYPEDEF: void* Atom**

: <XID> <ulong> ; inline
: <Window> <XID> ; inline
: <Drawable> <XID> ; inline
: <KeySym> <XID> ; inline
: <Atom> <ulong> ; inline

: *XID *ulong ; inline
: *Window *XID ; inline
: *Drawable *XID ; inline
: *KeySym *XID ; inline
: *Atom *ulong ; inline
!
! 2 - Display Functions
!

FUNCTION: Display* XOpenDisplay ( void* display_name ) ;

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

! 2.5 Closing the Display
FUNCTION: int XCloseDisplay ( Display* display ) ;

!
! 3 - Window Functions
!

! 3.2 - Window Attributes

: CWBackPixmap		1 0 shift ; inline
: CWBackPixel		1 1 shift ; inline
: CWBorderPixmap	1 2 shift ; inline
: CWBorderPixel         1 3 shift ; inline
: CWBitGravity		1 4 shift ; inline
: CWWinGravity		1 5 shift ; inline
: CWBackingStore        1 6 shift ; inline
: CWBackingPlanes	1 7 shift ; inline
: CWBackingPixel	1 8 shift ; inline
: CWOverrideRedirect	1 9 shift ; inline
: CWSaveUnder		1 10 shift ; inline
: CWEventMask		1 11 shift ; inline
: CWDontPropagate	1 12 shift ; inline
: CWColormap		1 13 shift ; inline
: CWCursor	        1 14 shift ; inline

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
	FIELD: Bool save_under
	FIELD: long event_mask
	FIELD: long do_not_propagate_mask
	FIELD: Bool override_redirect
	FIELD: Colormap colormap
	FIELD: Cursor cursor
END-STRUCT

: UnmapGravity		0 ; inline

: ForgetGravity		0 ; inline
: NorthWestGravity	1 ; inline
: NorthGravity		2 ; inline
: NorthEastGravity	3 ; inline
: WestGravity		4 ; inline
: CenterGravity		5 ; inline
: EastGravity		6 ; inline
: SouthWestGravity	7 ; inline
: SouthGravity		8 ; inline
: SouthEastGravity	9 ; inline
: StaticGravity		10 ; inline

! 3.3 - Creating Windows

FUNCTION: Window XCreateWindow ( Display* display, Window parent, int x, int y, uint width, uint height, uint border_width, int depth, uint class, Visual* visual, ulong valuemask, XSetWindowAttributes* attributes ) ;
FUNCTION: Window XCreateSimpleWindow ( Display* display, Window parent, int x, int y, uint width, uint height, uint border_width, ulong border, ulong background ) ;
FUNCTION: Status XDestroyWindow ( Display* display, Window w ) ;
FUNCTION: Status XMapWindow ( Display* display, Window window ) ;
FUNCTION: Status XMapSubwindows ( Display* display, Window window ) ;
FUNCTION: Status XUnmapWindow ( Display* display, Window w ) ;
FUNCTION: Status XUnmapSubwindows ( Display* display, Window w ) ;

! 3.5 Mapping Windows

FUNCTION: int XMapRaised ( Display* display, Window w ) ;

! 3.7 - Configuring Windows

: CWX			1 0 shift ; inline
: CWY			1 1 shift ; inline
: CWWidth		1 2 shift ; inline
: CWHeight		1 3 shift ; inline
: CWBorderWidth		1 4 shift ; inline
: CWSibling		1 5 shift ; inline
: CWStackMode		1 6 shift ; inline

BEGIN-STRUCT: XWindowChanges
	FIELD: int x
	FIELD: int y
	FIELD: int width
	FIELD: int height
	FIELD: int border_width
	FIELD: Window sibling
	FIELD: int stack_mode
END-STRUCT

FUNCTION: Status XConfigureWindow ( Display* display, Window w, uint value_mask, XWindowChanges* values ) ;
FUNCTION: Status XMoveWindow ( Display* display, Window w, int x, int y ) ;
FUNCTION: Status XResizeWindow ( Display* display, Window w, uint width, uint height ) ;
FUNCTION: Status XSetWindowBorderWidth ( Display* display, ulong w, uint width ) ;


! 3.8 Changing Window Stacking Order

FUNCTION: Status XRaiseWindow ( Display* display, Window w ) ;
FUNCTION: Status XLowerWindow ( Display* display, Window w ) ;

! 3.9 - Changing Window Attributes

FUNCTION: Status XChangeWindowAttributes (
  Display* display, Window w, ulong valuemask, XSetWindowAttributes* attr ) ;
FUNCTION: Status XSetWindowBackground (
  Display* display, Window w, ulong background_pixel ) ;
FUNCTION: Status XDefineCursor ( Display* display, Window w, Cursor cursor ) ;
FUNCTION: Status XUndefineCursor ( Display* display, Window w ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 4 - Window Information Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 4.1 - Obtaining Window Information

FUNCTION: Status XQueryTree (
  Display* display,
  Window w,
  Window* root_return,
  Window* parent_return,
  Window** children_return, uint* nchildren_return ) ;

BEGIN-STRUCT: XWindowAttributes
	FIELD: int x
	FIELD: int y
	FIELD: int width
	FIELD: int  height
	FIELD: int border_width
	FIELD: int depth
	FIELD: Visual* visual
	FIELD: Window root
	FIELD: int class
	FIELD: int bit_gravity
	FIELD: int win_gravity
	FIELD: int backing_store
	FIELD: ulong backing_planes
	FIELD: ulong backing_pixel
	FIELD: Bool save_under
	FIELD: Colormap colormap
	FIELD: Bool map_installed
	FIELD: int map_state
	FIELD: long all_event_masks
	FIELD: long your_event_mask
	FIELD: long do_not_propagate_mask
	FIELD: Bool override_redirect
	FIELD: Screen* screen
END-STRUCT

FUNCTION: Status XGetWindowAttributes ( Display* display, Window w, XWindowAttributes* attr ) ;

: IsUnmapped		0 ; inline
: IsUnviewable		1 ; inline
: IsViewable		2 ; inline

FUNCTION: Status XGetGeometry (
  Display* display,
  Drawable d,
  Window* root_return,
  int* x_return,
  int* y_return,
  uint* width_return,
  uint* height_return,
  uint* border_width_return,
  uint* depth_return ) ;

! 4.2 - Translating Screen Coordinates

FUNCTION: Bool XQueryPointer ( Display* display, Window w, Window* root_return, Window* child_return, int* root_x_return, int* root_y_return, int* win_x_return, int* win_y_return, uint* mask_return ) ;

! 4.3 - Properties and Atoms

FUNCTION: Atom XInternAtom ( Display* display, char* atom_name, Bool only_if_exists ) ;

FUNCTION: char* XGetAtomName ( Display* display, Atom atom ) ;

! 4.4 - Obtaining and Changing Window Properties

FUNCTION: int XGetWindowProperty ( Display* display, Window w, Atom property, long long_offset, long long_length, Bool delete, Atom req_type, Atom* actual_type_return, int* actual_format_return, ulong* nitems_return, ulong* bytes_after_return, char** prop_return ) ;

FUNCTION: int XChangeProperty ( Display* display, Window w, Atom property, Atom type, int format, int mode, char* data, int nelements ) ;

! 4.5 Selections

FUNCTION: int XSetSelectionOwner ( Display* display, Atom selection, Window owner, Time time ) ;

FUNCTION: Window XGetSelectionOwner ( Display* display, Atom selection ) ;

FUNCTION: int XConvertSelection ( Display* display, Atom selection, Atom target, Atom property, Window requestor, Time time ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 6 - Color Management Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XColor
	FIELD: ulong pixel
	FIELD: ushort red
	FIELD: ushort green
	FIELD: ushort blue
	FIELD: char flags
	FIELD: char pad
END-STRUCT

FUNCTION: Status XLookupColor ( Display* display, Colormap colormap, char* color_name, XColor* exact_def_return, XColor* screen_def_return ) ;
FUNCTION: Status XAllocColor ( Display* display, Colormap colormap, XColor* screen_in_out ) ;
FUNCTION: Status XQueryColor ( Display* display, Colormap colormap, XColor* def_in_out ) ;

! 6.4 Creating, Copying, and Destroying Colormaps

FUNCTION: Colormap XCreateColormap ( Display* display, Window w, Visual* visual, int alloc ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 7 - Graphics Context Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: GCFunction            1 0 shift ; inline
: GCPlaneMask           1 1 shift ; inline
: GCForeground          1 2 shift ; inline
: GCBackground          1 3 shift ; inline
: GCLineWidth           1 4 shift ; inline
: GCLineStyle           1 5 shift ; inline
: GCCapStyle            1 6 shift ; inline
: GCJoinStyle		1 7 shift ; inline
: GCFillStyle		1 8 shift ; inline
: GCFillRule		1 9 shift ; inline
: GCTile		1 10 shift ; inline
: GCStipple		1 11 shift ; inline
: GCTileStipXOrigin	1 12 shift ; inline
: GCTileStipYOrigin	1 13 shift ; inline
: GCFont 		1 14 shift ; inline
: GCSubwindowMode	1 15 shift ; inline
: GCGraphicsExposures   1 16 shift ; inline
: GCClipXOrigin		1 17 shift ; inline
: GCClipYOrigin		1 18 shift ; inline
: GCClipMask		1 19 shift ; inline
: GCDashOffset		1 20 shift ; inline
: GCDashList		1 21 shift ; inline
: GCArcMode		1 22 shift ; inline

: GXclear		HEX: 0 ; inline
: GXand			HEX: 1 ; inline
: GXandReverse		HEX: 2 ; inline
: GXcopy		HEX: 3 ; inline
: GXandInverted		HEX: 4 ; inline
: GXnoop		HEX: 5 ; inline
: GXxor			HEX: 6 ; inline
: GXor			HEX: 7 ; inline
: GXnor			HEX: 8 ; inline
: GXequiv		HEX: 9 ; inline
: GXinvert		HEX: a ; inline
: GXorReverse		HEX: b ; inline
: GXcopyInverted	HEX: c ; inline
: GXorInverted		HEX: d ; inline
: GXnand		HEX: e ; inline
: GXset			HEX: f ; inline

BEGIN-STRUCT: XGCValues
	FIELD: int function
	FIELD: ulong plane_mask
	FIELD: ulong foreground
	FIELD: ulong background
	FIELD: int line_width
	FIELD: int line_style
	FIELD: int cap_style
	FIELD: int join_style
	FIELD: int fill_style
	FIELD: int fill_rule
	FIELD: int arc_mode
	FIELD: Pixmap tile
	FIELD: Pixmap stipple
	FIELD: int ts_x_origin
	FIELD: int ts_y_origin
	FIELD: Font font
	FIELD: int subwindow_mode
	FIELD: Bool graphics_exposures
	FIELD: int clip_x_origin
	FIELD: int clip_y_origin
	FIELD: Pixmap clip_mask
	FIELD: int dash_offset
	FIELD: char dashes
END-STRUCT

FUNCTION: GC XCreateGC ( Display* display, Window d, ulong valuemask, XGCValues* values ) ;
FUNCTION: int XChangeGC ( Display* display, GC gc, ulong valuemask, XGCValues* values ) ;
FUNCTION: Status XGetGCValues ( Display* display, GC gc, ulong valuemask, XGCValues* values_return ) ;
FUNCTION: Status XSetForeground ( Display* display, GC gc, ulong foreground ) ;
FUNCTION: Status XSetBackground ( Display* display, GC gc, ulong background ) ;
FUNCTION: Status XSetFunction ( Display* display, GC gc, int function ) ;
FUNCTION: Status XSetSubwindowMode ( Display* display, GC gc, int subwindow_mode ) ;

: ClipByChildren 0 ; inline
: IncludeInferiors 1 ; inline

FUNCTION: Status XSetFont ( Display* display, GC gc, Font font ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 8 - Graphics Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

FUNCTION: Status XClearWindow ( Display* display, Window w ) ;
FUNCTION: Status XDrawPoint ( Display* display, Drawable d, GC gc, int x, int y ) ;
FUNCTION: Status XDrawLine ( Display* display, Drawable d, GC gc, int x1, int y1, int x2, int y2 ) ;
FUNCTION: Status XDrawArc ( Display* display, Drawable d, GC gc, int x, int y, uint width, uint height, int angle1, int angle2 ) ;
FUNCTION: Status XFillArc ( Display* display, Drawable d, GC gc, int x, int y, uint width, uint height, int angle1, int angle2 ) ;

! 8.5 - Font Metrics

BEGIN-STRUCT: XCharStruct
	FIELD: short lbearing;
	FIELD: short rbearing;
	FIELD: short width;
	FIELD: short ascent;
	FIELD: short descent;
	FIELD: ushort attributes;
END-STRUCT

FUNCTION: Font XLoadFont ( Display* display, char* name ) ;
FUNCTION: XFontStruct* XQueryFont ( Display* display, XID font_ID ) ;
FUNCTION: XFontStruct* XLoadQueryFont ( Display* display, char* name ) ;

BEGIN-STRUCT: XFontStruct
	FIELD: XExtData* ext_data
	FIELD: Font fid
	FIELD: uint direction
	FIELD: uint min_char_or_byte2
	FIELD: uint max_char_or_byte2
	FIELD: uint min_byte1
	FIELD: uint max_byte1
	FIELD: Bool all_chars_exist
	FIELD: uint default_char
	FIELD: int n_properties
	FIELD: XFontProp* properties
	FIELD: XCharStruct min_bounds
	FIELD: XCharStruct max_bounds
	FIELD: XCharStruct* per_char
	FIELD: int ascent
	FIELD: int descent
END-STRUCT

FUNCTION: int XTextWidth ( XFontStruct* font_struct, char* string, int count ) ;

! 8.6 - Drawing Text

FUNCTION: Status XDrawString (
	Display* display,
	Drawable d,
	GC gc,
	int x,
	int y,
	char* string,
	int length ) ;

!
! 9 - Window and Session Manager Functions
!

FUNCTION: Status XReparentWindow ( Display* display, Window w, Window parent, int x, int y ) ;
FUNCTION: Status XAddToSaveSet ( Display* display, Window w ) ;
FUNCTION: Status XRemoveFromSaveSet ( Display* display, Window w ) ;
FUNCTION: Status XGrabServer ( Display* display ) ;
FUNCTION: Status XUngrabServer ( Display* display ) ;
FUNCTION: Status XKillClient ( Display* display, XID resource ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 10 - Events
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 10.3 - Event Masks

: NoEventMask			0 ; inline
: KeyPressMask			1 0 shift ; inline
: KeyReleaseMask		1 1 shift ; inline
: ButtonPressMask		1 2 shift ; inline
: ButtonReleaseMask		1 3 shift ; inline
: EnterWindowMask		1 4 shift ; inline
: LeaveWindowMask		1 5 shift ; inline
: PointerMotionMask		1 6 shift ; inline
: PointerMotionHintMask		1 7 shift ; inline
: Button1MotionMask		1 8 shift ; inline
: Button2MotionMask		1 9 shift ; inline
: Button3MotionMask		1 10 shift ; inline
: Button4MotionMask		1 11 shift ; inline
: Button5MotionMask		1 12 shift ; inline
: ButtonMotionMask		1 13 shift ; inline
: KeymapStateMask		1 14 shift ; inline
: ExposureMask			1 15 shift ; inline
: VisibilityChangeMask		1 16 shift ; inline
: StructureNotifyMask		1 17 shift ; inline
: ResizeRedirectMask		1 18 shift ; inline
: SubstructureNotifyMask	1 19 shift ; inline
: SubstructureRedirectMask	1 20 shift ; inline
: FocusChangeMask		1 21 shift ; inline
: PropertyChangeMask		1 22 shift ; inline
: ColormapChangeMask		1 23 shift ; inline
: OwnerGrabButtonMask		1 24 shift ; inline

: KeyPress		2 ; inline
: KeyRelease		3 ; inline
: ButtonPress		4 ; inline
: ButtonRelease		5 ; inline
: MotionNotify		6 ; inline
: EnterNotify		7 ; inline
: LeaveNotify		8 ; inline
: FocusIn			9 ; inline
: FocusOut		10 ; inline
: KeymapNotify		11 ; inline
: Expose			12 ; inline
: GraphicsExpose		13 ; inline
: NoExpose		14 ; inline
: VisibilityNotify	15 ; inline
: CreateNotify		16 ; inline
: DestroyNotify		17 ; inline
: UnmapNotify		18 ; inline
: MapNotify		19 ; inline
: MapRequest		20 ; inline
: ReparentNotify		21 ; inline
: ConfigureNotify		22 ; inline
: ConfigureRequest	23 ; inline
: GravityNotify		24 ; inline
: ResizeRequest		25 ; inline
: CirculateNotify		26 ; inline
: CirculateRequest	27 ; inline
: PropertyNotify		28 ; inline
: SelectionClear		29 ; inline
: SelectionRequest	30 ; inline
: SelectionNotify		31 ; inline
: ColormapNotify		32 ; inline
: ClientMessage		33 ; inline
: MappingNotify		34 ; inline
: LASTEvent		35 ; inline



BEGIN-STRUCT: XAnyEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 10.5 Keyboard and Pointer Events

: Button1 1 ; inline
: Button2 2 ; inline
: Button3 3 ; inline
: Button4 4 ; inline
: Button5 5 ; inline

: Button1Mask		1 8  shift ; inline
: Button2Mask		1 9  shift ; inline
: Button3Mask		1 10 shift ; inline
: Button4Mask		1 11 shift ; inline
: Button5Mask		1 12 shift ; inline

: ShiftMask	1 0 shift ; inline
: LockMask	1 1 shift ; inline
: ControlMask	1 2 shift ; inline
: Mod1Mask	1 3 shift ; inline
: Mod2Mask	1 4 shift ; inline
: Mod3Mask	1 5 shift ; inline
: Mod4Mask	1 6 shift ; inline
: Mod5Mask	1 7 shift ; inline

BEGIN-STRUCT: XButtonEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
	FIELD: Window root
	FIELD: Window subwindow
	FIELD: Time time
	FIELD: int x
	FIELD: int y
	FIELD: int x_root
	FIELD: int y_root
	FIELD: uint state
	FIELD: uint button
	FIELD: Bool same_screen
END-STRUCT

TYPEDEF: XButtonEvent XButtonPressedEvent
TYPEDEF: XButtonEvent XButtonReleasedEvent


! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XKeyEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
	FIELD: Window root
	FIELD: Window subwindow
	FIELD: Time time
	FIELD: int x
	FIELD: int y
	FIELD: int x_root
	FIELD: int y_root
	FIELD: uint state
	FIELD: uint keycode
	FIELD: Bool same_screen
END-STRUCT

TYPEDEF: XKeyEvent XKeyPressedEvent
TYPEDEF: XKeyEvent XKeyReleasedEvent

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XMotionEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
	FIELD: Window root
	FIELD: Window subwindow
	FIELD: Time time
	FIELD: int x
	FIELD: int y
	FIELD: int x_root
	FIELD: int y_root
	FIELD: uint state
	FIELD: char is_hint
	FIELD: Bool same_screen
END-STRUCT

TYPEDEF: XMotionEvent XPointerMovedEvent

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XCrossingEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
	FIELD: Window root
	FIELD: Window subwindow
	FIELD: Time time
	FIELD: int x
	FIELD: int y
	FIELD: int x_root
	FIELD: int y_root
	FIELD: int mode
	FIELD: int detail
	FIELD: Bool same_screen
	FIELD: Bool focus
	FIELD: uint state
END-STRUCT

TYPEDEF: XCrossingEvent XEnterWindowEvent
TYPEDEF: XCrossingEvent XLeaveWindowEvent

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XFocusChangeEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
	FIELD: int mode
	FIELD: int detail
END-STRUCT

TYPEDEF: XFocusChangeEvent XFocusInEvent
TYPEDEF: XFocusChangeEvent XFocusOutEvent

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XExposeEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
	FIELD: int x
	FIELD: int y
	FIELD: int width
	FIELD: int height
	FIELD: int count
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XGraphicsExposeEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Drawable drawable
	FIELD: int x
	FIELD: int y
	FIELD: int width
	FIELD: int height
	FIELD: int count
	FIELD: int major_code
	FIELD: int minor_code
END-STRUCT

BEGIN-STRUCT: XNoExposeEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Drawable drawable
	FIELD: int major_code
	FIELD: int minor_code
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XVisibilityEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
	FIELD: int state
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XCreateWindowEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window parent
	FIELD: Window window
	FIELD: int x
	FIELD: int y
	FIELD: int width
	FIELD: int height
	FIELD: int border_width
	FIELD: Bool override_redirect
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XDestroyWindowEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window event
	FIELD: Window window
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XUnmapEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window event
	FIELD: Window window
	FIELD: Bool from_configure
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XMapEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window event
	FIELD: Window window
	FIELD: Bool override_redirect
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XMapRequestEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window parent
	FIELD: Window window
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XReparentEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window event
	FIELD: Window window
	FIELD: Window parent
	FIELD: int x
	FIELD: int y
	FIELD: Bool override_redirect
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XConfigureEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window event
	FIELD: Window window
	FIELD: int x
	FIELD: int y
	FIELD: int width
	FIELD: int height
	FIELD: int border_width
	FIELD: Window above
	FIELD: Bool override_redirect
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XGravityEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window event
	FIELD: Window window
	FIELD: int x
	FIELD: int y
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XResizeRequestEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
	FIELD: int width
	FIELD: int height
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XConfigureRequestEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window parent
	FIELD: Window window
	FIELD: int x
	FIELD: int y
	FIELD: int width
	FIELD: int height
	FIELD: int border_width
	FIELD: Window above
	FIELD: int detail
	FIELD: ulong value_mask
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XCirculateEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window event
	FIELD: Window window
	FIELD: int place
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XCirculateRequestEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window parent
	FIELD: Window window
	FIELD: int place
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XPropertyEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
	FIELD: Atom atom
	FIELD: Time time
	FIELD: int state
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XSelectionClearEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
	FIELD: Atom selection
	FIELD: Time time
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XSelectionRequestEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window owner
	FIELD: Window requestor
	FIELD: Atom selection
	FIELD: Atom target
	FIELD: Atom property
	FIELD: Time time
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XSelectionEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window requestor
	FIELD: Atom selection
	FIELD: Atom target
	FIELD: Atom property
	FIELD: Time time
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XColormapEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
	FIELD: Colormap colormap
	FIELD: Bool new
	FIELD: int state
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XClientMessageEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
	FIELD: Atom message_type
	FIELD: int format
	FIELD: long data0
	FIELD: long data1
	FIELD: long data2
	FIELD: long data3
	FIELD: long data4
!       union {
! 		char  b[20];
! 		short s[10];
! 		long  l[5];
! 	} data;
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XMappingEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
	FIELD: int request
	FIELD: int first_keycode
	FIELD: int count
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XErrorEvent
	FIELD: int type
	FIELD: Display* display
	FIELD: XID resourceid
	FIELD: ulong serial
	FIELD: uchar error_code
	FIELD: uchar request_code
	FIELD: uchar minor_code
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XKeymapEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
	! char key_vector[32];
	FIELD: int pad
	FIELD: int pad
	FIELD: int pad
	FIELD: int pad
	FIELD: int pad
	FIELD: int pad
	FIELD: int pad
	FIELD: int pad
END-STRUCT

C-UNION: XEvent
	int
	XAnyEvent
	XKeyEvent
	XButtonEvent
	XMotionEvent
	XCrossingEvent
	XFocusChangeEvent
	XExposeEvent
	XGraphicsExposeEvent
	XNoExposeEvent
	XVisibilityEvent
	XCreateWindowEvent
	XDestroyWindowEvent
	XUnmapEvent
	XMapEvent
	XMapRequestEvent
	XReparentEvent
	XConfigureEvent
	XGravityEvent
	XResizeRequestEvent
	XConfigureRequestEvent
	XCirculateEvent
	XCirculateRequestEvent
	XPropertyEvent
	XSelectionClearEvent
	XSelectionRequestEvent
	XSelectionEvent
	XColormapEvent
	XClientMessageEvent
	XMappingEvent
	XErrorEvent
	XKeymapEvent
;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 11 - Event Handling Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

FUNCTION: Status XSelectInput ( Display* display, Window w, long event_mask ) ;
FUNCTION: Status XFlush ( Display* display ) ;
FUNCTION: Status XSync ( Display* display, int discard ) ;
FUNCTION: int XPending ( Display* display ) ;
FUNCTION: Status XNextEvent ( Display* display, XEvent* event ) ;
FUNCTION: Status XMaskEvent ( Display* display, long event_mask, XEvent* event_return ) ;

! 11.3 - Event Queue Management

: QueuedAlready 0 ; inline
: QueuedAfterReading 1 ; inline
: QueuedAfterFlush 2 ; inline

FUNCTION: int XEventsQueued ( Display* display, int mode ) ;
FUNCTION: int XPending ( Display* display ) ;

! 11.6 - Sending Events to Other Applications

FUNCTION: Status XSendEvent ( Display* display, Window w, Bool propagate, long event_mask, XEvent* event_send ) ;

! 11.8 - Handling Protocol Errors

FUNCTION: int XSetErrorHandler ( void* handler ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 12 - Input Device Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: None 0 ; inline
: PointerRoot 1 ; inline

: RevertToNone		None ; inline
: RevertToPointerRoot	PointerRoot ; inline
: RevertToParent	2 ; inline

: GrabModeSync		0 ; inline
: GrabModeAsync		1 ; inline


FUNCTION: int XGrabPointer (
  Display* display,
  Window grab_window,
  Bool owner_events,
  uint event_mask,
  int pointer_mode,
  int keyboard_mode,
  Window confine_to,
  Cursor cursor,
  Time time ) ;

FUNCTION: Status XUngrabPointer ( Display* display, Time time ) ;
FUNCTION: Status XChangeActivePointerGrab ( Display* display, uint event_mask, Cursor cursor, Time time ) ;
FUNCTION: Status XGrabKey ( Display* display, int keycode, uint modifiers, Window grab_window, Bool owner_events, int pointer_mode, int keyboard_mode ) ;
FUNCTION: Status XSetInputFocus ( Display* display, Window focus, int revert_to, Time time ) ;
FUNCTION: Status XWarpPointer ( Display* display, Window src_w, Window dest_w, int src_x, int src_y, uint src_width, uint src_height, int dest_x, int dest_y ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 14 - Inter-Client Communication Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 14.1 Client to Window Manager Communication

FUNCTION: Status XFetchName ( Display* display, Window w, char** window_name_return ) ;
FUNCTION: Status XGetTransientForHint ( Display* display, Window w, Window* prop_window_return ) ;

! 14.1.1.  Manipulating Top-Level Windows

FUNCTION: Status XIconifyWindow (
	Display* display, Window w, int screen_number ) ;

FUNCTION: Status XWithdrawWindow (
	Display* display, Window w, int screen_number ) ;

! 14.1.6 - Setting and Reading the WM_HINTS Property

! 17.1.7 - Setting and Reading the WM_NORMAL_HINTS Property

: USPosition	1 0 shift ; inline
: USSize	1 1 shift ; inline
: PPosition	1 2 shift ; inline
: PSize		1 3 shift ; inline
: PMinSize	1 4 shift ; inline
: PMaxSize	1 5 shift ; inline
: PResizeInc	1 6 shift ; inline
: PAspect	1 7 shift ; inline
: PBaseSize	1 8 shift ; inline
: PWinGravity	1 9 shift ; inline
: PAllHints [ PPosition PSize PMinSize PMaxSize PResizeInc PAspect ]
0 [ execute bitor ] reduce ; inline

BEGIN-STRUCT: XSizeHints
    FIELD: long flags
    FIELD: int x
    FIELD: int y
    FIELD: int width
    FIELD: int height
    FIELD: int min_width
    FIELD: int min_height
    FIELD: int max_width
    FIELD: int max_height
    FIELD: int width_inc
    FIELD: int height_inc
    FIELD: int min_aspect_x
    FIELD: int min_aspect_y
    FIELD: int max_aspect_x
    FIELD: int max_aspect_y
    FIELD: int base_width
    FIELD: int base_height
    FIELD: int win_gravity;
END-STRUCT

! 14.1.10.  Setting and Reading the WM_PROTOCOLS Property

FUNCTION: Status XSetWMProtocols (
	Display* display, Window w, Atom* protocols, int count ) ;

FUNCTION: Status XGetWMProtocols (
	Display* display,
	Window w,
	Atom** protocols_return,
	int* count_return ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 16 - Application Utility Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 16.1 Keyboard Utility Functions

FUNCTION: KeySym XLookupKeysym ( XKeyEvent* key_event, int index ) ;

FUNCTION: int XLookupString (
	XKeyEvent* event_struct,
	void* buffer_return,
	int bytes_buffer,
	KeySym* keysym_return,
	XComposeStatus* status_in_out ) ;

! 16.7 Determining the Appropriate Visual Type

: VisualNoMask			HEX: 0 ; inline
: VisualIDMask 			HEX: 1 ; inline
: VisualScreenMask		HEX: 2 ; inline
: VisualDepthMask		HEX: 4 ; inline
: VisualClassMask		HEX: 8 ; inline
: VisualRedMaskMask		HEX: 10 ; inline
: VisualGreenMaskMask		HEX: 20 ; inline
: VisualBlueMaskMask		HEX: 40 ; inline
: VisualColormapSizeMask	HEX: 80 ; inline
: VisualBitsPerRGBMask		HEX: 100 ; inline
: VisualAllMask			HEX: 1FF ; inline

BEGIN-STRUCT: XVisualInfo
	FIELD: Visual* visual
	FIELD: VisualID visualid
	FIELD: int screen
	FIELD: uint depth
	FIELD: int class
	FIELD: ulong red_mask
	FIELD: ulong green_mask
	FIELD: ulong blue_mask
	FIELD: int colormap_size
	FIELD: int bits_per_rgb
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Appendix D - Compatibility Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

FUNCTION: Status XSetStandardProperties (
	Display* display,
	Window w,
	char* window_name,
	char* icon_name,
	Pixmap icon_pixmap,
	char** argv,
	int argc,
	XSizeHints* hints ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: CurrentTime 0 ; inline

: XA_PRIMARY  1 ; inline
: XA_SECONDARY 2 ; inline
: XA_ARC 3 ; inline
: XA_ATOM 4 ; inline
: XA_BITMAP 5 ; inline
: XA_CARDINAL 6 ; inline
: XA_COLORMAP 7 ; inline
: XA_CURSOR 8 ; inline
: XA_CUT_BUFFER0 9 ; inline
: XA_CUT_BUFFER1 10 ; inline
: XA_CUT_BUFFER2 11 ; inline
: XA_CUT_BUFFER3 12 ; inline
: XA_CUT_BUFFER4 13 ; inline
: XA_CUT_BUFFER5 14 ; inline
: XA_CUT_BUFFER6 15 ; inline
: XA_CUT_BUFFER7 16 ; inline
: XA_DRAWABLE 17 ; inline
: XA_FONT 18 ; inline
: XA_INTEGER 19 ; inline
: XA_PIXMAP 20 ; inline
: XA_POINT 21 ; inline
: XA_RECTANGLE 22 ; inline
: XA_RESOURCE_MANAGER 23 ; inline
: XA_RGB_COLOR_MAP 24 ; inline
: XA_RGB_BEST_MAP 25 ; inline
: XA_RGB_BLUE_MAP 26 ; inline
: XA_RGB_DEFAULT_MAP 27 ; inline
: XA_RGB_GRAY_MAP 28 ; inline
: XA_RGB_GREEN_MAP 29 ; inline
: XA_RGB_RED_MAP 30 ; inline
: XA_STRING 31 ; inline
: XA_VISUALID 32 ; inline
: XA_WINDOW 33 ; inline
: XA_WM_COMMAND 34 ; inline
: XA_WM_HINTS 35 ; inline
: XA_WM_CLIENT_MACHINE 36 ; inline
: XA_WM_ICON_NAME 37 ; inline
: XA_WM_ICON_SIZE 38 ; inline
: XA_WM_NAME 39 ; inline
: XA_WM_NORMAL_HINTS 40 ; inline
: XA_WM_SIZE_HINTS 41 ; inline
: XA_WM_ZOOM_HINTS 42 ; inline
: XA_MIN_SPACE 43 ; inline
: XA_NORM_SPACE 44 ; inline
: XA_MAX_SPACE 45 ; inline
: XA_END_SPACE 46 ; inline
: XA_SUPERSCRIPT_X 47 ; inline
: XA_SUPERSCRIPT_Y 48 ; inline
: XA_SUBSCRIPT_X 49 ; inline
: XA_SUBSCRIPT_Y 50 ; inline
: XA_UNDERLINE_POSITION 51 ; inline
: XA_UNDERLINE_THICKNESS 52 ; inline
: XA_STRIKEOUT_ASCENT 53 ; inline
: XA_STRIKEOUT_DESCENT 54 ; inline
: XA_ITALIC_ANGLE 55 ; inline
: XA_X_HEIGHT 56 ; inline
: XA_QUAD_WIDTH 57 ; inline
: XA_WEIGHT 58 ; inline
: XA_POINT_SIZE 59 ; inline
: XA_RESOLUTION 60 ; inline
: XA_COPYRIGHT 61 ; inline
: XA_NOTICE 62 ; inline
: XA_FONT_NAME 63 ; inline
: XA_FAMILY_NAME 64 ; inline
: XA_FULL_NAME 65 ; inline
: XA_CAP_HEIGHT 66 ; inline
: XA_WM_CLASS 67 ; inline
: XA_WM_TRANSIENT_FOR 68 ; inline

: XA_LAST_PREDEFINED 68 ; inline

: PropModeReplace         0 ; inline
: PropModePrepend         1 ; inline
: PropModeAppend          2 ; inline
    
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! The rest of the stuff is not from the book.
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

FUNCTION: void XFree ( void* data ) ;
FUNCTION: int XStoreName ( Display* display, Window w, char* window_name ) ;

: USPosition  1 0 shift ; inline
: USSize      1 1 shift ; inline
: PPosition   1 2 shift ; inline
: PSize       1 3 shift ; inline
: PMinSize    1 4 shift ; inline
: PMaxSize    1 5 shift ; inline
: PResizeInc  1 6 shift ; inline
: PAspect     1 7 shift ; inline
: PBaseSize   1 8 shift ; inline
: PWinGravity 1 9 shift ; inline

BEGIN-STRUCT: XSizeHints
    FIELD: long flags
    FIELD: int x
    FIELD: int y
    FIELD: int width
    FIELD: int height
    FIELD: int min_width
    FIELD: int min_height
    FIELD: int max_width
    FIELD: int max_height
    FIELD: int width_inc
    FIELD: int height_inc
    FIELD: int min_aspect_x
    FIELD: int min_aspect_y
    FIELD: int max_aspect_x
    FIELD: int max_aspect_y
    FIELD: int base_width
    FIELD: int base_height
    FIELD: int win_gravity
END-STRUCT

FUNCTION: void XSetWMNormalHints ( Display* display, Window w, XSizeHints* hints ) ;
