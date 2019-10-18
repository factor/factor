! Copyright (C) 2005, 2006 Eduardo Cavazos and Alex Chapman
! See http://factorcode.org/license.txt for BSD license.

! Based on X.h

USING: alien alien.c-types alien.syntax math x11.xlib ;
IN: x11.constants

TYPEDEF: ulong Mask

TYPEDEF: uchar KeyCode

! Reserved Resource and Constant Definitions

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

! Key masks. Used as modifiers to GrabButton and GrabKey, results of QueryPointer,
!   state in various key-, mouse-, and button-related events.


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


! button masks.  Used in same manner as Key masks above. Not to be confused
! with button names below.


: AnyModifier          ( -- n ) 15 2^ ; ! used in GrabButton, GrabKey

! button names. Used as arguments to GrabButton and as detail in ButtonPress
! and ButtonRelease events.  Not to be confused with button masks above.
! Note that 0 is already defined above as "AnyButton".

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

CONSTANT: Success 0 ! everything's okay
CONSTANT: BadRequest 1 ! bad request code
CONSTANT: BadValue 2 ! int parameter out of range
CONSTANT: BadWindow 3 ! parameter not a Window
CONSTANT: BadPixmap 4 ! parameter not a Pixmap
CONSTANT: BadAtom 5 ! parameter not an Atom
CONSTANT: BadCursor 6 ! parameter not a Cursor
CONSTANT: BadFont 7 ! parameter not a Font
CONSTANT: BadMatch 8 ! parameter mismatch
CONSTANT: BadDrawable 9 ! parameter not a Pixmap or Window
CONSTANT: BadAccess 10 ! depending on context:
                       !         - key/button already grabbed
                       !         - attempt to free an illegal 
                       !           cmap entry 
                       !        - attempt to store into a read-only 
                       !           color map entry.
                       !        - attempt to modify the access control
                       !           list from other than the local host.
CONSTANT: BadAlloc 11 ! insufficient resources
CONSTANT: BadColor 12 ! no such colormap
CONSTANT: BadGC 13 ! parameter not a GC
CONSTANT: BadIDChoice 14 ! choice not in range or already used
CONSTANT: BadName 15 ! font or color name doesn't exist
CONSTANT: BadLength 16 ! Request length incorrect
CONSTANT: BadImplementation 17 ! server is defective

CONSTANT: FirstExtensionError 128
CONSTANT: LastExtensionError 255

! *****************************************************************
! * WINDOW DEFINITIONS 
! *****************************************************************

! Window classes used by CreateWindow
! Note that CopyFromParent is already defined as 0 above

CONSTANT: InputOutput 1
CONSTANT: InputOnly 2

! Used in CreateWindow for backing-store hint

CONSTANT: NotUseful 0
CONSTANT: WhenMapped 1
CONSTANT: Always 2

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

CONSTANT: CoordModeOrigin 0 ! relative to the origin
CONSTANT: CoordModePrevious 1 ! relative to previous point

! Polygon shapes

CONSTANT: Complex 0 ! paths may intersect
CONSTANT: Nonconvex 1 ! no paths intersect, but not convex
CONSTANT: Convex 2 ! wholly convex

! Arc modes for PolyFillArc

CONSTANT: ArcChord 0 ! join endpoints of arc
CONSTANT: ArcPieSlice 1 ! join endpoints to center of arc

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

CONSTANT: XYBitmap 0 ! depth 1, XYFormat
CONSTANT: XYPixmap 1 ! depth == drawable depth
CONSTANT: ZPixmap 2 ! depth == drawable depth

! *****************************************************************
! *  COLOR MAP STUFF 
! *****************************************************************

! For CreateColormap

CONSTANT: AllocNone 0 ! create map with no entries
CONSTANT: AllocAll 1 ! allocate entire map writeable


! Flags used in StoreNamedColor, StoreColors

: DoRed        ( -- n ) 0 2^ ;
: DoGreen      ( -- n ) 1 2^ ;
: DoBlue       ( -- n ) 2 2^ ;

! *****************************************************************
! * CURSOR STUFF
! *****************************************************************

! QueryBestSize Class

CONSTANT: CursorShape 0 ! largest size that can be displayed
CONSTANT: TileShape 1 ! size tiled fastest
CONSTANT: StippleShape 2 ! size stippled fastest

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

! *****************************************************************
! * EXTENDED WINDOW MANAGER HINTS
! *****************************************************************

CONSTANT: _NET_WM_STATE_REMOVE 0
CONSTANT: _NET_WM_STATE_ADD 1
CONSTANT: _NET_WM_STATE_TOGGLE 2
