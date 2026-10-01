! Copyright (C) 2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax classes.struct
windows.types ;

IN: windows.comdlg32

<< "comdlg32" "comdlg32.dll" stdcall add-library >>

LIBRARY: comdlg32

CONSTANT: OFN_OVERWRITEPROMPT 2
CONSTANT: OFN_NOCHANGEDIR 8
CONSTANT: OFN_PATHMUSTEXIST 0x800
CONSTANT: OFN_FILEMUSTEXIST 0x1000
CONSTANT: OFN_EXPLORER 0x80000

STRUCT: OPENFILENAME
    { lStructSize DWORD }
    { hwndOwner HWND }
    { hInstance HINSTANCE }
    { lpstrFilter LPCTSTR }
    { lpstrCustomFilter LPTSTR }
    { nMaxCustFilter DWORD }
    { nFilterIndex DWORD }
    { lpstrFile LPTSTR }
    { nMaxFile DWORD }
    { lpstrFileTitle LPTSTR }
    { nMaxFileTitle DWORD }
    { lpstrInitialDir LPCTSTR }
    { lpstrTitle LPCTSTR }
    { Flags DWORD }
    { nFileOffset WORD }
    { nFileExtension WORD }
    { lpstrDefExt LPCTSTR }
    { lCustData LPARAM }
    { lpfnHook PVOID }
    { lpTemplateName LPCTSTR }
    { pvReserved void* }
    { dwReserved DWORD }
    { FlagsEx DWORD } ;

TYPEDEF: OPENFILENAME* LPOPENFILENAME

FUNCTION: BOOL GetSaveFileNameW ( LPOPENFILENAME lpofn )
ALIAS: GetSaveFileName GetSaveFileNameW

FUNCTION: BOOL GetOpenFileNameW ( LPOPENFILENAME lpofn )
ALIAS: GetOpenFileName GetOpenFileNameW

FUNCTION: DWORD CommDlgExtendedError ( )
