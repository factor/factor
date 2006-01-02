! Based on X.h
IN: x11
USING: alien math ;

TYPEDEF: ulong XID
TYPEDEF: ulong Mask
TYPEDEF: ulong Atom
TYPEDEF: ulong VisualID
TYPEDEF: ulong Time
TYPEDEF: ulong VisualID
TYPEDEF: XID Window
TYPEDEF: XID Drawable
TYPEDEF: XID Font
TYPEDEF: XID Pixmap
TYPEDEF: XID Cursor
TYPEDEF: XID Colormap
TYPEDEF: XID GContext
TYPEDEF: XID KeySym
TYPEDEF: uchar KeyCode

! Reserved Resource and Constant Definitions
: None 0 ;
: ParentRelative 1 ;
: CopyFromParent 0 ;
: PointerWindow 0 ;
: InputFocus 1 ;
: PointerRoot 1 ;
: AnyPropertyType 0 ;
: AnyKey 0 ;
: AnyButton 0 ;
: AllTemporary 0 ;
: CurrentTime 0 ;
: NoSymbol 0 ;

! Key masks. Used as modifiers to GrabButton and GrabKey, results of QueryPointer,
!   state in various key-, mouse-, and button-related events.

: ShiftMask	1 0 shift ;
: LockMask	1 1 shift ;
: ControlMask	1 2 shift ;
: Mod1Mask	1 3 shift ;
: Mod2Mask	1 4 shift ;
: Mod3Mask	1 5 shift ;
: Mod4Mask	1 6 shift ;
: Mod5Mask	1 7 shift ;

! modifier names.  Used to build a SetModifierMapping request or
! to read a GetModifierMapping request.  These correspond to the
! masks defined above.
: ShiftMapIndex		0 ;
: LockMapIndex		1 ;
: ControlMapIndex	2 ;
: Mod1MapIndex		3 ;
: Mod2MapIndex		4 ;
: Mod3MapIndex		5 ;
: Mod4MapIndex		6 ;
: Mod5MapIndex		7 ;


! button masks.  Used in same manner as Key masks above. Not to be confused
! with button names below.

: Button1Mask		1 8  shift ;
: Button2Mask		1 9  shift ;
: Button3Mask		1 10 shift ;
: Button4Mask		1 11 shift ;
: Button5Mask		1 12 shift ;

: AnyModifier		1 15 shift ; ! used in GrabButton, GrabKey

! button names. Used as arguments to GrabButton and as detail in ButtonPress
! and ButtonRelease events.  Not to be confused with button masks above.
! Note that 0 is already defined above as "AnyButton".

: Button1	1 ;
: Button2	2 ;
: Button3	3 ;
: Button4	4 ;
: Button5	5 ;

! Notify modes

: NotifyNormal		0 ;
: NotifyGrab		1 ;
: NotifyUngrab		2 ;
: NotifyWhileGrabbed	3 ;

: NotifyHint		1 ; ! for MotionNotify events
		       
! Notify detail

: NotifyAncestor	 0 ;
: NotifyVirtual		 1 ;
: NotifyInferior	 2 ;
: NotifyNonlinear	 3 ;
: NotifyNonlinearVirtual 4 ;
: NotifyPointer		 5 ;
: NotifyPointerRoot	 6 ;
: NotifyDetailNone	 7 ;

! Visibility notify

: VisibilityUnobscured		0 ;
: VisibilityPartiallyObscured	1 ;
: VisibilityFullyObscured	2 ;

! Circulation request

: PlaceOnTop		0 ;
: PlaceOnBottom		1 ;

! protocol families

: FamilyInternet	0 ;	( IPv4 )
: FamilyDECnet		1 ;
: FamilyChaos		2 ;
: FamilyInternet6	6 ;	( IPv6 )

! authentication families not tied to a specific protocol
: FamilyServerInterpreted 5 ;

! Property notification

: PropertyNewValue	0 ;
: PropertyDelete	1 ;

! Color Map notification

: ColormapUninstalled	0 ;
: ColormapInstalled	1 ;

! GrabPointer, GrabButton, GrabKeyboard, GrabKey Modes

: GrabModeSync		0 ;
: GrabModeAsync		1 ;

! GrabPointer, GrabKeyboard reply status

: GrabSuccess		0 ;
: AlreadyGrabbed	1 ;
: GrabInvalidTime	2 ;
: GrabNotViewable	3 ;
: GrabFrozen		4 ;

! AllowEvents modes

: AsyncPointer		0 ;
: SyncPointer		1 ;
: ReplayPointer		2 ;
: AsyncKeyboard		3 ;
: SyncKeyboard		4 ;
: ReplayKeyboard	5 ;
: AsyncBoth		6 ;
: SyncBoth		7 ;

! Used in SetInputFocus, GetInputFocus

: RevertToNone		None ;
: RevertToPointerRoot	PointerRoot ;
: RevertToParent	2 ;

! *****************************************************************
! * ERROR CODES 
! *****************************************************************

: Success	   0 ; ! everything's okay
: BadRequest	   1 ; ! bad request code
: BadValue	   2 ; ! int parameter out of range
: BadWindow	   3 ; ! parameter not a Window
: BadPixmap	   4 ; ! parameter not a Pixmap
: BadAtom	   5 ; ! parameter not an Atom
: BadCursor	   6 ; ! parameter not a Cursor
: BadFont	   7 ; ! parameter not a Font
: BadMatch	   8 ; ! parameter mismatch
: BadDrawable	   9 ; ! parameter not a Pixmap or Window
: BadAccess	  10 ; ! depending on context:
		       !	 - key/button already grabbed
		       !	 - attempt to free an illegal 
		       !	   cmap entry 
		       !	- attempt to store into a read-only 
		       !	   color map entry.
 		       !	- attempt to modify the access control
		       !	   list from other than the local host.
: BadAlloc	    11 ; ! insufficient resources
: BadColor	    12 ; ! no such colormap
: BadGC		    13 ; ! parameter not a GC
: BadIDChoice	    14 ; ! choice not in range or already used
: BadName           15 ; ! font or color name doesn't exist
: BadLength	    16 ; ! Request length incorrect
: BadImplementation 17 ; ! server is defective

: FirstExtensionError	128 ;
: LastExtensionError	255 ;

! *****************************************************************
! * WINDOW DEFINITIONS 
! *****************************************************************

! Window classes used by CreateWindow
! Note that CopyFromParent is already defined as 0 above

: InputOutput		1 ;
: InputOnly		2 ;

! Used in CreateWindow for backing-store hint

: NotUseful               0 ;
: WhenMapped              1 ;
: Always                  2 ;

! Used in ChangeSaveSet

: SetModeInsert           0 ;
: SetModeDelete           1 ;

! Used in ChangeCloseDownMode

: DestroyAll              0 ;
: RetainPermanent         1 ;
: RetainTemporary         2 ;

! Window stacking method (in configureWindow)

: Above                   0 ;
: Below                   1 ;
: TopIf                   2 ;
: BottomIf                3 ;
: Opposite                4 ;

! Circulation direction

: RaiseLowest             0 ;
: LowerHighest            1 ;

! Property modes

: PropModeReplace         0 ;
: PropModePrepend         1 ;
: PropModeAppend          2 ;

! *****************************************************************
! * GRAPHICS DEFINITIONS
! *****************************************************************

! LineStyle

: LineSolid		0 ;
: LineOnOffDash		1 ;
: LineDoubleDash	2 ;

! capStyle

: CapNotLast		0 ;
: CapButt		1 ;
: CapRound		2 ;
: CapProjecting		3 ;

! joinStyle

: JoinMiter		0 ;
: JoinRound		1 ;
: JoinBevel		2 ;

! fillStyle

: FillSolid		0 ;
: FillTiled		1 ;
: FillStippled		2 ;
: FillOpaqueStippled	3 ;

! fillRule

: EvenOddRule		0 ;
: WindingRule		1 ;

! subwindow mode

: ClipByChildren	0 ;
: IncludeInferiors	1 ;

! SetClipRectangles ordering

: Unsorted		0 ;
: YSorted		1 ;
: YXSorted		2 ;
: YXBanded		3 ;

! CoordinateMode for drawing routines

: CoordModeOrigin   0 ; ! relative to the origin
: CoordModePrevious 1 ; ! relative to previous point

! Polygon shapes

: Complex	0 ; ! paths may intersect
: Nonconvex	1 ; ! no paths intersect, but not convex
: Convex	2 ; ! wholly convex

! Arc modes for PolyFillArc

: ArcChord    0 ; ! join endpoints of arc
: ArcPieSlice 1 ; ! join endpoints to center of arc

! *****************************************************************
! * FONTS 
! *****************************************************************

! used in QueryFont -- draw direction

: FontLeftToRight		0 ;
: FontRightToLeft		1 ;

: FontChange		255 ;

! *****************************************************************
! *  IMAGING 
! *****************************************************************

! ImageFormat -- PutImage, GetImage

: XYBitmap		0 ; ! depth 1, XYFormat
: XYPixmap		1 ; ! depth == drawable depth
: ZPixmap		2 ; ! depth == drawable depth

! *****************************************************************
! *  COLOR MAP STUFF 
! *****************************************************************

! For CreateColormap

: AllocNone		0 ; ! create map with no entries
: AllocAll		1 ; ! allocate entire map writeable


! Flags used in StoreNamedColor, StoreColors

: DoRed		1 0 shift ;
: DoGreen	1 1 shift ;
: DoBlue	1 2 shift ;

! *****************************************************************
! * CURSOR STUFF
! *****************************************************************

! QueryBestSize Class

: CursorShape		0 ; ! largest size that can be displayed
: TileShape		1 ; ! size tiled fastest
: StippleShape		2 ; ! size stippled fastest

! ***************************************************************** 
! * KEYBOARD/POINTER STUFF
! *****************************************************************

: AutoRepeatModeOff	0 ;
: AutoRepeatModeOn	1 ;
: AutoRepeatModeDefault	2 ;

: LedModeOff		0 ;
: LedModeOn		1 ;

! masks for ChangeKeyboardControl

: KBKeyClickPercent	1 0 shift ;
: KBBellPercent		1 1 shift ;
: KBBellPitch		1 2 shift ;
: KBBellDuration	1 3 shift ;
: KBLed			1 4 shift ;
: KBLedMode		1 5 shift ;
: KBKey			1 6 shift ;
: KBAutoRepeatMode	1 7 shift ;

: MappingSuccess     	0 ;
: MappingBusy        	1 ;
: MappingFailed		2 ;

: MappingModifier		0 ;
: MappingKeyboard		1 ;
: MappingPointer		2 ;

! *****************************************************************
! * SCREEN SAVER STUFF 
! *****************************************************************

: DontPreferBlanking	0 ;
: PreferBlanking	1 ;
: DefaultBlanking	2 ;

: DisableScreenSaver	0 ;
: DisableScreenInterval	0 ;

: DontAllowExposures	0 ;
: AllowExposures	1 ;
: DefaultExposures	2 ;

! for ForceScreenSaver

: ScreenSaverReset 0 ;
: ScreenSaverActive 1 ;

! *****************************************************************
! * HOSTS AND CONNECTIONS
! *****************************************************************

! for ChangeHosts

: HostInsert		0 ;
: HostDelete		1 ;

! for ChangeAccessControl

: EnableAccess		1 ;
: DisableAccess		0 ;

! Display classes  used in opening the connection 
! Note that the statically allocated ones are even numbered and the
! dynamically changeable ones are odd numbered

: StaticGray		0 ;
: GrayScale		1 ;
: StaticColor		2 ;
: PseudoColor		3 ;
: TrueColor		4 ;
: DirectColor		5 ;


! Byte order  used in imageByteOrder and bitmapBitOrder

: LSBFirst		0 ;
: MSBFirst		1 ;

