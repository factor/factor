! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types io.backend io.files io.windows kernel
math windows windows.kernel32 combinators.cleave
windows.time calendar combinators math.functions
sequences namespaces words symbols ;
IN: io.windows.files

SYMBOLS: +read-only+ +hidden+ +system+
+archive+ +device+ +normal+ +temporary+
+sparse-file+ +reparse-point+ +compressed+ +offline+
+not-content-indexed+ +encrypted+ ;

: win32-file-attribute ( n attr symbol -- n )
    >r dupd mask? [ r> , ] [ r> drop ] if ;

: win32-file-attributes ( n -- seq )
    [
        FILE_ATTRIBUTE_READONLY +read-only+ win32-file-attribute
        FILE_ATTRIBUTE_HIDDEN +hidden+ win32-file-attribute
        FILE_ATTRIBUTE_SYSTEM +system+ win32-file-attribute
        FILE_ATTRIBUTE_DIRECTORY +directory+ win32-file-attribute
        FILE_ATTRIBUTE_ARCHIVE +archive+ win32-file-attribute
        FILE_ATTRIBUTE_DEVICE +device+ win32-file-attribute
        FILE_ATTRIBUTE_NORMAL +normal+ win32-file-attribute
        FILE_ATTRIBUTE_TEMPORARY +temporary+ win32-file-attribute
        FILE_ATTRIBUTE_SPARSE_FILE +sparse-file+ win32-file-attribute
        FILE_ATTRIBUTE_REPARSE_POINT +reparse-point+ win32-file-attribute
        FILE_ATTRIBUTE_COMPRESSED +compressed+ win32-file-attribute
        FILE_ATTRIBUTE_OFFLINE +offline+ win32-file-attribute
        FILE_ATTRIBUTE_NOT_CONTENT_INDEXED +not-content-indexed+ win32-file-attribute
        FILE_ATTRIBUTE_ENCRYPTED +encrypted+ win32-file-attribute
        drop
    ] { } make ;

: win32-file-type ( n -- symbol )
    FILE_ATTRIBUTE_DIRECTORY mask? +directory+ +regular-file+ ? ;

: WIN32_FIND_DATA>file-info
    {
        [ WIN32_FIND_DATA-dwFileAttributes win32-file-type ]
        [
            [ WIN32_FIND_DATA-nFileSizeLow ]
            [ WIN32_FIND_DATA-nFileSizeHigh ] bi >64bit
        ]
        [ WIN32_FIND_DATA-dwFileAttributes ]
        ! [ WIN32_FIND_DATA-ftCreationTime FILETIME>timestamp ]
        [ WIN32_FIND_DATA-ftLastWriteTime FILETIME>timestamp ]
        ! [ WIN32_FIND_DATA-ftLastAccessTime FILETIME>timestamp ]
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
        [ BY_HANDLE_FILE_INFORMATION-dwFileAttributes win32-file-type ]
        [
            [ BY_HANDLE_FILE_INFORMATION-nFileSizeLow ]
            [ BY_HANDLE_FILE_INFORMATION-nFileSizeHigh ] bi >64bit
        ]
        [ BY_HANDLE_FILE_INFORMATION-dwFileAttributes ]
        ! [ BY_HANDLE_FILE_INFORMATION-ftCreationTime FILETIME>timestamp ]
        [ BY_HANDLE_FILE_INFORMATION-ftLastWriteTime FILETIME>timestamp ]
        ! [ BY_HANDLE_FILE_INFORMATION-ftLastAccessTime FILETIME>timestamp ]
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
    normalize-pathname get-file-information-stat ;

M: windows-nt-io link-info ( path -- info )
    file-info ;
