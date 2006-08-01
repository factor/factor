! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien kernel errors ;
IN: win32-api

LIBRARY: kernel32

! FUNCTION: MAKEINTRESOURCEA
! FUNCTION: MAKEINTRESOURCEW

! : MAKEINTRESOURCE \ MAKEINTRESOURCEW \ MAKEINTRESOURCEA unicode-exec ;
! #define IS_INTRESOURCE(_r) (((ULONG_PTR)(_r) >> 16) == 0)
! #define MAKEINTRESOURCEA(i) (LPSTR)((ULONG_PTR)((WORD)(i)))
! #define MAKEINTRESOURCEW(i) (LPWSTR)((ULONG_PTR)((WORD)(i)))


! FUNCTION: DWORD FormatMessage(
    ! DWORD dwFlags,
    ! LPCVOID lpSource,
    ! DWORD dwMessageId,
    ! DWORD dwLanguageId,
    ! LPTSTR lpBuffer,
    ! DWORD nSize,
    ! va_list* Arguments
! ) ;


! FUNCTION: HMODULE GetModuleHandleA ( LPCTSTR lpModulename ) ;
! FUNCTION: HMODULE GetModuleHandleW ( LPCWSTR lpModulename ) ;

FUNCTION: HMODULE GetModuleHandleA ( void* lpModulename ) ;
FUNCTION: HMODULE GetModuleHandleW ( void* lpModulename ) ;

: GetModuleHandle \ GetModuleHandleW \ GetModuleHandleA unicode-exec ;


! FUNCTION: HMODULE GetModuleHandleEx (
!    DWORD dwFlags,
!    LPCTSTR lpModulename,
!    HMODULE* phModule ) ;



FUNCTION: DWORD GetLastError ( ) ;

: (win32-error) ( id -- string )
    "char*" f "error_message" [ "int" ] alien-invoke ;

: win32-error ( -- )
    GetLastError dup 0 = [ (win32-error) throw ] unless drop ;

: GHND HEX: 40 ; inline
: GMEM_FIXED 0 ; inline
: GMEM_MOVEABLE 2 ; inline
: GMEM_ZEROINIT HEX: 40 ; inline
: GPTR HEX: 40 ; inline

FUNCTION: HGLOBAL GlobalAlloc ( UINT uFlags, SIZE_T dwBytes ) ;
FUNCTION: LPVOID GlobalLock ( HGLOBAL hMem ) ;
! FUNCTION: char* GlobalLock ( HGLOBAL hMem ) ;
FUNCTION: BOOL GlobalUnlock ( HGLOBAL hMem ) ;

FUNCTION: DWORD SleepEx ( DWORD dwMilliSeconds, BOOL bAlertable ) ;


