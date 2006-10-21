! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien namespaces kernel words ;
IN: win32-api

! http://msdn.microsoft.com/library/default.asp?url=/library/en-us/winprog/winprog/windows_data_types.asp

SYMBOL: unicode f unicode set
: unicode-exec ( unicode-func ascii-func -- func )
	unicode get [
		drop execute
	] [
		nip execute
	] if ; inline

: unicode? unicode get ; inline

: win64? f ;

! win64
! char uchar short ushort int uint long ulong longlong ulonglong
! 1    1     2     2      *   *    ?
! win32
! char uchar short ushort int uint long ulong longlong ulonglong
! 1    1     2     2      *   *    4    4     8        8


TYPEDEF: char                CHAR
TYPEDEF: uchar               UCHAR
TYPEDEF: uchar               BYTE

TYPEDEF: short               wchar_t
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

TYPEDEF: int                 ULONG
TYPEDEF: void*               ULONG_PTR
TYPEDEF: void*               PULONG_PTR

TYPEDEF: void                VOID
TYPEDEF: void*               PVOID
TYPEDEF: void*               LPVOID
TYPEDEF: void*               LPCVOID

TYPEDEF: float               FLOAT
TYPEDEF: short       HALF_PTR
TYPEDEF: ushort      UHALF_PTR
TYPEDEF: int         INT_PTR
TYPEDEF: uint        UINT_PTR

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

TYPEDEF: uchar       TBYTE
TYPEDEF: char        TCHAR


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
TYPEDEF: HANDLE              HKEY
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
TYPEDEF: WORD                LANGID
TYPEDEF: DWORD               LCID
TYPEDEF: DWORD               LCTYPE
TYPEDEF: DWORD               LGRPID
TYPEDEF: LONG_PTR            LPARAM
TYPEDEF: BOOL*               LPBOOL
TYPEDEF: BYTE*               LPBYTE
TYPEDEF: DWORD*              LPCOLORREF
TYPEDEF: WCHAR*              LPCWSTR
TYPEDEF: WCHAR*              LPWSTR

! TYPEDEF: LPCWSTR     LPCTSTR
! TYPEDEF: LPWSTR      LPTSTR
! TYPEDEF: LPCWSTR     PCTSTR
! TYPEDEF: LPWSTR      PTSTR

TYPEDEF: WCHAR*              LPWSTR
TYPEDEF: CHAR*               LPSTR
! TYPEDEF: CHAR*               LPCSTR
TYPEDEF: VOID*               LPCSTR

TYPEDEF: LPCSTR      LPCTSTR
TYPEDEF: LPSTR       LPTSTR
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

! BEGIN-STRUCT: PAINTSTRUCT
    ! FIELD: HDC  hdc
    ! FIELD: BOOL fErase
    ! FIELD: RECT rcPaint
    ! FIELD: BOOL fRestore
    ! FIELD: BOOL fIncUpdate
    ! FIELD: BYTE[32] rgbReserved
! END-STRUCT

TYPEDEF: void* LPPAINTSTRUCT
TYPEDEF: void* PAINTSTRUCT

BEGIN-STRUCT: POINT
    FIELD: LONG x
    FIELD: LONG y
END-STRUCT 

BEGIN-STRUCT: MSG
    FIELD: HWND        hWnd
    FIELD: UINT        message
    FIELD: WPARAM      wParam
    FIELD: LPARAM      lParam
    FIELD: DWORD       time
    FIELD: POINT       pt
END-STRUCT
TYPEDEF: MSG*                LPMSG

BEGIN-STRUCT: PIXELFORMATDESCRIPTOR
  FIELD: WORD  nSize
  FIELD: WORD  nVersion
  FIELD: DWORD dwFlags 
  FIELD: BYTE  iPixelType
  FIELD: BYTE  cColorBits
  FIELD: BYTE  cRedBits
  FIELD: BYTE  cRedShift
  FIELD: BYTE  cGreenBits
  FIELD: BYTE  cGreenShift
  FIELD: BYTE  cBlueBits
  FIELD: BYTE  cBlueShift
  FIELD: BYTE  cAlphaBits
  FIELD: BYTE  cAlphaShift
  FIELD: BYTE  cAccumBits
  FIELD: BYTE  cAccumRedBits
  FIELD: BYTE  cAccumGreenBits
  FIELD: BYTE  cAccumBlueBits
  FIELD: BYTE  cAccumAlphaBits
  FIELD: BYTE  cDepthBits
  FIELD: BYTE  cStencilBits
  FIELD: BYTE  cAuxBuffers
  FIELD: BYTE  iLayerType
  FIELD: BYTE  bReserved
  FIELD: DWORD dwLayerMask
  FIELD: DWORD dwVisibleMask
  FIELD: DWORD dwDamageMask
END-STRUCT

BEGIN-STRUCT: RECT
    FIELD: LONG left
    FIELD: LONG top
    FIELD: LONG right
    FIELD: LONG bottom
END-STRUCT

TYPEDEF: RECT* PRECT
TYPEDEF: RECT* LPRECT
TYPEDEF: PIXELFORMATDESCRIPTOR PFD
TYPEDEF: PFD* LPPFD
TYPEDEF: HANDLE HGLRC
TYPEDEF: HANDLE HRGN
