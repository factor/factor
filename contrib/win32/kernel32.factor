IN: win32
USING: alien kernel errors ;

LIBRARY: kernel

! FUNCTION: MAKEINTRESOURCEA
! FUNCTION: MAKEINTRESOURCEW

! : MAKEINTRESOURCE \ MAKEINTRESOURCEW \ MAKEINTRESOURCEA unicode-exec ;
! #define IS_INTRESOURCE(_r) (((ULONG_PTR)(_r) >> 16) == 0)
! #define MAKEINTRESOURCEA(i) (LPSTR)((ULONG_PTR)((WORD)(i)))
! #define MAKEINTRESOURCEW(i) (LPWSTR)((ULONG_PTR)((WORD)(i)))



FUNCTION: HMODULE GetModuleHandleA ( char* lpModulename ) ;
FUNCTION: HMODULE GetModuleHandleW ( char* lpModulename ) ;

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



