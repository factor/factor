! Copyright (C) 2005, 2006 Eduardo Cavazos and Alex Chapman, 2016 Björn Lindqvist
! https://factorcode.org/license.txt for BSD license.

! Selected parts of /usr/include/X11/X.h
USING: alien.c-types alien.syntax math ;
IN: x11.X

! Resources
TYPEDEF: ulong XID
TYPEDEF: ulong Mask
TYPEDEF: ulong Atom
TYPEDEF: XID Window
TYPEDEF: XID Drawable
TYPEDEF: XID Font
TYPEDEF: XID Pixmap
TYPEDEF: XID Cursor
TYPEDEF: XID Colormap
TYPEDEF: XID GContext
TYPEDEF: XID KeySym

TYPEDEF: uchar KeyCode

! Reserved resource and constant definitions
CONSTANT: ParentRelative 1
CONSTANT: CopyFromParent 0
CONSTANT: PointerWindow 0
CONSTANT: InputFocus 1
CONSTANT: PointerRoot 1
CONSTANT: AnyPropertyType 0
CONSTANT: AnyKey 0
CONSTANT: AnyButton 0
CONSTANT: AllTemporary 0
CONSTANT: CurrentTime 0
CONSTANT: NoSymbol 0

CONSTANT: None 0

! Input Event Masks. Used as event-mask window attribute and as
! arguments to Grab requests. Not to be confused with event names.
: NoEventMask              ( -- n ) 0 ; inline
: KeyPressMask             ( -- n ) 0 2^ ; inline
: KeyReleaseMask           ( -- n ) 1 2^ ; inline
: ButtonPressMask          ( -- n ) 2 2^ ; inline
: ButtonReleaseMask        ( -- n ) 3 2^ ; inline
: EnterWindowMask          ( -- n ) 4 2^ ; inline
: LeaveWindowMask          ( -- n ) 5 2^ ; inline
: PointerMotionMask        ( -- n ) 6 2^ ; inline
: PointerMotionHintMask    ( -- n ) 7 2^ ; inline
: Button1MotionMask        ( -- n ) 8 2^ ; inline
: Button2MotionMask        ( -- n ) 9 2^ ; inline
: Button3MotionMask        ( -- n ) 10 2^ ; inline
: Button4MotionMask        ( -- n ) 11 2^ ; inline
: Button5MotionMask        ( -- n ) 12 2^ ; inline
: ButtonMotionMask         ( -- n ) 13 2^ ; inline
: KeymapStateMask          ( -- n ) 14 2^ ; inline
: ExposureMask             ( -- n ) 15 2^ ; inline
: VisibilityChangeMask     ( -- n ) 16 2^ ; inline
: StructureNotifyMask      ( -- n ) 17 2^ ; inline
: ResizeRedirectMask       ( -- n ) 18 2^ ; inline
: SubstructureNotifyMask   ( -- n ) 19 2^ ; inline
: SubstructureRedirectMask ( -- n ) 20 2^ ; inline
: FocusChangeMask          ( -- n ) 21 2^ ; inline
: PropertyChangeMask       ( -- n ) 22 2^ ; inline
: ColormapChangeMask       ( -- n ) 23 2^ ; inline
: OwnerGrabButtonMask      ( -- n ) 24 2^ ; inline

! Event names. Used in "type" field in XEvent structures. Not to be
! confused with event masks above. They start from 2 because 0 and 1
! are reserved in the protocol for errors and replies.
CONSTANT: KeyPress              2
CONSTANT: KeyRelease            3
CONSTANT: ButtonPress           4
CONSTANT: ButtonRelease         5
CONSTANT: MotionNotify          6
CONSTANT: EnterNotify           7
CONSTANT: LeaveNotify           8
CONSTANT: FocusIn               9
CONSTANT: FocusOut              10
CONSTANT: KeymapNotify          11
CONSTANT: Expose                12
CONSTANT: GraphicsExpose        13
CONSTANT: NoExpose              14
CONSTANT: VisibilityNotify      15
CONSTANT: CreateNotify          16
CONSTANT: DestroyNotify         17
CONSTANT: UnmapNotify           18
CONSTANT: MapNotify             19
CONSTANT: MapRequest            20
CONSTANT: ReparentNotify        21
CONSTANT: ConfigureNotify       22
CONSTANT: ConfigureRequest      23
CONSTANT: GravityNotify         24
CONSTANT: ResizeRequest         25
CONSTANT: CirculateNotify       26
CONSTANT: CirculateRequest      27
CONSTANT: PropertyNotify        28
CONSTANT: SelectionClear        29
CONSTANT: SelectionRequest      30
CONSTANT: SelectionNotify       31
CONSTANT: ColormapNotify        32
CONSTANT: ClientMessage         33
CONSTANT: MappingNotify         34
CONSTANT: GenericEvent          35
CONSTANT: LASTEvent             36

! Key masks. Used as modifiers to GrabButton and GrabKey, results of
! QueryPointer, state in various key-, mouse-, and button-related
! events.
: ShiftMask   ( -- n ) 1 0 shift ; inline
: LockMask    ( -- n ) 1 1 shift ; inline
: ControlMask ( -- n ) 1 2 shift ; inline
: Mod1Mask    ( -- n ) 1 3 shift ; inline
: Mod2Mask    ( -- n ) 1 4 shift ; inline
: Mod3Mask    ( -- n ) 1 5 shift ; inline
: Mod4Mask    ( -- n ) 1 6 shift ; inline
: Mod5Mask    ( -- n ) 1 7 shift ; inline

! modifier names.  Used to build a SetModifierMapping request or
! to read a GetModifierMapping request.  These correspond to the
! masks defined above.
CONSTANT: ShiftMapIndex 0
CONSTANT: LockMapIndex 1
CONSTANT: ControlMapIndex 2
CONSTANT: Mod1MapIndex 3
CONSTANT: Mod2MapIndex 4
CONSTANT: Mod3MapIndex 5
CONSTANT: Mod4MapIndex 6
CONSTANT: Mod5MapIndex 7

! button masks. Used in same manner as Key masks above. Not to be
! confused with button names below.
: Button1Mask ( -- n ) 1 8  shift ; inline
: Button2Mask ( -- n ) 1 9  shift ; inline
: Button3Mask ( -- n ) 1 10 shift ; inline
: Button4Mask ( -- n ) 1 11 shift ; inline
: Button5Mask ( -- n ) 1 12 shift ; inline

: AnyModifier          ( -- n ) 15 2^ ; ! used in GrabButton, GrabKey

! button names. Used as arguments to GrabButton and as detail in
! ButtonPress and ButtonRelease events.  Not to be confused with
! button masks above. Note that 0 is already defined above as
! "AnyButton".  */
CONSTANT: Button1 1
CONSTANT: Button2 2
CONSTANT: Button3 3
CONSTANT: Button4 4
CONSTANT: Button5 5

! Notify modes

CONSTANT: NotifyNormal 0
CONSTANT: NotifyGrab 1
CONSTANT: NotifyUngrab 2
CONSTANT: NotifyWhileGrabbed 3

CONSTANT: NotifyHint 1 ! for MotionNotify events

! Notify detail

CONSTANT: NotifyAncestor 0
CONSTANT: NotifyVirtual 1
CONSTANT: NotifyInferior 2
CONSTANT: NotifyNonlinear 3
CONSTANT: NotifyNonlinearVirtual 4
CONSTANT: NotifyPointer 5
CONSTANT: NotifyPointerRoot 6
CONSTANT: NotifyDetailNone 7

! Visibility notify

CONSTANT: VisibilityUnobscured 0
CONSTANT: VisibilityPartiallyObscured 1
CONSTANT: VisibilityFullyObscured 2

! Circulation request

CONSTANT: PlaceOnTop 0
CONSTANT: PlaceOnBottom 1

! protocol families

CONSTANT: FamilyInternet 0     ! IPv4
CONSTANT: FamilyDECnet 1
CONSTANT: FamilyChaos 2
CONSTANT: FamilyInternet6 6     ! IPv6

! authentication families not tied to a specific protocol
CONSTANT: FamilyServerInterpreted 5

! Property notification

CONSTANT: PropertyNewValue 0
CONSTANT: PropertyDelete 1

! Color Map notification

CONSTANT: ColormapUninstalled 0
CONSTANT: ColormapInstalled 1

! GrabPointer, GrabButton, GrabKeyboard, GrabKey Modes

CONSTANT: GrabModeSync 0
CONSTANT: GrabModeAsync 1

! GrabPointer, GrabKeyboard reply status

CONSTANT: GrabSuccess 0
CONSTANT: AlreadyGrabbed 1
CONSTANT: GrabInvalidTime 2
CONSTANT: GrabNotViewable 3
CONSTANT: GrabFrozen 4

! AllowEvents modes

CONSTANT: AsyncPointer 0
CONSTANT: SyncPointer 1
CONSTANT: ReplayPointer 2
CONSTANT: AsyncKeyboard 3
CONSTANT: SyncKeyboard 4
CONSTANT: ReplayKeyboard 5
CONSTANT: AsyncBoth 6
CONSTANT: SyncBoth 7

! Used in SetInputFocus, GetInputFocus

: RevertToNone         ( -- n ) None ;
: RevertToPointerRoot  ( -- n ) PointerRoot ;
CONSTANT: RevertToParent 2

! *****************************************************************
! * ERROR CODES
! *****************************************************************

CONSTANT: Success 0         ! everything's okay
CONSTANT: BadRequest 1      ! bad request code
CONSTANT: BadValue 2        ! int parameter out of range
CONSTANT: BadWindow 3       ! parameter not a Window
CONSTANT: BadPixmap 4       ! parameter not a Pixmap
CONSTANT: BadAtom 5         ! parameter not an Atom
CONSTANT: BadCursor 6       ! parameter not a Cursor
CONSTANT: BadFont 7         ! parameter not a Font
CONSTANT: BadMatch 8        ! parameter mismatch
CONSTANT: BadDrawable 9     ! parameter not a Pixmap or Window
CONSTANT: BadAccess 10      ! depending on context:
                            !         - key/button already grabbed
                            !         - attempt to free an illegal
                            !           cmap entry
                            !        - attempt to store into a read-only
                            !           color map entry.
                            !        - attempt to modify the access control
                            !           list from other than the local host.
CONSTANT: BadAlloc 11       ! insufficient resources
CONSTANT: BadColor 12       ! no such colormap
CONSTANT: BadGC 13          ! parameter not a GC
CONSTANT: BadIDChoice 14    ! choice not in range or already used
CONSTANT: BadName 15        ! font or color name doesn't exist
CONSTANT: BadLength 16      ! Request length incorrect
CONSTANT: BadImplementation 17  ! server is defective

CONSTANT: FirstExtensionError 128
CONSTANT: LastExtensionError 255

! *****************************************************************
! * WINDOW DEFINITIONS
! *****************************************************************

! Window classes used by CreateWindow
! Note that CopyFromParent is already defined as 0 above

CONSTANT: InputOutput 1
CONSTANT: InputOnly 2

! ConfigureWindow structure
: CWX           ( -- n ) 0 2^ ; inline
: CWY           ( -- n ) 1 2^ ; inline
: CWWidth       ( -- n ) 2 2^ ; inline
: CWHeight      ( -- n ) 3 2^ ; inline
: CWBorderWidth ( -- n ) 4 2^ ; inline
: CWSibling     ( -- n ) 5 2^ ; inline
: CWStackMode   ( -- n ) 6 2^ ; inline

! Bit Gravity

CONSTANT: ForgetGravity         0
CONSTANT: NorthWestGravity      1
CONSTANT: NorthGravity          2
CONSTANT: NorthEastGravity      3
CONSTANT: WestGravity           4
CONSTANT: CenterGravity         5
CONSTANT: EastGravity           6
CONSTANT: SouthWestGravity      7
CONSTANT: SouthGravity          8
CONSTANT: SouthEastGravity      9
CONSTANT: StaticGravity         10

! Window gravity + bit gravity above

CONSTANT: UnmapGravity          0

! Used in CreateWindow for backing-store hint

CONSTANT: NotUseful 0
CONSTANT: WhenMapped 1
CONSTANT: Always 2

! Used in GetWindowAttributes reply
CONSTANT: IsUnmapped            0
CONSTANT: IsUnviewable          1
CONSTANT: IsViewable            2


! Used in ChangeSaveSet

CONSTANT: SetModeInsert 0
CONSTANT: SetModeDelete 1

! Used in ChangeCloseDownMode

CONSTANT: DestroyAll 0
CONSTANT: RetainPermanent 1
CONSTANT: RetainTemporary 2

! Window stacking method (in configureWindow)

CONSTANT: Above 0
CONSTANT: Below 1
CONSTANT: TopIf 2
CONSTANT: BottomIf 3
CONSTANT: Opposite 4

! Circulation direction

CONSTANT: RaiseLowest 0
CONSTANT: LowerHighest 1

! Property modes

CONSTANT: PropModeReplace 0
CONSTANT: PropModePrepend 1
CONSTANT: PropModeAppend 2

! *****************************************************************
! * GRAPHICS DEFINITIONS
! *****************************************************************

! graphics functions, as in GC.alu

CONSTANT: GXclear               0x0
CONSTANT: GXand                 0x1
CONSTANT: GXandReverse          0x2
CONSTANT: GXcopy                0x3
CONSTANT: GXandInverted         0x4
CONSTANT: GXnoop                0x5
CONSTANT: GXxor                 0x6
CONSTANT: GXor                  0x7
CONSTANT: GXnor                 0x8
CONSTANT: GXequiv               0x9
CONSTANT: GXinvert              0xa
CONSTANT: GXorReverse           0xb
CONSTANT: GXcopyInverted        0xc
CONSTANT: GXorInverted          0xd
CONSTANT: GXnand                0xe
CONSTANT: GXset                 0xf

! LineStyle

CONSTANT: LineSolid 0
CONSTANT: LineOnOffDash 1
CONSTANT: LineDoubleDash 2

! capStyle

CONSTANT: CapNotLast 0
CONSTANT: CapButt 1
CONSTANT: CapRound 2
CONSTANT: CapProjecting 3

! joinStyle

CONSTANT: JoinMiter 0
CONSTANT: JoinRound 1
CONSTANT: JoinBevel 2

! fillStyle

CONSTANT: FillSolid 0
CONSTANT: FillTiled 1
CONSTANT: FillStippled 2
CONSTANT: FillOpaqueStippled 3

! fillRule

CONSTANT: EvenOddRule 0
CONSTANT: WindingRule 1

! subwindow mode

CONSTANT: ClipByChildren 0
CONSTANT: IncludeInferiors 1

! SetClipRectangles ordering

CONSTANT: Unsorted 0
CONSTANT: YSorted 1
CONSTANT: YXSorted 2
CONSTANT: YXBanded 3

! CoordinateMode for drawing routines

CONSTANT: CoordModeOrigin 0     ! relative to the origin
CONSTANT: CoordModePrevious 1   ! relative to previous point

! Polygon shapes

CONSTANT: Complex 0 ! paths may intersect
CONSTANT: Nonconvex 1 ! no paths intersect, but not convex
CONSTANT: Convex 2 ! wholly convex

! Arc modes for PolyFillArc

CONSTANT: ArcChord 0 ! join endpoints of arc
CONSTANT: ArcPieSlice 1 ! join endpoints to center of arc

! GC components: masks used in CreateGC, CopyGC, ChangeGC, OR'ed into
! GC.stateChanges

: GCFunction          ( -- n ) 0 2^ ; inline
: GCPlaneMask         ( -- n ) 1 2^ ; inline
: GCForeground        ( -- n ) 2 2^ ; inline
: GCBackground        ( -- n ) 3 2^ ; inline
: GCLineWidth         ( -- n ) 4 2^ ; inline
: GCLineStyle         ( -- n ) 5 2^ ; inline
: GCCapStyle          ( -- n ) 6 2^ ; inline
: GCJoinStyle         ( -- n ) 7 2^ ; inline
: GCFillStyle         ( -- n ) 8 2^ ; inline
: GCFillRule          ( -- n ) 9 2^ ; inline
: GCTile              ( -- n ) 10 2^ ; inline
: GCStipple           ( -- n ) 11 2^ ; inline
: GCTileStipXOrigin   ( -- n ) 12 2^ ; inline
: GCTileStipYOrigin   ( -- n ) 13 2^ ; inline
: GCFont              ( -- n ) 14 2^ ; inline
: GCSubwindowMode     ( -- n ) 15 2^ ; inline
: GCGraphicsExposures ( -- n ) 16 2^ ; inline
: GCClipXOrigin       ( -- n ) 17 2^ ; inline
: GCClipYOrigin       ( -- n ) 18 2^ ; inline
: GCClipMask          ( -- n ) 19 2^ ; inline
: GCDashOffset        ( -- n ) 20 2^ ; inline
: GCDashList          ( -- n ) 21 2^ ; inline
: GCArcMode           ( -- n ) 22 2^ ; inline

! *****************************************************************
! * FONTS
! *****************************************************************

! used in QueryFont -- draw direction

CONSTANT: FontLeftToRight 0
CONSTANT: FontRightToLeft 1

CONSTANT: FontChange 255

! *****************************************************************
! *  IMAGING
! *****************************************************************

! ImageFormat -- PutImage, GetImage

CONSTANT: XYBitmap 0    ! depth 1, XYFormat
CONSTANT: XYPixmap 1    ! depth == drawable depth
CONSTANT: ZPixmap 2     ! depth == drawable depth

! *****************************************************************
! *  COLOR MAP STUFF
! *****************************************************************

! For CreateColormap

CONSTANT: AllocNone 0   ! create map with no entries
CONSTANT: AllocAll 1    ! allocate entire map writeable


! Flags used in StoreNamedColor, StoreColors

: DoRed        ( -- n ) 0 2^ ;
: DoGreen      ( -- n ) 1 2^ ;
: DoBlue       ( -- n ) 2 2^ ;

! *****************************************************************
! * CURSOR STUFF
! *****************************************************************

! QueryBestSize Class

CONSTANT: CursorShape 0     ! largest size that can be displayed
CONSTANT: TileShape 1       ! size tiled fastest
CONSTANT: StippleShape 2    ! size stippled fastest

! *****************************************************************
! * KEYBOARD/POINTER STUFF
! *****************************************************************

CONSTANT: AutoRepeatModeOff 0
CONSTANT: AutoRepeatModeOn 1
CONSTANT: AutoRepeatModeDefault 2

CONSTANT: LedModeOff 0
CONSTANT: LedModeOn 1

! masks for ChangeKeyboardControl

: KBKeyClickPercent    ( -- n ) 0 2^ ;
: KBBellPercent        ( -- n ) 1 2^ ;
: KBBellPitch          ( -- n ) 2 2^ ;
: KBBellDuration       ( -- n ) 3 2^ ;
: KBLed                ( -- n ) 4 2^ ;
: KBLedMode            ( -- n ) 5 2^ ;
: KBKey                ( -- n ) 6 2^ ;
: KBAutoRepeatMode     ( -- n ) 7 2^ ;

CONSTANT: MappingSuccess 0
CONSTANT: MappingBusy 1
CONSTANT: MappingFailed 2

CONSTANT: MappingModifier 0
CONSTANT: MappingKeyboard 1
CONSTANT: MappingPointer 2

! *****************************************************************
! * SCREEN SAVER STUFF
! *****************************************************************

CONSTANT: DontPreferBlanking 0
CONSTANT: PreferBlanking 1
CONSTANT: DefaultBlanking 2

CONSTANT: DisableScreenSaver 0
CONSTANT: DisableScreenInterval 0

CONSTANT: DontAllowExposures 0
CONSTANT: AllowExposures 1
CONSTANT: DefaultExposures 2

! for ForceScreenSaver

CONSTANT: ScreenSaverReset 0
CONSTANT: ScreenSaverActive 1

! *****************************************************************
! * HOSTS AND CONNECTIONS
! *****************************************************************

! for ChangeHosts

CONSTANT: HostInsert 0
CONSTANT: HostDelete 1

! for ChangeAccessControl

CONSTANT: EnableAccess 1
CONSTANT: DisableAccess 0

! Display classes  used in opening the connection
! Note that the statically allocated ones are even numbered and the
! dynamically changeable ones are odd numbered

CONSTANT: StaticGray 0
CONSTANT: GrayScale 1
CONSTANT: StaticColor 2
CONSTANT: PseudoColor 3
CONSTANT: TrueColor 4
CONSTANT: DirectColor 5

! Byte order  used in imageByteOrder and bitmapBitOrder

CONSTANT: LSBFirst 0
CONSTANT: MSBFirst 1
