! Copyright (C) 2005, 2006 Eduardo Cavazos
! See https://factorcode.org/license.txt for BSD license.
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
!
! https://www.x.org/releases/X11R7.6/doc/libX11/specs/libX11/libX11.html
USING: accessors alien.c-types alien.data alien.syntax classes.struct
io.encodings.ascii kernel literals math x11.X x11.syntax ;
IN: x11.xlib

LIBRARY: xlib

TYPEDEF: c-string XPointer
C-TYPE: Screen
TYPEDEF: void* GC
C-TYPE: Visual
C-TYPE: XExtData
C-TYPE: XFontProp
C-TYPE: XComposeStatus
TYPEDEF: void* XIM
TYPEDEF: void* XIC

TYPEDEF: int Status

TYPEDEF: int Bool

TYPEDEF: ulong VisualID
TYPEDEF: ulong Time

: *XID ( bytes -- n ) ulong deref ;
ALIAS: *Window *XID
ALIAS: *Drawable *XID
ALIAS: *KeySym *XID
: *Atom ( bytes -- n ) ulong deref ;
!
! 2 - Display Functions
!

! This struct is incomplete
STRUCT: Display
    { ext_data void* }
    { free_funcs void* }
    { fd int } ;

X-FUNCTION: Display* XOpenDisplay ( c-string[ascii] display_name )

! 2.2 Obtaining Information about the Display, Image Formats, or Screens

X-FUNCTION: ulong XBlackPixel ( Display* display, int screen_number )
X-FUNCTION: ulong XWhitePixel ( Display* display, int screen_number )
X-FUNCTION: Colormap XDefaultColormap ( Display* display, int screen_number )
X-FUNCTION: int XDefaultDepth ( Display* display, int screen_number )
X-FUNCTION: GC XDefaultGC ( Display* display, int screen_number )
X-FUNCTION: int XDefaultScreen ( Display* display )
X-FUNCTION: Window XRootWindow ( Display* display, int screen_number )
X-FUNCTION: Window XDefaultRootWindow ( Display* display )
X-FUNCTION: int XProtocolVersion ( Display* display )
X-FUNCTION: int XProtocolRevision ( Display* display )
X-FUNCTION: int XQLength ( Display* display )
X-FUNCTION: int XScreenCount ( Display* display )
X-FUNCTION: int XConnectionNumber ( Display* display )

! 2.5 Closing the Display
X-FUNCTION: int XCloseDisplay ( Display* display )

!
! 3 - Window Functions
!

! 3.2 - Window Attributes

: CWBackPixmap       ( -- n ) 0 2^ ; inline
: CWBackPixel        ( -- n ) 1 2^ ; inline
: CWBorderPixmap     ( -- n ) 2 2^ ; inline
: CWBorderPixel      ( -- n ) 3 2^ ; inline
: CWBitGravity       ( -- n ) 4 2^ ; inline
: CWWinGravity       ( -- n ) 5 2^ ; inline
: CWBackingStore     ( -- n ) 6 2^ ; inline
: CWBackingPlanes    ( -- n ) 7 2^ ; inline
: CWBackingPixel     ( -- n ) 8 2^ ; inline
: CWOverrideRedirect ( -- n ) 9 2^ ; inline
: CWSaveUnder        ( -- n ) 10 2^ ; inline
: CWEventMask        ( -- n ) 11 2^ ; inline
: CWDontPropagate    ( -- n ) 12 2^ ; inline
: CWColormap         ( -- n ) 13 2^ ; inline
: CWCursor           ( -- n ) 14 2^ ; inline

STRUCT: XSetWindowAttributes
    { background_pixmap Pixmap }
    { background_pixel ulong }
    { border_pixmap Pixmap }
    { border_pixel ulong }
    { bit_gravity int }
    { win_gravity int }
    { backing_store int }
    { backing_planes ulong }
    { backing_pixel ulong }
    { save_under Bool }
    { event_mask long }
    { do_not_propagate_mask long }
    { override_redirect Bool }
    { colormap Colormap }
    { cursor Cursor } ;

! 3.3 - Creating Windows

X-FUNCTION: Window XCreateWindow ( Display* display,
                                   Window parent,
                                   int x, int y, uint width, uint height,
                                   uint border_width, int depth, uint class,
                                   Visual* visual, ulong valuemask,
                                   XSetWindowAttributes* attributes )
X-FUNCTION: Window XCreateSimpleWindow ( Display* display,
                                         Window parent,
                                         int x, int y, uint width, uint height,
                                         uint border_width, ulong border,
                                         ulong background )
X-FUNCTION: Status XDestroyWindow ( Display* display, Window w )
X-FUNCTION: Status XMapWindow ( Display* display, Window window )
X-FUNCTION: Status XMapSubwindows ( Display* display, Window window )
X-FUNCTION: Status XUnmapWindow ( Display* display, Window w )
X-FUNCTION: Status XUnmapSubwindows ( Display* display, Window w )

! 3.5 Mapping Windows

X-FUNCTION: int XMapRaised ( Display* display, Window w )

! 3.7 - Configuring Windows

STRUCT: XWindowChanges
    { x int }
    { y int }
    { width int }
    { height int }
    { border_width int }
    { sibling Window }
    { stack_mode int } ;

X-FUNCTION: Status XConfigureWindow ( Display* display,
                                      Window w,
                                      uint value_mask, XWindowChanges* values )
X-FUNCTION: Status XMoveWindow ( Display* display, Window w,
                                 int x, int y )
X-FUNCTION: Status XResizeWindow ( Display* display,
                                   Window w,
                                   uint width,
                                   uint height )
X-FUNCTION: Status XSetWindowBorderWidth ( Display* display,
                                           ulong w,
                                           uint width )


! 3.8 Changing Window Stacking Order

X-FUNCTION: Status XRaiseWindow ( Display* display, Window w )
X-FUNCTION: Status XLowerWindow ( Display* display, Window w )

! 3.9 - Changing Window Attributes

X-FUNCTION: Status XChangeWindowAttributes ( Display* display,
                                             Window w,
                                             ulong valuemask,
                                             XSetWindowAttributes* attr )
X-FUNCTION: Status XSetWindowBackground ( Display* display,
                                          Window w, ulong background_pixel )
X-FUNCTION: Status XDefineCursor ( Display* display, Window w, Cursor cursor )
X-FUNCTION: Status XUndefineCursor ( Display* display, Window w )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 4 - Window Information Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 4.1 - Obtaining Window Information

X-FUNCTION: Status XQueryTree ( Display* display,
                                Window w,
                                Window* root_return,
                                Window* parent_return,
                                Window** children_return,
                                uint* nchildren_return )

STRUCT: XWindowAttributes
    { x int }
    { y int }
    { width int }
    {  height int }
    { border_width int }
    { depth int }
    { visual Visual* }
    { root Window }
    { class int }
    { bit_gravity int }
    { win_gravity int }
    { backing_store int }
    { backing_planes ulong }
    { backing_pixel ulong }
    { save_under Bool }
    { colormap Colormap }
    { map_installed Bool }
    { map_state int }
    { all_event_masks long }
    { your_event_mask long }
    { do_not_propagate_mask long }
    { override_redirect Bool }
    { screen Screen* } ;

X-FUNCTION: Status XGetWindowAttributes ( Display* display,
                                          Window w,
                                          XWindowAttributes* attr )

X-FUNCTION: Status XGetGeometry ( Display* display,
                                  Drawable d,
                                  Window* root_return,
                                  int* x_return,
                                  int* y_return,
                                  uint* width_return,
                                  uint* height_return,
                                  uint* border_width_return,
                                  uint* depth_return )

! 4.2 - Translating Screen Coordinates

X-FUNCTION: Bool XQueryPointer ( Display* display,
                                 Window w,
                                 Window* root_return, Window* child_return,
                                 int* root_x_return, int* root_y_return,
                                 int* win_x_return, int* win_y_return,
                                 uint* mask_return )

! 4.3 - Properties and Atoms

X-FUNCTION: Atom XInternAtom ( Display* display,
                               c-string atom_name,
                               Bool only_if_exists )

X-FUNCTION: c-string XGetAtomName ( Display* display, Atom atom )

! 4.4 - Obtaining and Changing Window Properties

X-FUNCTION: int XGetWindowProperty ( Display* display, Window w, Atom property,
                                     long long_offset, long long_length,
                                     Bool delete, Atom req_type,
                                     Atom* actual_type_return,
                                     int* actual_format_return,
                                     ulong* nitems_return,
                                     ulong* bytes_after_return,
                                     c-string* prop_return )

X-FUNCTION: int XChangeProperty ( Display* display, Window w, Atom property,
                                  Atom type, int format,
                                  int mode, void* data, int nelements )

! 4.5 Selections

X-FUNCTION: int XSetSelectionOwner ( Display* display,
                                     Atom selection,
                                     Window owner,
                                     Time time )

X-FUNCTION: Window XGetSelectionOwner ( Display* display, Atom selection )

X-FUNCTION: int XConvertSelection ( Display* display,
                                    Atom selection,
                                    Atom target,
                                    Atom property,
                                    Window requestor,
                                    Time time )


! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 5 - Pixmap and Cursor Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 5.1 - Creating and Freeing Pixmaps

X-FUNCTION: Pixmap XCreatePixmap ( Display* display,
                                   Drawable d,
                                   uint width, uint height, uint depth )
X-FUNCTION: int XFreePixmap ( Display* display, Pixmap pixmap )

! 5.2 - Creating, Recoloring, and Freeing Cursors

C-TYPE: XColor
X-FUNCTION: Cursor XCreatePixmapCursor ( Display* display,
                                         Pixmap source, Pixmap mask,
                                         XColor* foreground_color,
                                         XColor* background_color,
                                         uint x, uint y )
X-FUNCTION: int XFreeCursor ( Display* display, Cursor cursor )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 6 - Color Management Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XColor
    { pixel ulong }
    { red ushort }
    { green ushort }
    { blue ushort }
    { flags char }
    { pad char } ;

X-FUNCTION: Status XLookupColor ( Display* display,
                                  Colormap colormap,
                                  c-string color_name,
                                  XColor* exact_def_return,
                                  XColor* screen_def_return )
X-FUNCTION: Status XAllocColor ( Display* display, Colormap colormap, XColor* screen_in_out )
X-FUNCTION: Status XQueryColor ( Display* display, Colormap colormap, XColor* def_in_out )

! 6.4 Creating, Copying, and Destroying Colormaps

X-FUNCTION: Colormap XCreateColormap ( Display* display, Window w, Visual* visual, int alloc )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 7 - Graphics Context Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XGCValues
    { function int }
    { plane_mask ulong }
    { foreground ulong }
    { background ulong }
    { line_width int }
    { line_style int }
    { cap_style int }
    { join_style int }
    { fill_style int }
    { fill_rule int }
    { arc_mode int }
    { tile Pixmap }
    { stipple Pixmap }
    { ts_x_origin int }
    { ts_y_origin int }
    { font Font }
    { subwindow_mode int }
    { graphics_exposures Bool }
    { clip_x_origin int }
    { clip_y_origin int }
    { clip_mask Pixmap }
    { dash_offset int }
    { dashes char } ;

X-FUNCTION: GC XCreateGC ( Display* display, Window d, ulong valuemask, XGCValues* values )
X-FUNCTION: int XChangeGC ( Display* display, GC gc, ulong valuemask, XGCValues* values )
X-FUNCTION: Status XGetGCValues ( Display* display, GC gc, ulong valuemask, XGCValues* values_return )
X-FUNCTION: Status XSetForeground ( Display* display, GC gc, ulong foreground )
X-FUNCTION: Status XSetBackground ( Display* display, GC gc, ulong background )
X-FUNCTION: Status XSetFunction ( Display* display, GC gc, int function )
X-FUNCTION: Status XSetSubwindowMode ( Display* display, GC gc, int subwindow_mode )

X-FUNCTION: GContext XGContextFromGC ( GC gc )

X-FUNCTION: Status XSetFont ( Display* display, GC gc, Font font )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 8 - Graphics Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

X-FUNCTION: Status XClearWindow ( Display* display, Window w )
X-FUNCTION: Status XDrawPoint ( Display* display, Drawable d, GC gc, int x, int y )
X-FUNCTION: Status XDrawLine ( Display* display, Drawable d, GC gc, int x1, int y1, int x2, int y2 )
X-FUNCTION: Status XDrawArc ( Display* display, Drawable d, GC gc, int x, int y, uint width, uint height, int angle1, int angle2 )
X-FUNCTION: Status XFillArc ( Display* display, Drawable d, GC gc, int x, int y, uint width, uint height, int angle1, int angle2 )

! 8.5 - Font Metrics

STRUCT: XCharStruct
    { lbearing short }
    { rbearing short }
    { width short }
    { ascent short }
    { descent short }
    { attributes ushort } ;

STRUCT: XFontStruct
    { ext_data XExtData* }
    { fid Font }
    { direction uint }
    { min_char_or_byte2 uint }
    { max_char_or_byte2 uint }
    { min_byte1 uint }
    { max_byte1 uint }
    { all_chars_exist Bool }
    { default_char uint }
    { n_properties int }
    { properties XFontProp* }
    { min_bounds XCharStruct }
    { max_bounds XCharStruct }
    { per_char XCharStruct* }
    { ascent int }
    { descent int } ;

X-FUNCTION: Font XLoadFont ( Display* display, c-string name )
X-FUNCTION: XFontStruct* XQueryFont ( Display* display, XID font_ID )
X-FUNCTION: XFontStruct* XLoadQueryFont ( Display* display, c-string name )

X-FUNCTION: int XTextWidth ( XFontStruct* font_struct, c-string string, int count )

! 8.6 - Drawing Text

X-FUNCTION: Status XDrawString (
        Display* display,
        Drawable d,
        GC gc,
        int x,
        int y,
        c-string string,
        int length )

! 8.7 - Transferring Images between Client and Server

CONSTANT: AllPlanes -1

STRUCT: XImage-funcs
    { create_image void* }
    { destroy_image void* }
    { get_pixel void* }
    { put_pixel void* }
    { sub_image void* }
    { add_pixel void* } ;

STRUCT: XImage
    { width int }
    { height int }
    { xoffset int }
    { format int }
    { data uchar* }
    { byte_order int }
    { bitmap_unit int }
    { bitmap_bit_order int }
    { bitmap_pad int }
    { depth int }
    { bytes_per_line int }
    { bits_per_pixel int }
    { red_mask ulong }
    { green_mask ulong }
    { blue_mask ulong }
    { obdata XPointer }
    { f XImage-funcs } ;

X-FUNCTION: XImage* XGetImage ( Display* display, Drawable d, int x, int y, uint width, uint height, ulong plane_mask, int format )
X-FUNCTION: int XDestroyImage ( XImage* ximage )

: XImage-size ( ximage -- size )
    [ height>> ] [ bytes_per_line>> ] bi * ;

: XImage-pixels ( ximage -- byte-array )
    [ data>> ] [ XImage-size ] bi memory>byte-array ;

!
! 9 - Window and Session Manager Functions
!

X-FUNCTION: Status XReparentWindow ( Display* display, Window w, Window parent, int x, int y )
X-FUNCTION: Status XAddToSaveSet ( Display* display, Window w )
X-FUNCTION: Status XRemoveFromSaveSet ( Display* display, Window w )
X-FUNCTION: Status XGrabServer ( Display* display )
X-FUNCTION: Status XUngrabServer ( Display* display )
X-FUNCTION: Status XKillClient ( Display* display, XID resource )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 10 - Events
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 10.3 - Event Masks

STRUCT: XAnyEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { window Window } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 10.5 Keyboard and Pointer Events

STRUCT: XButtonEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { window Window }
    { root Window }
    { subwindow Window }
    { time Time }
    { x int }
    { y int }
    { x_root int }
    { y_root int }
    { state uint }
    { button uint }
    { same_screen Bool } ;

TYPEDEF: XButtonEvent XButtonPressedEvent
TYPEDEF: XButtonEvent XButtonReleasedEvent


! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XKeyEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { window Window }
    { root Window }
    { subwindow Window }
    { time Time }
    { x int }
    { y int }
    { x_root int }
    { y_root int }
    { state uint }
    { keycode uint }
    { same_screen Bool } ;

TYPEDEF: XKeyEvent XKeyPressedEvent
TYPEDEF: XKeyEvent XKeyReleasedEvent

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XMotionEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { window Window }
    { root Window }
    { subwindow Window }
    { time Time }
    { x int }
    { y int }
    { x_root int }
    { y_root int }
    { state uint }
    { is_hint char }
    { same_screen Bool } ;

TYPEDEF: XMotionEvent XPointerMovedEvent

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XCrossingEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { window Window }
    { root Window }
    { subwindow Window }
    { time Time }
    { x int }
    { y int }
    { x_root int }
    { y_root int }
    { mode int }
    { detail int }
    { same_screen Bool }
    { focus Bool }
    { state uint } ;

TYPEDEF: XCrossingEvent XEnterWindowEvent
TYPEDEF: XCrossingEvent XLeaveWindowEvent

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XFocusChangeEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { window Window }
    { mode int }
    { detail int } ;

TYPEDEF: XFocusChangeEvent XFocusInEvent
TYPEDEF: XFocusChangeEvent XFocusOutEvent

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XExposeEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { window Window }
    { x int }
    { y int }
    { width int }
    { height int }
    { count int } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XGraphicsExposeEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { drawable Drawable }
    { x int }
    { y int }
    { width int }
    { height int }
    { count int }
    { major_code int }
    { minor_code int } ;

STRUCT: XNoExposeEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { drawable Drawable }
    { major_code int }
    { minor_code int } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XVisibilityEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { window Window }
    { state int } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XCreateWindowEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { parent Window }
    { window Window }
    { x int }
    { y int }
    { width int }
    { height int }
    { border_width int }
    { override_redirect Bool } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XDestroyWindowEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { event Window }
    { window Window } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XUnmapEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { event Window }
    { window Window }
    { from_configure Bool } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XMapEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { event Window }
    { window Window }
    { override_redirect Bool } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XMapRequestEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { parent Window }
    { window Window } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XReparentEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { event Window }
    { window Window }
    { parent Window }
    { x int }
    { y int }
    { override_redirect Bool } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XConfigureEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { event Window }
    { window Window }
    { x int }
    { y int }
    { width int }
    { height int }
    { border_width int }
    { above Window }
    { override_redirect Bool } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XGravityEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { event Window }
    { window Window }
    { x int }
    { y int } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XResizeRequestEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { window Window }
    { width int }
    { height int } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XConfigureRequestEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { parent Window }
    { window Window }
    { x int }
    { y int }
    { width int }
    { height int }
    { border_width int }
    { above Window }
    { detail int }
    { value_mask ulong } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XCirculateEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { event Window }
    { window Window }
    { place int } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XCirculateRequestEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { parent Window }
    { window Window }
    { place int } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XPropertyEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { window Window }
    { atom Atom }
    { time Time }
    { state int } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XSelectionClearEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { window Window }
    { selection Atom }
    { time Time } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XSelectionRequestEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { owner Window }
    { requestor Window }
    { selection Atom }
    { target Atom }
    { property Atom }
    { time Time } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XSelectionEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { requestor Window }
    { selection Atom }
    { target Atom }
    { property Atom }
    { time Time } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XColormapEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { window Window }
    { colormap Colormap }
    { new Bool }
    { state int } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XClientMessageEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { window Window }
    { message_type Atom }
    { format int }
    { data0 long }
    { data1 long }
    { data2 long }
    { data3 long }
    { data4 long } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XMappingEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { window Window }
    { request int }
    { first_keycode int }
    { count int } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XErrorEvent
    { type int }
    { display Display* }
    { resourceid XID }
    { serial ulong }
    { error_code uchar }
    { request_code uchar }
    { minor_code uchar } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

STRUCT: XKeymapEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { window Window }
    { pad int[8] } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Newer things, needed for XInput2 support. Not in the book.

! GenericEvent is the standard event for all newer extensions.
STRUCT: XGenericEvent
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { extension int }
    { evtype int } ;

STRUCT: XGenericEventCookie
    { type int }
    { serial ulong }
    { send_event Bool }
    { display Display* }
    { extension int }
    { evtype int }
    { cookie uint }
    { data void* } ;

X-FUNCTION: Bool XGetEventData ( Display* dpy, XGenericEventCookie* cookie )
X-FUNCTION: void XFreeEventData ( Display* dpy, XGenericEventCookie* cookie )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

UNION-STRUCT: XEvent
    { int int }
    { XAnyEvent XAnyEvent }
    { XKeyEvent XKeyEvent }
    { XButtonEvent XButtonEvent }
    { XMotionEvent XMotionEvent }
    { XCrossingEvent XCrossingEvent }
    { XFocusChangeEvent XFocusChangeEvent }
    { XExposeEvent XExposeEvent }
    { XGraphicsExposeEvent XGraphicsExposeEvent }
    { XNoExposeEvent XNoExposeEvent }
    { XVisibilityEvent XVisibilityEvent }
    { XCreateWindowEvent XCreateWindowEvent }
    { XDestroyWindowEvent XDestroyWindowEvent }
    { XUnmapEvent XUnmapEvent }
    { XMapEvent XMapEvent }
    { XMapRequestEvent XMapRequestEvent }
    { XReparentEvent XReparentEvent }
    { XConfigureEvent XConfigureEvent }
    { XGravityEvent XGravityEvent }
    { XResizeRequestEvent XResizeRequestEvent }
    { XConfigureRequestEvent XConfigureRequestEvent }
    { XCirculateEvent XCirculateEvent }
    { XCirculateRequestEvent XCirculateRequestEvent }
    { XPropertyEvent XPropertyEvent }
    { XSelectionClearEvent XSelectionClearEvent }
    { XSelectionRequestEvent XSelectionRequestEvent }
    { XSelectionEvent XSelectionEvent }
    { XColormapEvent XColormapEvent }
    { XClientMessageEvent XClientMessageEvent }
    { XMappingEvent XMappingEvent }
    { XErrorEvent XErrorEvent }
    { XKeymapEvent XKeymapEvent }
    { XGenericEvent XGenericEvent }
    { XGenericEventCookie XGenericEventCookie }
    { padding long[24] } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 11 - Event Handling Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

X-FUNCTION: Status XSelectInput ( Display* display, Window w, long event_mask )
X-FUNCTION: Status XFlush ( Display* display )
X-FUNCTION: Status XSync ( Display* display, int discard )
X-FUNCTION: Status XNextEvent ( Display* display, XEvent* event )
X-FUNCTION: Status XMaskEvent ( Display* display,
                                long event_mask,
                                XEvent* event_return )

! 11.3 - Event Queue Management

CONSTANT: QueuedAlready 0
CONSTANT: QueuedAfterReading 1
CONSTANT: QueuedAfterFlush 2

X-FUNCTION: int XEventsQueued ( Display* display, int mode )
X-FUNCTION: int XPending ( Display* display )

! 11.6 - Sending Events to Other Applications

X-FUNCTION: Status XSendEvent ( Display* display,
                                Window w,
                                Bool propagate,
                                long event_mask,
                                XEvent* event_send )

! 11.8 - Handling Protocol Errors

X-FUNCTION: int XSetErrorHandler ( void* handler )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 12 - Input Device Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
X-FUNCTION: int XGrabPointer (
    Display* display,
    Window grab_window,
    Bool owner_events,
    uint event_mask,
    int pointer_mode,
    int keyboard_mode,
    Window confine_to,
    Cursor cursor,
    Time time
)

X-FUNCTION: Status XUngrabPointer ( Display* display, Time time )
X-FUNCTION: Status XChangeActivePointerGrab ( Display* display, uint event_mask, Cursor cursor, Time time )
X-FUNCTION: Status XGrabKey (
    Display* display, int keycode, uint modifiers,
    Window grab_window, Bool owner_events,
    int pointer_mode, int keyboard_mode
)
X-FUNCTION: int XGrabKeyboard (
    Display* display, Window grab_window,
    Bool owner_events,
    int pointer_mode, int keyboard_mode, Time time
)
X-FUNCTION: Status XSetInputFocus ( Display* display, Window focus, int revert_to, Time time )

X-FUNCTION: Status XGetInputFocus (
    Display* display,
    Window* focus_return,
    int* revert_to_return
)

X-FUNCTION: Status XWarpPointer (
    Display* display,
    Window src_w, Window dest_w,
    int src_x, int src_y, uint src_width, uint src_height,
    int dest_x, int dest_y
)

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 14 - Inter-Client Communication Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 14.1 Client to Window Manager Communication

X-FUNCTION: Status XFetchName ( Display* display, Window w, c-string* window_name_return )
X-FUNCTION: Status XGetTransientForHint ( Display* display, Window w, Window* prop_window_return )

! 14.1.1.  Manipulating Top-Level Windows

X-FUNCTION: Status XIconifyWindow (
    Display* display,
    Window w,
    int screen_number
)

X-FUNCTION: Status XWithdrawWindow (
    Display* display,
    Window w,
    int screen_number
)

! 14.1.6 - Setting and Reading the WM_HINTS Property

! 17.1.7 - Setting and Reading the WM_NORMAL_HINTS Property

: USPosition   ( -- n ) 0 2^ ; inline
: USSize       ( -- n ) 1 2^ ; inline
: PPosition    ( -- n ) 2 2^ ; inline
: PSize        ( -- n ) 3 2^ ; inline
: PMinSize     ( -- n ) 4 2^ ; inline
: PMaxSize     ( -- n ) 5 2^ ; inline
: PResizeInc   ( -- n ) 6 2^ ; inline
: PAspect      ( -- n ) 7 2^ ; inline
: PBaseSize    ( -- n ) 8 2^ ; inline
: PWinGravity  ( -- n ) 9 2^ ; inline
CONSTANT: PAllHints
    flags{ PPosition PSize PMinSize PMaxSize PResizeInc PAspect }

STRUCT: XSizeHints
    { flags long }
    { x int }
    { y int }
    { width int }
    { height int }
    { min_width int }
    { min_height int }
    { max_width int }
    { max_height int }
    { width_inc int }
    { height_inc int }
    { min_aspect_x int }
    { min_aspect_y int }
    { max_aspect_x int }
    { max_aspect_y int }
    { base_width int }
    { base_height int }
    { win_gravity int } ;

! 14.1.10.  Setting and Reading the WM_PROTOCOLS Property

X-FUNCTION: Status XSetWMProtocols (
        Display* display, Window w, Atom* protocols, int count )

X-FUNCTION: Status XGetWMProtocols (
        Display* display,
        Window w,
        Atom** protocols_return,
        int* count_return )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 16 - Application Utility Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! 16.1 Keyboard Utility Functions

X-FUNCTION: KeySym XLookupKeysym ( XKeyEvent* key_event, int index )

X-FUNCTION: int XLookupString (
    XKeyEvent* event_struct,
    void* buffer_return,
    int bytes_buffer,
    KeySym* keysym_return,
    XComposeStatus* status_in_out
)

! 16.7 Determining the Appropriate Visual Type

CONSTANT: VisualNoMask                  0x0
CONSTANT: VisualIDMask                  0x1
CONSTANT: VisualScreenMask              0x2
CONSTANT: VisualDepthMask               0x4
CONSTANT: VisualClassMask               0x8
CONSTANT: VisualRedMaskMask             0x10
CONSTANT: VisualGreenMaskMask           0x20
CONSTANT: VisualBlueMaskMask            0x40
CONSTANT: VisualColormapSizeMask        0x80
CONSTANT: VisualBitsPerRGBMask          0x100
CONSTANT: VisualAllMask                 0x1FF

STRUCT: XVisualInfo
    { visual Visual* }
    { visualid VisualID }
    { screen int }
    { depth uint }
    { class int }
    { red_mask ulong }
    { green_mask ulong }
    { blue_mask ulong }
    { colormap_size int }
    { bits_per_rgb int } ;

! 16.9 Manipulating Bitmaps
X-FUNCTION: Pixmap XCreateBitmapFromData (
    Display* display,
    Drawable d,
    c-string data,
    uint width,
    uint height )

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Appendix C - Extensions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
X-FUNCTION: Bool XQueryExtension (
    Display* display,
    c-string name,
    int* major_opcode_return,
    int* first_event_return,
    int* first_error_return
)

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Appendix D - Compatibility Functions
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

X-FUNCTION: Status XSetStandardProperties (
    Display* display,
    Window w,
    c-string window_name,
    c-string icon_name,
    Pixmap icon_pixmap,
    c-string* argv,
    int argc,
    XSizeHints* hints
)

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

CONSTANT: XA_PRIMARY  1
CONSTANT: XA_SECONDARY 2
CONSTANT: XA_ARC 3
CONSTANT: XA_ATOM 4
CONSTANT: XA_BITMAP 5
CONSTANT: XA_CARDINAL 6
CONSTANT: XA_COLORMAP 7
CONSTANT: XA_CURSOR 8
CONSTANT: XA_CUT_BUFFER0 9
CONSTANT: XA_CUT_BUFFER1 10
CONSTANT: XA_CUT_BUFFER2 11
CONSTANT: XA_CUT_BUFFER3 12
CONSTANT: XA_CUT_BUFFER4 13
CONSTANT: XA_CUT_BUFFER5 14
CONSTANT: XA_CUT_BUFFER6 15
CONSTANT: XA_CUT_BUFFER7 16
CONSTANT: XA_DRAWABLE 17
CONSTANT: XA_FONT 18
CONSTANT: XA_INTEGER 19
CONSTANT: XA_PIXMAP 20
CONSTANT: XA_POINT 21
CONSTANT: XA_RECTANGLE 22
CONSTANT: XA_RESOURCE_MANAGER 23
CONSTANT: XA_RGB_COLOR_MAP 24
CONSTANT: XA_RGB_BEST_MAP 25
CONSTANT: XA_RGB_BLUE_MAP 26
CONSTANT: XA_RGB_DEFAULT_MAP 27
CONSTANT: XA_RGB_GRAY_MAP 28
CONSTANT: XA_RGB_GREEN_MAP 29
CONSTANT: XA_RGB_RED_MAP 30
CONSTANT: XA_STRING 31
CONSTANT: XA_VISUALID 32
CONSTANT: XA_WINDOW 33
CONSTANT: XA_WM_COMMAND 34
CONSTANT: XA_WM_HINTS 35
CONSTANT: XA_WM_CLIENT_MACHINE 36
CONSTANT: XA_WM_ICON_NAME 37
CONSTANT: XA_WM_ICON_SIZE 38
CONSTANT: XA_WM_NAME 39
CONSTANT: XA_WM_NORMAL_HINTS 40
CONSTANT: XA_WM_SIZE_HINTS 41
CONSTANT: XA_WM_ZOOM_HINTS 42
CONSTANT: XA_MIN_SPACE 43
CONSTANT: XA_NORM_SPACE 44
CONSTANT: XA_MAX_SPACE 45
CONSTANT: XA_END_SPACE 46
CONSTANT: XA_SUPERSCRIPT_X 47
CONSTANT: XA_SUPERSCRIPT_Y 48
CONSTANT: XA_SUBSCRIPT_X 49
CONSTANT: XA_SUBSCRIPT_Y 50
CONSTANT: XA_UNDERLINE_POSITION 51
CONSTANT: XA_UNDERLINE_THICKNESS 52
CONSTANT: XA_STRIKEOUT_ASCENT 53
CONSTANT: XA_STRIKEOUT_DESCENT 54
CONSTANT: XA_ITALIC_ANGLE 55
CONSTANT: XA_X_HEIGHT 56
CONSTANT: XA_QUAD_WIDTH 57
CONSTANT: XA_WEIGHT 58
CONSTANT: XA_POINT_SIZE 59
CONSTANT: XA_RESOLUTION 60
CONSTANT: XA_COPYRIGHT 61
CONSTANT: XA_NOTICE 62
CONSTANT: XA_FONT_NAME 63
CONSTANT: XA_FAMILY_NAME 64
CONSTANT: XA_FULL_NAME 65
CONSTANT: XA_CAP_HEIGHT 66
CONSTANT: XA_WM_CLASS 67
CONSTANT: XA_WM_TRANSIENT_FOR 68

CONSTANT: XA_LAST_PREDEFINED 68

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! The rest of the stuff is not from the book.
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

X-FUNCTION: void XFree ( void* data )
X-FUNCTION: int XStoreName ( Display* display, Window w, c-string window_name )
X-FUNCTION: void XSetWMNormalHints ( Display* display,
                                     Window w,
                                     XSizeHints* hints )
X-FUNCTION: int XBell ( Display* display, int percent )

! !!! INPUT METHODS

CONSTANT: XIMPreeditArea      0x0001
CONSTANT: XIMPreeditCallbacks 0x0002
CONSTANT: XIMPreeditPosition  0x0004
CONSTANT: XIMPreeditNothing   0x0008
CONSTANT: XIMPreeditNone      0x0010
CONSTANT: XIMStatusArea       0x0100
CONSTANT: XIMStatusCallbacks  0x0200
CONSTANT: XIMStatusNothing    0x0400
CONSTANT: XIMStatusNone       0x0800

CONSTANT: XNVaNestedList "XNVaNestedList"
CONSTANT: XNQueryInputStyle "queryInputStyle"
CONSTANT: XNClientWindow "clientWindow"
CONSTANT: XNInputStyle "inputStyle"
CONSTANT: XNFocusWindow "focusWindow"
CONSTANT: XNResourceName "resourceName"
CONSTANT: XNResourceClass "resourceClass"
CONSTANT: XNGeometryCallback "geometryCallback"
CONSTANT: XNDestroyCallback "destroyCallback"
CONSTANT: XNFilterEvents "filterEvents"
CONSTANT: XNPreeditStartCallback "preeditStartCallback"
CONSTANT: XNPreeditDoneCallback "preeditDoneCallback"
CONSTANT: XNPreeditDrawCallback "preeditDrawCallback"
CONSTANT: XNPreeditCaretCallback "preeditCaretCallback"
CONSTANT: XNPreeditStateNotifyCallback "preeditStateNotifyCallback"
CONSTANT: XNPreeditAttributes "preeditAttributes"
CONSTANT: XNStatusStartCallback "statusStartCallback"
CONSTANT: XNStatusDoneCallback "statusDoneCallback"
CONSTANT: XNStatusDrawCallback "statusDrawCallback"
CONSTANT: XNStatusAttributes "statusAttributes"
CONSTANT: XNArea "area"
CONSTANT: XNAreaNeeded "areaNeeded"
CONSTANT: XNSpotLocation "spotLocation"
CONSTANT: XNColormap "colorMap"
CONSTANT: XNStdColormap "stdColorMap"
CONSTANT: XNForeground "foreground"
CONSTANT: XNBackground "background"
CONSTANT: XNBackgroundPixmap "backgroundPixmap"
CONSTANT: XNFontSet "fontSet"
CONSTANT: XNLineSpace "lineSpace"
CONSTANT: XNCursor "cursor"

CONSTANT: XNQueryIMValuesList "queryIMValuesList"
CONSTANT: XNQueryICValuesList "queryICValuesList"
CONSTANT: XNVisiblePosition "visiblePosition"
CONSTANT: XNR6PreeditCallback "r6PreeditCallback"
CONSTANT: XNStringConversionCallback "stringConversionCallback"
CONSTANT: XNStringConversion "stringConversion"
CONSTANT: XNResetState "resetState"
CONSTANT: XNHotKey "hotKey"
CONSTANT: XNHotKeyState "hotKeyState"
CONSTANT: XNPreeditState "preeditState"
CONSTANT: XNSeparatorofNestedList "separatorofNestedList"

CONSTANT: XBufferOverflow -1
CONSTANT: XLookupNone      1
CONSTANT: XLookupChars     2
CONSTANT: XLookupKeySym    3
CONSTANT: XLookupBoth      4

X-FUNCTION: Bool XFilterEvent ( XEvent* event, Window w )

X-FUNCTION: XIM XOpenIM ( Display* dpy,
                          void* rdb,
                          c-string res_name,
                          c-string res_class )

X-FUNCTION: Status XCloseIM ( XIM im )

X-FUNCTION: XIC XCreateIC ( XIM im,
                            c-string key1, Window value1,
                            c-string key2, Window value2,
                            c-string key3, int value3,
                            c-string key4, c-string value4,
                            c-string key5, c-string value5,
                            int key6 )

X-FUNCTION: void XDestroyIC ( XIC ic )

X-FUNCTION: void XSetICFocus ( XIC ic )

X-FUNCTION: void XUnsetICFocus ( XIC ic )

X-FUNCTION: int XwcLookupString ( XIC ic,
                                  XKeyPressedEvent* event,
                                  ulong* buffer_return,
                                  int bytes_buffer,
                                  KeySym* keysym_return,
                                  Status* status_return )

X-FUNCTION: int Xutf8LookupString ( XIC ic,
                                    XKeyPressedEvent* event,
                                    c-string buffer_return,
                                    int bytes_buffer,
                                    KeySym* keysym_return,
                                    Status* status_return )

! !!! category of setlocale
CONSTANT: LC_ALL      0
CONSTANT: LC_COLLATE  1
CONSTANT: LC_CTYPE    2
CONSTANT: LC_MONETARY 3
CONSTANT: LC_NUMERIC  4
CONSTANT: LC_TIME     5

X-FUNCTION: c-string setlocale ( int category, c-string name )

X-FUNCTION: Bool XSupportsLocale ( )

X-FUNCTION: c-string XSetLocaleModifiers ( c-string modifier_list )

! uncategorized xlib bindings

X-FUNCTION: int XQueryKeymap ( Display* display, char[32] keys_return )
