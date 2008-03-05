! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types io.files io.windows kernel
math windows windows.kernel32 combinators.cleave
windows.time calendar combinators math.functions
sequences combinators.lib namespaces words ;
IN: io.windows.files

SYMBOL: +read-only+
SYMBOL: +hidden+
SYMBOL: +system+
SYMBOL: +directory+
SYMBOL: +archive+
SYMBOL: +device+
SYMBOL: +normal+
SYMBOL: +temporary+
SYMBOL: +sparse-file+
SYMBOL: +reparse-point+
SYMBOL: +compressed+
SYMBOL: +offline+
SYMBOL: +not-content-indexed+
SYMBOL: +encrypted+

: expand-constants ( word/obj -- obj'/obj )
    dup word? [ execute ] when ;

: get-flags ( n seq -- seq' )
    [
        [
            first2 expand-constants
            [ swapd mask? [ , ] [ drop ] if ] 2curry
        ] map call-with
    ] { } make ;

: win32-file-attributes ( n -- seq )
    {
        { +read-only+ FILE_ATTRIBUTE_READONLY }
        { +hidden+ FILE_ATTRIBUTE_HIDDEN }
        { +system+ FILE_ATTRIBUTE_SYSTEM }
        { +directory+ FILE_ATTRIBUTE_DIRECTORY }
        { +archive+ FILE_ATTRIBUTE_ARCHIVE }
        { +device+ FILE_ATTRIBUTE_DEVICE }
        { +normal+ FILE_ATTRIBUTE_NORMAL }
        { +temporary+ FILE_ATTRIBUTE_TEMPORARY }
        { +sparse-file+ FILE_ATTRIBUTE_SPARSE_FILE }
        { +reparse-point+ FILE_ATTRIBUTE_REPARSE_POINT }
        { +compressed+ FILE_ATTRIBUTE_COMPRESSED }
        { +offline+ FILE_ATTRIBUTE_OFFLINE }
        { +not-content-indexed+ FILE_ATTRIBUTE_NOT_CONTENT_INDEXED }
        { +encrypted+ FILE_ATTRIBUTE_ENCRYPTED }
    } get-flags ;

: WIN32_FIND_DATA>file-info
    {
        [ WIN32_FIND_DATA-dwFileAttributes win32-file-attributes ]
        [
            [ WIN32_FIND_DATA-nFileSizeLow ]
            [ WIN32_FIND_DATA-nFileSizeHigh ] bi >64bit
        ]
        [ WIN32_FIND_DATA-dwFileAttributes ]
        [
            WIN32_FIND_DATA-ftLastWriteTime FILETIME>timestamp
        ]
    } cleave
    \ file-info construct-boa ;

: find-first-file-stat ( path -- WIN32_FIND_DATA )
    "WIN32_FIND_DATA" <c-object> [
        FindFirstFile
        [ INVALID_HANDLE_VALUE = [ win32-error ] when ] keep
        FindClose win32-error=0/f
    ] keep ;

: BY_HANDLE_FILE_INFORMATION>file-info
    {
        [ BY_HANDLE_FILE_INFORMATION-dwFileAttributes win32-file-attributes ]
        [
            [ BY_HANDLE_FILE_INFORMATION-nFileSizeLow ]
            [ BY_HANDLE_FILE_INFORMATION-nFileSizeHigh ] bi >64bit
        ]
        [ BY_HANDLE_FILE_INFORMATION-dwFileAttributes ]
        [
            BY_HANDLE_FILE_INFORMATION-ftLastWriteTime
            FILETIME>timestamp
        ]
    } cleave
    \ file-info construct-boa ;

: get-file-information ( handle -- BY_HANDLE_FILE_INFORMATION )
    [
        "BY_HANDLE_FILE_INFORMATION" <c-object>
        [ GetFileInformationByHandle win32-error=0/f ] keep
    ] keep CloseHandle win32-error=0/f ;

: get-file-information-stat ( path -- BY_HANDLE_FILE_INFORMATION )
    dup
    GENERIC_READ FILE_SHARE_READ f
    OPEN_EXISTING FILE_FLAG_BACKUP_SEMANTICS f
    CreateFileW dup INVALID_HANDLE_VALUE = [
        drop find-first-file-stat WIN32_FIND_DATA>file-info
    ] [
        nip
        get-file-information BY_HANDLE_FILE_INFORMATION>file-info
    ] if ;

M: windows-nt-io file-info ( path -- info )
    get-file-information-stat ;

