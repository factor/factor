! Copyright (C) 2010 Niklas Waern.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax classes.struct
locals math sequences x11.X x11.syntax x11.xlib ;
IN: x11.xinput2.ffi

<< "xinput2" "libXi.so" cdecl add-library >>

LIBRARY: xinput2


! *********
! * XI2.h *
! *********
<PRIVATE
: mask-index   ( event -- n ) -3 shift ;
: bitmask ( event -- n ) 7 bitand 2^ ;
PRIVATE>

:: XISetMask ( mask event -- )
    event mask-index :> index
    event bitmask index mask nth bitor
    index mask set-nth ; inline

:: XIClearMask ( mask event -- )
    event mask-index :> index
    event bitmask bitnot index mask nth bitand
    index mask set-nth ; inline

:: XIMaskIsSet ( mask event -- n )
    event mask-index :> index
    event bitmask index mask nth bitand ;

: XIMaskLen ( event -- n ) 7 + -3 shift ;


! *************
! * XInput2.h *
! *************
STRUCT: XIAddMasterInfo
    { type      int }
    { name      c-string }
    { send_core Bool }
    { enable    Bool } ;

STRUCT: XIRemoveMasterInfo
    { type            int }
    { deviceid        int }
    { return_mode     int }
    { return_pointer  int }
    { return_keyboard int } ;

STRUCT: XIAttachSlaveInfo
    { type       int }
    { deviceid   int }
    { new_master int } ;

STRUCT: XIDetachSlaveInfo
    { type     int }
    { deviceid int } ;

UNION-STRUCT: XIAnyHierarchyChangeInfo
    { type   int }
    { add    XIAddMasterInfo }
    { remove XIRemoveMasterInfo }
    { attach XIAttachSlaveInfo }
    { detach XIDetachSlaveInfo } ;

STRUCT: XIModifierState
    { base      int }
    { latched   int }
    { locked    int }
    { effective int } ;

TYPEDEF: XIModifierState XIGroupState

STRUCT: XIButtonState
    { mask_len int }
    { mask     uchar* } ;

STRUCT: XIValuatorState
    { mask_len int }
    { mask     uchar* }
    { values   double* } ;

STRUCT: XIEventMask
    { deviceid int }
    { mask_len int }
    { mask     uchar* } ;

STRUCT: XIAnyClassInfo
    { type     int }
    { sourceid int } ;

STRUCT: XIButtonClassInfo
    { type        int }
    { sourceid    int }
    { num_buttons int }
    { labels      Atom* }
    { state       XIButtonState } ;

STRUCT: XIKeyClassInfo
    { type         int }
    { sourceid     int }
    { num_keycodes int }
    { keycodes     int* } ;

STRUCT: XIValuatorClassInfo
    { type       int }
    { sourceid   int }
    { number     int }
    { label      Atom }
    { min        double }
    { max        double }
    { value      double }
    { resolution int }
    { mode       int } ;

STRUCT: XIDeviceInfo
    { deviceid    int }
    { name        c-string }
    { use         int }
    { attachment  int }
    { enabled     Bool }
    { num_classes int }
    { classes     XIAnyClassInfo** } ;

STRUCT: XIGrabModifiers
    { modifiers int }
    { status    int } ;


! Generic XI2 event. All XI2 events have the same header.
STRUCT: XIEvent
    { type       int }
    { serial     ulong }
    { send_event Bool }
    { display    Display* }
    { extension  int }
    { evtype     int }
    { time       Time } ;

STRUCT: XIHierarchyInfo
    { deviceid   int }
    { attachment int }
    { use        int }
    { enabled    Bool }
    { flags      int } ;

! Notifies the client that the device hierarcy has been changed
! The client is expected to re-query the server for the device
! hierarchy.
STRUCT: XIHierarchyEvent
    { type       int }
    { serial     ulong }
    { send_event Bool }
    { display    Display }
    { extension  int }
    { evtype     int }
    { time       Time }
    { flags      int }
    { num_info   int }
    { info       XIHierarchyInfo* } ;

! Notifies the client that the classes have been changed.
! This happens when the slave device that sends through the
! master changes.
STRUCT: XIDeviceChangedEvent
    { type        int }
    { serial      ulong }
    { send_event  Bool }
    { display     Display* }
    { extension   int }
    { evtype      int }
    { time        Time }
    { deviceid    int }
    { sourceid    int }
    { reason      int }
    { num_classes int }
    { classes     XIAnyClassInfo** } ;

STRUCT: XIDeviceEvent
    { type       int }
    { serial     ulong }
    { send_event Bool }
    { display    Display* }
    { extension  int }
    { evtype     int }
    { time       Time }
    { deviceid   int }
    { sourceid   int }
    { detail     int }
    { root       Window }
    { event      Window }
    { child      Window }
    { root_x     double }
    { root_y     double }
    { event_x    double }
    { event_y    double }
    { flags      int }
    { buttons    XIButtonState }
    { valuators  XIValuatorState }
    { mods       XIModifierState }
    { group      XIGroupState } ;

STRUCT: XIRawEvent
    { type       int }
    { serial     ulong }
    { send_event Bool }
    { display    Display* }
    { extension  int }
    { evtype     int }
    { time       Time }
    { deviceid   int }
    { sourceid   int }
    { detail     int }
    { flags      int }
    { valuators  XIValuatorState }
    { raw_values double* } ;

STRUCT: XIEnterEvent
    { type        int }
    { serial      ulong }
    { send_event  Bool }
    { display     Display* }
    { extension   int }
    { evtype      int }
    { time        Time }
    { deviceid    int }
    { sourceid    int }
    { detail      int }
    { root        Window }
    { event       Window }
    { child       Window }
    { root_x      double }
    { root_y      double }
    { event_x     double }
    { event_y     double }
    { mode        int }
    { focus       Bool }
    { same_screen Bool }
    { buttons     XIButtonState }
    { mods        XIModifierState }
    { group       XIGroupState } ;

TYPEDEF: XIEnterEvent XILeaveEvent
TYPEDEF: XIEnterEvent XIFocusInEvent
TYPEDEF: XIEnterEvent XIFocusOutEvent

STRUCT: XIPropertyEvent
    { type       int }
    { serial     ulong }
    { send_event Bool }
    { display    Display* }
    { extension  int }
    { evtype     int }
    { time       Time }
    { deviceid   int }
    { property   Atom }
    { what       int } ;



X-FUNCTION: Bool XIQueryPointer (
    Display*         display,
    int              deviceid,
    Window           win,
    Window*          root,
    Window*          child,
    double*          root_x,
    double*          root_y,
    double*          win_x,
    double*          win_y,
    XIButtonState*   buttons,
    XIModifierState* mods,
    XIGroupState*    group )

X-FUNCTION: Bool XIWarpPointer (
    Display* display,
    int      deviceid,
    Window   src_win,
    Window   dst_win,
    double   src_x,
    double   src_y,
    uint     src_width,
    uint     src_height,
    double   dst_x,
    double   dst_y )

X-FUNCTION: Status XIDefineCursor (
    Display* display,
    int      deviceid,
    Window   win,
    Cursor   cursor )

X-FUNCTION: Status XIUndefineCursor (
    Display* display,
    int      deviceid,
    Window   win )

X-FUNCTION: Status XIChangeHierarchy (
    Display*                  display,
    XIAnyHierarchyChangeInfo* changes,
    int                       num_changes )

X-FUNCTION: Status XISetClientPointer (
    Display* dpy,
    Window   win,
    int      deviceid )

X-FUNCTION: Bool XIGetClientPointer (
    Display* dpy,
    Window   win,
    int*     deviceid )

X-FUNCTION: int XISelectEvents (
    Display*     dpy,
    Window       win,
    XIEventMask* masks,
    int          num_masks )

X-FUNCTION: XIEventMask* XIGetSelectedEvents (
    Display* dpy,
    Window   win,
    int*     num_masks_return )

X-FUNCTION: Status XIQueryVersion (
    Display* display,
    int*     major_version_inout,
    int*     minor_version_inout )

X-FUNCTION: XIDeviceInfo* XIQueryDevice (
    Display* dpy,
    int      deviceid,
    int*     ndevices_return )

X-FUNCTION: Status XISetFocus (
    Display* dpy,
    int      deviceid,
    Window   focus,
    Time     time )

X-FUNCTION: Status XIGetFocus (
    Display* dpy,
    int      deviceid,
    Window*  focus_return )

X-FUNCTION: Status XIGrabDevice (
    Display*     dpy,
    int          deviceid,
    Window       grab_window,
    Time         time,
    Cursor       cursor,
    int          grab_mode,
    int          paired_device_mode,
    Bool         owner_events,
    XIEventMask* mask )

X-FUNCTION: Status XIUngrabDevice (
    Display* dpy,
    int      deviceid,
    Time     time )

X-FUNCTION: Status XIAllowEvents (
    Display* display,
    int      deviceid,
    int      event_mode,
    Time     time )

X-FUNCTION: int XIGrabButton (
    Display*         display,
    int              deviceid,
    int              button,
    Window           grab_window,
    Cursor           cursor,
    int              grab_mode,
    int              paired_device_mode,
    int              owner_events,
    XIEventMask*     mask,
    int              num_modifiers,
    XIGrabModifiers* modifiers_inout )

X-FUNCTION: int XIGrabKeycode (
    Display*         display,
    int              deviceid,
    int              keycode,
    Window           grab_window,
    int              grab_mode,
    int              paired_device_mode,
    int              owner_events,
    XIEventMask*     mask,
    int              num_modifiers,
    XIGrabModifiers* modifiers_inout )

X-FUNCTION: int XIGrabEnter (
    Display*         display,
    int              deviceid,
    Window           grab_window,
    Cursor           cursor,
    int              grab_mode,
    int              paired_device_mode,
    int              owner_events,
    XIEventMask*     mask,
    int              num_modifiers,
    XIGrabModifiers* modifiers_inout )

X-FUNCTION: int XIGrabFocusIn (
    Display*         display,
    int              deviceid,
    Window           grab_window,
    int              grab_mode,
    int              paired_device_mode,
    int              owner_events,
    XIEventMask*     mask,
    int              num_modifiers,
    XIGrabModifiers* modifiers_inout )

X-FUNCTION: Status XIUngrabButton (
    Display*         display,
    int              deviceid,
    int              button,
    Window           grab_window,
    int              num_modifiers,
    XIGrabModifiers* modifiers )

X-FUNCTION: Status XIUngrabKeycode (
    Display*         display,
    int              deviceid,
    int              keycode,
    Window           grab_window,
    int              num_modifiers,
    XIGrabModifiers* modifiers )

X-FUNCTION: Status XIUngrabEnter (
    Display*         display,
    int              deviceid,
    Window           grab_window,
    int              num_modifiers,
    XIGrabModifiers* modifiers )

X-FUNCTION: Status XIUngrabFocusIn (
    Display*         display,
    int              deviceid,
    Window           grab_window,
    int              num_modifiers,
    XIGrabModifiers* modifiers )

X-FUNCTION: Atom* XIListProperties (
    Display* display,
    int      deviceid,
    int*     num_props_return )

X-FUNCTION: void XIChangeProperty (
    Display* display,
    int      deviceid,
    Atom     property,
    Atom     type,
    int      format,
    int      mode,
    uchar*   data,
    int      num_items )

X-FUNCTION: void XIDeleteProperty (
    Display* display,
    int      deviceid,
    Atom     property )

X-FUNCTION: Status XIGetProperty (
    Display* display,
    int      deviceid,
    Atom     property,
    long     offset,
    long     length,
    Bool     delete_property,
    Atom     type,
    Atom*    type_return,
    int*     format_return,
    ulong*   num_items_return,
    ulong*   bytes_after_return,
    uchar**  data )

X-FUNCTION: void XIFreeDeviceInfo ( XIDeviceInfo* info )
