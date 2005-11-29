IN: win32
USE: alien

TYPEDEF: uchar               BYTE
TYPEDEF: BYTE*               PBYTE
TYPEDEF: BYTE*               LPBYTE
TYPEDEF: int                 BOOL
TYPEDEF: BOOL*               PBOOL
TYPEDEF: BOOL*               LPBOOL
TYPEDEF: int                 INT
TYPEDEF: int*                PINT
TYPEDEF: int*                LPINT
TYPEDEF: uint                UINT
TYPEDEF: uint*               PUINT
TYPEDEF: long                LONG
TYPEDEF: long*               LPLONG
TYPEDEF: float               FLOAT
TYPEDEF: FLOAT*              PFLOAT
TYPEDEF: ushort              WORD
TYPEDEF: WORD*               PWORD
TYPEDEF: WORD*               LPWORD
TYPEDEF: ulong               DWORD
TYPEDEF: long                LONG_PTR
TYPEDEF: ulong               ULONG_PTR
TYPEDEF: long*               PLONG_PTR
TYPEDEF: ulong*              PULONG_PTR
TYPEDEF: DWORD*              PDWORD
TYPEDEF: DWORD*              LPDWORD
TYPEDEF: void*               LPVOID
TYPEDEF: void*               LPCVOID
TYPEDEF: char*               LPCSTR
TYPEDEF: char*               LPCTSTR
TYPEDEF: WORD                ATOM


! TYPEDEF: ushort wchar_t
! TYPEDEF: ushort* wchar_t*
! TYPEDEF: wchar_t ushort
TYPEDEF: ushort LPCWSTR

TYPEDEF: int       HANDLE

TYPEDEF: HANDLE    HGDIOBJ
TYPEDEF: HANDLE    HKEY
TYPEDEF: HANDLE*   PHKEY
TYPEDEF: HANDLE    HACCEL
TYPEDEF: HANDLE    HBITMAP
TYPEDEF: HANDLE    HBRUSH
TYPEDEF: HANDLE    HCOLORSPACE
TYPEDEF: HANDLE    HDC
TYPEDEF: HANDLE    HGLRC       ! OpenGL
TYPEDEF: HANDLE    HDESK
TYPEDEF: HANDLE    HENHMETAFILE
TYPEDEF: HANDLE    HFONT
TYPEDEF: HANDLE    HICON
TYPEDEF: HANDLE    HMENU
TYPEDEF: HANDLE    HMETAFILE
TYPEDEF: HANDLE    HINSTANCE
TYPEDEF: HINSTANCE HMODULE
TYPEDEF: HANDLE    HPALETTE
TYPEDEF: HANDLE    HPEN
TYPEDEF: HANDLE    HRGN
TYPEDEF: HANDLE    HRSRC
TYPEDEF: HANDLE    HSTR
TYPEDEF: HANDLE    HTASK
TYPEDEF: HANDLE    HWINSTA
TYPEDEF: HANDLE    HWND
TYPEDEF: HANDLE    HKL
TYPEDEF: HANDLE    HCURSOR

TYPEDEF: RECT* LPRECT
TYPEDEF: void* PWNDCLASS
TYPEDEF: void* PWNDCLASSEX

TYPEDEF: void* WNDPROC

! typedef LRESULT (CALLBACK* WNDPROC)(HWND, UINT, WPARAM, LPARAM);

BEGIN-STRUCT: WNDCLASS
    FIELD: UINT style
    FIELD: WNDPROC lpfnWndProc
    FIELD: int cbClsExtra
    FIELD: int cbWndExtra
    FIELD: HINSTANCE hInstance
    FIELD: HICON hIcon
    FIELD: HCURSOR hCursor
    FIELD: HBRUSH hbrBackground
    FIELD: LPCTSTR lpszMenuName
    FIELD: LPCTSTR lpszClassName
END-STRUCT

BEGIN-STRUCT: WNDCLASSEX
    FIELD: UINT cbSize
    FIELD: UINT style
    FIELD: WNDPROC lpfnWndProc
    FIELD: int cbClsExtra
    FIELD: int cbWndExtra
    FIELD: HINSTANCE hInstance
    FIELD: HICON hIcon
    FIELD: HCURSOR hCursor
    FIELD: HBRUSH hbrBackground
    FIELD: LPCTSTR lpszMenuName
    FIELD: LPCTSTR lpszClassName
    FIELD: HICON hIconSm
END-STRUCT

BEGIN-STRUCT: RECT
    FIELD: LONG left
    FIELD: LONG top
    FIELD: LONG right
    FIELD: LONG bottom
END-STRUCT

BEGIN-STRUCT: PAINTSTRUCT
    FIELD: HDC  hdc
    FIELD: BOOL fErase
    FIELD: RECT rcPaint
    FIELD: BOOL fRestore
    FIELD: BOOL fIncUpdate
    FIELD: BYTE rgbReserved[32]
END-STRUCT

