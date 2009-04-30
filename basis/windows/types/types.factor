! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.syntax namespaces kernel words
sequences math math.bitwise math.vectors colors ;
IN: windows.types

TYPEDEF: char                CHAR
TYPEDEF: uchar               UCHAR
TYPEDEF: uchar               BYTE

TYPEDEF: ushort              wchar_t
TYPEDEF: wchar_t             WCHAR

TYPEDEF: short               SHORT
TYPEDEF: ushort              USHORT

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
TYPEDEF: long                LONG_PTR
TYPEDEF: long*               PLONG_PTR

TYPEDEF: uint                ULONG
TYPEDEF: void*               ULONG_PTR
TYPEDEF: void*               PULONG_PTR

TYPEDEF: void                VOID
TYPEDEF: void*               PVOID
TYPEDEF: void*               LPVOID
TYPEDEF: void*               LPCVOID

TYPEDEF: float               FLOAT

TYPEDEF: intptr_t    HALF_PTR
TYPEDEF: intptr_t    UHALF_PTR
TYPEDEF: intptr_t    INT_PTR
TYPEDEF: intptr_t    UINT_PTR

TYPEDEF: int         LONG_PTR
TYPEDEF: ulong       ULONG_PTR

TYPEDEF: int         INT32
TYPEDEF: uint        UINT32
TYPEDEF: uint        DWORD32
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

TYPEDEF: wchar_t*  LPCSTR
TYPEDEF: wchar_t*  LPWSTR
TYPEDEF: WCHAR       TCHAR
TYPEDEF: LPWSTR      LPTCH
TYPEDEF: LPWSTR      PTCH
TYPEDEF: TCHAR       TBYTE

TYPEDEF: WORD                ATOM
TYPEDEF: BYTE                BOOLEAN
TYPEDEF: DWORD               COLORREF
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
TYPEDEF: HANDLE              HENMETAFILE
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
TYPEDEF: DWORD*              LPCOLORREF
TYPEDEF: WCHAR*              LPCWSTR
! TYPEDEF: WCHAR*              LPWSTR

TYPEDEF: WCHAR*               LPSTR
TYPEDEF: wchar_t* LPCTSTR
TYPEDEF: wchar_t* LPWTSTR

TYPEDEF: wchar_t*       LPTSTR
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
TYPEDEF: WCHAR*              PCWSTR
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
TYPEDEF: WCHAR*              PWCHAR
TYPEDEF: WORD*               PWORD
TYPEDEF: WCHAR*              PWSTR
TYPEDEF: HANDLE              SC_HANDLE
TYPEDEF: LPVOID              SC_LOCK
TYPEDEF: HANDLE              SERVICE_STATUS_HANDLE
TYPEDEF: ULONG_PTR           SIZE_T
TYPEDEF: LONG_PTR            SSIZE_T
TYPEDEF: LONGLONG            USN
TYPEDEF: UINT_PTR            WPARAM

TYPEDEF: RECT* LPRECT
TYPEDEF: void* PWNDCLASS
TYPEDEF: void* PWNDCLASSEX
TYPEDEF: void* LPWNDCLASS
TYPEDEF: void* LPWNDCLASSEX
TYPEDEF: void* MSGBOXPARAMSA
TYPEDEF: void* MSGBOXPARAMSW
TYPEDEF: void* LPOVERLAPPED_COMPLETION_ROUTINE

TYPEDEF: size_t socklen_t

TYPEDEF: void* WNDPROC

CONSTANT: FALSE 0
CONSTANT: TRUE 1

: >BOOLEAN ( ? -- 1/0 ) TRUE FALSE ? ; inline

! typedef LRESULT (CALLBACK* WNDPROC)(HWND, UINT, WPARAM, LPARAM);

C-STRUCT: WNDCLASS
    { "UINT" "style" }
    { "WNDPROC" "lpfnWndProc" }
    { "int" "cbClsExtra" }
    { "int" "cbWndExtra" }
    { "HINSTANCE" "hInstance" }
    { "HICON" "hIcon" }
    { "HCURSOR" "hCursor" }
    { "HBRUSH" "hbrBackground" }
    { "LPCTSTR" "lpszMenuName" }
    { "LPCTSTR" "lpszClassName" } ;

C-STRUCT: WNDCLASSEX
    { "UINT" "cbSize" }
    { "UINT" "style" }
    { "WNDPROC" "lpfnWndProc" }
    { "int" "cbClsExtra" }
    { "int" "cbWndExtra" }
    { "HINSTANCE" "hInstance" }
    { "HICON" "hIcon" }
    { "HCURSOR" "hCursor" }
    { "HBRUSH" "hbrBackground" }
    { "LPCTSTR" "lpszMenuName" }
    { "LPCTSTR" "lpszClassName" }
    { "HICON" "hIconSm" } ;

C-STRUCT: RECT
    { "LONG" "left" }
    { "LONG" "top" }
    { "LONG" "right" }
    { "LONG" "bottom" } ;

C-STRUCT: PAINTSTRUCT
    { "HDC" " hdc" }
    { "BOOL" "fErase" }
    { "RECT" "rcPaint" }
    { "BOOL" "fRestore" }
    { "BOOL" "fIncUpdate" }
    { "BYTE[32]" "rgbReserved" }
;

C-STRUCT: BITMAPINFOHEADER
    { "DWORD"  "biSize" }
    { "LONG"   "biWidth" }
    { "LONG"   "biHeight" }
    { "WORD"   "biPlanes" }
    { "WORD"   "biBitCount" }
    { "DWORD"  "biCompression" }
    { "DWORD"  "biSizeImage" }
    { "LONG"   "biXPelsPerMeter" }
    { "LONG"   "biYPelsPerMeter" }
    { "DWORD"  "biClrUsed" }
    { "DWORD"  "biClrImportant" } ;

C-STRUCT: RGBQUAD
    { "BYTE" "rgbBlue" }
    { "BYTE" "rgbGreen" }
    { "BYTE" "rgbRed" }
    { "BYTE" "rgbReserved" } ;

C-STRUCT: BITMAPINFO
    { "BITMAPINFOHEADER" "bmiHeader" }
    { "RGBQUAD[1]" "bmiColors" } ;

TYPEDEF: void* LPPAINTSTRUCT
TYPEDEF: void* PAINTSTRUCT

C-STRUCT: POINT
    { "LONG" "x" }
    { "LONG" "y" } ; 

C-STRUCT: SIZE
    { "LONG" "cx" }
    { "LONG" "cy" } ; 

C-STRUCT: MSG
    { "HWND" "hWnd" }
    { "UINT" "message" }
    { "WPARAM" "wParam" }
    { "LPARAM" "lParam" }
    { "DWORD" "time" }
    { "POINT" "pt" } ;

TYPEDEF: MSG*                LPMSG

C-STRUCT: PIXELFORMATDESCRIPTOR
    { "WORD" "nSize" }
    { "WORD" "nVersion" }
    { "DWORD" "dwFlags" }
    { "BYTE" "iPixelType" }
    { "BYTE" "cColorBits" }
    { "BYTE" "cRedBits" }
    { "BYTE" "cRedShift" }
    { "BYTE" "cGreenBits" }
    { "BYTE" "cGreenShift" }
    { "BYTE" "cBlueBits" }
    { "BYTE" "cBlueShift" }
    { "BYTE" "cAlphaBits" }
    { "BYTE" "cAlphaShift" }
    { "BYTE" "cAccumBits" }
    { "BYTE" "cAccumRedBits" }
    { "BYTE" "cAccumGreenBits" }
    { "BYTE" "cAccumBlueBits" }
    { "BYTE" "cAccumAlphaBits" }
    { "BYTE" "cDepthBits" }
    { "BYTE" "cStencilBits" }
    { "BYTE" "cAuxBuffers" }
    { "BYTE" "iLayerType" }
    { "BYTE" "bReserved" }
    { "DWORD" "dwLayerMask" }
    { "DWORD" "dwVisibleMask" }
    { "DWORD" "dwDamageMask" } ;

C-STRUCT: RECT
    { "LONG" "left" }
    { "LONG" "top" }
    { "LONG" "right" }
    { "LONG" "bottom" } ;

: <RECT> ( loc dim -- RECT )
    over v+
    "RECT" <c-object>
    over first over set-RECT-right
    swap second over set-RECT-bottom
    over first over set-RECT-left
    swap second over set-RECT-top ;

TYPEDEF: RECT* PRECT
TYPEDEF: RECT* LPRECT
TYPEDEF: PIXELFORMATDESCRIPTOR PFD
TYPEDEF: PFD* LPPFD
TYPEDEF: HANDLE HGLRC
TYPEDEF: HANDLE HRGN

C-STRUCT: LVITEM
    { "uint" "mask" }
    { "int" "iItem" }
    { "int" "iSubItem" }
    { "uint" "state" }
    { "uint" "stateMask" }
    { "void*" "pszText" }
    { "int" "cchTextMax" }
    { "int" "iImage" }
    { "long" "lParam" }
    { "int" "iIndent" }
    { "int" "iGroupId" }
    { "uint" "cColumns" }
    { "uint*" "puColumns" }
    { "int*" "piColFmt" }
    { "int" "iGroup" } ;

C-STRUCT: LVFINDINFO
    { "uint" "flags" }
    { "char*" "psz" }
    { "long" "lParam" }
    { "POINT" "pt" }
    { "uint" "vkDirection" } ;

C-STRUCT: ACCEL
    { "BYTE" "fVirt" }
    { "WORD" "key" }
    { "WORD" "cmd" } ;
TYPEDEF: ACCEL* LPACCEL

TYPEDEF: DWORD COLORREF
TYPEDEF: DWORD* LPCOLORREF

: RGB ( r g b -- COLORREF )
    { 16 8 0 } bitfield ; inline

: color>RGB ( color -- COLORREF )
    >rgba-components drop [ 255 * >integer ] tri@ RGB ;

C-STRUCT: TEXTMETRICW
    { "LONG" "tmHeight" }
    { "LONG" "tmAscent" }
    { "LONG" "tmDescent" }
    { "LONG" "tmInternalLeading" }
    { "LONG" "tmExternalLeading" }
    { "LONG" "tmAveCharWidth" }
    { "LONG" "tmMaxCharWidth" }
    { "LONG" "tmWeight" }
    { "LONG" "tmOverhang" }
    { "LONG" "tmDigitizedAspectX" }
    { "LONG" "tmDigitizedAspectY" }
    { "WCHAR" "tmFirstChar" }
    { "WCHAR" "tmLastChar" }
    { "WCHAR" "tmDefaultChar" }
    { "WCHAR" "tmBreakChar" }
    { "BYTE" "tmItalic" }
    { "BYTE" "tmUnderlined" }
    { "BYTE" "tmStruckOut" }
    { "BYTE" "tmPitchAndFamily" }
    { "BYTE" "tmCharSet" } ;

TYPEDEF: TEXTMETRICW* LPTEXTMETRIC
