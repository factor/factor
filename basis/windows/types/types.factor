! Copyright (C) 2005, 2006 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct colors
io.encodings.utf16 io.encodings.utf8 kernel math math.bitwise
math.functions math.vectors sequences ;
FROM: alien.c-types => float short ;
IN: windows.types

TYPEDEF: char                CHAR
TYPEDEF: uchar               UCHAR
TYPEDEF: uchar               BYTE

TYPEDEF: ushort              wchar_t

TYPEDEF: wchar_t             WCHAR

TYPEDEF: short               SHORT
TYPEDEF: ushort              USHORT
TYPEDEF: short               INT16
TYPEDEF: ushort              UINT16

TYPEDEF: ushort              WORD
TYPEDEF: ulong               DWORD

TYPEDEF: int                 INT
TYPEDEF: uint                UINT

TYPEDEF: int                 BOOL

TYPEDEF: int*                PINT
TYPEDEF: int*                LPINT
TYPEDEF: int                 HFILE

TYPEDEF: long                LONG
TYPEDEF: long*               LPLONG
TYPEDEF: intptr_t            LONG_PTR

TYPEDEF: uint                ULONG
TYPEDEF: uintptr_t           ULONG_PTR

TYPEDEF: void                VOID
TYPEDEF: void*               PVOID
TYPEDEF: void*               LPVOID
TYPEDEF: void*               LPCVOID

TYPEDEF: float               FLOAT

TYPEDEF: intptr_t    HALF_PTR
TYPEDEF: intptr_t    UHALF_PTR
TYPEDEF: intptr_t    INT_PTR
TYPEDEF: intptr_t    UINT_PTR

TYPEDEF: int         INT32
TYPEDEF: uint        UINT32
TYPEDEF: uint        DWORD32
TYPEDEF: long        LONG32
TYPEDEF: ulong       ULONG32
TYPEDEF: ulonglong   ULONG64
TYPEDEF: long*       POINTER_32
TYPEDEF: longlong*   POINTER_64
TYPEDEF: longlong    INT64
TYPEDEF: ulonglong   UINT64
TYPEDEF: longlong    LONGLONG
TYPEDEF: ulonglong   ULONGLONG
TYPEDEF: longlong    LONG64
TYPEDEF: ulonglong   DWORD64
TYPEDEF: longlong    LARGE_INTEGER
TYPEDEF: ulonglong   ULARGE_INTEGER
TYPEDEF: LARGE_INTEGER* PLARGE_INTEGER
TYPEDEF: ULARGE_INTEGER* PULARGE_INTEGER
TYPEDEF: size_t SIZE_T
TYPEDEF: ptrdiff_t SSIZE_T

TYPEDEF: { c-string utf16n } LPCSTR
TYPEDEF: { c-string utf16n } LPTCSTR

TYPEDEF: { c-string utf16n } LPWSTR
TYPEDEF: WCHAR       TCHAR
TYPEDEF: LPWSTR      LPTCH
TYPEDEF: LPWSTR      PTCH
TYPEDEF: TCHAR       TBYTE

TYPEDEF: WORD                ATOM
TYPEDEF: BYTE                BOOLEAN
TYPEDEF: ULONGLONG           DWORDLONG
TYPEDEF: ULONG_PTR           DWORD_PTR
TYPEDEF: PVOID               HANDLE
TYPEDEF: HANDLE              HACCEL
TYPEDEF: HANDLE              HBITMAP
TYPEDEF: HANDLE              HBRUSH
TYPEDEF: HANDLE              HCOLORSPACE
TYPEDEF: HANDLE              HCONV
TYPEDEF: HANDLE              HCONVLIST
TYPEDEF: HANDLE              HICON
TYPEDEF: HICON               HCURSOR
TYPEDEF: HANDLE              HDC
TYPEDEF: HANDLE              HDDEDATA
TYPEDEF: HANDLE              HDESK
TYPEDEF: HANDLE              HDROP
TYPEDEF: HANDLE              HDWP
TYPEDEF: HANDLE              HENHMETAFILE
TYPEDEF: HANDLE              HFONT
TYPEDEF: HANDLE              HGDIOBJ
TYPEDEF: HANDLE              HGLOBAL
TYPEDEF: HANDLE              HHOOK
TYPEDEF: HANDLE              HINSTANCE
TYPEDEF: DWORD               HKEY
TYPEDEF: HANDLE              HKL
TYPEDEF: HANDLE              HLOCAL
TYPEDEF: HANDLE              HMENU
TYPEDEF: HANDLE              HMETAFILE
TYPEDEF: HANDLE              HMETAFILEPICT
TYPEDEF: HINSTANCE           HMODULE
TYPEDEF: HANDLE              HMONITOR
TYPEDEF: HANDLE              HPALETTE
TYPEDEF: HANDLE              HPEN
TYPEDEF: LONG                HRESULT
TYPEDEF: HANDLE              HRGN
TYPEDEF: HANDLE              HRSRC
TYPEDEF: HANDLE              HSZ
TYPEDEF: HANDLE              WINSTA   ! MS docs say  typedef HANDLE WINSTA ;
TYPEDEF: HANDLE              HWINSTA  ! typo??
TYPEDEF: HANDLE              HWND
TYPEDEF: HANDLE              HCRYPTPROV
TYPEDEF: WORD                LANGID
TYPEDEF: DWORD               LCID
TYPEDEF: DWORD               LCTYPE
TYPEDEF: DWORD               LGRPID
TYPEDEF: LONG_PTR            LPARAM
TYPEDEF: BOOL*               LPBOOL
TYPEDEF: BYTE*               LPBYTE

TYPEDEF: { c-string utf16n } LPCWSTR
! TYPEDEF: WCHAR*              LPWSTR

TYPEDEF: { c-string utf8 } LPSTR
TYPEDEF: { c-string utf16n } LPCTSTR
TYPEDEF: { c-string utf16n } LPWTSTR
TYPEDEF: { c-string utf16n } LPTSTR
TYPEDEF: LPCSTR      PCTSTR
TYPEDEF: LPSTR       PTSTR

TYPEDEF: DWORD*              LPDWORD
TYPEDEF: HANDLE*             LPHANDLE
TYPEDEF: WORD*               LPWORD
TYPEDEF: LONG_PTR            LRESULT
TYPEDEF: BOOL*               PBOOL
TYPEDEF: BOOLEAN*            PBOOLEAN
TYPEDEF: BYTE*               PBYTE
TYPEDEF: CHAR*               PCHAR
TYPEDEF: CHAR*               PCSTR
TYPEDEF: { c-string utf16n } PCWSTR
TYPEDEF: DWORD*              PDWORD
TYPEDEF: DWORDLONG*          PDWORDLONG
TYPEDEF: DWORD_PTR*          PDWORD_PTR
TYPEDEF: DWORD32*            PDWORD32
TYPEDEF: DWORD64*            PDWORD64
TYPEDEF: FLOAT*              PFLOAT
TYPEDEF: HALF_PTR*           PHALF_PTR
TYPEDEF: HANDLE*             PHANDLE
TYPEDEF: HKEY*               PHKEY
TYPEDEF: INT_PTR*            PINT_PTR
TYPEDEF: INT32*              PINT32
TYPEDEF: INT64*              PINT64
TYPEDEF: PDWORD              PLCID
TYPEDEF: LONG*               PLONG
TYPEDEF: LONGLONG*           PLONGLONG
TYPEDEF: LONG_PTR*           PLONG_PTR
TYPEDEF: LONG32*             PLONG32
TYPEDEF: LONG64*             PLONG64
TYPEDEF: SHORT*              PSHORT
TYPEDEF: SIZE_T*             PSIZE_T
TYPEDEF: SSIZE_T*            PSSIZE_T
TYPEDEF: CHAR*               PSTR
TYPEDEF: TBYTE*              PTBYTE
TYPEDEF: TCHAR*              PTCHAR
TYPEDEF: UCHAR*              PUCHAR
TYPEDEF: UHALF_PTR*          PUHALF_PTR
TYPEDEF: UINT*               PUINT
TYPEDEF: UINT_PTR*           PUINT_PTR
TYPEDEF: UINT32*             PUINT32
TYPEDEF: UINT64*             PUINT64
TYPEDEF: ULONG*              PULONG
TYPEDEF: ULONGLONG*          PULONGLONG
TYPEDEF: ULONG_PTR*          PULONG_PTR
TYPEDEF: ULONG32*            PULONG32
TYPEDEF: ULONG64*            PULONG64
TYPEDEF: USHORT*             PUSHORT
TYPEDEF: { c-string utf16n } PWCHAR
TYPEDEF: WORD*               PWORD
TYPEDEF: { c-string utf16n } PWSTR
TYPEDEF: HANDLE              SC_HANDLE
TYPEDEF: LPVOID              SC_LOCK
TYPEDEF: HANDLE              SERVICE_STATUS_HANDLE
TYPEDEF: LONGLONG            USN
TYPEDEF: UINT_PTR            WPARAM
TYPEDEF: DWORD               ACCESS_MASK
TYPEDEF: ACCESS_MASK*        PACCESS_MASK

TYPEDEF: size_t socklen_t

TYPEDEF: void* WNDPROC

CONSTANT: FALSE 0
CONSTANT: TRUE 1

: >BOOLEAN ( ? -- 1/0 ) TRUE FALSE ? ; inline

! typedef LRESULT (CALLBACK* WNDPROC)(HWND, UINT, WPARAM, LPARAM);

STRUCT: WNDCLASS
    { style UINT }
    { lpfnWndProc WNDPROC }
    { cbClsExtra int }
    { cbWndExtra int }
    { hInstance HINSTANCE }
    { hIcon HICON }
    { hCursor HCURSOR }
    { hbrBackground HBRUSH }
    { lpszMenuName LPCTSTR }
    { lpszClassName LPCTSTR } ;

STRUCT: WNDCLASSEX
    { cbSize UINT }
    { style UINT }
    { lpfnWndProc WNDPROC }
    { cbClsExtra int }
    { cbWndExtra int }
    { hInstance HINSTANCE }
    { hIcon HICON }
    { hCursor HCURSOR }
    { hbrBackground HBRUSH }
    { lpszMenuName LPCTSTR }
    { lpszClassName LPCTSTR }
    { hIconSm HICON } ;

STRUCT: RECT
    { left LONG }
    { top LONG }
    { right LONG }
    { bottom LONG } ;

STRUCT: PAINTSTRUCT
    { hdc HDC }
    { fErase BOOL }
    { rcPaint RECT }
    { fRestore BOOL }
    { fIncUpdate BOOL }
    { rgbReserved BYTE[32] } ;

STRUCT: BITMAPINFOHEADER
    { biSize DWORD }
    { biWidth LONG }
    { biHeight LONG }
    { biPlanes WORD }
    { biBitCount WORD }
    { biCompression DWORD }
    { biSizeImage DWORD }
    { biXPelsPerMeter LONG }
    { biYPelsPerMeter LONG }
    { biClrUsed DWORD }
    { biClrImportant DWORD } ;

STRUCT: RGBQUAD
    { rgbBlue BYTE }
    { rgbGreen BYTE }
    { rgbRed BYTE }
    { rgbReserved BYTE } ;

STRUCT: BITMAPINFO
    { bmiHeader BITMAPINFOHEADER }
    { bimColors RGBQUAD[1] } ;

TYPEDEF: void* LPPAINTSTRUCT
TYPEDEF: void* PAINTSTRUCT

STRUCT: POINT
    { x LONG }
    { y LONG } ;
TYPEDEF: POINT* LPPOINT

STRUCT: SIZE
    { cx LONG }
    { cy LONG } ;

STRUCT: MSG
    { hWnd HWND }
    { message UINT }
    { wParam WPARAM }
    { lParam LPARAM }
    { time DWORD }
    { pt POINT } ;

TYPEDEF: MSG*                LPMSG

STRUCT: PIXELFORMATDESCRIPTOR
    { nSize WORD }
    { nVersion WORD }
    { dwFlags DWORD }
    { iPixelType BYTE }
    { cColorBits BYTE }
    { cRedBits BYTE }
    { cRedShift BYTE }
    { cGreenBits BYTE }
    { cGreenShift BYTE }
    { cBlueBits BYTE }
    { cBlueShift BYTE }
    { cAlphaBits BYTE }
    { cAlphaShift BYTE }
    { cAccumBits BYTE }
    { cAccumRedBits BYTE }
    { cAccumGreenBits BYTE }
    { cAccumBlueBits BYTE }
    { cAccumAlphaBits BYTE }
    { cDepthBits BYTE }
    { cStencilBits BYTE }
    { cAuxBuffers BYTE }
    { iLayerType BYTE }
    { bReserved BYTE }
    { dwLayerMask DWORD }
    { dwVisibleMask DWORD }
    { dwDamageMask DWORD } ;

: <RECT> ( loc dim -- RECT )
    dupd v+ [ first2 ] bi@ RECT boa ;

TYPEDEF: RECT* PRECT
TYPEDEF: RECT* LPRECT
TYPEDEF: PIXELFORMATDESCRIPTOR PFD
TYPEDEF: PFD* LPPFD
TYPEDEF: HANDLE HGLRC

TYPEDEF: void* PWNDCLASS
TYPEDEF: void* PWNDCLASSEX
TYPEDEF: void* LPWNDCLASS
TYPEDEF: void* LPWNDCLASSEX
TYPEDEF: void* MSGBOXPARAMSA
TYPEDEF: void* MSGBOXPARAMSW
TYPEDEF: void* LPOVERLAPPED_COMPLETION_ROUTINE

STRUCT: LVITEM
    { mask uint }
    { iItem int }
    { iSubItem int }
    { state uint }
    { stateMask uint }
    { pszText void* }
    { cchTextMax int }
    { iImage int }
    { lParam long }
    { iIndent int }
    { iGroupId int }
    { cColumns uint }
    { puColumns uint* }
    { piColFmt int* }
    { iGroup int } ;

STRUCT: LVFINDINFO
    { flags uint }
    { psz c-string }
    { lParam long }
    { pt POINT }
    { vkDirection uint } ;

STRUCT: ACCEL
    { fVirt BYTE }
    { key WORD }
    { cmd WORD } ;
TYPEDEF: ACCEL* LPACCEL

TYPEDEF: DWORD COLORREF
TYPEDEF: DWORD* LPCOLORREF

: RGB ( r g b -- COLORREF )
    { 16 8 0 } bitfield ; inline
: >RGB< ( COLORREF -- r g b )
    [           0xff bitand ]
    [  -8 shift 0xff bitand ]
    [ -16 shift 0xff bitand ] tri ;

: color>RGB ( color -- COLORREF )
    >rgba-components drop [ 255 round * >integer ] tri@ RGB ;
: RGB>color ( COLORREF -- color )
    >RGB< [ 255 /f ] tri@ 1.0 <rgba> ;

STRUCT: TEXTMETRICW
    { tmHeight LONG }
    { tmAscent LONG }
    { tmDescent LONG }
    { tmInternalLeading LONG }
    { tmExternalLeading LONG }
    { tmAveCharWidth LONG }
    { tmMaxCharWidth LONG }
    { tmWeight LONG }
    { tmOverhang LONG }
    { tmDigitizedAspectX LONG }
    { tmDigitizedAspectY LONG }
    { tmFirstChar WCHAR }
    { tmLastChar WCHAR }
    { tmDefaultChar WCHAR }
    { tmBreakChar WCHAR }
    { tmItalic BYTE }
    { tmUnderlined BYTE }
    { tmStruckOut BYTE }
    { tmPitchAndFamily BYTE }
    { tmCharSet BYTE } ;

TYPEDEF: TEXTMETRICW* LPTEXTMETRIC

TYPEDEF: ULONG PROPID

CALLBACK: BOOL WNDENUMPROC ( HWND hWnd, LPARAM lParam )
CALLBACK: LRESULT HOOKPROC ( int nCode, WPARAM wParam, LPARAM lParam )
