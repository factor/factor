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

USING: kernel arrays alien alien.c-types alien.syntax
math words sequences namespaces continuations ;
IN: x11.xlib

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
TYPEDEF: void* XIM
TYPEDEF: void* XIC

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

C-STRUCT: XSetWindowAttributes
	{ "Pixmap" "background_pixmap" }
	{ "ulong" "background_pixel" }
	{ "Pixmap" "border_pixmap" }
	{ "ulong" "border_pixel" }
	{ "int" "bit_gravity" }
	{ "int" "win_gravity" }
	{ "int" "backing_store" }
	{ "ulong" "backing_planes" }
	{ "ulong" "backing_pixel" }
	{ "Bool" "save_under" }
	{ "long" "event_mask" }
	{ "long" "do_not_propagate_mask" }
	{ "Bool" "override_redirect" }
	{ "Colormap" "colormap" }
	{ "Cursor" "cursor" } ;

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

C-STRUCT: XWindowChanges
	{ "int" "x" }
	{ "int" "y" }
	{ "int" "width" }
	{ "int" "height" }
	{ "int" "border_width" }
	{ "Window" "sibling" }
	{ "int" "stack_mode" } ;

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

C-STRUCT: XWindowAttributes
	{ "int" "x" }
	{ "int" "y" }
	{ "int" "width" }
	{ "int" " height" }
	{ "int" "border_width" }
	{ "int" "depth" }
	{ "Visual*" "visual" }
	{ "Window" "root" }
	{ "int" "class" }
	{ "int" "bit_gravity" }
	{ "int" "win_gravity" }
	{ "int" "backing_store" }
	{ "ulong" "backing_planes" }
	{ "ulong" "backing_pixel" }
	{ "Bool" "save_under" }
	{ "Colormap" "colormap" }
	{ "Bool" "map_installed" }
	{ "int" "map_state" }
	{ "long" "all_event_masks" }
	{ "long" "your_event_mask" }
	{ "long" "do_not_propagate_mask" }
	{ "Bool" "override_redirect" }
	{ "Screen*" "screen" } ;

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

FUNCTION: int XChangeProperty ( Display* display, Window w, Atom property, Atom type, int format, int mode, void* data, int nelements ) ;

! 4.5 Selections

FUNCTION: int XSetSelectionOwner ( Display* display, Atom selection, Window owner, Time time ) ;

FUNCTION: Window XGetSelectionOwner ( Display* display, Atom selection ) ;

FUNCTION: int XConvertSelection ( Display* display, Atom selection, Atom target, Atom property, Window requestor, Time time ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 6 - Color Management Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XColor
	{ "ulong" "pixel" }
	{ "ushort" "red" }
	{ "ushort" "green" }
	{ "ushort" "blue" }
	{ "char" "flags" }
	{ "char" "pad" } ;

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

C-STRUCT: XGCValues
	{ "int" "function" }
	{ "ulong" "plane_mask" }
	{ "ulong" "foreground" }
	{ "ulong" "background" }
	{ "int" "line_width" }
	{ "int" "line_style" }
	{ "int" "cap_style" }
	{ "int" "join_style" }
	{ "int" "fill_style" }
	{ "int" "fill_rule" }
	{ "int" "arc_mode" }
	{ "Pixmap" "tile" }
	{ "Pixmap" "stipple" }
	{ "int" "ts_x_origin" }
	{ "int" "ts_y_origin" }
	{ "Font" "font" }
	{ "int" "subwindow_mode" }
	{ "Bool" "graphics_exposures" }
	{ "int" "clip_x_origin" }
	{ "int" "clip_y_origin" }
	{ "Pixmap" "clip_mask" }
	{ "int" "dash_offset" }
	{ "char" "dashes" } ;

FUNCTION: GC XCreateGC ( Display* display, Window d, ulong valuemask, XGCValues* values ) ;
FUNCTION: int XChangeGC ( Display* display, GC gc, ulong valuemask, XGCValues* values ) ;
FUNCTION: Status XGetGCValues ( Display* display, GC gc, ulong valuemask, XGCValues* values_return ) ;
FUNCTION: Status XSetForeground ( Display* display, GC gc, ulong foreground ) ;
FUNCTION: Status XSetBackground ( Display* display, GC gc, ulong background ) ;
FUNCTION: Status XSetFunction ( Display* display, GC gc, int function ) ;
FUNCTION: Status XSetSubwindowMode ( Display* display, GC gc, int subwindow_mode ) ;

FUNCTION: GContext XGContextFromGC ( GC gc ) ;

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

C-STRUCT: XCharStruct
	{ "short" "lbearing" }
	{ "short" "rbearing" }
	{ "short" "width" }
	{ "short" "ascent" }
	{ "short" "descent" }
	{ "ushort" "attributes" } ;

FUNCTION: Font XLoadFont ( Display* display, char* name ) ;
FUNCTION: XFontStruct* XQueryFont ( Display* display, XID font_ID ) ;
FUNCTION: XFontStruct* XLoadQueryFont ( Display* display, char* name ) ;

C-STRUCT: XFontStruct
	{ "XExtData*" "ext_data" }
	{ "Font" "fid" }
	{ "uint" "direction" }
	{ "uint" "min_char_or_byte2" }
	{ "uint" "max_char_or_byte2" }
	{ "uint" "min_byte1" }
	{ "uint" "max_byte1" }
	{ "Bool" "all_chars_exist" }
	{ "uint" "default_char" }
	{ "int" "n_properties" }
	{ "XFontProp*" "properties" }
	{ "XCharStruct" "min_bounds" }
	{ "XCharStruct" "max_bounds" }
	{ "XCharStruct*" "per_char" }
	{ "int" "ascent" }
	{ "int" "descent" } ;

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

C-STRUCT: XAnyEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "window" } ;

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

C-STRUCT: XButtonEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "window" }
	{ "Window" "root" }
	{ "Window" "subwindow" }
	{ "Time" "time" }
	{ "int" "x" }
	{ "int" "y" }
	{ "int" "x_root" }
	{ "int" "y_root" }
	{ "uint" "state" }
	{ "uint" "button" }
	{ "Bool" "same_screen" } ;

TYPEDEF: XButtonEvent XButtonPressedEvent
TYPEDEF: XButtonEvent XButtonReleasedEvent


! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XKeyEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "window" }
	{ "Window" "root" }
	{ "Window" "subwindow" }
	{ "Time" "time" }
	{ "int" "x" }
	{ "int" "y" }
	{ "int" "x_root" }
	{ "int" "y_root" }
	{ "uint" "state" }
	{ "uint" "keycode" }
	{ "Bool" "same_screen" } ;

TYPEDEF: XKeyEvent XKeyPressedEvent
TYPEDEF: XKeyEvent XKeyReleasedEvent

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XMotionEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "window" }
	{ "Window" "root" }
	{ "Window" "subwindow" }
	{ "Time" "time" }
	{ "int" "x" }
	{ "int" "y" }
	{ "int" "x_root" }
	{ "int" "y_root" }
	{ "uint" "state" }
	{ "char" "is_hint" }
	{ "Bool" "same_screen" } ;

TYPEDEF: XMotionEvent XPointerMovedEvent

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XCrossingEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "window" }
	{ "Window" "root" }
	{ "Window" "subwindow" }
	{ "Time" "time" }
	{ "int" "x" }
	{ "int" "y" }
	{ "int" "x_root" }
	{ "int" "y_root" }
	{ "int" "mode" }
	{ "int" "detail" }
	{ "Bool" "same_screen" }
	{ "Bool" "focus" }
	{ "uint" "state" } ;

TYPEDEF: XCrossingEvent XEnterWindowEvent
TYPEDEF: XCrossingEvent XLeaveWindowEvent

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XFocusChangeEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "window" }
	{ "int" "mode" }
	{ "int" "detail" } ;

TYPEDEF: XFocusChangeEvent XFocusInEvent
TYPEDEF: XFocusChangeEvent XFocusOutEvent

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XExposeEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "window" }
	{ "int" "x" }
	{ "int" "y" }
	{ "int" "width" }
	{ "int" "height" }
	{ "int" "count" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XGraphicsExposeEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Drawable" "drawable" }
	{ "int" "x" }
	{ "int" "y" }
	{ "int" "width" }
	{ "int" "height" }
	{ "int" "count" }
	{ "int" "major_code" }
	{ "int" "minor_code" } ;

C-STRUCT: XNoExposeEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Drawable" "drawable" }
	{ "int" "major_code" }
	{ "int" "minor_code" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XVisibilityEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "window" }
	{ "int" "state" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XCreateWindowEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "parent" }
	{ "Window" "window" }
	{ "int" "x" }
	{ "int" "y" }
	{ "int" "width" }
	{ "int" "height" }
	{ "int" "border_width" }
	{ "Bool" "override_redirect" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XDestroyWindowEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "event" }
	{ "Window" "window" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XUnmapEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "event" }
	{ "Window" "window" }
	{ "Bool" "from_configure" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XMapEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "event" }
	{ "Window" "window" }
	{ "Bool" "override_redirect" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XMapRequestEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "parent" }
	{ "Window" "window" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XReparentEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "event" }
	{ "Window" "window" }
	{ "Window" "parent" }
	{ "int" "x" }
	{ "int" "y" }
	{ "Bool" "override_redirect" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XConfigureEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "event" }
	{ "Window" "window" }
	{ "int" "x" }
	{ "int" "y" }
	{ "int" "width" }
	{ "int" "height" }
	{ "int" "border_width" }
	{ "Window" "above" }
	{ "Bool" "override_redirect" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XGravityEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "event" }
	{ "Window" "window" }
	{ "int" "x" }
	{ "int" "y" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XResizeRequestEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "window" }
	{ "int" "width" }
	{ "int" "height" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XConfigureRequestEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "parent" }
	{ "Window" "window" }
	{ "int" "x" }
	{ "int" "y" }
	{ "int" "width" }
	{ "int" "height" }
	{ "int" "border_width" }
	{ "Window" "above" }
	{ "int" "detail" }
	{ "ulong" "value_mask" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XCirculateEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "event" }
	{ "Window" "window" }
	{ "int" "place" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XCirculateRequestEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "parent" }
	{ "Window" "window" }
	{ "int" "place" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XPropertyEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "window" }
	{ "Atom" "atom" }
	{ "Time" "time" }
	{ "int" "state" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XSelectionClearEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "window" }
	{ "Atom" "selection" }
	{ "Time" "time" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XSelectionRequestEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "owner" }
	{ "Window" "requestor" }
	{ "Atom" "selection" }
	{ "Atom" "target" }
	{ "Atom" "property" }
	{ "Time" "time" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XSelectionEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "requestor" }
	{ "Atom" "selection" }
	{ "Atom" "target" }
	{ "Atom" "property" }
	{ "Time" "time" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XColormapEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "window" }
	{ "Colormap" "colormap" }
	{ "Bool" "new" }
	{ "int" "state" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XClientMessageEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "window" }
	{ "Atom" "message_type" }
	{ "int" "format" }
	{ "long" "data0" }
	{ "long" "data1" }
	{ "long" "data2" }
	{ "long" "data3" }
	{ "long" "data4" }
!       union {
! 		char  b[20];
! 		short s[10];
! 		long  l[5];
! 	} data;
;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XMappingEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "window" }
	{ "int" "request" }
	{ "int" "first_keycode" }
	{ "int" "count" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XErrorEvent
	{ "int" "type" }
	{ "Display*" "display" }
	{ "XID" "resourceid" }
	{ "ulong" "serial" }
	{ "uchar" "error_code" }
	{ "uchar" "request_code" }
	{ "uchar" "minor_code" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

C-STRUCT: XKeymapEvent
	{ "int" "type" }
	{ "ulong" "serial" }
	{ "Bool" "send_event" }
	{ "Display*" "display" }
	{ "Window" "window" }
	! char key_vector[32];
	{ "int" "pad" }
	{ "int" "pad" }
	{ "int" "pad" }
	{ "int" "pad" }
	{ "int" "pad" }
	{ "int" "pad" }
	{ "int" "pad" }
	{ "int" "pad" } ;

C-UNION: XEvent
	"int"
	"XAnyEvent"
	"XKeyEvent"
	"XButtonEvent"
	"XMotionEvent"
	"XCrossingEvent"
	"XFocusChangeEvent"
	"XExposeEvent"
	"XGraphicsExposeEvent"
	"XNoExposeEvent"
	"XVisibilityEvent"
	"XCreateWindowEvent"
	"XDestroyWindowEvent"
	"XUnmapEvent"
	"XMapEvent"
	"XMapRequestEvent"
	"XReparentEvent"
	"XConfigureEvent"
	"XGravityEvent"
	"XResizeRequestEvent"
	"XConfigureRequestEvent"
	"XCirculateEvent"
	"XCirculateRequestEvent"
	"XPropertyEvent"
	"XSelectionClearEvent"
	"XSelectionRequestEvent"
	"XSelectionEvent"
	"XColormapEvent"
	"XClientMessageEvent"
	"XMappingEvent"
	"XErrorEvent"
	"XKeymapEvent"
	{ "long" 24 } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 11 - Event Handling Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

FUNCTION: Status XSelectInput ( Display* display, Window w, long event_mask ) ;
FUNCTION: Status XFlush ( Display* display ) ;
FUNCTION: Status XSync ( Display* display, int discard ) ;
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

FUNCTION: Status XGetInputFocus ( Display* display,
	  	 		  Window*  focus_return,
				  int* 	   revert_to_return ) ;

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

C-STRUCT: XSizeHints
    { "long" "flags" }
    { "int" "x" }
    { "int" "y" }
    { "int" "width" }
    { "int" "height" }
    { "int" "min_width" }
    { "int" "min_height" }
    { "int" "max_width" }
    { "int" "max_height" }
    { "int" "width_inc" }
    { "int" "height_inc" }
    { "int" "min_aspect_x" }
    { "int" "min_aspect_y" }
    { "int" "max_aspect_x" }
    { "int" "max_aspect_y" }
    { "int" "base_width" }
    { "int" "base_height" }
    { "int" "win_gravity" } ;

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

C-STRUCT: XVisualInfo
	{ "Visual*" "visual" }
	{ "VisualID" "visualid" }
	{ "int" "screen" }
	{ "uint" "depth" }
	{ "int" "class" }
	{ "ulong" "red_mask" }
	{ "ulong" "green_mask" }
	{ "ulong" "blue_mask" }
	{ "int" "colormap_size" }
	{ "int" "bits_per_rgb" } ;

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
    
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! The rest of the stuff is not from the book.
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

FUNCTION: void XFree ( void* data ) ;
FUNCTION: int XStoreName ( Display* display, Window w, char* window_name ) ;

FUNCTION: void XSetWMNormalHints ( Display* display, Window w, XSizeHints* hints ) ;

! !!! INPUT METHODS

: XIMPreeditArea      HEX: 0001 ;
: XIMPreeditCallbacks HEX: 0002 ;
: XIMPreeditPosition  HEX: 0004 ;
: XIMPreeditNothing   HEX: 0008 ;
: XIMPreeditNone      HEX: 0010 ;
: XIMStatusArea       HEX: 0100 ;
: XIMStatusCallbacks  HEX: 0200 ;
: XIMStatusNothing    HEX: 0400 ;
: XIMStatusNone       HEX: 0800 ;

: XNVaNestedList "XNVaNestedList" ;
: XNQueryInputStyle "queryInputStyle" ;
: XNClientWindow "clientWindow" ;
: XNInputStyle "inputStyle" ;
: XNFocusWindow "focusWindow" ;
: XNResourceName "resourceName" ;
: XNResourceClass "resourceClass" ;
: XNGeometryCallback "geometryCallback" ;
: XNDestroyCallback "destroyCallback" ;
: XNFilterEvents "filterEvents" ;
: XNPreeditStartCallback "preeditStartCallback" ;
: XNPreeditDoneCallback "preeditDoneCallback" ;
: XNPreeditDrawCallback "preeditDrawCallback" ;
: XNPreeditCaretCallback "preeditCaretCallback" ;
: XNPreeditStateNotifyCallback "preeditStateNotifyCallback" ;
: XNPreeditAttributes "preeditAttributes" ;
: XNStatusStartCallback "statusStartCallback" ;
: XNStatusDoneCallback "statusDoneCallback" ;
: XNStatusDrawCallback "statusDrawCallback" ;
: XNStatusAttributes "statusAttributes" ;
: XNArea "area" ;
: XNAreaNeeded "areaNeeded" ;
: XNSpotLocation "spotLocation" ;
: XNColormap "colorMap" ;
: XNStdColormap "stdColorMap" ;
: XNForeground "foreground" ;
: XNBackground "background" ;
: XNBackgroundPixmap "backgroundPixmap" ;
: XNFontSet "fontSet" ;
: XNLineSpace "lineSpace" ;
: XNCursor "cursor" ;

: XNQueryIMValuesList "queryIMValuesList" ;
: XNQueryICValuesList "queryICValuesList" ;
: XNVisiblePosition "visiblePosition" ;
: XNR6PreeditCallback "r6PreeditCallback" ;
: XNStringConversionCallback "stringConversionCallback" ;
: XNStringConversion "stringConversion" ;
: XNResetState "resetState" ;
: XNHotKey "hotKey" ;
: XNHotKeyState "hotKeyState" ;
: XNPreeditState "preeditState" ;
: XNSeparatorofNestedList "separatorofNestedList" ;

: XBufferOverflow -1 ;
: XLookupNone      1 ;
: XLookupChars     2 ;
: XLookupKeySym    3 ;
: XLookupBoth      4 ;

FUNCTION: Bool XFilterEvent ( XEvent* event, Window w ) ;

FUNCTION: XIM XOpenIM ( Display* dpy, void* rdb, char* res_name, char* res_class ) ;

FUNCTION: Status XCloseIM ( XIM im ) ;

FUNCTION: XIC XCreateIC ( XIM im, char* key1, Window value1, char* key2, Window value2, char* key3, int value3, char* key4, char* value4, char* key5, char* value5, int key6 ) ;

FUNCTION: void XDestroyIC ( XIC ic ) ;

FUNCTION: void XSetICFocus ( XIC ic ) ;
        
FUNCTION: void XUnsetICFocus ( XIC ic ) ;

FUNCTION: int XwcLookupString ( XIC ic, XKeyPressedEvent* event, ulong* buffer_return, int bytes_buffer, KeySym* keysym_return, Status* status_return ) ;

FUNCTION: int Xutf8LookupString ( XIC ic, XKeyPressedEvent* event, char* buffer_return, int bytes_buffer, KeySym* keysym_return, Status* status_return ) ;

SYMBOL: dpy
SYMBOL: scr
SYMBOL: root

: flush-dpy ( -- ) dpy get XFlush drop ;

: x-atom ( string -- atom ) dpy get swap 0 XInternAtom ;

: check-display
    [
        "Cannot connect to X server - check $DISPLAY" throw
    ] unless* ;

: initialize-x ( display-string -- )
    dup [ string>char-alien ] when
    XOpenDisplay check-display dpy set-global
    dpy get XDefaultScreen scr set-global
    dpy get scr get XRootWindow root set-global ;

: close-x ( -- ) dpy get XCloseDisplay drop ;

: with-x ( display-string quot -- )
    >r initialize-x r> [ close-x ] [ ] cleanup ;
