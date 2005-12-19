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

! Event Definitions
: NoEventMask			0 ;
: KeyPressMask			1 0  shift ;
: KeyReleaseMask		1 1  shift ;
: ButtonPressMask		1 2  shift ;
: ButtonReleaseMask		1 3  shift ;
: EnterWindowMask		1 4  shift ;
: LeaveWindowMask		1 5  shift ;
: PointerMotionMask		1 6  shift ;
: PointerMotionHintMask		1 7  shift ;
: Button1MotionMask		1 8  shift ;
: Button2MotionMask		1 9  shift ;
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

! Event names.  Used in "type" field in XEvent structures.  Not to be
! confused with event masks above.  They start from 2 because 0 and 1
! are reserved in the protocol for errors and replies.
: KeyPress	   2 ;
: KeyRelease	   3 ;
: ButtonPress	   4 ;
: ButtonRelease	   5 ;
: MotionNotify	   6 ;
: EnterNotify	   7 ;
: LeaveNotify	   8 ;
: FocusIn	   9 ;
: FocusOut	   10 ;
: KeymapNotify	   11 ;
: Expose	   12 ;
: GraphicsExpose   13 ;
: NoExpose	   14 ;
: VisibilityNotify 15 ;
: CreateNotify	   16 ;
: DestroyNotify	   17 ;
: UnmapNotify	   18 ;
: MapNotify	   19 ;
: MapRequest	   20 ;
: ReparentNotify   21 ;
: ConfigureNotify  22 ;
: ConfigureRequest 23 ;
: GravityNotify	   24 ;
: ResizeRequest	   25 ;
: CirculateNotify  26 ;
: CirculateRequest 27 ;
: PropertyNotify   28 ;
: SelectionClear   29 ;
: SelectionRequest 30 ;
: SelectionNotify  31 ;
: ColormapNotify   32 ;
: ClientMessage	   33 ;
: MappingNotify	   34 ;
: LASTEvent	   35 ;	! must be bigger than any event #

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

! Window attributes for CreateWindow and ChangeWindowAttributes

: CWBackPixmap		1 0 shift ;
: CWBackPixel		1 1 shift ;
: CWBorderPixmap	1 2 shift ;
: CWBorderPixel         1 3 shift ;
: CWBitGravity		1 4 shift ;
: CWWinGravity		1 5 shift ;
: CWBackingStore        1 6 shift ;
: CWBackingPlanes       1 7 shift ;
: CWBackingPixel        1 8 shift ;
: CWOverrideRedirect	1 9 shift ;
: CWSaveUnder		1 10 shift ;
: CWEventMask		1 11 shift ;
: CWDontPropagate       1 12 shift ;
: CWColormap		1 13 shift ;
: CWCursor	        1 14 shift ;

! ConfigureWindow structure

: CWX			1 0 shift ;
: CWY			1 1 shift ;
: CWWidth		1 2 shift ;
: CWHeight		1 3 shift ;
: CWBorderWidth		1 4 shift ;
: CWSibling		1 5 shift ;
: CWStackMode		1 6 shift ;


! Bit Gravity

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

! Window gravity + bit gravity above

: UnmapGravity		0 ;

! Used in CreateWindow for backing-store hint

: NotUseful               0 ;
: WhenMapped              1 ;
: Always                  2 ;

! Used in GetWindowAttributes reply

: IsUnmapped		0 ;
: IsUnviewable		1 ;
: IsViewable		2 ;

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

! graphics functions, as in GC.alu

: GXclear		HEX: 0 ; ! 0
: GXand			HEX: 1 ; ! src AND dst
: GXandReverse		HEX: 2 ; ! src AND NOT dst
: GXcopy		HEX: 3 ; ! src
: GXandInverted		HEX: 4 ; ! NOT src AND dst
: GXnoop		HEX: 5 ; ! dst
: GXxor			HEX: 6 ; ! src XOR dst
: GXor			HEX: 7 ; ! src OR dst
: GXnor			HEX: 8 ; ! NOT src AND NOT dst
: GXequiv		HEX: 9 ; ! NOT src XOR dst
: GXinvert		HEX: a ; ! NOT dst
: GXorReverse		HEX: b ; ! src OR NOT dst
: GXcopyInverted	HEX: c ; ! NOT src
: GXorInverted		HEX: d ; ! NOT src OR dst
: GXnand		HEX: e ; ! NOT src OR NOT dst
: GXset			HEX: f ; ! 1

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

! GC components: masks used in CreateGC, CopyGC, ChangeGC, OR'ed into
! GC.stateChanges

: GCFunction          1 0 shift ;
: GCPlaneMask         1 1 shift ;
: GCForeground        1 2 shift ;
: GCBackground        1 3 shift ;
: GCLineWidth         1 4 shift ;
: GCLineStyle         1 5 shift ;
: GCCapStyle          1 6 shift ;
: GCJoinStyle	      1 7 shift ;
: GCFillStyle	      1 8 shift ;
: GCFillRule	      1 9 shift  ;
: GCTile	      1 10 shift ;
: GCStipple	      1 11 shift ;
: GCTileStipXOrigin   1 12 shift ;
: GCTileStipYOrigin   1 13 shift ;
: GCFont 	      1 14 shift ;
: GCSubwindowMode     1 15 shift ;
: GCGraphicsExposures 1 16 shift ;
: GCClipXOrigin	      1 17 shift ;
: GCClipYOrigin	      1 18 shift ;
: GCClipMask	      1 19 shift ;
: GCDashOffset	      1 20 shift ;
: GCDashList	      1 21 shift ;
: GCArcMode	      1 22 shift ;
: GCLastBit	      22 ;

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

