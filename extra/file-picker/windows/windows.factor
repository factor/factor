! Copyright (C) 2014 John Benediktsson, Doug Coleman.
! Copyright (C) 2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings
alien.syntax classes.struct destructors file-picker
io.encodings.string io.encodings.utf8 kernel libc literals math
system windows windows.comdlg32 windows.kernel32 windows.shell32
windows.types windows.user32 ;
IN: file-picker.windows
LIBRARY: shell32

TYPEDEF: void* PIDLIST_ABSOLUTE
TYPEDEF: void* PCIDLIST_ABSOLUTE
TYPEDEF: void* BFFCALLBACK

FUNCTION: HRESULT SHGetFolderLocation (
    HWND hwndOwner,
    int nFolder,
    HANDLE hToken,
    DWORD dwReserved,
    PIDLIST_ABSOLUTE* ppidl
)

STRUCT: BROWSEINFO
  { hwndOwner HWND }
  { pidlRoot PCIDLIST_ABSOLUTE }
  { pszDisplayName LPTSTR }
  { lpszTitle LPCTSTR }
  { ulFlags UINT }
  { lpfn BFFCALLBACK }
  { lParam LPARAM }
  { iImage int } ;

CONSTANT: BIF_RETURNONLYFSDIRS 0x00000001
CONSTANT: BIF_DONTGOBELOWDOMAIN 0x00000002
CONSTANT: BIF_STATUSTEXT 0x00000004
CONSTANT: BIF_RETURNFSANCESTORS 0x00000008
CONSTANT: BIF_EDITBOX 0x00000010
CONSTANT: BIF_VALIDATE 0x00000020
CONSTANT: BIF_NEWDIALOGSTYLE 0x00000040
CONSTANT: BIF_BROWSEINCLUDEURLS 0x00000080
CONSTANT: BIF_USENEWUI flags{ BIF_EDITBOX BIF_NEWDIALOGSTYLE }
CONSTANT: BIF_UAHINT 0x00000100
CONSTANT: BIF_NONEWFOLDERBUTTON 0x00000200
CONSTANT: BIF_NOTRANSLATETARGETS 0x00000400
CONSTANT: BIF_BROWSEFORCOMPUTER 0x00001000
CONSTANT: BIF_BROWSEFORPRINTER 0x00002000
CONSTANT: BIF_BROWSEINCLUDEFILES 0x00004000
CONSTANT: BIF_SHAREABLE 0x00008000
CONSTANT: BIF_BROWSEFILEJUNCTIONS 0x00010000

FUNCTION: PIDLIST_ABSOLUTE SHBrowseForFolder (
    BROWSEINFO* lpbi
)

FUNCTION: BOOL SHGetPathFromIDList (
  PCIDLIST_ABSOLUTE pidl,
  LPTSTR pszPath
)


M: windows open-file-dialog
    [
        BROWSEINFO new
            GetDesktopWindow >>hwndOwner
            "Select a file or folder" utf8 malloc-string &free >>lpszTitle
            BIF_BROWSEINCLUDEFILES >>ulFlags
        SHBrowseForFolder [
            MAX_UNICODE_PATH 1 + malloc &free [ SHGetPathFromIDList ] keep
            swap [ utf8 alien>string ] [ drop f ] if
        ] [
            f
        ] if*
    ] with-destructors ;

M: windows save-file-dialog
    [
        drop ! TODO: support supplying a suggested file name or path
        OPENFILENAME [ malloc-struct &free ] [ heap-size ] bi >>lStructSize
            MAX_UNICODE_PATH [ 2 calloc &free >>lpstrFile ] [ >>nMaxFile ] bi
            OFN_OVERWRITEPROMPT >>Flags
        dup GetSaveFileName zero? [ drop f ] [ lpstrFile>> ] if
    ] with-destructors ;
