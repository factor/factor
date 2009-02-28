! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays math io.backend io.files.info
io.files.windows io.files.windows.nt kernel windows.kernel32
windows.time windows accessors alien.c-types combinators
generalizations system alien.strings io.encodings.utf16n
sequences splitting windows.errors fry continuations destructors
calendar ascii combinators.short-circuit ;
IN: io.files.info.windows

TUPLE: windows-file-info < file-info attributes ;

: WIN32_FIND_DATA>file-info ( WIN32_FIND_DATA -- file-info )
    [ \ windows-file-info new ] dip
    {
        [ WIN32_FIND_DATA-dwFileAttributes win32-file-type >>type ]
        [ WIN32_FIND_DATA-dwFileAttributes win32-file-attributes >>attributes ]
        [
            [ WIN32_FIND_DATA-nFileSizeLow ]
            [ WIN32_FIND_DATA-nFileSizeHigh ] bi >64bit >>size
        ]
        [ WIN32_FIND_DATA-dwFileAttributes >>permissions ]
        [ WIN32_FIND_DATA-ftCreationTime FILETIME>timestamp >>created ]
        [ WIN32_FIND_DATA-ftLastWriteTime FILETIME>timestamp >>modified ]
        [ WIN32_FIND_DATA-ftLastAccessTime FILETIME>timestamp >>accessed ]
    } cleave ;

: find-first-file-stat ( path -- WIN32_FIND_DATA )
    "WIN32_FIND_DATA" <c-object> [
        FindFirstFile
        [ INVALID_HANDLE_VALUE = [ win32-error ] when ] keep
        FindClose win32-error=0/f
    ] keep ;

: BY_HANDLE_FILE_INFORMATION>file-info ( HANDLE_FILE_INFORMATION -- file-info )
    [ \ windows-file-info new ] dip
    {
        [ BY_HANDLE_FILE_INFORMATION-dwFileAttributes win32-file-type >>type ]
        [ BY_HANDLE_FILE_INFORMATION-dwFileAttributes win32-file-attributes >>attributes ]
        [
            [ BY_HANDLE_FILE_INFORMATION-nFileSizeLow ]
            [ BY_HANDLE_FILE_INFORMATION-nFileSizeHigh ] bi >64bit >>size
        ]
        [ BY_HANDLE_FILE_INFORMATION-dwFileAttributes >>permissions ]
        [
            BY_HANDLE_FILE_INFORMATION-ftCreationTime
            FILETIME>timestamp >>created
        ]
        [
            BY_HANDLE_FILE_INFORMATION-ftLastWriteTime
            FILETIME>timestamp >>modified
        ]
        [
            BY_HANDLE_FILE_INFORMATION-ftLastAccessTime
            FILETIME>timestamp >>accessed
        ]
        ! [ BY_HANDLE_FILE_INFORMATION-nNumberOfLinks ]
        ! [
          ! [ BY_HANDLE_FILE_INFORMATION-nFileIndexLow ]
          ! [ BY_HANDLE_FILE_INFORMATION-nFileIndexHigh ] bi >64bit
        ! ]
    } cleave ;

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

M: windows file-info ( path -- info )
    normalize-path get-file-information-stat ;

M: windows link-info ( path -- info )
    file-info ;

: volume-information ( normalized-path -- volume-name volume-serial max-component flags type )
    MAX_PATH 1+ [ <byte-array> ] keep
    "DWORD" <c-object>
    "DWORD" <c-object>
    "DWORD" <c-object>
    MAX_PATH 1+ [ <byte-array> ] keep
    [ GetVolumeInformation win32-error=0/f ] 7 nkeep
    drop 5 nrot drop
    [ utf16n alien>string ] 4 ndip
    utf16n alien>string ;

: file-system-space ( normalized-path -- available-space total-space free-space )
    "ULARGE_INTEGER" <c-object>
    "ULARGE_INTEGER" <c-object>
    "ULARGE_INTEGER" <c-object>
    [ GetDiskFreeSpaceEx win32-error=0/f ] 3keep ;

: calculate-file-system-info ( file-system-info -- file-system-info' )
    [ dup [ total-space>> ] [ free-space>> ] bi - >>used-space drop ] keep ;

TUPLE: win32-file-system-info < file-system-info max-component flags device-serial ;

ERROR: not-absolute-path ;

: root-directory ( string -- string' )
    unicode-prefix ?head drop
    dup {
        [ length 2 >= ]
        [ second CHAR: : = ]
        [ first Letter? ]
    } 1&& [ 2 head "\\" append ] [ not-absolute-path ] if ;

M: winnt file-system-info ( path -- file-system-info )
    normalize-path root-directory
    dup [ volume-information ] [ file-system-space ] bi
    \ win32-file-system-info new
        swap *ulonglong >>free-space
        swap *ulonglong >>total-space
        swap *ulonglong >>available-space
        swap >>type
        swap *uint >>flags
        swap *uint >>max-component
        swap *uint >>device-serial
        swap >>device-name
        swap >>mount-point
    calculate-file-system-info ;

: volume>paths ( string -- array )
    16384 "ushort" <c-array> tuck dup length
    0 <uint> dup [ GetVolumePathNamesForVolumeName 0 = ] dip swap [
        win32-error-string throw
    ] [
        *uint "ushort" heap-size * head
        utf16n alien>string CHAR: \0 split
    ] if ;

: find-first-volume ( -- string handle )
    MAX_PATH 1+ [ <byte-array> ] keep
    dupd
    FindFirstVolume dup win32-error=0/f
    [ utf16n alien>string ] dip ;

: find-next-volume ( handle -- string/f )
    MAX_PATH 1+ [ <byte-array> tuck ] keep
    FindNextVolume 0 = [
        GetLastError ERROR_NO_MORE_FILES =
        [ drop f ] [ win32-error-string throw ] if
    ] [
        utf16n alien>string
    ] if ;

: find-volumes ( -- array )
    find-first-volume
    [
        '[
            [ _ find-next-volume dup ] [ ] produce nip
            swap prefix
        ]
    ] [ '[ _ FindVolumeClose win32-error=0/f ] ] bi [ ] cleanup ;

M: winnt file-systems ( -- array )
    find-volumes [ volume>paths ] map
    concat [
        [ file-system-info ]
        [ drop \ file-system-info new swap >>mount-point ] recover
    ] map ;

: file-times ( path -- timestamp timestamp timestamp )
    [
        normalize-path open-existing &dispose handle>>
        "FILETIME" <c-object>
        "FILETIME" <c-object>
        "FILETIME" <c-object>
        [ GetFileTime win32-error=0/f ] 3keep
        [ FILETIME>timestamp >local-time ] tri@
    ] with-destructors ;

: set-file-times ( path timestamp/f timestamp/f timestamp/f -- )
    #! timestamp order: creation access write
    [
        [
            normalize-path open-existing &dispose handle>>
        ] 3dip (set-file-times)
    ] with-destructors ;

: set-file-create-time ( path timestamp -- )
    f f set-file-times ;

: set-file-access-time ( path timestamp -- )
    [ f ] dip f set-file-times ;

: set-file-write-time ( path timestamp -- )
    [ f f ] dip set-file-times ;
