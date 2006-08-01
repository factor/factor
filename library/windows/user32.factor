! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien parser namespaces kernel syntax words math io prettyprint ;
IN: win32-api




LIBRARY: user32
FUNCTION: HKL ActivateKeyboardLayout ( HKL hkl, UINT Flags ) ;

FUNCTION: BOOL AdjustWindowRect ( LPRECT lpRect, DWORD dwStyle, BOOL bMenu ) ;
FUNCTION: BOOL AdjustWindowRectEx ( LPRECT lpRect, DWORD dwStyle, BOOL bMenu, DWORD dwExStyle ) ;
! FUNCTION: AlignRects
! FUNCTION: AllowForegroundActivation
! FUNCTION: AllowSetForegroundWindow
! FUNCTION: AnimateWindow



FUNCTION: BOOL AnyPopup ( ) ;

! FUNCTION: AppendMenuA
! FUNCTION: AppendMenuW
! FUNCTION: ArrangeIconicWindows
! FUNCTION: AttachThreadInput
! FUNCTION: BeginDeferWindowPos


FUNCTION: HDC BeginPaint ( HWND hwnd, LPPAINTSTRUCT lpPaint ) ;

! FUNCTION: BlockInput
! FUNCTION: BringWindowToTop
! FUNCTION: BroadcastSystemMessage
! FUNCTION: BroadcastSystemMessageA
! FUNCTION: BroadcastSystemMessageExA
! FUNCTION: BroadcastSystemMessageExW
! FUNCTION: BroadcastSystemMessageW
! FUNCTION: BuildReasonArray
! FUNCTION: CalcMenuBar
! FUNCTION: CallMsgFilter
! FUNCTION: CallMsgFilterA
! FUNCTION: CallMsgFilterW
! FUNCTION: CallNextHookEx
! FUNCTION: CallWindowProcA
! FUNCTION: CallWindowProcW
! FUNCTION: CascadeChildWindows
! FUNCTION: CascadeWindows
! FUNCTION: ChangeClipboardChain
! FUNCTION: ChangeDisplaySettingsA
! FUNCTION: ChangeDisplaySettingsExA
! FUNCTION: ChangeDisplaySettingsExW
! FUNCTION: ChangeDisplaySettingsW
! FUNCTION: ChangeMenuA
! FUNCTION: ChangeMenuW
! FUNCTION: CharLowerA
! FUNCTION: CharLowerBuffA
! FUNCTION: CharLowerBuffW
! FUNCTION: CharLowerW
! FUNCTION: CharNextA
! FUNCTION: CharNextExA
! FUNCTION: CharNextW
! FUNCTION: CharPrevA
! FUNCTION: CharPrevExA
! FUNCTION: CharPrevW
! FUNCTION: CharToOemA
! FUNCTION: CharToOemBuffA
! FUNCTION: CharToOemBuffW
! FUNCTION: CharToOemW
! FUNCTION: CharUpperA
! FUNCTION: CharUpperBuffA
! FUNCTION: CharUpperBuffW
! FUNCTION: CharUpperW
! FUNCTION: CheckDlgButton
! FUNCTION: CheckMenuItem
! FUNCTION: CheckMenuRadioItem
! FUNCTION: CheckRadioButton
! FUNCTION: ChildWindowFromPoint
! FUNCTION: ChildWindowFromPointEx
! FUNCTION: ClientThreadSetup
! FUNCTION: ClientToScreen
! FUNCTION: CliImmSetHotKey
! FUNCTION: ClipCursor
FUNCTION: BOOL CloseClipboard ( ) ;
! FUNCTION: CloseDesktop
! FUNCTION: CloseWindow
! FUNCTION: CloseWindowStation
! FUNCTION: CopyAcceleratorTableA
! FUNCTION: CopyAcceleratorTableW
! FUNCTION: CopyIcon
! FUNCTION: CopyImage
! FUNCTION: CopyRect
! FUNCTION: CountClipboardFormats
! FUNCTION: CreateAcceleratorTableA
! FUNCTION: CreateAcceleratorTableW
! FUNCTION: CreateCaret
! FUNCTION: CreateCursor
! FUNCTION: CreateDesktopA
! FUNCTION: CreateDesktopW
! FUNCTION: CreateDialogIndirectParamA
! FUNCTION: CreateDialogIndirectParamAorW
! FUNCTION: CreateDialogIndirectParamW
! FUNCTION: CreateDialogParamA
! FUNCTION: CreateDialogParamW
! FUNCTION: CreateIcon
! FUNCTION: CreateIconFromResource
! FUNCTION: CreateIconFromResourceEx
! FUNCTION: CreateIconIndirect
! FUNCTION: CreateMDIWindowA
! FUNCTION: CreateMDIWindowW
! FUNCTION: CreateMenu
! FUNCTION: CreatePopupMenu
! FUNCTION: CreateSystemThreads

FUNCTION: HWND CreateWindowExA (
                DWORD dwExStyle,
                LPCSTR lpClassName,
                LPCSTR lpWindowName,
                DWORD dwStyle,
                uint X,
                uint Y,
                uint nWidth,
                uint nHeight,
                HWND hWndParent,
                HMENU hMenu,
                HINSTANCE hInstance,
                LPVOID lpParam ) ;

FUNCTION: HWND CreateWindowExW (
                DWORD dwExStyle,
                LPCWSTR lpClassName,
                LPCWSTR lpWindowName,
                DWORD dwStyle,
                uint X,
                uint Y,
                uint nWidth,
                uint nHeight,
                HWND hWndParent,
                HMENU hMenu,
                HINSTANCE hInstance,
                LPVOID lpParam ) ;

: CreateWindowEx \ CreateWindowExW \ CreateWindowExA unicode-exec ;

! 11 >r <r
: CreateWindow >r >r >r >r >r >r >r >r >r >r >r 0 r> r> r> r> r> r> r> r> r> r> r> CreateWindowEx ;


! FUNCTION: CreateWindowStationA
! FUNCTION: CreateWindowStationW
! FUNCTION: CsrBroadcastSystemMessageExW
! FUNCTION: CtxInitUser32
! FUNCTION: DdeAbandonTransaction
! FUNCTION: DdeAccessData
! FUNCTION: DdeAddData
! FUNCTION: DdeClientTransaction
! FUNCTION: DdeCmpStringHandles
! FUNCTION: DdeConnect
! FUNCTION: DdeConnectList
! FUNCTION: DdeCreateDataHandle
! FUNCTION: DdeCreateStringHandleA
! FUNCTION: DdeCreateStringHandleW
! FUNCTION: DdeDisconnect
! FUNCTION: DdeDisconnectList
! FUNCTION: DdeEnableCallback
! FUNCTION: DdeFreeDataHandle
! FUNCTION: DdeFreeStringHandle
! FUNCTION: DdeGetData
! FUNCTION: DdeGetLastError
! FUNCTION: DdeGetQualityOfService
! FUNCTION: DdeImpersonateClient
! FUNCTION: DdeInitializeA
! FUNCTION: DdeInitializeW
! FUNCTION: DdeKeepStringHandle
! FUNCTION: DdeNameService
! FUNCTION: DdePostAdvise
! FUNCTION: DdeQueryConvInfo
! FUNCTION: DdeQueryNextServer
! FUNCTION: DdeQueryStringA
! FUNCTION: DdeQueryStringW
! FUNCTION: DdeReconnect
! FUNCTION: DdeSetQualityOfService
! FUNCTION: DdeSetUserHandle
! FUNCTION: DdeUnaccessData
! FUNCTION: DdeUninitialize
! FUNCTION: DefDlgProcA
! FUNCTION: DefDlgProcW
! FUNCTION: DeferWindowPos
! FUNCTION: DefFrameProcA
! FUNCTION: DefFrameProcW
! FUNCTION: DefMDIChildProcA
! FUNCTION: DefMDIChildProcW
! FUNCTION: DefRawInputProc
FUNCTION: LRESULT DefWindowProcA ( HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam ) ;
FUNCTION: LRESULT DefWindowProcW ( HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam ) ;
: DefWindowProc \ DefWindowProcW \ DefWindowProcA unicode-exec ;
! FUNCTION: DeleteMenu
! FUNCTION: DeregisterShellHookWindow
! FUNCTION: DestroyAcceleratorTable
! FUNCTION: DestroyCaret
! FUNCTION: DestroyCursor
! FUNCTION: DestroyIcon
! FUNCTION: DestroyMenu
! FUNCTION: DestroyReasons
FUNCTION: BOOL DestroyWindow ( HWND hWnd ) ;
! FUNCTION: DeviceEventWorker
! FUNCTION: DialogBoxIndirectParamA
! FUNCTION: DialogBoxIndirectParamAorW
! FUNCTION: DialogBoxIndirectParamW
! FUNCTION: DialogBoxParamA
! FUNCTION: DialogBoxParamW
! FUNCTION: DisableProcessWindowsGhosting

FUNCTION: LONG DispatchMessageA ( MSG* lpMsg ) ;
FUNCTION: LONG DispatchMessageW ( MSG* lpMsg ) ;
: DispatchMessage \ DispatchMessageW \ DispatchMessageA unicode-exec ;

! FUNCTION: DisplayExitWindowsWarnings
! FUNCTION: DlgDirListA
! FUNCTION: DlgDirListComboBoxA
! FUNCTION: DlgDirListComboBoxW
! FUNCTION: DlgDirListW
! FUNCTION: DlgDirSelectComboBoxExA
! FUNCTION: DlgDirSelectComboBoxExW
! FUNCTION: DlgDirSelectExA
! FUNCTION: DlgDirSelectExW
! FUNCTION: DragDetect
! FUNCTION: DragObject


FUNCTION: BOOL DrawAnimatedRects ( HWND hWnd, int idAni, RECT* lprcFrom, RECT* lprcTo ) ;
! FUNCTION: BOOL DrawCaption ( HWND hWnd, HDC hdc, LPRECT lprc, UINT uFlags ) ;

! FUNCTION: DrawEdge
! FUNCTION: DrawFocusRect
! FUNCTION: DrawFrame
! FUNCTION: DrawFrameControl
! FUNCTION: DrawIcon
! FUNCTION: DrawIconEx
! FUNCTION: DrawMenuBar
! FUNCTION: DrawMenuBarTemp
! FUNCTION: DrawStateA
! FUNCTION: DrawStateW
! FUNCTION: DrawTextA
! FUNCTION: DrawTextExA
! FUNCTION: DrawTextExW
! FUNCTION: DrawTextW
! FUNCTION: EditWndProc
FUNCTION: BOOL EmptyClipboard ( ) ;
! FUNCTION: EnableMenuItem
! FUNCTION: EnableScrollBar
! FUNCTION: EnableWindow
! FUNCTION: EndDeferWindowPos
! FUNCTION: EndDialog
! FUNCTION: EndMenu

FUNCTION: BOOL EndPaint ( HWND hWnd, PAINTSTRUCT* lpPaint) ;

! FUNCTION: EndTask
! FUNCTION: EnterReaderModeHelper
! FUNCTION: EnumChildWindows
FUNCTION: UINT EnumClipboardFormats ( UINT format ) ;
! FUNCTION: EnumDesktopsA
! FUNCTION: EnumDesktopsW
! FUNCTION: EnumDesktopWindows
! FUNCTION: EnumDisplayDevicesA
! FUNCTION: EnumDisplayDevicesW
! FUNCTION: EnumDisplayMonitors
! FUNCTION: EnumDisplaySettingsA
! FUNCTION: EnumDisplaySettingsExA
! FUNCTION: EnumDisplaySettingsExW
! FUNCTION: EnumDisplaySettingsW
! FUNCTION: EnumPropsA
! FUNCTION: EnumPropsExA
! FUNCTION: EnumPropsExW
! FUNCTION: EnumPropsW
! FUNCTION: EnumThreadWindows
! FUNCTION: EnumWindows
! FUNCTION: EnumWindowStationsA
! FUNCTION: EnumWindowStationsW
! FUNCTION: EqualRect
! FUNCTION: ExcludeUpdateRgn
! FUNCTION: ExitWindowsEx
! FUNCTION: FillRect
! FUNCTION: FindWindowA
! FUNCTION: FindWindowExA
! FUNCTION: FindWindowExW
! FUNCTION: FindWindowW
! FUNCTION: FlashWindow
! FUNCTION: FlashWindowEx
! FUNCTION: FrameRect
! FUNCTION: FreeDDElParam
! FUNCTION: GetActiveWindow
! FUNCTION: GetAltTabInfo
! FUNCTION: GetAltTabInfoA
! FUNCTION: GetAltTabInfoW
! FUNCTION: GetAncestor
! FUNCTION: GetAppCompatFlags
! FUNCTION: GetAppCompatFlags2
! FUNCTION: GetAsyncKeyState
FUNCTION: HWND GetCapture ( ) ;
! FUNCTION: GetCaretBlinkTime
! FUNCTION: GetCaretPos
FUNCTION: BOOL GetClassInfoA ( HINSTANCE hInst, LPCTSTR lpszClass, LPWNDCLASS lpwcx ) ;
FUNCTION: BOOL GetClassInfoW ( HINSTANCE hInst, LPCWSTR lpszClass, LPWNDCLASS lpwcx ) ;
: GetClassInfo \ GetClassInfoW \ GetClassInfoA unicode-exec ;

FUNCTION: BOOL GetClassInfoExA ( HINSTANCE hInst, LPCTSTR lpszClass, LPWNDCLASSEX lpwcx ) ;
FUNCTION: BOOL GetClassInfoExW ( HINSTANCE hInst, LPCWSTR lpszClass, LPWNDCLASSEX lpwcx ) ;
: GetClassInfoEx \ GetClassInfoExW \ GetClassInfoExA unicode-exec ;

FUNCTION: ULONG_PTR GetClassLongA ( HWND hWnd, int nIndex ) ;
FUNCTION: ULONG_PTR GetClassLongW ( HWND hWnd, int nIndex ) ;
: GetClassLong \ GetClassLongW \ GetClassLongA unicode-exec ;
: GetClassLongPtr \ GetClassLongW \ GetClassLongA unicode-exec ;


! FUNCTION: GetClassNameA
! FUNCTION: GetClassNameW
! FUNCTION: GetClassWord
! FUNCTION: BOOL GetClientRect ( HWND hWnd, LPRECT lpRect ) ;

FUNCTION: HANDLE GetClipboardData ( UINT uFormat ) ;

! FUNCTION: GetClipboardFormatNameA
! FUNCTION: GetClipboardFormatNameW
FUNCTION: HWND GetClipboardOwner ( ) ;
FUNCTION: DWORD GetClipboardSequenceNumber ( ) ;
! FUNCTION: GetClipboardViewer
! FUNCTION: GetClipCursor
! FUNCTION: GetComboBoxInfo
! FUNCTION: GetCursor
! FUNCTION: GetCursorFrameInfo
! FUNCTION: GetCursorInfo
! FUNCTION: GetCursorPos
FUNCTION: HDC GetDC ( HWND hWnd ) ;
FUNCTION: HDC GetDCEx ( HWND hWnd, HRGN hrgnClip, DWORD flags ) ;
! FUNCTION: GetDesktopWindow
! FUNCTION: GetDialogBaseUnits
! FUNCTION: GetDlgCtrlID
! FUNCTION: GetDlgItem
! FUNCTION: GetDlgItemInt
! FUNCTION: GetDlgItemTextA
! FUNCTION: GetDlgItemTextW
! FUNCTION: GetDoubleClickTime
FUNCTION: HWND GetFocus ( ) ;
! FUNCTION: GetForegroundWindow
! FUNCTION: GetGuiResources
! FUNCTION: GetGUIThreadInfo
! FUNCTION: GetIconInfo
! FUNCTION: GetInputDesktop
! FUNCTION: GetInputState
! FUNCTION: GetInternalWindowPos
! FUNCTION: GetKBCodePage
! FUNCTION: GetKeyboardLayout
! FUNCTION: GetKeyboardLayoutList
! FUNCTION: GetKeyboardLayoutNameA
! FUNCTION: GetKeyboardLayoutNameW
! FUNCTION: GetKeyboardState
! FUNCTION: GetKeyboardType
! FUNCTION: GetKeyNameTextA
! FUNCTION: GetKeyNameTextW
FUNCTION: SHORT GetKeyState ( int nVirtKey ) ;
! FUNCTION: GetLastActivePopup
! FUNCTION: GetLastInputInfo
! FUNCTION: GetLayeredWindowAttributes
! FUNCTION: GetListBoxInfo
! FUNCTION: GetMenu
! FUNCTION: GetMenuBarInfo
! FUNCTION: GetMenuCheckMarkDimensions
! FUNCTION: GetMenuContextHelpId
! FUNCTION: GetMenuDefaultItem
! FUNCTION: GetMenuInfo
! FUNCTION: GetMenuItemCount
! FUNCTION: GetMenuItemID
! FUNCTION: GetMenuItemInfoA
! FUNCTION: GetMenuItemInfoW
! FUNCTION: GetMenuItemRect
! FUNCTION: GetMenuState
! FUNCTION: GetMenuStringA
! FUNCTION: GetMenuStringW

FUNCTION: BOOL GetMessageA ( LPMSG lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax ) ;
FUNCTION: BOOL GetMessageW ( LPMSG lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax ) ;
: GetMessage \ GetMessageW \ GetMessageA unicode-exec ;

! FUNCTION: GetMessageExtraInfo
! FUNCTION: GetMessagePos
! FUNCTION: GetMessageTime
! FUNCTION: GetMonitorInfoA
! FUNCTION: GetMonitorInfoW
! FUNCTION: GetMouseMovePointsEx
! FUNCTION: GetNextDlgGroupItem
! FUNCTION: GetNextDlgTabItem
! FUNCTION: GetOpenClipboardWindow
FUNCTION: HWND GetParent ( HWND hWnd ) ;
FUNCTION: int GetPriorityClipboardFormat ( UINT* paFormatPriorityList, int cFormats ) ;
! FUNCTION: GetProcessDefaultLayout
! FUNCTION: GetProcessWindowStation
! FUNCTION: GetProgmanWindow
! FUNCTION: GetPropA
! FUNCTION: GetPropW
! FUNCTION: GetQueueStatus
! FUNCTION: GetRawInputBuffer
! FUNCTION: GetRawInputData
! FUNCTION: GetRawInputDeviceInfoA
! FUNCTION: GetRawInputDeviceInfoW
! FUNCTION: GetRawInputDeviceList
! FUNCTION: GetReasonTitleFromReasonCode
! FUNCTION: GetRegisteredRawInputDevices
! FUNCTION: GetScrollBarInfo
! FUNCTION: GetScrollInfo
! FUNCTION: GetScrollPos
! FUNCTION: GetScrollRange
! FUNCTION: GetShellWindow
! FUNCTION: GetSubMenu
! FUNCTION: GetSysColor
FUNCTION: HBRUSH GetSysColorBrush ( int nIndex ) ;
! FUNCTION: GetSystemMenu
! FUNCTION: GetSystemMetrics
! FUNCTION: GetTabbedTextExtentA
! FUNCTION: GetTabbedTextExtentW
! FUNCTION: GetTaskmanWindow
! FUNCTION: GetThreadDesktop
! FUNCTION: GetTitleBarInfo


FUNCTION: HWND GetTopWindow ( HWND hWnd ) ;
! FUNCTION: BOOL GetUpdateRect ( HWND hWnd, LPRECT lpRect, BOOL bErase ) ;
FUNCTION: int GetUpdateRgn ( HWND hWnd, HRGN hRgn, BOOL bErase ) ;


! FUNCTION: GetUserObjectInformationA
! FUNCTION: GetUserObjectInformationW
! FUNCTION: GetUserObjectSecurity
FUNCTION: HWND GetWindow ( HWND hWnd, UINT uCmd ) ;
! FUNCTION: GetWindowContextHelpId
! FUNCTION: GetWindowDC
! FUNCTION: GetWindowInfo
! FUNCTION: GetWindowLongA
! FUNCTION: GetWindowLongW
! FUNCTION: GetWindowModuleFileName
! FUNCTION: GetWindowModuleFileNameA
! FUNCTION: GetWindowModuleFileNameW
! FUNCTION: GetWindowPlacement
! FUNCTION: BOOL GetWindowRect ( HWND hWnd, LPRECT lpRect ) ;
! FUNCTION: GetWindowRgn
! FUNCTION: GetWindowRgnBox
! FUNCTION: GetWindowTextA
! FUNCTION: GetWindowTextLengthA
! FUNCTION: GetWindowTextLengthW
! FUNCTION: GetWindowTextW
! FUNCTION: GetWindowThreadProcessId
! FUNCTION: GetWindowWord
! FUNCTION: GetWinStationInfo
! FUNCTION: GrayStringA
! FUNCTION: GrayStringW
! FUNCTION: HideCaret
! FUNCTION: HiliteMenuItem
! FUNCTION: ImpersonateDdeClientWindow
! FUNCTION: IMPGetIMEA
! FUNCTION: IMPGetIMEW
! FUNCTION: IMPQueryIMEA
! FUNCTION: IMPQueryIMEW
! FUNCTION: IMPSetIMEA
! FUNCTION: IMPSetIMEW
! FUNCTION: InflateRect
! FUNCTION: InitializeLpkHooks
! FUNCTION: InitializeWin32EntryTable
! FUNCTION: InSendMessage
! FUNCTION: InSendMessageEx
! FUNCTION: InsertMenuA
! FUNCTION: InsertMenuItemA
! FUNCTION: InsertMenuItemW
! FUNCTION: InsertMenuW
! FUNCTION: InternalGetWindowText
! FUNCTION: IntersectRect
! FUNCTION: InvalidateRect
! FUNCTION: InvalidateRgn
! FUNCTION: InvertRect
! FUNCTION: IsCharAlphaA
! FUNCTION: IsCharAlphaNumericA
! FUNCTION: IsCharAlphaNumericW
! FUNCTION: IsCharAlphaW
! FUNCTION: IsCharLowerA
! FUNCTION: IsCharLowerW
! FUNCTION: IsCharUpperA
! FUNCTION: IsCharUpperW
FUNCTION: BOOL IsChild ( HWND hWndParent, HWND hWnd ) ;
FUNCTION: BOOL IsClipboardFormatAvailable ( UINT format ) ;
! FUNCTION: IsDialogMessage
! FUNCTION: IsDialogMessageA
! FUNCTION: IsDialogMessageW
! FUNCTION: IsDlgButtonChecked
FUNCTION: BOOL IsGUIThread ( BOOL bConvert ) ;
FUNCTION: BOOL IsHungAppWindow ( HWND hWnd ) ;
FUNCTION: BOOL IsIconic ( HWND hWnd ) ;
FUNCTION: BOOL IsMenu ( HMENU hMenu ) ;
! FUNCTION: BOOL IsRectEmpty
! FUNCTION: BOOL IsServerSideWindow
FUNCTION: BOOL IsWindow ( HWND hWnd ) ;
! FUNCTION: BOOL IsWindowEnabled
! FUNCTION: BOOL IsWindowInDestroy
FUNCTION: BOOL IsWindowUnicode ( HWND hWnd ) ;
FUNCTION: BOOL IsWindowVisible ( HWND hWnd ) ;
! FUNCTION: BOOL IsWinEventHookInstalled
FUNCTION: BOOL IsZoomed ( HWND hWnd ) ;
! FUNCTION: keybd_event
! FUNCTION: KillSystemTimer
! FUNCTION: KillTimer
! FUNCTION: LoadAcceleratorsA
! FUNCTION: LoadAcceleratorsW
! FUNCTION: LoadBitmapA
! FUNCTION: LoadBitmapW
! FUNCTION: LoadCursorFromFileA
! FUNCTION: LoadCursorFromFileW


! FUNCTION: HCURSOR LoadCursorA ( HINSTANCE hInstance, LPCTSTR lpCursorName ) ;
! FUNCTION: HCURSOR LoadCursorW ( HINSTANCE hInstance, LPCWSTR lpCursorName ) ;
FUNCTION: HCURSOR LoadCursorA ( HINSTANCE hInstance, ushort lpCursorName ) ;
FUNCTION: HCURSOR LoadCursorW ( HINSTANCE hInstance, ushort lpCursorName ) ;
: LoadCursor \ LoadCursorW \ LoadCursorA unicode-exec ;

! FUNCTION: HICON LoadIconA ( HINSTANCE hInstance, LPCTSTR lpIconName ) ;
! FUNCTION: HICON LoadIconW ( HINSTANCE hInstance, LPCWSTR lpIconName ) ;
FUNCTION: HICON LoadIconA ( HINSTANCE hInstance, ushort lpIconName ) ;
FUNCTION: HICON LoadIconW ( HINSTANCE hInstance, ushort lpIconName ) ;
: LoadIcon \ LoadIconW \ LoadIconA unicode-exec ;

! FUNCTION: LoadImageA
! FUNCTION: LoadImageW
! FUNCTION: LoadKeyboardLayoutA
! FUNCTION: LoadKeyboardLayoutEx
! FUNCTION: LoadKeyboardLayoutW
! FUNCTION: LoadLocalFonts
! FUNCTION: LoadMenuA
! FUNCTION: LoadMenuIndirectA
! FUNCTION: LoadMenuIndirectW
! FUNCTION: LoadMenuW
! FUNCTION: LoadRemoteFonts
! FUNCTION: LoadStringA
! FUNCTION: LoadStringW
! FUNCTION: LockSetForegroundWindow
! FUNCTION: LockWindowStation
! FUNCTION: LockWindowUpdate
! FUNCTION: LockWorkStation
! FUNCTION: LookupIconIdFromDirectory
! FUNCTION: LookupIconIdFromDirectoryEx
! FUNCTION: MapDialogRect
! FUNCTION: MapVirtualKeyA
! FUNCTION: MapVirtualKeyExA
! FUNCTION: MapVirtualKeyExW
! FUNCTION: MapVirtualKeyW
! FUNCTION: MapWindowPoints
! FUNCTION: MB_GetString
! FUNCTION: MBToWCSEx
! FUNCTION: MenuItemFromPoint
! FUNCTION: MenuWindowProcA
! FUNCTION: MenuWindowProcW

! -1 is Simple beep
FUNCTION: BOOL MessageBeep ( UINT uType ) ;

FUNCTION: int MessageBoxA ( 
                HWND hWnd,
                LPCSTR lpText,
                LPCSTR lpCaption,
                UINT uType ) ;

FUNCTION: int MessageBoxW (
                HWND hWnd,
                LPCWSTR lpText,
                LPCWSTR lpCaption,
                UINT uType) ;

FUNCTION: int MessageBoxExA ( HWND hWnd,
                LPCSTR lpText,
                LPCSTR lpCaption,
                UINT uType,
                WORD wLanguageId
                ) ;

FUNCTION: int MessageBoxExW (
                HWND hWnd,
                LPCWSTR lpText,
                LPCWSTR lpCaption,
                UINT uType,
                WORD wLanguageId ) ;

FUNCTION: int MessageBoxIndirectA (
                 MSGBOXPARAMSA* params ) ;

FUNCTION: int MessageBoxIndirectW (
                 MSGBOXPARAMSW* params ) ;


: MessageBox ( -- )
    \ MessageBoxW \ MessageBoxA unicode-exec ;

: MessageBoxEx ( -- )
    \ MessageBoxExW \ MessageBoxExA unicode-exec ;

: MessageBoxIndirect ( -- )
    \ MessageBoxIndirectW \ MessageBoxIndirectA unicode-exec ;

! FUNCTION: MessageBoxTimeoutA ! dllexported, not in header
! FUNCTION: MessageBoxTimeoutW ! dllexported, not in header

! FUNCTION: ModifyMenuA
! FUNCTION: ModifyMenuW
! FUNCTION: MonitorFromPoint
! FUNCTION: MonitorFromRect
! FUNCTION: MonitorFromWindow
! FUNCTION: mouse_event



FUNCTION: BOOL MoveWindow (
    HWND hWnd,
    int X,
    int Y,
    int nWidth,
    int nHeight,
    BOOL bRepaint ) ;


! FUNCTION: MsgWaitForMultipleObjects
! FUNCTION: MsgWaitForMultipleObjectsEx
! FUNCTION: NotifyWinEvent
! FUNCTION: OemKeyScan
! FUNCTION: OemToCharA
! FUNCTION: OemToCharBuffA
! FUNCTION: OemToCharBuffW
! FUNCTION: OemToCharW
! FUNCTION: OffsetRect
FUNCTION: BOOL OpenClipboard ( HWND hWndNewOwner ) ;
! FUNCTION: OpenDesktopA
! FUNCTION: OpenDesktopW
! FUNCTION: OpenIcon
! FUNCTION: OpenInputDesktop
! FUNCTION: OpenWindowStationA
! FUNCTION: OpenWindowStationW
! FUNCTION: PackDDElParam
! FUNCTION: PaintDesktop
! FUNCTION: PaintMenuBar
FUNCTION: BOOL PeekMessageA ( LPMSG lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax, UINT wRemoveMsg ) ;
FUNCTION: BOOL PeekMessageW ( LPMSG lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax, UINT wRemoveMsg ) ;
: PeekMessage \ PeekMessageW \ PeekMessageA unicode-exec ;

! FUNCTION: PostMessageA
! FUNCTION: PostMessageW
FUNCTION: void PostQuitMessage ( int nExitCode ) ;
! FUNCTION: PostThreadMessageA
! FUNCTION: PostThreadMessageW
! FUNCTION: PrintWindow
! FUNCTION: PrivateExtractIconExA
! FUNCTION: PrivateExtractIconExW
! FUNCTION: PrivateExtractIconsA
! FUNCTION: PrivateExtractIconsW
! FUNCTION: PrivateSetDbgTag
! FUNCTION: PrivateSetRipFlags
! FUNCTION: PtInRect
! FUNCTION: QuerySendMessage
! FUNCTION: QueryUserCounters
! FUNCTION: RealChildWindowFromPoint
! FUNCTION: RealGetWindowClass
! FUNCTION: RealGetWindowClassA
! FUNCTION: RealGetWindowClassW
! FUNCTION: ReasonCodeNeedsBugID
! FUNCTION: ReasonCodeNeedsComment
! FUNCTION: RecordShutdownReason
! FUNCTION: RedrawWindow

FUNCTION: ATOM RegisterClassA ( WNDCLASS* lpWndClass) ;
FUNCTION: ATOM RegisterClassW ( WNDCLASS* lpWndClass ) ;
FUNCTION: ATOM RegisterClassExA ( WNDCLASSEX* lpwcx ) ;
FUNCTION: ATOM RegisterClassExW ( WNDCLASSEX* lpwcx ) ;

: RegisterClass \ RegisterClassW \ RegisterClassA unicode-exec ;
: RegisterClassEx \ RegisterClassExW \ RegisterClassExA unicode-exec ;

! FUNCTION: RegisterClipboardFormatA
! FUNCTION: RegisterClipboardFormatW
! FUNCTION: RegisterDeviceNotificationA
! FUNCTION: RegisterDeviceNotificationW
! FUNCTION: RegisterHotKey
! FUNCTION: RegisterLogonProcess
! FUNCTION: RegisterMessagePumpHook
! FUNCTION: RegisterRawInputDevices
! FUNCTION: RegisterServicesProcess
! FUNCTION: RegisterShellHookWindow
! FUNCTION: RegisterSystemThread
! FUNCTION: RegisterTasklist
! FUNCTION: RegisterUserApiHook
! FUNCTION: RegisterWindowMessageA
! FUNCTION: RegisterWindowMessageW
FUNCTION: BOOL ReleaseCapture ( ) ;
FUNCTION: int ReleaseDC ( HWND hWnd, HDC hDC ) ;
! FUNCTION: RemoveMenu
! FUNCTION: RemovePropA
! FUNCTION: RemovePropW
! FUNCTION: ReplyMessage
! FUNCTION: ResolveDesktopForWOW
! FUNCTION: ReuseDDElParam
! FUNCTION: ScreenToClient
! FUNCTION: ScrollChildren
! FUNCTION: ScrollDC
! FUNCTION: ScrollWindow
! FUNCTION: ScrollWindowEx
! FUNCTION: SendDlgItemMessageA
! FUNCTION: SendDlgItemMessageW
! FUNCTION: SendIMEMessageExA
! FUNCTION: SendIMEMessageExW
! FUNCTION: UINT SendInput ( UINT nInputs, LPINPUT pInputs, int cbSize ) ;
FUNCTION: LRESULT SendMessageA ( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam ) ;
FUNCTION: LRESULT SendMessageW ( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam ) ;
: SendMessage \ SendMessageW \ SendMessageA unicode-exec ;
! FUNCTION: SendMessageCallbackA
! FUNCTION: SendMessageCallbackW
! FUNCTION: SendMessageTimeoutA
! FUNCTION: SendMessageTimeoutW
! FUNCTION: SendNotifyMessageA
! FUNCTION: SendNotifyMessageW
! FUNCTION: SetActiveWindow
FUNCTION: HWND SetCapture ( HWND hWnd ) ;
! FUNCTION: SetCaretBlinkTime
! FUNCTION: SetCaretPos

FUNCTION: ULONG_PTR SetClassLongW ( HWND hWnd, int nIndex, LONG_PTR dwNewLong ) ;
FUNCTION: ULONG_PTR SetClassLongA ( HWND hWnd, int nIndex, LONG_PTR dwNewLong ) ;
: SetClassLongPtr \ SetClassLongW \ SetClassLongA unicode-exec ;
: SetClassLong \ SetClassLongW \ SetClassLongA unicode-exec ;

! FUNCTION: SetClassWord
FUNCTION: HANDLE SetClipboardData ( UINT uFormat, HANDLE hMem ) ;
! FUNCTION: SetClipboardViewer
! FUNCTION: SetConsoleReserveKeys
! FUNCTION: SetCursor
! FUNCTION: SetCursorContents
! FUNCTION: SetCursorPos
! FUNCTION: SetDebugErrorLevel
! FUNCTION: SetDeskWallpaper
! FUNCTION: SetDlgItemInt
! FUNCTION: SetDlgItemTextA
! FUNCTION: SetDlgItemTextW
! FUNCTION: SetDoubleClickTime
FUNCTION: HWND SetFocus ( HWND hWnd ) ;
FUNCTION: BOOL SetForegroundWindow ( HWND hWnd ) ;
! FUNCTION: SetInternalWindowPos
! FUNCTION: SetKeyboardState
! type is ignored
FUNCTION: void SetLastErrorEx ( DWORD dwErrCode, DWORD dwType ) ; 
: SetLastError 0 SetLastErrorEx ;
! FUNCTION: SetLayeredWindowAttributes
! FUNCTION: SetLogonNotifyWindow
! FUNCTION: SetMenu
! FUNCTION: SetMenuContextHelpId
! FUNCTION: SetMenuDefaultItem
! FUNCTION: SetMenuInfo
! FUNCTION: SetMenuItemBitmaps
! FUNCTION: SetMenuItemInfoA
! FUNCTION: SetMenuItemInfoW
! FUNCTION: SetMessageExtraInfo
! FUNCTION: SetMessageQueue
! FUNCTION: SetParent
! FUNCTION: SetProcessDefaultLayout
! FUNCTION: SetProcessWindowStation
! FUNCTION: SetProgmanWindow
! FUNCTION: SetPropA
! FUNCTION: SetPropW
! FUNCTION: SetRect
! FUNCTION: SetRectEmpty
! FUNCTION: SetScrollInfo
! FUNCTION: SetScrollPos
! FUNCTION: SetScrollRange
! FUNCTION: SetShellWindow
! FUNCTION: SetShellWindowEx
! FUNCTION: SetSysColors
! FUNCTION: SetSysColorsTemp
! FUNCTION: SetSystemCursor
! FUNCTION: SetSystemMenu
! FUNCTION: SetSystemTimer
! FUNCTION: SetTaskmanWindow
! FUNCTION: SetThreadDesktop
! FUNCTION: SetTimer
! FUNCTION: SetUserObjectInformationA
! FUNCTION: SetUserObjectInformationW
! FUNCTION: SetUserObjectSecurity
! FUNCTION: SetWindowContextHelpId
! FUNCTION: SetWindowLongA
! FUNCTION: SetWindowLongW
! FUNCTION: SetWindowPlacement
! FUNCTION: SetWindowPos
! FUNCTION: SetWindowRgn
! FUNCTION: SetWindowsHookA
! FUNCTION: SetWindowsHookExA
! FUNCTION: SetWindowsHookExW
! FUNCTION: SetWindowsHookW
! FUNCTION: SetWindowStationUser
! FUNCTION: SetWindowTextA
! FUNCTION: SetWindowTextW
! FUNCTION: SetWindowWord
! FUNCTION: SetWinEventHook
! FUNCTION: ShowCaret
! FUNCTION: ShowCursor
! FUNCTION: ShowOwnedPopups
! FUNCTION: ShowScrollBar
! FUNCTION: ShowStartGlass

FUNCTION: BOOL ShowWindow ( HWND hWnd, int nCmdShow ) ;

! FUNCTION: ShowWindowAsync
! FUNCTION: SoftModalMessageBox
! FUNCTION: SubtractRect
! FUNCTION: SwapMouseButton
! FUNCTION: SwitchDesktop
! FUNCTION: SwitchToThisWindow
! FUNCTION: SystemParametersInfoA
! FUNCTION: SystemParametersInfoW
! FUNCTION: TabbedTextOutA
! FUNCTION: TabbedTextOutW
! FUNCTION: TileChildWindows
! FUNCTION: TileWindows
! FUNCTION: ToAscii
! FUNCTION: ToAsciiEx
! FUNCTION: ToUnicode
! FUNCTION: ToUnicodeEx
! FUNCTION: TrackMouseEvent
! FUNCTION: TrackPopupMenu
! FUNCTION: TrackPopupMenuEx
! FUNCTION: TranslateAccelerator
! FUNCTION: TranslateAcceleratorA
! FUNCTION: TranslateAcceleratorW
! FUNCTION: TranslateMDISysAccel
FUNCTION: BOOL TranslateMessage ( MSG* lpMsg ) ;

! FUNCTION: UnhookWindowsHook
! FUNCTION: UnhookWindowsHookEx
! FUNCTION: UnhookWinEvent
! FUNCTION: UnionRect
! FUNCTION: UnloadKeyboardLayout
! FUNCTION: UnlockWindowStation
! FUNCTION: UnpackDDElParam
FUNCTION: BOOL UnregisterClassA ( LPCTSTR lpClassName, HINSTANCE hInstance ) ;
FUNCTION: BOOL UnregisterClassW ( LPCWSTR lpClassName, HINSTANCE hInstance ) ;
: UnregisterClass \ UnregisterClassW \ UnregisterClassA unicode-exec ;
! FUNCTION: UnregisterDeviceNotification
! FUNCTION: UnregisterHotKey
! FUNCTION: UnregisterMessagePumpHook
! FUNCTION: UnregisterUserApiHook
! FUNCTION: UpdateLayeredWindow
! FUNCTION: UpdatePerUserSystemParameters


FUNCTION: BOOL UpdateWindow ( HWND hWnd ) ;

! FUNCTION: User32InitializeImmEntryTable
! FUNCTION: UserClientDllInitialize
! FUNCTION: UserHandleGrantAccess
! FUNCTION: UserLpkPSMTextOut
! FUNCTION: UserLpkTabbedTextOut
! FUNCTION: UserRealizePalette
! FUNCTION: UserRegisterWowHandlers
! FUNCTION: ValidateRect
! FUNCTION: ValidateRgn
! FUNCTION: VkKeyScanA
! FUNCTION: VkKeyScanExA
! FUNCTION: VkKeyScanExW
! FUNCTION: VkKeyScanW
! FUNCTION: VRipOutput
! FUNCTION: VTagOutput
! FUNCTION: WaitForInputIdle
! FUNCTION: WaitMessage
! FUNCTION: WCSToMBEx
! FUNCTION: Win32PoolAllocationStats
! FUNCTION: WindowFromDC
! FUNCTION: WindowFromPoint
! FUNCTION: WinHelpA
! FUNCTION: WinHelpW
! FUNCTION: WINNLSEnableIME
! FUNCTION: WINNLSGetEnableStatus
! FUNCTION: WINNLSGetIMEHotkey
! FUNCTION: wsprintfA
! FUNCTION: wsprintfW
! FUNCTION: wvsprintfA
! FUNCTION: wvsprintfW

