USING: alien parser namespaces kernel syntax words math io prettyprint ;
IN: win32-api


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

: WS_EX_DLGMODALFRAME     HEX: 00000001 ; inline
: WS_EX_NOPARENTNOTIFY    HEX: 00000004 ; inline
: WS_EX_TOPMOST           HEX: 00000008 ; inline
: WS_EX_ACCEPTFILES       HEX: 00000010 ; inline
: WS_EX_TRANSPARENT       HEX: 00000020 ; inline
: WS_EX_MDICHILD          HEX: 00000040 ; inline
: WS_EX_TOOLWINDOW        HEX: 00000080 ; inline
: WS_EX_WINDOWEDGE        HEX: 00000100 ; inline
: WS_EX_CLIENTEDGE        HEX: 00000200 ; inline
: WS_EX_CONTEXTHELP       HEX: 00000400 ; inline

: WS_EX_RIGHT             HEX: 00001000 ; inline
: WS_EX_LEFT              HEX: 00000000 ; inline
: WS_EX_RTLREADING        HEX: 00002000 ; inline
: WS_EX_LTRREADING        HEX: 00000000 ; inline
: WS_EX_LEFTSCROLLBAR     HEX: 00004000 ; inline
: WS_EX_RIGHTSCROLLBAR    HEX: 00000000 ; inline
: WS_EX_CONTROLPARENT     HEX: 00010000 ; inline
: WS_EX_STATICEDGE        HEX: 00020000 ; inline
: WS_EX_APPWINDOW         HEX: 00040000 ; inline
: WS_EX_OVERLAPPEDWINDOW WS_EX_WINDOWEDGE WS_EX_CLIENTEDGE bitor ; inline
: WS_EX_PALETTEWINDOW
    WS_EX_WINDOWEDGE WS_EX_TOOLWINDOW bitor WS_EX_TOPMOST bitor ; inline


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

! PeekMessage
: PM_NOREMOVE   0 ;
: PM_REMOVE     1 ;
: PM_NOYIELD    2 ;
! : PM_QS_INPUT         (QS_INPUT << 16) ;
! : PM_QS_POSTMESSAGE   ((QS_POSTMESSAGE | QS_HOTKEY | QS_TIMER) << 16) ;
! : PM_QS_PAINT         (QS_PAINT << 16) ;
! : PM_QS_SENDMESSAGE   (QS_SENDMESSAGE << 16) ;


! 
! Standard Cursor IDs
!
: IDC_ARROW           32512 ;
: IDC_IBEAM           32513 ;
: IDC_WAIT            32514 ;
: IDC_CROSS           32515 ;
: IDC_UPARROW         32516 ;
: IDC_SIZE            32640 ; ! OBSOLETE: use IDC_SIZEALL
: IDC_ICON            32641 ; ! OBSOLETE: use IDC_ARROW
: IDC_SIZENWSE        32642 ;
: IDC_SIZENESW        32643 ;
: IDC_SIZEWE          32644 ;
: IDC_SIZENS          32645 ;
: IDC_SIZEALL         32646 ;
: IDC_NO              32648 ; ! not in win3.1
: IDC_HAND            32649 ;
: IDC_APPSTARTING     32650 ; ! not in win3.1
: IDC_HELP            32651 ;





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


: WM_NULL                         0 ; inline
: WM_CREATE                       1 ; inline
: WM_DESTROY                      2 ; inline
: WM_MOVE                         3 ; inline
: WM_SIZE                         5 ; inline
: WM_ACTIVATE                     6 ; inline


! Virtual Keys, Standard Set
: VK_LBUTTON        HEX: 01 ; inline
: VK_RBUTTON        HEX: 02 ; inline
: VK_CANCEL         HEX: 03 ; inline
: VK_MBUTTON        HEX: 04 ; inline  ! NOT contiguous with L & RBUTTON
: VK_XBUTTON1       HEX: 05 ; inline  ! NOT contiguous with L & RBUTTON
: VK_XBUTTON2       HEX: 06 ; inline  ! NOT contiguous with L & RBUTTON
! 0x07 : unassigned
: VK_BACK           HEX: 08 ; inline
: VK_TAB            HEX: 09 ; inline
! 0x0A - 0x0B : reserved

: VK_CLEAR          HEX: 0C ; inline
: VK_RETURN         HEX: 0D ; inline

: VK_SHIFT          HEX: 10 ; inline
: VK_CONTROL        HEX: 11 ; inline
: VK_MENU           HEX: 12 ; inline
: VK_PAUSE          HEX: 13 ; inline
: VK_CAPITAL        HEX: 14 ; inline

: VK_KANA           HEX: 15 ; inline
: VK_HANGEUL        HEX: 15 ; inline ! old name - here for compatibility
: VK_HANGUL         HEX: 15 ; inline
: VK_JUNJA          HEX: 17 ; inline
: VK_FINAL          HEX: 18 ; inline
: VK_HANJA          HEX: 19 ; inline
: VK_KANJI          HEX: 19 ; inline

: VK_ESCAPE         HEX: 1B ; inline

: VK_CONVERT        HEX: 1C ; inline
: VK_NONCONVERT     HEX: 1D ; inline
: VK_ACCEPT         HEX: 1E ; inline
: VK_MODECHANGE     HEX: 1F ; inline

: VK_SPACE          HEX: 20 ; inline
: VK_PRIOR          HEX: 21 ; inline
: VK_NEXT           HEX: 22 ; inline
: VK_END            HEX: 23 ; inline
: VK_HOME           HEX: 24 ; inline
: VK_LEFT           HEX: 25 ; inline
: VK_UP             HEX: 26 ; inline
: VK_RIGHT          HEX: 27 ; inline
: VK_DOWN           HEX: 28 ; inline
: VK_SELECT         HEX: 29 ; inline
: VK_PRINT          HEX: 2A ; inline
: VK_EXECUTE        HEX: 2B ; inline
: VK_SNAPSHOT       HEX: 2C ; inline
: VK_INSERT         HEX: 2D ; inline
: VK_DELETE         HEX: 2E ; inline
: VK_HELP           HEX: 2F ; inline

! VK_0 - VK_9 are the same as ASCII '0' - '9' (0x30 - 0x39)
! 0x40 : unassigned
! VK_A - VK_Z are the same as ASCII 'A' - 'Z' (0x41 - 0x5A)

: VK_LWIN           HEX: 5B ; inline
: VK_RWIN           HEX: 5C ; inline
: VK_APPS           HEX: 5D ; inline

! 0x5E : reserved

: VK_SLEEP          HEX: 5F ; inline

: VK_NUMPAD0        HEX: 60 ; inline
: VK_NUMPAD1        HEX: 61 ; inline
: VK_NUMPAD2        HEX: 62 ; inline
: VK_NUMPAD3        HEX: 63 ; inline
: VK_NUMPAD4        HEX: 64 ; inline
: VK_NUMPAD5        HEX: 65 ; inline
: VK_NUMPAD6        HEX: 66 ; inline
: VK_NUMPAD7        HEX: 67 ; inline
: VK_NUMPAD8        HEX: 68 ; inline
: VK_NUMPAD9        HEX: 69 ; inline
: VK_MULTIPLY       HEX: 6A ; inline
: VK_ADD            HEX: 6B ; inline
: VK_SEPARATOR      HEX: 6C ; inline
: VK_SUBTRACT       HEX: 6D ; inline
: VK_DECIMAL        HEX: 6E ; inline
: VK_DIVIDE         HEX: 6F ; inline
: VK_F1             HEX: 70 ; inline
: VK_F2             HEX: 71 ; inline
: VK_F3             HEX: 72 ; inline
: VK_F4             HEX: 73 ; inline
: VK_F5             HEX: 74 ; inline
: VK_F6             HEX: 75 ; inline
: VK_F7             HEX: 76 ; inline
: VK_F8             HEX: 77 ; inline
: VK_F9             HEX: 78 ; inline
: VK_F10            HEX: 79 ; inline
: VK_F11            HEX: 7A ; inline
: VK_F12            HEX: 7B ; inline
: VK_F13            HEX: 7C ; inline
: VK_F14            HEX: 7D ; inline
: VK_F15            HEX: 7E ; inline
: VK_F16            HEX: 7F ; inline
: VK_F17            HEX: 80 ; inline
: VK_F18            HEX: 81 ; inline
: VK_F19            HEX: 82 ; inline
: VK_F20            HEX: 83 ; inline
: VK_F21            HEX: 84 ; inline
: VK_F22            HEX: 85 ; inline
: VK_F23            HEX: 86 ; inline
: VK_F24            HEX: 87 ; inline

! 0x88 - 0x8F : unassigned

: VK_NUMLOCK        HEX: 90 ; inline
: VK_SCROLL         HEX: 91 ; inline

! NEC PC-9800 kbd definitions
: VK_OEM_NEC_EQUAL  HEX: 92 ; inline  ! '=' key on numpad

! Fujitsu/OASYS kbd definitions
: VK_OEM_FJ_JISHO   HEX: 92 ; inline  ! 'Dictionary' key
: VK_OEM_FJ_MASSHOU HEX: 93 ; inline  ! 'Unregister word' key
: VK_OEM_FJ_TOUROKU HEX: 94 ; inline  ! 'Register word' key
: VK_OEM_FJ_LOYA    HEX: 95 ; inline  ! 'Left OYAYUBI' key
: VK_OEM_FJ_ROYA    HEX: 96 ; inline  ! 'Right OYAYUBI' key

! 0x97 - 0x9F : unassigned

! VK_L* & VK_R* - left and right Alt, Ctrl and Shift virtual keys.
! Used only as parameters to GetAsyncKeyState() and GetKeyState().
! No other API or message will distinguish left and right keys in this way.
: VK_LSHIFT         HEX: A0 ; inline
: VK_RSHIFT         HEX: A1 ; inline
: VK_LCONTROL       HEX: A2 ; inline
: VK_RCONTROL       HEX: A3 ; inline
: VK_LMENU          HEX: A4 ; inline
: VK_RMENU          HEX: A5 ; inline

: VK_BROWSER_BACK        HEX: A6 ; inline
: VK_BROWSER_FORWARD     HEX: A7 ; inline
: VK_BROWSER_REFRESH     HEX: A8 ; inline
: VK_BROWSER_STOP        HEX: A9 ; inline
: VK_BROWSER_SEARCH      HEX: AA ; inline
: VK_BROWSER_FAVORITES   HEX: AB ; inline
: VK_BROWSER_HOME        HEX: AC ; inline

: VK_VOLUME_MUTE         HEX: AD ; inline
: VK_VOLUME_DOWN         HEX: AE ; inline
: VK_VOLUME_UP           HEX: AF ; inline
: VK_MEDIA_NEXT_TRACK    HEX: B0 ; inline
: VK_MEDIA_PREV_TRACK    HEX: B1 ; inline
: VK_MEDIA_STOP          HEX: B2 ; inline
: VK_MEDIA_PLAY_PAUSE    HEX: B3 ; inline
: VK_LAUNCH_MAIL         HEX: B4 ; inline
: VK_LAUNCH_MEDIA_SELECT HEX: B5 ; inline
: VK_LAUNCH_APP1         HEX: B6 ; inline
: VK_LAUNCH_APP2         HEX: B7 ; inline

! 0xB8 - 0xB9 : reserved

: VK_OEM_1          HEX: BA ; inline  ! ';:' for US
: VK_OEM_PLUS       HEX: BB ; inline  ! '+' any country
: VK_OEM_COMMA      HEX: BC ; inline  ! ',' any country
: VK_OEM_MINUS      HEX: BD ; inline  ! '-' any country
: VK_OEM_PERIOD     HEX: BE ; inline  ! '.' any country
: VK_OEM_2          HEX: BF ; inline  ! '/?' for US
: VK_OEM_3          HEX: C0 ; inline  ! '`~' for US

! 0xC1 - 0xD7 : reserved

! 0xD8 - 0xDA : unassigned

: VK_OEM_4          HEX: DB ; inline !  '[{' for US
: VK_OEM_5          HEX: DC ; inline !  '\|' for US
: VK_OEM_6          HEX: DD ; inline !  ']}' for US
: VK_OEM_7          HEX: DE ; inline !  ''"' for US
: VK_OEM_8          HEX: DF ; inline

! 0xE0 : reserved

! Various extended or enhanced keyboards
: VK_OEM_AX         HEX: E1 ; inline !  'AX' key on Japanese AX kbd
: VK_OEM_102        HEX: E2 ; inline !  "<>" or "\|" on RT 102-key kbd.
: VK_ICO_HELP       HEX: E3 ; inline !  Help key on ICO
: VK_ICO_00         HEX: E4 ; inline !  00 key on ICO

: VK_PROCESSKEY     HEX: E5 ; inline

: VK_ICO_CLEAR      HEX: E6 ; inline

: VK_PACKET         HEX: E7 ; inline

! 0xE8 : unassigned

! Nokia/Ericsson definitions
: VK_OEM_RESET      HEX: E9 ; inline
: VK_OEM_JUMP       HEX: EA ; inline
: VK_OEM_PA1        HEX: EB ; inline
: VK_OEM_PA2        HEX: EC ; inline
: VK_OEM_PA3        HEX: ED ; inline
: VK_OEM_WSCTRL     HEX: EE ; inline
: VK_OEM_CUSEL      HEX: EF ; inline
: VK_OEM_ATTN       HEX: F0 ; inline
: VK_OEM_FINISH     HEX: F1 ; inline
: VK_OEM_COPY       HEX: F2 ; inline
: VK_OEM_AUTO       HEX: F3 ; inline
: VK_OEM_ENLW       HEX: F4 ; inline
: VK_OEM_BACKTAB    HEX: F5 ; inline

: VK_ATTN           HEX: F6 ; inline
: VK_CRSEL          HEX: F7 ; inline
: VK_EXSEL          HEX: F8 ; inline
: VK_EREOF          HEX: F9 ; inline
: VK_PLAY           HEX: FA ; inline
: VK_ZOOM           HEX: FB ; inline
: VK_NONAME         HEX: FC ; inline
: VK_PA1            HEX: FD ; inline
: VK_OEM_CLEAR      HEX: FE ; inline
! 0xFF : reserved

! Key State Masks for Mouse Messages
: MK_LBUTTON          HEX: 0001 ; inline
: MK_RBUTTON          HEX: 0002 ; inline
: MK_SHIFT            HEX: 0004 ; inline
: MK_CONTROL          HEX: 0008 ; inline
: MK_MBUTTON          HEX: 0010 ; inline
: MK_XBUTTON1         HEX: 0020 ; inline
: MK_XBUTTON2         HEX: 0040 ; inline


! Some fields are not defined for win64
! Window field offsets for GetWindowLong()
! TODO: win32 only!!
windows? [
    : GWL_WNDPROC         -4 ;
    : GWL_HINSTANCE       -6 ;
    : GWL_HWNDPARENT      -8 ;
    : GWL_USERDATA        -21 ;
    : GWL_ID              -12 ;
] when

: GWL_STYLE           -16 ;
: GWL_EXSTYLE         -20 ;

: GWLP_WNDPROC        -4 ;
: GWLP_HINSTANCE      -6 ;
: GWLP_HWNDPARENT     -8 ;
: GWLP_USERDATA       -21 ;
: GWLP_ID             -12 ;

! Class field offsets for GetClassLong()
! TODO: win32 only!
windows? [
    : GCL_MENUNAME        -8 ;
    : GCL_HBRBACKGROUND   -10 ;
    : GCL_HCURSOR         -12 ;
    : GCL_HICON           -14 ;
    : GCL_HMODULE         -16 ;
    : GCL_WNDPROC         -24 ;
    : GCL_HICONSM         -34 ;
] when
: GCL_CBWNDEXTRA      -18 ;
: GCL_CBCLSEXTRA      -20 ;
: GCL_STYLE           -26 ;
: GCW_ATOM            -32 ;

: GCLP_MENUNAME       -8 ;
: GCLP_HBRBACKGROUND  -10 ;
: GCLP_HCURSOR        -12 ;
: GCLP_HICON          -14 ;
: GCLP_HMODULE        -16 ;
: GCLP_WNDPROC        -24 ;
: GCLP_HICONSM        -34 ;



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
! FUNCTION: GetCapture
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
! FUNCTION: ReleaseCapture
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

