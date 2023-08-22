! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors alien.c-types alien.data alien.strings
alien.syntax classes.struct destructors io.files.trash
io.pathnames kernel libc literals math sequences system
windows.types ;

IN: io.files.trash.windows

<PRIVATE

LIBRARY: shell32

TYPEDEF: WORD FILEOP_FLAGS

STRUCT: SHFILEOPSTRUCTW
    { hwnd HWND }
    { wFunc UINT }
    { pFrom LPCWSTR* }
    { pTo LPCWSTR* }
    { fFlags FILEOP_FLAGS }
    { fAnyOperationsAborted BOOL }
    { hNameMappings LPVOID }
    { lpszProgressTitle LPCWSTR } ;

FUNCTION: int SHFileOperationW ( SHFILEOPSTRUCTW* lpFileOp )

CONSTANT: FO_MOVE 0x0001
CONSTANT: FO_COPY 0x0002
CONSTANT: FO_DELETE 0x0003
CONSTANT: FO_RENAME 0x0004

CONSTANT: FOF_MULTIDESTFILES 0x0001
CONSTANT: FOF_CONFIRMMOUSE 0x0002
CONSTANT: FOF_SILENT 0x0004
CONSTANT: FOF_RENAMEONCOLLISION 0x0008
CONSTANT: FOF_NOCONFIRMATION 0x0010
CONSTANT: FOF_WANTMAPPINGHANDLE 0x0020
CONSTANT: FOF_ALLOWUNDO 0x0040
CONSTANT: FOF_FILESONLY 0x0080
CONSTANT: FOF_SIMPLEPROGRESS 0x0100
CONSTANT: FOF_NOCONFIRMMKDIR 0x0200
CONSTANT: FOF_NOERRORUI 0x0400
CONSTANT: FOF_NOCOPYSECURITYATTRIBS 0x0800
CONSTANT: FOF_NORECURSION 0x1000
CONSTANT: FOF_NO_CONNECTED_ELEMENTS 0x2000
CONSTANT: FOF_WANTNUKEWARNING 0x4000
CONSTANT: FOF_NORECURSEREPARSE 0x8000

PRIVATE>

M: windows send-to-trash ( path -- )
    [
        absolute-path native-string>alien B{ 0 0 } append
        malloc-byte-array &free

        SHFILEOPSTRUCTW new
            f >>hwnd
            FO_DELETE >>wFunc
            swap >>pFrom
            f >>pTo
            flags{
                FOF_ALLOWUNDO
                FOF_NOCONFIRMATION
                FOF_NOERRORUI
                FOF_SILENT
            } >>fFlags

        SHFileOperationW [ throw ] unless-zero

    ] with-destructors ;
