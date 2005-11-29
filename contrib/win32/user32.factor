IN: win32
USING: alien parser namespaces kernel syntax words math io prettyprint ;


TYPEDEF: void* MSGBOXPARAMSA
TYPEDEF: void* MSGBOXPARAMSW


! HKL for ActivateKeyboardLayout
: HKL_PREV 0 ;
: HKL_NEXT 1 ;

: CW_USEDEFAULT HEX: 80000000 ;

: WS_OVERLAPPED       HEX: 00000000 ;
: WS_POPUP            HEX: 80000000 ;
: WS_CHILD            HEX: 40000000 ;
: WS_MINIMIZE         HEX: 20000000 ;
: WS_VISIBLE          HEX: 10000000 ;
: WS_DISABLED         HEX: 08000000 ;
: WS_CLIPSIBLINGS     HEX: 04000000 ;
: WS_CLIPCHILDREN     HEX: 02000000 ;
: WS_MAXIMIZE         HEX: 01000000 ;
: WS_CAPTION          HEX: 00C00000 ; !    /* WS_BORDER | WS_DLGFRAME  */
: WS_BORDER           HEX: 00800000 ;
: WS_DLGFRAME         HEX: 00400000 ;
: WS_VSCROLL          HEX: 00200000 ;
: WS_HSCROLL          HEX: 00100000 ;
: WS_SYSMENU          HEX: 00080000 ;
: WS_THICKFRAME       HEX: 00040000 ;
: WS_GROUP            HEX: 00020000 ;
: WS_TABSTOP          HEX: 00010000 ;
: WS_MINIMIZEBOX      HEX: 00020000 ;
: WS_MAXIMIZEBOX      HEX: 00010000 ;

! Common window styles
: WS_OVERLAPPEDWINDOW WS_OVERLAPPED WS_CAPTION WS_SYSMENU WS_THICKFRAME WS_MINIMIZEBOX WS_MAXIMIZEBOX bitor bitor bitor bitor bitor ;

: WS_POPUPWINDOW      WS_POPUP WS_BORDER WS_SYSMENU bitor bitor ;

: WS_CHILDWINDOW      WS_CHILD ;

: WS_TILED            WS_OVERLAPPED ;
: WS_ICONIC           WS_MINIMIZE ;
: WS_SIZEBOX          WS_THICKFRAME ;
: WS_TILEDWINDOW      WS_OVERLAPPEDWINDOW ;



! Extended window styles

: WS_EX_DLGMODALFRAME     HEX: 00000001 ;
: WS_EX_NOPARENTNOTIFY    HEX: 00000004 ;
: WS_EX_TOPMOST           HEX: 00000008 ;
: WS_EX_ACCEPTFILES       HEX: 00000010 ;
: WS_EX_TRANSPARENT       HEX: 00000020 ;
: WS_EX_MDICHILD          HEX: 00000040 ;
: WS_EX_TOOLWINDOW        HEX: 00000080 ;
: WS_EX_WINDOWEDGE        HEX: 00000100 ;
: WS_EX_CLIENTEDGE        HEX: 00000200 ;
: WS_EX_CONTEXTHELP       HEX: 00000400 ;

: CS_VREDRAW          HEX: 0001 ;
: CS_HREDRAW          HEX: 0002 ;
: CS_DBLCLKS          HEX: 0008 ;
: CS_OWNDC            HEX: 0020 ;
: CS_CLASSDC          HEX: 0040 ;
: CS_PARENTDC         HEX: 0080 ;
: CS_NOCLOSE          HEX: 0200 ;
: CS_SAVEBITS         HEX: 0800 ;
: CS_BYTEALIGNCLIENT  HEX: 1000 ;
: CS_BYTEALIGNWINDOW  HEX: 2000 ;
: CS_GLOBALCLASS      HEX: 4000 ;

: COLOR_SCROLLBAR         0 ;
: COLOR_BACKGROUND        1 ;
: COLOR_ACTIVECAPTION     2 ;
: COLOR_INACTIVECAPTION   3 ;
: COLOR_MENU              4 ;
: COLOR_WINDOW            5 ;
: COLOR_WINDOWFRAME       6 ;
: COLOR_MENUTEXT          7 ;
: COLOR_WINDOWTEXT        8 ;
: COLOR_CAPTIONTEXT       9 ;
: COLOR_ACTIVEBORDER      10 ;
: COLOR_INACTIVEBORDER    11 ;
: COLOR_APPWORKSPACE      12 ;
: COLOR_HIGHLIGHT         13 ;
: COLOR_HIGHLIGHTTEXT     14 ;
: COLOR_BTNFACE           15 ;
: COLOR_BTNSHADOW         16 ;
: COLOR_GRAYTEXT          17 ;
: COLOR_BTNTEXT           18 ;
: COLOR_INACTIVECAPTIONTEXT 19 ;
: COLOR_BTNHIGHLIGHT      20 ;

: IDI_APPLICATION     32512 ;
: IDI_HAND            32513 ;
: IDI_QUESTION        32514 ;
: IDI_EXCLAMATION     32515 ;
: IDI_ASTERISK        32516 ;
: IDI_WINLOGO         32517 ;

! ShowWindow() Commands
: SW_HIDE             0 ;
: SW_SHOWNORMAL       1 ;
: SW_NORMAL           1 ;
: SW_SHOWMINIMIZED    2 ;
: SW_SHOWMAXIMIZED    3 ;
: SW_MAXIMIZE         3 ;
: SW_SHOWNOACTIVATE   4 ;
: SW_SHOW             5 ;
: SW_MINIMIZE         6 ;
: SW_SHOWMINNOACTIVE  7 ;
: SW_SHOWNA           8 ;
: SW_RESTORE          9 ;
: SW_SHOWDEFAULT      10 ;
: SW_FORCEMINIMIZE    11 ;
: SW_MAX              11 ;



: MAKEINTRESOURCE ( int -- something )
    ;
! 
! Standard Cursor IDs
!
: IDC_ARROW           32512 MAKEINTRESOURCE ;
: IDC_IBEAM           32513 MAKEINTRESOURCE ;
: IDC_WAIT            32514 MAKEINTRESOURCE ;
: IDC_CROSS           32515 MAKEINTRESOURCE ;
: IDC_UPARROW         32516 MAKEINTRESOURCE ;
: IDC_SIZE            32640 MAKEINTRESOURCE ; ! OBSOLETE: use IDC_SIZEALL
: IDC_ICON            32641 MAKEINTRESOURCE ; ! OBSOLETE: use IDC_ARROW
: IDC_SIZENWSE        32642 MAKEINTRESOURCE ;
: IDC_SIZENESW        32643 MAKEINTRESOURCE ;
: IDC_SIZEWE          32644 MAKEINTRESOURCE ;
: IDC_SIZENS          32645 MAKEINTRESOURCE ;
: IDC_SIZEALL         32646 MAKEINTRESOURCE ;
: IDC_NO              32648 MAKEINTRESOURCE ; ! not in win3.1
: IDC_HAND            32649 MAKEINTRESOURCE ;
: IDC_APPSTARTING     32650 MAKEINTRESOURCE ; ! not in win3.1
: IDC_HELP            32651 MAKEINTRESOURCE ;





! Predefined Clipboard Formats
: CF_TEXT             1 ; inline
: CF_BITMAP           2 ; inline
: CF_METAFILEPICT     3 ; inline
: CF_SYLK             4 ; inline
: CF_DIF              5 ; inline
: CF_TIFF             6 ; inline
: CF_OEMTEXT          7 ; inline
: CF_DIB              8 ; inline
: CF_PALETTE          9 ; inline
: CF_PENDATA          10 ; inline
: CF_RIFF             11 ; inline
: CF_WAVE             12 ; inline
: CF_UNICODETEXT      13 ; inline
: CF_ENHMETAFILE      14 ; inline
: CF_HDROP            15 ; inline
: CF_LOCALE           16 ; inline
: CF_DIBV5            17 ; inline
: CF_MAX              18 ; inline

: CF_OWNERDISPLAY HEX: 0080 ; inline
: CF_DSPTEXT HEX: 0081 ; inline
: CF_DSPBITMAP HEX: 0082 ; inline
: CF_DSPMETAFILEPICT HEX: 0083 ; inline
: CF_DSPENHMETAFILE HEX: 008E ; inline

! "Private" formats don't get GlobalFree()'d
: CF_PRIVATEFIRST HEX: 200 ; inline
: CF_PRIVATELAST HEX: 2FF ; inline





! "GDIOBJ" formats do get DeleteObject()'d
: CF_GDIOBJFIRST HEX: 300 ; inline
: CF_GDIOBJLAST HEX: 3FF ; inline






LIBRARY: user
FUNCTION: HKL ActivateKeyboardLayout ( HKL hkl, UINT Flags ) ;

! FUNCTION: AdjustWindowRect
! FUNCTION: AdjustWindowRectEx
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


FUNCTION: HDC BeginPaint (   HWND hwnd,  LPPAINTSTRUCT lpPaint ) ;

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
                int X,
                int Y,
                int nWidth,
                int nHeight,
                HWND hWndParent,
                HMENU hMenu,
                HINSTANCE hInstance,
                LPVOID lpParam ) ;

FUNCTION: HWND CreateWindowExW (
                DWORD dwExStyle,
                LPCWSTR lpClassName,
                LPCWSTR lpWindowName,
                DWORD dwStyle,
                int X,
                int Y,
                int nWidth,
                int nHeight,
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
! FUNCTION: DefWindowProcA
! FUNCTION: DefWindowProcW
! FUNCTION: DeleteMenu
! FUNCTION: DeregisterShellHookWindow
! FUNCTION: DestroyAcceleratorTable
! FUNCTION: DestroyCaret
! FUNCTION: DestroyCursor
! FUNCTION: DestroyIcon
! FUNCTION: DestroyMenu
! FUNCTION: DestroyReasons
! FUNCTION: DestroyWindow
! FUNCTION: DeviceEventWorker
! FUNCTION: DialogBoxIndirectParamA
! FUNCTION: DialogBoxIndirectParamAorW
! FUNCTION: DialogBoxIndirectParamW
! FUNCTION: DialogBoxParamA
! FUNCTION: DialogBoxParamW
! FUNCTION: DisableProcessWindowsGhosting
! FUNCTION: DispatchMessageA
! FUNCTION: DispatchMessageW
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
FUNCTION: BOOL DrawCaption ( HWND hWnd, HDC hdc, LPRECT lprc, UINT uFlags ) ;

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

FUNCTION: BOOL EndPaint (
    HWND hWnd,
    PAINTSTRUCT* lpPaint
    ) ;

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
! FUNCTION: GetCapture
! FUNCTION: GetCaretBlinkTime
! FUNCTION: GetCaretPos
! FUNCTION: GetClassInfoA
! FUNCTION: GetClassInfoExA
! FUNCTION: GetClassInfoExW
! FUNCTION: GetClassInfoW
! FUNCTION: GetClassLongA
! FUNCTION: GetClassLongW
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
! FUNCTION: GetDC
! FUNCTION: GetDCEx
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
! FUNCTION: GetKeyState
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
! FUNCTION: GetMessageA
! FUNCTION: GetMessageExtraInfo
! FUNCTION: GetMessagePos
! FUNCTION: GetMessageTime
! FUNCTION: GetMessageW
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
! FUNCTION: GetSysColorBrush
! FUNCTION: GetSystemMenu
! FUNCTION: GetSystemMetrics
! FUNCTION: GetTabbedTextExtentA
! FUNCTION: GetTabbedTextExtentW
! FUNCTION: GetTaskmanWindow
! FUNCTION: GetThreadDesktop
! FUNCTION: GetTitleBarInfo


FUNCTION: HWND GetTopWindow ( HWND hWnd ) ;
FUNCTION: BOOL GetUpdateRect ( HWND hWnd, LPRECT lpRect, BOOL bErase ) ;
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
! FUNCTION: GetWindowRect
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


FUNCTION: HCURSOR LoadCursorA ( HINSTANCE hInstance, LPCTSTR lpCursorName ) ;
FUNCTION: HCURSOR LoadCursorW ( HINSTANCE hInstance, LPWCTSTR lpCursorName ) ;
: LoadCursor \ LoadCursorW \ LoadCursorA unicode-exec ;

FUNCTION: HICON LoadIconA ( HINSTANCE hInstance, LPCTSTR lpIconName ) ;
FUNCTION: HICON LoadIconW ( HINSTANCE hInstance, LPCTSTR lpIconName ) ;
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


: MB_ICONASTERISK    HEX: 00000040 ;
: MB_ICONEXCLAMATION HEX: 00000030 ;
: MB_ICONHAND        HEX: 00000010 ;
: MB_ICONQUESTION    HEX: 00000020 ;
: MB_OK              HEX: 00000000 ;
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
! FUNCTION: PeekMessageA
! FUNCTION: PeekMessageW
! FUNCTION: PostMessageA
! FUNCTION: PostMessageW
! FUNCTION: PostQuitMessage
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
! FUNCTION: ReleaseCapture
! FUNCTION: ReleaseDC
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
FUNCTION: UINT SendInput ( UINT nInputs, LPINPUT pInputs, int cbSize ) ;
! FUNCTION: SendMessageA
! FUNCTION: SendMessageCallbackA
! FUNCTION: SendMessageCallbackW
! FUNCTION: SendMessageTimeoutA
! FUNCTION: SendMessageTimeoutW
! FUNCTION: SendMessageW
! FUNCTION: SendNotifyMessageA
! FUNCTION: SendNotifyMessageW
! FUNCTION: SetActiveWindow
! FUNCTION: SetCapture
! FUNCTION: SetCaretBlinkTime
! FUNCTION: SetCaretPos
! FUNCTION: SetClassLongA
! FUNCTION: SetClassLongW
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
! FUNCTION: SetFocus
! FUNCTION: SetForegroundWindow
! FUNCTION: SetInternalWindowPos
! FUNCTION: SetKeyboardState
! FUNCTION: SetLastErrorEx
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
! FUNCTION: TranslateMessage
! FUNCTION: TranslateMessageEx
! FUNCTION: UnhookWindowsHook
! FUNCTION: UnhookWindowsHookEx
! FUNCTION: UnhookWinEvent
! FUNCTION: UnionRect
! FUNCTION: UnloadKeyboardLayout
! FUNCTION: UnlockWindowStation
! FUNCTION: UnpackDDElParam
! FUNCTION: UnregisterClassA
! FUNCTION: UnregisterClassW
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

