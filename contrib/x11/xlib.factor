! Eduardo Cavazos - wayo.cavazos@gmail.com
!
! The most popular guides to programming the X Window System are the
! series from Oreilly. For programming with Xlib, there is the
! reference manual and the programmers guide. However, a lesser known
! manual is the free Xlib manual that comes with the MIT X
! distribution. The arrangement and order of these bindings follows
! the structure of the free Xlib manual. If you add to this library
! and are wondering what part of the file to modify, just find the
! function or data structure in the manual and note the section.

IN: xlib USING: kernel arrays alien math words sequences ;

LIBRARY: xlib

"xlib" "libX11.so" "cdecl" add-library

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

TYPEDEF: int Status

TYPEDEF: int Bool

TYPEDEF: ulong VisualID
TYPEDEF: ulong Time

TYPEDEF: void* Window**

: False 0 ;
: True 1 ;

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

! 2.5 Closing the Display
FUNCTION: int XCloseDisplay ( Display* display ) ;

!
! 3 - Window Functions
!

! 3.2 - Window Attributes

: CWBackPixmap		1 0 shift ;
: CWBackPixel		1 1 shift ;
: CWBorderPixmap	1 2 shift ;
: CWBorderPixel         1 3 shift ;
: CWBitGravity		1 4 shift ;
: CWWinGravity		1 5 shift ;
: CWBackingStore        1 6 shift ;
: CWBackingPlanes	1 7 shift ;
: CWBackingPixel	1 8 shift ;
: CWOverrideRedirect	1 9 shift ;
: CWSaveUnder		1 10 shift ;
: CWEventMask		1 11 shift ;
: CWDontPropagate	1 12 shift ;
: CWColormap		1 13 shift ;
: CWCursor	        1 14 shift ;

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

: UnmapGravity		0 ;

: ForgetGravity		0 ;
: NorthWestGravity	1 ;
: NorthGravity		2 ;
: NorthEastGravity	3 ;
: WestGravity		4 ;
: CenterGravity		5 ;
: EastGravity		6 ;
: SouthWestGravity	7 ;
: SouthGravity		8 ;
: SouthEastGravity	9 ;
: StaticGravity		10 ;

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

: CWX			1 0 shift ;
: CWY			1 1 shift ;
: CWWidth		1 2 shift ;
: CWHeight		1 3 shift ;
: CWBorderWidth		1 4 shift ;
: CWSibling		1 5 shift ;
: CWStackMode		1 6 shift ;

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

FUNCTION: Status XChangeWindowAttributes ( Display* display, Window w, ulong valuemask, XSetWindowAttributes* attr ) ;
FUNCTION: Status XSetWindowBackground ( Display* display, Window w, ulong background_pixel ) ;
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

: IsUnmapped		0 ;
: IsUnviewable		1 ;
: IsViewable		2 ;

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

: GCFunction            1 0 shift ;
: GCPlaneMask           1 1 shift ;
: GCForeground          1 2 shift ;
: GCBackground          1 3 shift ;
: GCLineWidth           1 4 shift ;
: GCLineStyle           1 5 shift ;
: GCCapStyle            1 6 shift ;
: GCJoinStyle		1 7 shift ;
: GCFillStyle		1 8 shift ;
: GCFillRule		1 9 shift ;
: GCTile		1 10 shift ;
: GCStipple		1 11 shift ;
: GCTileStipXOrigin	1 12 shift ;
: GCTileStipYOrigin	1 13 shift ;
: GCFont 		1 14 shift ;
: GCSubwindowMode	1 15 shift ;
: GCGraphicsExposures   1 16 shift ;
: GCClipXOrigin		1 17 shift ;
: GCClipYOrigin		1 18 shift ;
: GCClipMask		1 19 shift ;
: GCDashOffset		1 20 shift ;
: GCDashList		1 21 shift ;
: GCArcMode		1 22 shift ;

: GXclear		HEX: 0 ;
: GXand			HEX: 1 ;
: GXandReverse		HEX: 2 ;
: GXcopy		HEX: 3 ;
: GXandInverted		HEX: 4 ;
: GXnoop		HEX: 5 ;
: GXxor			HEX: 6 ;
: GXor			HEX: 7 ;
: GXnor			HEX: 8 ;
: GXequiv		HEX: 9 ;
: GXinvert		HEX: a ;
: GXorReverse		HEX: b ;
: GXcopyInverted	HEX: c ;
: GXorInverted		HEX: d ;
: GXnand		HEX: e ;
: GXset			HEX: f ;

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

: ClipByChildren 0 ;
: IncludeInferiors 1 ;

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

: NoEventMask			0 ;
: KeyPressMask			1 0 shift ;
: KeyReleaseMask		1 1 shift ;
: ButtonPressMask		1 2 shift ;
: ButtonReleaseMask		1 3 shift ;
: EnterWindowMask		1 4 shift ;
: LeaveWindowMask		1 5 shift ;
: PointerMotionMask		1 6 shift ;
: PointerMotionHintMask		1 7 shift ;
: Button1MotionMask		1 8 shift ;
: Button2MotionMask		1 9 shift ;
: Button3MotionMask		1 10 shift ;
: Button4MotionMask		1 11 shift ;
: Button5MotionMask		1 12 shift ;
: ButtonMotionMask		1 13 shift ;
: KeymapStateMask		1 14 shift ;
: ExposureMask			1 15 shift ;
: VisibilityChangeMask		1 16 shift ;
: StructureNotifyMask		1 17 shift ;
: ResizeRedirectMask		1 18 shift ;
: SubstructureNotifyMask	1 19 shift ;
: SubstructureRedirectMask	1 20 shift ;
: FocusChangeMask		1 21 shift ;
: PropertyChangeMask		1 22 shift ;
: ColormapChangeMask		1 23 shift ;
: OwnerGrabButtonMask		1 24 shift ;

: KeyPress		2 ;
: KeyRelease		3 ;
: ButtonPress		4 ;
: ButtonRelease		5 ;
: MotionNotify		6 ;
: EnterNotify		7 ;
: LeaveNotify		8 ;
: FocusIn			9 ;
: FocusOut		10 ;
: KeymapNotify		11 ;
: Expose			12 ;
: GraphicsExpose		13 ;
: NoExpose		14 ;
: VisibilityNotify	15 ;
: CreateNotify		16 ;
: DestroyNotify		17 ;
: UnmapNotify		18 ;
: MapNotify		19 ;
: MapRequest		20 ;
: ReparentNotify		21 ;
: ConfigureNotify		22 ;
: ConfigureRequest	23 ;
: GravityNotify		24 ;
: ResizeRequest		25 ;
: CirculateNotify		26 ;
: CirculateRequest	27 ;
: PropertyNotify		28 ;
: SelectionClear		29 ;
: SelectionRequest	30 ;
: SelectionNotify		31 ;
: ColormapNotify		32 ;
: ClientMessage		33 ;
: MappingNotify		34 ;
: LASTEvent		35 ;



BEGIN-STRUCT: XAnyEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: Button1 1 ;
: Button2 2 ;
: Button3 3 ;
: Button4 4 ;
: Button5 5 ;

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

: XButtonEvent-position ( event -- { x y } )
  dup XButtonEvent-x swap XButtonEvent-y 2array ;

: XButtonEvent-root-position ( event -- { x y } )
  dup XButtonEvent-x swap XButtonEvent-y 2array ;


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
	FIELD: ulong serial
	FIELD: uchar error_code
	FIELD: uchar request_code
	FIELD: uchar minor_code
	FIELD: XID resourceid
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

BEGIN-STRUCT: XKeymapEvent
	FIELD: int type
	FIELD: ulong serial
	FIELD: Bool send_event
	FIELD: Display* display
	FIELD: Window window
	! char key_vector[32];
END-STRUCT

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! BEGIN-UNION: XEvent
!            int type;
!            XAnyEvent xany;
!            XKeyEvent xkey;
!            XButtonEvent xbutton;
!            XMotionEvent xmotion;
!            XCrossingEvent xcrossing;
!            XFocusChangeEvent xfocus;
!            XExposeEvent xexpose;
!            XGraphicsExposeEvent xgraphicsexpose;
!            XNoExposeEvent xnoexpose;
!            XVisibilityEvent xvisibility;
!            XCreateWindowEvent xcreatewindow;
!            XDestroyWindowEvent xdestroywindow;
!            XUnmapEvent xunmap;
!            XMapEvent xmap;
!            XMapRequestEvent xmaprequest;
!            XReparentEvent xreparent;
!            XConfigureEvent xconfigure;
!            XGravityEvent xgravity;
!            XResizeRequestEvent xresizerequest;
!            XConfigureRequestEvent xconfigurerequest;
!            XCirculateEvent xcirculate;
!            XCirculateRequestEvent xcirculaterequest;
!            XPropertyEvent xproperty;
!            XSelectionClearEvent xselectionclear;
!            XSelectionRequestEvent xselectionrequest;
!            XSelectionEvent xselection;
!            XColormapEvent xcolormap;
!            XClientMessageEvent xclient;
!            XMappingEvent xmapping;
!            XErrorEvent xerror;
!            XKeymapEvent xkeymap;
!            long pad[24];
! END-UNION

BEGIN-UNION: XEvent
	MEMBER: int
	MEMBER: XAnyEvent
!	MEMBER: XKeyEvent
	MEMBER: XButtonEvent
!	MEMBER: XMotionEvent
!	MEMBER: XCrossingEvent
!	MEMBER: XFocusChangeEvent
!	MEMBER: XExposeEvent
!	MEMBER: XGraphicsExposeEvent
!	MEMBER: XNoExposeEvent
!	MEMBER: XVisibilityEvent
!	MEMBER: XCreateWindowEvent
!	MEMBER: XDestroyWindowEvent
!	MEMBER: XUnmapEvent
!	MEMBER: XMapEvent
!	MEMBER: XMapRequestEvent
!	MEMBER: XReparentEvent
!	MEMBER: XConfigureEvent
!	MEMBER: XGravityEvent
!	MEMBER: XResizeRequestEvent
!	MEMBER: XConfigureRequestEvent
!	MEMBER: XCirculateEvent
!	MEMBER: XCirculateRequestEvent
!	MEMBER: XPropertyEvent
!	MEMBER: XSelectionClearEvent
!	MEMBER: XSelectionRequestEvent
!	MEMBER: XSelectionEvent
!	MEMBER: XColormapEvent
!	MEMBER: XClientMessageEvent
!	MEMBER: XMappingEvent
!	MEMBER: XErrorEvent
!	MEMBER: XKeymapEvent
!            long pad[24];
END-UNION

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

: QueuedAlready 0 ;
: QueuedAfterReading 1 ;
: QueuedAfterFlush 2 ;

FUNCTION: int XEventsQueued ( Display* display, int mode ) ;
FUNCTION: int XPending ( Display* display ) ;

! 11.6 - Sending Events to Other Applications

FUNCTION: Status XSendEvent ( Display* display, Window w, Bool propagate, long event_mask, XEvent* event_send ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 12 - Input Device Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: None 0 ;
: PointerRoot 1 ;

: RevertToNone		None ;
: RevertToPointerRoot	PointerRoot ;
: RevertToParent	2 ;

: GrabModeSync		0 ;
: GrabModeAsync		1 ;


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

FUNCTION: Status XSetWMProtocols ( Display* display, Window w, Atom* protocols, int count ) ;

FUNCTION: Status XFetchName ( Display* display, Window w, char** window_name_return ) ;
FUNCTION: Status XGetTransientForHint ( Display* display, Window w, Window* prop_window_return ) ;

! 14.1.6 - Setting and Reading the WM_HINTS Property

! 17.1.7 - Setting and Reading the WM_NORMAL_HINTS Property

: USPosition	1 0 shift ;
: USSize	1 1 shift ;
: PPosition	1 2 shift ;
: PSize		1 3 shift ;
: PMinSize	1 4 shift ;
: PMaxSize	1 5 shift ;
: PResizeInc	1 6 shift ;
: PAspect	1 7 shift ;
: PBaseSize	1 8 shift ;
: PWinGravity	1 9 shift ;
: PAllHints [ PPosition PSize PMinSize PMaxSize PResizeInc PAspect ]
0 [ execute bitor ] reduce ;

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

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 16 - Application Utility Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 16.1 Keyboard Utility Functions

FUNCTION: KeySym XLookupKeysym ( XKeyEvent* key_event, int index ) ;


FUNCTION: int XLookupString ( XKeyEvent* event_struct, char* buffer_return, int bytes_buffer, KeySym* keysym_return, XComposeStatus* status_in_out ) ;

! 16.7 Determining the Appropriate Visual Type

: VisualNoMask			HEX: 0 ;
: VisualIDMask 			HEX: 1 ;
: VisualScreenMask		HEX: 2 ;
: VisualDepthMask		HEX: 4 ;
: VisualClassMask		HEX: 8 ;
: VisualRedMaskMask		HEX: 10 ;
: VisualGreenMaskMask		HEX: 20 ;
: VisualBlueMaskMask		HEX: 40 ;
: VisualColormapSizeMask	HEX: 80 ;
: VisualBitsPerRGBMask		HEX: 100 ;
: VisualAllMask			HEX: 1FF ;

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

: CurrentTime 0 ;

: XA_PRIMARY  1 ;
: XA_SECONDARY 2 ;
: XA_ARC 3 ;
: XA_ATOM 4 ;
: XA_BITMAP 5 ;
: XA_CARDINAL 6 ;
: XA_COLORMAP 7 ;
: XA_CURSOR 8 ;
: XA_CUT_BUFFER0 9 ;
: XA_CUT_BUFFER1 10 ;
: XA_CUT_BUFFER2 11 ;
: XA_CUT_BUFFER3 12 ;
: XA_CUT_BUFFER4 13 ;
: XA_CUT_BUFFER5 14 ;
: XA_CUT_BUFFER6 15 ;
: XA_CUT_BUFFER7 16 ;
: XA_DRAWABLE 17 ;
: XA_FONT 18 ;
: XA_INTEGER 19 ;
: XA_PIXMAP 20 ;
: XA_POINT 21 ;
: XA_RECTANGLE 22 ;
: XA_RESOURCE_MANAGER 23 ;
: XA_RGB_COLOR_MAP 24 ;
: XA_RGB_BEST_MAP 25 ;
: XA_RGB_BLUE_MAP 26 ;
: XA_RGB_DEFAULT_MAP 27 ;
: XA_RGB_GRAY_MAP 28 ;
: XA_RGB_GREEN_MAP 29 ;
: XA_RGB_RED_MAP 30 ;
: XA_STRING 31 ;
: XA_VISUALID 32 ;
: XA_WINDOW 33 ;
: XA_WM_COMMAND 34 ;
: XA_WM_HINTS 35 ;
: XA_WM_CLIENT_MACHINE 36 ;
: XA_WM_ICON_NAME 37 ;
: XA_WM_ICON_SIZE 38 ;
: XA_WM_NAME 39 ;
: XA_WM_NORMAL_HINTS 40 ;
: XA_WM_SIZE_HINTS 41 ;
: XA_WM_ZOOM_HINTS 42 ;
: XA_MIN_SPACE 43 ;
: XA_NORM_SPACE 44 ;
: XA_MAX_SPACE 45 ;
: XA_END_SPACE 46 ;
: XA_SUPERSCRIPT_X 47 ;
: XA_SUPERSCRIPT_Y 48 ;
: XA_SUBSCRIPT_X 49 ;
: XA_SUBSCRIPT_Y 50 ;
: XA_UNDERLINE_POSITION 51 ;
: XA_UNDERLINE_THICKNESS 52 ;
: XA_STRIKEOUT_ASCENT 53 ;
: XA_STRIKEOUT_DESCENT 54 ;
: XA_ITALIC_ANGLE 55 ;
: XA_X_HEIGHT 56 ;
: XA_QUAD_WIDTH 57 ;
: XA_WEIGHT 58 ;
: XA_POINT_SIZE 59 ;
: XA_RESOLUTION 60 ;
: XA_COPYRIGHT 61 ;
: XA_NOTICE 62 ;
: XA_FONT_NAME 63 ;
: XA_FAMILY_NAME 64 ;
: XA_FULL_NAME 65 ;
: XA_CAP_HEIGHT 66 ;
: XA_WM_CLASS 67 ;
: XA_WM_TRANSIENT_FOR 68 ;

: XA_LAST_PREDEFINED 68 ;

: PropModeReplace         0 ;
: PropModePrepend         1 ;
: PropModeAppend          2 ;
