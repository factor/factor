! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types alien.data alien.strings
alien.syntax classes.struct classes.struct.packed destructors
kernel io.encodings.utf16n io.trash libc math sequences system
windows.types ;

IN: io.trash.windows

<PRIVATE

LIBRARY: shell32

TYPEDEF: WORD FILEOP_FLAGS

PACKED-STRUCT: SHFILEOPSTRUCTW
    { hwnd HWND }
    { wFunc UINT }
    { pFrom LPCWSTR* }
    { pTo LPCWSTR* }
    { fFlags FILEOP_FLAGS }
    { fAnyOperationsAborted BOOL }
    { hNameMappings LPVOID }
    { lpszProgressTitle LPCWSTR } ;

FUNCTION: int SHFileOperationW ( SHFILEOPSTRUCTW* lpFileOp ) ;

CONSTANT: FO_MOVE HEX: 0001
CONSTANT: FO_COPY HEX: 0002
CONSTANT: FO_DELETE HEX: 0003
CONSTANT: FO_RENAME HEX: 0004

CONSTANT: FOF_MULTIDESTFILES HEX: 0001
CONSTANT: FOF_CONFIRMMOUSE HEX: 0002
CONSTANT: FOF_SILENT HEX: 0004
CONSTANT: FOF_RENAMEONCOLLISION HEX: 0008
CONSTANT: FOF_NOCONFIRMATION HEX: 0010
CONSTANT: FOF_WANTMAPPINGHANDLE HEX: 0020
CONSTANT: FOF_ALLOWUNDO HEX: 0040
CONSTANT: FOF_FILESONLY HEX: 0080
CONSTANT: FOF_SIMPLEPROGRESS HEX: 0100
CONSTANT: FOF_NOCONFIRMMKDIR HEX: 0200
CONSTANT: FOF_NOERRORUI HEX: 0400
CONSTANT: FOF_NOCOPYSECURITYATTRIBS HEX: 0800
CONSTANT: FOF_NORECURSION HEX: 1000
CONSTANT: FOF_NO_CONNECTED_ELEMENTS HEX: 2000
CONSTANT: FOF_WANTNUKEWARNING HEX: 4000
CONSTANT: FOF_NORECURSEREPARSE HEX: 8000

PRIVATE>

M: windows send-to-trash ( path -- )
    [
        utf16n string>alien B{ 0 0 } append
        malloc-byte-array &free

        SHFILEOPSTRUCTW <struct>
            f >>hwnd
            FO_DELETE >>wFunc
            swap >>pFrom
            f >>pTo
            FOF_ALLOWUNDO
            FOF_NOCONFIRMATION bitor
            FOF_NOERRORUI bitor
            FOF_SILENT bitor >>fFlags

        SHFileOperationW [ throw ] unless-zero

    ] with-destructors ;



