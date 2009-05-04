! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax parser namespaces kernel math
windows.types generalizations math.bitwise ;
IN: windows.user32

! HKL for ActivateKeyboardLayout
CONSTANT: HKL_PREV 0
CONSTANT: HKL_NEXT 1

CONSTANT: CW_USEDEFAULT HEX: 80000000

CONSTANT: WS_OVERLAPPED       HEX: 00000000
CONSTANT: WS_POPUP            HEX: 80000000
CONSTANT: WS_CHILD            HEX: 40000000
CONSTANT: WS_MINIMIZE         HEX: 20000000
CONSTANT: WS_VISIBLE          HEX: 10000000
CONSTANT: WS_DISABLED         HEX: 08000000
CONSTANT: WS_CLIPSIBLINGS     HEX: 04000000
CONSTANT: WS_CLIPCHILDREN     HEX: 02000000
CONSTANT: WS_MAXIMIZE         HEX: 01000000
CONSTANT: WS_CAPTION          HEX: 00C00000
CONSTANT: WS_BORDER           HEX: 00800000
CONSTANT: WS_DLGFRAME         HEX: 00400000
CONSTANT: WS_VSCROLL          HEX: 00200000
CONSTANT: WS_HSCROLL          HEX: 00100000
CONSTANT: WS_SYSMENU          HEX: 00080000
CONSTANT: WS_THICKFRAME       HEX: 00040000
CONSTANT: WS_GROUP            HEX: 00020000
CONSTANT: WS_TABSTOP          HEX: 00010000
CONSTANT: WS_MINIMIZEBOX      HEX: 00020000
CONSTANT: WS_MAXIMIZEBOX      HEX: 00010000

! Common window styles
: WS_OVERLAPPEDWINDOW ( -- n )
    {
        WS_OVERLAPPED
        WS_CAPTION
        WS_SYSMENU
        WS_THICKFRAME
        WS_MINIMIZEBOX
        WS_MAXIMIZEBOX
    } flags ; foldable

: WS_POPUPWINDOW ( -- n )
    { WS_POPUP WS_BORDER WS_SYSMENU } flags ; foldable

ALIAS: WS_CHILDWINDOW      WS_CHILD

ALIAS: WS_TILED            WS_OVERLAPPED
ALIAS: WS_ICONIC           WS_MINIMIZE
ALIAS: WS_SIZEBOX          WS_THICKFRAME
ALIAS: WS_TILEDWINDOW WS_OVERLAPPEDWINDOW

! Extended window styles

CONSTANT: WS_EX_DLGMODALFRAME     HEX: 00000001
CONSTANT: WS_EX_NOPARENTNOTIFY    HEX: 00000004
CONSTANT: WS_EX_TOPMOST           HEX: 00000008
CONSTANT: WS_EX_ACCEPTFILES       HEX: 00000010
CONSTANT: WS_EX_TRANSPARENT       HEX: 00000020
CONSTANT: WS_EX_MDICHILD          HEX: 00000040
CONSTANT: WS_EX_TOOLWINDOW        HEX: 00000080
CONSTANT: WS_EX_WINDOWEDGE        HEX: 00000100
CONSTANT: WS_EX_CLIENTEDGE        HEX: 00000200
CONSTANT: WS_EX_CONTEXTHELP       HEX: 00000400

CONSTANT: WS_EX_RIGHT             HEX: 00001000
CONSTANT: WS_EX_LEFT              HEX: 00000000
CONSTANT: WS_EX_RTLREADING        HEX: 00002000
CONSTANT: WS_EX_LTRREADING        HEX: 00000000
CONSTANT: WS_EX_LEFTSCROLLBAR     HEX: 00004000
CONSTANT: WS_EX_RIGHTSCROLLBAR    HEX: 00000000
CONSTANT: WS_EX_CONTROLPARENT     HEX: 00010000
CONSTANT: WS_EX_STATICEDGE        HEX: 00020000
CONSTANT: WS_EX_APPWINDOW         HEX: 00040000
: WS_EX_OVERLAPPEDWINDOW ( -- n )
    WS_EX_WINDOWEDGE WS_EX_CLIENTEDGE bitor ; foldable
: WS_EX_PALETTEWINDOW ( -- n )
    { WS_EX_WINDOWEDGE WS_EX_TOOLWINDOW WS_EX_TOPMOST } flags ; foldable

CONSTANT: CS_VREDRAW          HEX: 0001
CONSTANT: CS_HREDRAW          HEX: 0002
CONSTANT: CS_DBLCLKS          HEX: 0008
CONSTANT: CS_OWNDC            HEX: 0020
CONSTANT: CS_CLASSDC          HEX: 0040
CONSTANT: CS_PARENTDC         HEX: 0080
CONSTANT: CS_NOCLOSE          HEX: 0200
CONSTANT: CS_SAVEBITS         HEX: 0800
CONSTANT: CS_BYTEALIGNCLIENT  HEX: 1000
CONSTANT: CS_BYTEALIGNWINDOW  HEX: 2000
CONSTANT: CS_GLOBALCLASS      HEX: 4000

CONSTANT: COLOR_SCROLLBAR         0
CONSTANT: COLOR_BACKGROUND        1
CONSTANT: COLOR_ACTIVECAPTION     2
CONSTANT: COLOR_INACTIVECAPTION   3
CONSTANT: COLOR_MENU              4
CONSTANT: COLOR_WINDOW            5
CONSTANT: COLOR_WINDOWFRAME       6
CONSTANT: COLOR_MENUTEXT          7
CONSTANT: COLOR_WINDOWTEXT        8
CONSTANT: COLOR_CAPTIONTEXT       9
CONSTANT: COLOR_ACTIVEBORDER      10
CONSTANT: COLOR_INACTIVEBORDER    11
CONSTANT: COLOR_APPWORKSPACE      12
CONSTANT: COLOR_HIGHLIGHT         13
CONSTANT: COLOR_HIGHLIGHTTEXT     14
CONSTANT: COLOR_BTNFACE           15
CONSTANT: COLOR_BTNSHADOW         16
CONSTANT: COLOR_GRAYTEXT          17
CONSTANT: COLOR_BTNTEXT           18
CONSTANT: COLOR_INACTIVECAPTIONTEXT 19
CONSTANT: COLOR_BTNHIGHLIGHT      20

CONSTANT: IDI_APPLICATION     32512
CONSTANT: IDI_HAND            32513
CONSTANT: IDI_QUESTION        32514
CONSTANT: IDI_EXCLAMATION     32515
CONSTANT: IDI_ASTERISK        32516
CONSTANT: IDI_WINLOGO         32517

! ShowWindow() Commands
CONSTANT: SW_HIDE             0
CONSTANT: SW_SHOWNORMAL       1
CONSTANT: SW_NORMAL           1
CONSTANT: SW_SHOWMINIMIZED    2
CONSTANT: SW_SHOWMAXIMIZED    3
CONSTANT: SW_MAXIMIZE         3
CONSTANT: SW_SHOWNOACTIVATE   4
CONSTANT: SW_SHOW             5
CONSTANT: SW_MINIMIZE         6
CONSTANT: SW_SHOWMINNOACTIVE  7
CONSTANT: SW_SHOWNA           8
CONSTANT: SW_RESTORE          9
CONSTANT: SW_SHOWDEFAULT      10
CONSTANT: SW_FORCEMINIMIZE    11
CONSTANT: SW_MAX              11

! PeekMessage
CONSTANT: PM_NOREMOVE   0
CONSTANT: PM_REMOVE     1
CONSTANT: PM_NOYIELD    2
! : PM_QS_INPUT         (QS_INPUT << 16) ;
! : PM_QS_POSTMESSAGE   ((QS_POSTMESSAGE | QS_HOTKEY | QS_TIMER) << 16) ;
! : PM_QS_PAINT         (QS_PAINT << 16) ;
! : PM_QS_SENDMESSAGE   (QS_SENDMESSAGE << 16) ;


! 
! Standard Cursor IDs
!
CONSTANT: IDC_ARROW           32512
CONSTANT: IDC_IBEAM           32513
CONSTANT: IDC_WAIT            32514
CONSTANT: IDC_CROSS           32515
CONSTANT: IDC_UPARROW         32516
CONSTANT: IDC_SIZE            32640 ! OBSOLETE: use IDC_SIZEALL
CONSTANT: IDC_ICON            32641 ! OBSOLETE: use IDC_ARROW
CONSTANT: IDC_SIZENWSE        32642
CONSTANT: IDC_SIZENESW        32643
CONSTANT: IDC_SIZEWE          32644
CONSTANT: IDC_SIZENS          32645
CONSTANT: IDC_SIZEALL         32646
CONSTANT: IDC_NO              32648 ! not in win3.1
CONSTANT: IDC_HAND            32649
CONSTANT: IDC_APPSTARTING     32650 ! not in win3.1
CONSTANT: IDC_HELP            32651

! Predefined Clipboard Formats
CONSTANT: CF_TEXT             1
CONSTANT: CF_BITMAP           2
CONSTANT: CF_METAFILEPICT     3
CONSTANT: CF_SYLK             4
CONSTANT: CF_DIF              5
CONSTANT: CF_TIFF             6
CONSTANT: CF_OEMTEXT          7
CONSTANT: CF_DIB              8
CONSTANT: CF_PALETTE          9
CONSTANT: CF_PENDATA          10
CONSTANT: CF_RIFF             11
CONSTANT: CF_WAVE             12
CONSTANT: CF_UNICODETEXT      13
CONSTANT: CF_ENHMETAFILE      14
CONSTANT: CF_HDROP            15
CONSTANT: CF_LOCALE           16
CONSTANT: CF_DIBV5            17
CONSTANT: CF_MAX              18

CONSTANT: CF_OWNERDISPLAY HEX: 0080
CONSTANT: CF_DSPTEXT HEX: 0081
CONSTANT: CF_DSPBITMAP HEX: 0082
CONSTANT: CF_DSPMETAFILEPICT HEX: 0083
CONSTANT: CF_DSPENHMETAFILE HEX: 008E

! "Private" formats don't get GlobalFree()'d
CONSTANT: CF_PRIVATEFIRST HEX: 200
CONSTANT: CF_PRIVATELAST HEX: 2FF

! "GDIOBJ" formats do get DeleteObject()'d
CONSTANT: CF_GDIOBJFIRST HEX: 300
CONSTANT: CF_GDIOBJLAST HEX: 3FF

! Virtual Keys, Standard Set
CONSTANT: VK_LBUTTON        HEX: 01
CONSTANT: VK_RBUTTON        HEX: 02
CONSTANT: VK_CANCEL         HEX: 03
CONSTANT: VK_MBUTTON        HEX: 04  ! NOT contiguous with L & RBUTTON
CONSTANT: VK_XBUTTON1       HEX: 05  ! NOT contiguous with L & RBUTTON
CONSTANT: VK_XBUTTON2       HEX: 06  ! NOT contiguous with L & RBUTTON
! 0x07 : unassigned
CONSTANT: VK_BACK           HEX: 08
CONSTANT: VK_TAB            HEX: 09
! 0x0A - 0x0B : reserved

CONSTANT: VK_CLEAR          HEX: 0C
CONSTANT: VK_RETURN         HEX: 0D

CONSTANT: VK_SHIFT          HEX: 10
CONSTANT: VK_CONTROL        HEX: 11
CONSTANT: VK_MENU           HEX: 12
CONSTANT: VK_PAUSE          HEX: 13
CONSTANT: VK_CAPITAL        HEX: 14

CONSTANT: VK_KANA           HEX: 15
CONSTANT: VK_HANGEUL        HEX: 15 ! old name - here for compatibility
CONSTANT: VK_HANGUL         HEX: 15
CONSTANT: VK_JUNJA          HEX: 17
CONSTANT: VK_FINAL          HEX: 18
CONSTANT: VK_HANJA          HEX: 19
CONSTANT: VK_KANJI          HEX: 19

CONSTANT: VK_ESCAPE         HEX: 1B

CONSTANT: VK_CONVERT        HEX: 1C
CONSTANT: VK_NONCONVERT     HEX: 1D
CONSTANT: VK_ACCEPT         HEX: 1E
CONSTANT: VK_MODECHANGE     HEX: 1F

CONSTANT: VK_SPACE          HEX: 20
CONSTANT: VK_PRIOR          HEX: 21
CONSTANT: VK_NEXT           HEX: 22
CONSTANT: VK_END            HEX: 23
CONSTANT: VK_HOME           HEX: 24
CONSTANT: VK_LEFT           HEX: 25
CONSTANT: VK_UP             HEX: 26
CONSTANT: VK_RIGHT          HEX: 27
CONSTANT: VK_DOWN           HEX: 28
CONSTANT: VK_SELECT         HEX: 29
CONSTANT: VK_PRINT          HEX: 2A
CONSTANT: VK_EXECUTE        HEX: 2B
CONSTANT: VK_SNAPSHOT       HEX: 2C
CONSTANT: VK_INSERT         HEX: 2D
CONSTANT: VK_DELETE         HEX: 2E
CONSTANT: VK_HELP           HEX: 2F

CONSTANT: VK_0 CHAR: 0
CONSTANT: VK_1 CHAR: 1
CONSTANT: VK_2 CHAR: 2
CONSTANT: VK_3 CHAR: 3
CONSTANT: VK_4 CHAR: 4
CONSTANT: VK_5 CHAR: 5
CONSTANT: VK_6 CHAR: 6
CONSTANT: VK_7 CHAR: 7
CONSTANT: VK_8 CHAR: 8
CONSTANT: VK_9 CHAR: 9

CONSTANT: VK_A CHAR: A
CONSTANT: VK_B CHAR: B
CONSTANT: VK_C CHAR: C
CONSTANT: VK_D CHAR: D
CONSTANT: VK_E CHAR: E
CONSTANT: VK_F CHAR: F
CONSTANT: VK_G CHAR: G
CONSTANT: VK_H CHAR: H
CONSTANT: VK_I CHAR: I
CONSTANT: VK_J CHAR: J
CONSTANT: VK_K CHAR: K
CONSTANT: VK_L CHAR: L
CONSTANT: VK_M CHAR: M
CONSTANT: VK_N CHAR: N
CONSTANT: VK_O CHAR: O
CONSTANT: VK_P CHAR: P
CONSTANT: VK_Q CHAR: Q
CONSTANT: VK_R CHAR: R
CONSTANT: VK_S CHAR: S
CONSTANT: VK_T CHAR: T
CONSTANT: VK_U CHAR: U
CONSTANT: VK_V CHAR: V
CONSTANT: VK_W CHAR: W
CONSTANT: VK_X CHAR: X
CONSTANT: VK_Y CHAR: Y
CONSTANT: VK_Z CHAR: Z

CONSTANT: VK_LWIN           HEX: 5B
CONSTANT: VK_RWIN           HEX: 5C
CONSTANT: VK_APPS           HEX: 5D

! 0x5E : reserved

CONSTANT: VK_SLEEP          HEX: 5F

CONSTANT: VK_NUMPAD0        HEX: 60
CONSTANT: VK_NUMPAD1        HEX: 61
CONSTANT: VK_NUMPAD2        HEX: 62
CONSTANT: VK_NUMPAD3        HEX: 63
CONSTANT: VK_NUMPAD4        HEX: 64
CONSTANT: VK_NUMPAD5        HEX: 65
CONSTANT: VK_NUMPAD6        HEX: 66
CONSTANT: VK_NUMPAD7        HEX: 67
CONSTANT: VK_NUMPAD8        HEX: 68
CONSTANT: VK_NUMPAD9        HEX: 69
CONSTANT: VK_MULTIPLY       HEX: 6A
CONSTANT: VK_ADD            HEX: 6B
CONSTANT: VK_SEPARATOR      HEX: 6C
CONSTANT: VK_SUBTRACT       HEX: 6D
CONSTANT: VK_DECIMAL        HEX: 6E
CONSTANT: VK_DIVIDE         HEX: 6F
CONSTANT: VK_F1             HEX: 70
CONSTANT: VK_F2             HEX: 71
CONSTANT: VK_F3             HEX: 72
CONSTANT: VK_F4             HEX: 73
CONSTANT: VK_F5             HEX: 74
CONSTANT: VK_F6             HEX: 75
CONSTANT: VK_F7             HEX: 76
CONSTANT: VK_F8             HEX: 77
CONSTANT: VK_F9             HEX: 78
CONSTANT: VK_F10            HEX: 79
CONSTANT: VK_F11            HEX: 7A
CONSTANT: VK_F12            HEX: 7B
CONSTANT: VK_F13            HEX: 7C
CONSTANT: VK_F14            HEX: 7D
CONSTANT: VK_F15            HEX: 7E
CONSTANT: VK_F16            HEX: 7F
CONSTANT: VK_F17            HEX: 80
CONSTANT: VK_F18            HEX: 81
CONSTANT: VK_F19            HEX: 82
CONSTANT: VK_F20            HEX: 83
CONSTANT: VK_F21            HEX: 84
CONSTANT: VK_F22            HEX: 85
CONSTANT: VK_F23            HEX: 86
CONSTANT: VK_F24            HEX: 87

! 0x88 - 0x8F : unassigned

CONSTANT: VK_NUMLOCK        HEX: 90
CONSTANT: VK_SCROLL         HEX: 91

! NEC PC-9800 kbd definitions
CONSTANT: VK_OEM_NEC_EQUAL  HEX: 92  ! '=' key on numpad

! Fujitsu/OASYS kbd definitions
CONSTANT: VK_OEM_FJ_JISHO   HEX: 92  ! 'Dictionary' key
CONSTANT: VK_OEM_FJ_MASSHOU HEX: 93  ! 'Unregister word' key
CONSTANT: VK_OEM_FJ_TOUROKU HEX: 94  ! 'Register word' key
CONSTANT: VK_OEM_FJ_LOYA    HEX: 95  ! 'Left OYAYUBI' key
CONSTANT: VK_OEM_FJ_ROYA    HEX: 96  ! 'Right OYAYUBI' key

! 0x97 - 0x9F : unassigned

! VK_L* & VK_R* - left and right Alt, Ctrl and Shift virtual keys.
! Used only as parameters to GetAsyncKeyState() and GetKeyState().
! No other API or message will distinguish left and right keys in this way.
CONSTANT: VK_LSHIFT         HEX: A0
CONSTANT: VK_RSHIFT         HEX: A1
CONSTANT: VK_LCONTROL       HEX: A2
CONSTANT: VK_RCONTROL       HEX: A3
CONSTANT: VK_LMENU          HEX: A4
CONSTANT: VK_RMENU          HEX: A5

CONSTANT: VK_BROWSER_BACK        HEX: A6
CONSTANT: VK_BROWSER_FORWARD     HEX: A7
CONSTANT: VK_BROWSER_REFRESH     HEX: A8
CONSTANT: VK_BROWSER_STOP        HEX: A9
CONSTANT: VK_BROWSER_SEARCH      HEX: AA
CONSTANT: VK_BROWSER_FAVORITES   HEX: AB
CONSTANT: VK_BROWSER_HOME        HEX: AC

CONSTANT: VK_VOLUME_MUTE         HEX: AD
CONSTANT: VK_VOLUME_DOWN         HEX: AE
CONSTANT: VK_VOLUME_UP           HEX: AF
CONSTANT: VK_MEDIA_NEXT_TRACK    HEX: B0
CONSTANT: VK_MEDIA_PREV_TRACK    HEX: B1
CONSTANT: VK_MEDIA_STOP          HEX: B2
CONSTANT: VK_MEDIA_PLAY_PAUSE    HEX: B3
CONSTANT: VK_LAUNCH_MAIL         HEX: B4
CONSTANT: VK_LAUNCH_MEDIA_SELECT HEX: B5
CONSTANT: VK_LAUNCH_APP1         HEX: B6
CONSTANT: VK_LAUNCH_APP2         HEX: B7

! 0xB8 - 0xB9 : reserved

CONSTANT: VK_OEM_1          HEX: BA  ! ';:' for US
CONSTANT: VK_OEM_PLUS       HEX: BB  ! '+' any country
CONSTANT: VK_OEM_COMMA      HEX: BC  ! ',' any country
CONSTANT: VK_OEM_MINUS      HEX: BD  ! '-' any country
CONSTANT: VK_OEM_PERIOD     HEX: BE  ! '.' any country
CONSTANT: VK_OEM_2          HEX: BF  ! '/?' for US
CONSTANT: VK_OEM_3          HEX: C0  ! '`~' for US

! 0xC1 - 0xD7 : reserved

! 0xD8 - 0xDA : unassigned

CONSTANT: VK_OEM_4          HEX: DB !  '[{' for US
CONSTANT: VK_OEM_5          HEX: DC !  '\|' for US
CONSTANT: VK_OEM_6          HEX: DD !  ']}' for US
CONSTANT: VK_OEM_7          HEX: DE !  ''"' for US
CONSTANT: VK_OEM_8          HEX: DF

! 0xE0 : reserved

! Various extended or enhanced keyboards
CONSTANT: VK_OEM_AX         HEX: E1 !  'AX' key on Japanese AX kbd
CONSTANT: VK_OEM_102        HEX: E2 !  "<>" or "\|" on RT 102-key kbd.
CONSTANT: VK_ICO_HELP       HEX: E3 !  Help key on ICO
CONSTANT: VK_ICO_00         HEX: E4 !  00 key on ICO

CONSTANT: VK_PROCESSKEY     HEX: E5

CONSTANT: VK_ICO_CLEAR      HEX: E6

CONSTANT: VK_PACKET         HEX: E7

! 0xE8 : unassigned

! Nokia/Ericsson definitions
CONSTANT: VK_OEM_RESET      HEX: E9
CONSTANT: VK_OEM_JUMP       HEX: EA
CONSTANT: VK_OEM_PA1        HEX: EB
CONSTANT: VK_OEM_PA2        HEX: EC
CONSTANT: VK_OEM_PA3        HEX: ED
CONSTANT: VK_OEM_WSCTRL     HEX: EE
CONSTANT: VK_OEM_CUSEL      HEX: EF
CONSTANT: VK_OEM_ATTN       HEX: F0
CONSTANT: VK_OEM_FINISH     HEX: F1
CONSTANT: VK_OEM_COPY       HEX: F2
CONSTANT: VK_OEM_AUTO       HEX: F3
CONSTANT: VK_OEM_ENLW       HEX: F4
CONSTANT: VK_OEM_BACKTAB    HEX: F5

CONSTANT: VK_ATTN           HEX: F6
CONSTANT: VK_CRSEL          HEX: F7
CONSTANT: VK_EXSEL          HEX: F8
CONSTANT: VK_EREOF          HEX: F9
CONSTANT: VK_PLAY           HEX: FA
CONSTANT: VK_ZOOM           HEX: FB
CONSTANT: VK_NONAME         HEX: FC
CONSTANT: VK_PA1            HEX: FD
CONSTANT: VK_OEM_CLEAR      HEX: FE
! 0xFF : reserved

! Key State Masks for Mouse Messages
CONSTANT: MK_LBUTTON          HEX: 0001
CONSTANT: MK_RBUTTON          HEX: 0002
CONSTANT: MK_SHIFT            HEX: 0004
CONSTANT: MK_CONTROL          HEX: 0008
CONSTANT: MK_MBUTTON          HEX: 0010
CONSTANT: MK_XBUTTON1         HEX: 0020
CONSTANT: MK_XBUTTON2         HEX: 0040

! Some fields are not defined for win64
! Window field offsets for GetWindowLong()
CONSTANT: GWL_WNDPROC         -4
CONSTANT: GWL_HINSTANCE       -6
CONSTANT: GWL_HWNDPARENT      -8
CONSTANT: GWL_USERDATA        -21
CONSTANT: GWL_ID              -12

CONSTANT: GWL_STYLE           -16
CONSTANT: GWL_EXSTYLE         -20

CONSTANT: GWLP_WNDPROC        -4
CONSTANT: GWLP_HINSTANCE      -6
CONSTANT: GWLP_HWNDPARENT     -8
CONSTANT: GWLP_USERDATA       -21
CONSTANT: GWLP_ID             -12

! Class field offsets for GetClassLong()
CONSTANT: GCL_MENUNAME        -8
CONSTANT: GCL_HBRBACKGROUND   -10
CONSTANT: GCL_HCURSOR         -12
CONSTANT: GCL_HICON           -14
CONSTANT: GCL_HMODULE         -16
CONSTANT: GCL_WNDPROC         -24
CONSTANT: GCL_HICONSM         -34
CONSTANT: GCL_CBWNDEXTRA      -18
CONSTANT: GCL_CBCLSEXTRA      -20
CONSTANT: GCL_STYLE           -26
CONSTANT: GCW_ATOM            -32

CONSTANT: GCLP_MENUNAME       -8
CONSTANT: GCLP_HBRBACKGROUND  -10
CONSTANT: GCLP_HCURSOR        -12
CONSTANT: GCLP_HICON          -14
CONSTANT: GCLP_HMODULE        -16
CONSTANT: GCLP_WNDPROC        -24
CONSTANT: GCLP_HICONSM        -34

CONSTANT: MB_ICONASTERISK    HEX: 00000040
CONSTANT: MB_ICONEXCLAMATION HEX: 00000030
CONSTANT: MB_ICONHAND        HEX: 00000010
CONSTANT: MB_ICONQUESTION    HEX: 00000020
CONSTANT: MB_OK              HEX: 00000000

ALIAS: FVIRTKEY TRUE
CONSTANT: FNOINVERT 2
CONSTANT: FSHIFT 4
CONSTANT: FCONTROL 8
CONSTANT: FALT 16

CONSTANT: MAPVK_VK_TO_VSC 0
CONSTANT: MAPVK_VSC_TO_VK 1
CONSTANT: MAPVK_VK_TO_CHAR 2
CONSTANT: MAPVK_VSC_TO_VK_EX 3
CONSTANT: MAPVK_VK_TO_VSC_EX 3

CONSTANT: TME_HOVER 1
CONSTANT: TME_LEAVE 2
CONSTANT: TME_NONCLIENT 16
CONSTANT: TME_QUERY HEX: 40000000
CONSTANT: TME_CANCEL HEX: 80000000
CONSTANT: HOVER_DEFAULT HEX: ffffffff
C-STRUCT: TRACKMOUSEEVENT
    { "DWORD" "cbSize" }
    { "DWORD" "dwFlags" }
    { "HWND" "hwndTrack" }
    { "DWORD" "dwHoverTime" } ;
TYPEDEF: TRACKMOUSEEVENT* LPTRACKMOUSEEVENT

CONSTANT: DBT_DEVICEARRIVAL HEX: 8000
CONSTANT: DBT_DEVICEREMOVECOMPLETE HEX: 8004

CONSTANT: DBT_DEVTYP_DEVICEINTERFACE 5

CONSTANT: DEVICE_NOTIFY_WINDOW_HANDLE 0
CONSTANT: DEVICE_NOTIFY_SERVICE_HANDLE 1

CONSTANT: DEVICE_NOTIFY_ALL_INTERFACE_CLASSES 4

C-STRUCT: DEV_BROADCAST_HDR
    { "DWORD" "dbch_size" }
    { "DWORD" "dbch_devicetype" }
    { "DWORD" "dbch_reserved" } ;

C-STRUCT: DEV_BROADCAST_DEVICEW
    { "DWORD" "dbcc_size" }
    { "DWORD" "dbcc_devicetype" }
    { "DWORD" "dbcc_reserved" }
    { "GUID"  "dbcc_classguid" }
    { { "WCHAR" 1 } "dbcc_name" } ;

CONSTANT: CCHDEVICENAME 32

C-STRUCT: MONITORINFOEX
    { "DWORD" "cbSize" }
    { "RECT"  "rcMonitor" }
    { "RECT"  "rcWork" }
    { "DWORD" "dwFlags" }
    { { "TCHAR" CCHDEVICENAME } "szDevice" } ;

TYPEDEF: MONITORINFOEX* LPMONITORINFOEX
TYPEDEF: MONITORINFOEX* LPMONITORINFO

CONSTANT: MONITOR_DEFAULTTONULL 0
CONSTANT: MONITOR_DEFAULTTOPRIMARY 1
CONSTANT: MONITOR_DEFAULTTONEAREST 2
CONSTANT: MONITORINFOF_PRIMARY 1
CONSTANT: SWP_NOSIZE 1
CONSTANT: SWP_NOMOVE 2
CONSTANT: SWP_NOZORDER 4
CONSTANT: SWP_NOREDRAW 8
CONSTANT: SWP_NOACTIVATE 16
CONSTANT: SWP_FRAMECHANGED 32
CONSTANT: SWP_SHOWWINDOW 64
CONSTANT: SWP_HIDEWINDOW 128
CONSTANT: SWP_NOCOPYBITS 256
CONSTANT: SWP_NOOWNERZORDER 512
CONSTANT: SWP_NOSENDCHANGING 1024
CONSTANT: SWP_DRAWFRAME SWP_FRAMECHANGED
CONSTANT: SWP_NOREPOSITION SWP_NOOWNERZORDER
CONSTANT: SWP_DEFERERASE 8192
CONSTANT: SWP_ASYNCWINDOWPOS 16384


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
FUNCTION: HWND ChildWindowFromPoint ( HWND hWndParent, POINT point ) ;
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
FUNCTION: int CopyAcceleratorTableW ( HACCEL hAccelSrc, LPACCEL lpAccelDst, int cAccelEntries ) ;
ALIAS: CopyAcceleratorTable CopyAcceleratorTableW
! FUNCTION: CopyIcon
! FUNCTION: CopyImage
! FUNCTION: CopyRect
! FUNCTION: CountClipboardFormats
! FUNCTION: CreateAcceleratorTableA
FUNCTION: HACCEL CreateAcceleratorTableW ( LPACCEL lpaccl, int cEntries ) ;
ALIAS: CreateAcceleratorTable CreateAcceleratorTableW
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

FUNCTION: HWND CreateWindowExW (
                DWORD dwExStyle,
                LPCTSTR lpClassName,
                LPCTSTR lpWindowName,
                DWORD dwStyle,
                uint X,
                uint Y,
                uint nWidth,
                uint nHeight,
                HWND hWndParent,
                HMENU hMenu,
                HINSTANCE hInstance,
                LPVOID lpParam ) ;

ALIAS: CreateWindowEx CreateWindowExW

: CreateWindow ( a b c d e f g h i j k -- hwnd ) 0 12 -nrot CreateWindowEx ; inline

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
FUNCTION: LRESULT DefWindowProcW ( HWND hWnd, UINT Msg, WPARAM wParam, LPARAM lParam ) ;
ALIAS: DefWindowProc DefWindowProcW
! FUNCTION: DeleteMenu
! FUNCTION: DeregisterShellHookWindow
FUNCTION: BOOL DestroyAcceleratorTable ( HACCEL hAccel ) ;
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

FUNCTION: LONG DispatchMessageW ( MSG* lpMsg ) ;
ALIAS: DispatchMessage DispatchMessageW

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

FUNCTION: BOOL DrawIcon ( HDC hDC, int X, int Y, HICON hIcon ) ;

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
FUNCTION: int FillRect ( HDC hDC, RECT* lprc, HBRUSH hbr ) ;
FUNCTION: HWND FindWindowA ( char* lpClassName, char* lpWindowName ) ;
FUNCTION: HWND FindWindowExA ( HWND hwndParent, HWND childAfter, char* lpClassName, char* lpWindowName ) ;
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
FUNCTION: BOOL GetClassInfoW ( HINSTANCE hInst, LPCWSTR lpszClass, LPWNDCLASS lpwcx ) ;
ALIAS: GetClassInfo GetClassInfoW

FUNCTION: BOOL GetClassInfoExW ( HINSTANCE hInst, LPCWSTR lpszClass, LPWNDCLASSEX lpwcx ) ;
ALIAS: GetClassInfoEx GetClassInfoExW

FUNCTION: ULONG_PTR GetClassLongW ( HWND hWnd, int nIndex ) ;
ALIAS: GetClassLong GetClassLongW
ALIAS: GetClassLongPtr GetClassLongW


! FUNCTION: GetClassNameA
! FUNCTION: GetClassNameW
! FUNCTION: GetClassWord
FUNCTION: BOOL GetClientRect ( HWND hWnd, LPRECT lpRect ) ;

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
FUNCTION: uint GetDoubleClickTime ( ) ;
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

FUNCTION: BOOL GetMessageW ( LPMSG lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax ) ;
ALIAS: GetMessage GetMessageW

! FUNCTION: GetMessageExtraInfo
! FUNCTION: GetMessagePos
! FUNCTION: GetMessageTime
! FUNCTION: GetMonitorInfoA

FUNCTION: BOOL GetMonitorInfoW ( HMONITOR hMonitor, LPMONITORINFO lpmi ) ;
ALIAS: GetMonitorInfo GetMonitorInfoW

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
FUNCTION: LONG_PTR GetWindowLongW ( HANDLE hWnd, int index ) ;
ALIAS: GetWindowLong GetWindowLongW
! FUNCTION: GetWindowModuleFileName
! FUNCTION: GetWindowModuleFileNameA
! FUNCTION: GetWindowModuleFileNameW
! FUNCTION: GetWindowPlacement
FUNCTION: BOOL GetWindowRect ( HWND hWnd, LPRECT lpRect ) ;
! FUNCTION: GetWindowRgn
! FUNCTION: GetWindowRgnBox
FUNCTION: int GetWindowTextA ( HWND hWnd, char* lpString, int nMaxCount ) ;
! FUNCTION: GetWindowTextLengthA
! FUNCTION: GetWindowTextLengthW
! FUNCTION: GetWindowTextW
FUNCTION: DWORD GetWindowThreadProcessId ( HWND hWnd, void* lpdwProcessId ) ;
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
FUNCTION: HACCEL LoadAcceleratorsW ( HINSTANCE hInstance, LPCTSTR lpTableName ) ;
! FUNCTION: LoadBitmapA
! FUNCTION: LoadBitmapW
! FUNCTION: LoadCursorFromFileA
! FUNCTION: LoadCursorFromFileW


! FUNCTION: HCURSOR LoadCursorW ( HINSTANCE hInstance, LPCWSTR lpCursorName ) ;
FUNCTION: HCURSOR LoadCursorW ( HINSTANCE hInstance, ushort lpCursorName ) ;
ALIAS: LoadCursor LoadCursorW

! FUNCTION: HICON LoadIconA ( HINSTANCE hInstance, LPCTSTR lpIconName ) ;
FUNCTION: HICON LoadIconW ( HINSTANCE hInstance, LPCTSTR lpIconName ) ;
ALIAS: LoadIcon LoadIconW

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

FUNCTION: UINT MapVirtualKeyW ( UINT uCode, UINT uMapType ) ;
ALIAS: MapVirtualKey MapVirtualKeyW

FUNCTION: UINT MapVirtualKeyExW ( UINT uCode, UINT uMapType, HKL dwhkl ) ;
ALIAS: MapVirtualKeyEx MapVirtualKeyExW

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

! FUNCTION: int MessageBoxIndirectA ( MSGBOXPARAMSA* params ) ;
! FUNCTION: int MessageBoxIndirectW ( MSGBOXPARAMSW* params ) ;


ALIAS: MessageBox MessageBoxW

ALIAS: MessageBoxEx MessageBoxExW

! : MessageBoxIndirect
    ! \ MessageBoxIndirectW \ MessageBoxIndirectA unicode-exec ;

! FUNCTION: MessageBoxTimeoutA ! dllexported, not in header
! FUNCTION: MessageBoxTimeoutW ! dllexported, not in header

! FUNCTION: ModifyMenuA
! FUNCTION: ModifyMenuW
! FUNCTION: MonitorFromPoint
! FUNCTION: MonitorFromRect
FUNCTION: HMONITOR MonitorFromWindow ( HWND hWnd, DWORD dwFlags ) ;
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
ALIAS: PeekMessage PeekMessageW

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

FUNCTION: ATOM RegisterClassA ( WNDCLASS* lpWndClass ) ;
FUNCTION: ATOM RegisterClassW ( WNDCLASS* lpWndClass ) ;
FUNCTION: ATOM RegisterClassExA ( WNDCLASSEX* lpwcx ) ;
FUNCTION: ATOM RegisterClassExW ( WNDCLASSEX* lpwcx ) ;

ALIAS: RegisterClass RegisterClassW
ALIAS: RegisterClassEx RegisterClassExW

! FUNCTION: RegisterClipboardFormatA
! FUNCTION: RegisterClipboardFormatW
FUNCTION: HANDLE RegisterDeviceNotificationA ( HANDLE hRecipient, LPVOID NotificationFilter, DWORD Flags ) ;
FUNCTION: HANDLE RegisterDeviceNotificationW ( HANDLE hRecipient, LPVOID NotificationFilter, DWORD Flags ) ;
ALIAS: RegisterDeviceNotification RegisterDeviceNotificationW
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
FUNCTION: LRESULT SendMessageW ( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam ) ;
ALIAS: SendMessage SendMessageW
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
ALIAS: SetClassLongPtr SetClassLongW
ALIAS: SetClassLong SetClassLongW

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
: SetLastError ( errcode -- ) 0 SetLastErrorEx ; inline
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
FUNCTION: LONG_PTR SetWindowLongW ( HANDLE hWnd, int index, LONG_PTR dwNewLong ) ;
ALIAS: SetWindowLong SetWindowLongW
! FUNCTION: SetWindowPlacement
FUNCTION: BOOL SetWindowPos ( HWND hWnd, HWND hWndInsertAfter, int X, int Y, int cx, int cy, UINT uFlags ) ;

: HWND_BOTTOM ( -- alien ) 1 <alien> ;
: HWND_NOTOPMOST ( -- alien ) -2 <alien> ;
CONSTANT: HWND_TOP f
: HWND_TOPMOST ( -- alien ) -1 <alien> ;

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
FUNCTION: BOOL TrackMouseEvent ( LPTRACKMOUSEEVENT lpEventTrack ) ;
! FUNCTION: TrackPopupMenu
! FUNCTION: TrackPopupMenuEx
! FUNCTION: TranslateAccelerator
! FUNCTION: TranslateAcceleratorA
FUNCTION: int TranslateAcceleratorW ( HWND hWnd, HACCEL hAccTable, LPMSG lpMsg ) ;
ALIAS: TranslateAccelerator TranslateAcceleratorW

! FUNCTION: TranslateMDISysAccel
FUNCTION: BOOL TranslateMessage ( MSG* lpMsg ) ;

! FUNCTION: UnhookWindowsHook
! FUNCTION: UnhookWindowsHookEx
! FUNCTION: UnhookWinEvent
! FUNCTION: UnionRect
! FUNCTION: UnloadKeyboardLayout
! FUNCTION: UnlockWindowStation
! FUNCTION: UnpackDDElParam
FUNCTION: BOOL UnregisterClassW ( LPCWSTR lpClassName, HINSTANCE hInstance ) ;
ALIAS: UnregisterClass UnregisterClassW
FUNCTION: BOOL UnregisterDeviceNotification ( HANDLE hDevNotify ) ;
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

: msgbox ( str -- )
    f swap "DebugMsg" MB_OK MessageBox drop ;
