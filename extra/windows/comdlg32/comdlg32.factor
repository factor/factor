! Copyright (C) 2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.libraries alien.syntax classes.struct
windows.types ;

IN: windows.comdlg32

<< "comdlg32" "comdlg32.dll" stdcall add-library >>

LIBRARY: comdlg32

CONSTANT: OFN_OVERWRITEPROMPT 2

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
    { lpTemplateName LPCTSTR } ;

TYPEDEF: OPENFILENAME* LPOPENFILENAME

FUNCTION: BOOL GetSaveFileNameW ( LPOPENFILENAME lpofn )
ALIAS: GetSaveFileName GetSaveFileNameW
