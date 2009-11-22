! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays math io.backend io.files.info
io.files.windows io.files.windows.nt kernel windows.kernel32
windows.time windows.types windows accessors alien.c-types
combinators generalizations system alien.strings
io.encodings.utf16n sequences splitting windows.errors fry
continuations destructors calendar ascii
combinators.short-circuit locals classes.struct
specialized-arrays alien.data ;
SPECIALIZED-ARRAY: ushort
IN: io.files.info.windows

:: round-up-to ( n multiple -- n' )
    n multiple rem [
        n
    ] [
        multiple swap - n +
    ] if-zero ;

TUPLE: windows-file-info < file-info attributes ;

: get-compressed-file-size ( path -- n )
    DWORD <c-object> [ GetCompressedFileSize ] keep
    over INVALID_FILE_SIZE = [
        win32-error-string throw
    ] [
        *uint >64bit
    ] if ;

: set-windows-size-on-disk ( file-info path -- file-info )
    over attributes>> +compressed+ swap member? [
        get-compressed-file-size
    ] [
        drop dup size>> 4096 round-up-to
    ] if >>size-on-disk ;

: WIN32_FIND_DATA>file-info ( WIN32_FIND_DATA -- file-info )
    [ \ windows-file-info new ] dip
    {
        [ dwFileAttributes>> win32-file-type >>type ]
        [ dwFileAttributes>> win32-file-attributes >>attributes ]
        [ [ nFileSizeLow>> ] [ nFileSizeHigh>> ] bi >64bit >>size ]
        [ dwFileAttributes>> >>permissions ]
        [ ftCreationTime>> FILETIME>timestamp >>created ]
        [ ftLastWriteTime>> FILETIME>timestamp >>modified ]
        [ ftLastAccessTime>> FILETIME>timestamp >>accessed ]
    } cleave ;

: find-first-file-stat ( path -- WIN32_FIND_DATA )
    WIN32_FIND_DATA <struct> [
        FindFirstFile
        [ INVALID_HANDLE_VALUE = [ win32-error ] when ] keep
        FindClose win32-error=0/f
    ] keep ;

: BY_HANDLE_FILE_INFORMATION>file-info ( HANDLE_FILE_INFORMATION -- file-info )
    [ \ windows-file-info new ] dip
    {
        [ dwFileAttributes>> win32-file-type >>type ]
        [ dwFileAttributes>> win32-file-attributes >>attributes ]
        [
            [ nFileSizeLow>> ]
            [ nFileSizeHigh>> ] bi >64bit >>size
        ]
        [ dwFileAttributes>> >>permissions ]
        [ ftCreationTime>> FILETIME>timestamp >>created ]
        [ ftLastWriteTime>> FILETIME>timestamp >>modified ]
        [ ftLastAccessTime>> FILETIME>timestamp >>accessed ]
        ! [ nNumberOfLinks>> ]
        ! [
          ! [ nFileIndexLow>> ]
          ! [ nFileIndexHigh>> ] bi >64bit
        ! ]
    } cleave ;

: get-file-information ( handle -- BY_HANDLE_FILE_INFORMATION )
    [
        BY_HANDLE_FILE_INFORMATION <struct>
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
    normalize-path
    [ get-file-information-stat ]
    [ set-windows-size-on-disk ] bi ;

M: windows link-info ( path -- info )
    file-info ;

: volume-information ( normalized-path -- volume-name volume-serial max-component flags type )
    MAX_PATH 1 + [ <ushort-array> ] keep
    DWORD <c-object>
    DWORD <c-object>
    DWORD <c-object>
    MAX_PATH 1 + [ <ushort-array> ] keep
    [ GetVolumeInformation win32-error=0/f ] 7 nkeep
    drop 5 nrot drop
    [ utf16n alien>string ] 4 ndip
    utf16n alien>string ;

: file-system-space ( normalized-path -- available-space total-space free-space )
    ULARGE_INTEGER <c-object>
    ULARGE_INTEGER <c-object>
    ULARGE_INTEGER <c-object>
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

<PRIVATE

: (file-system-info) ( path -- file-system-info )
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

PRIVATE>

M: winnt file-system-info ( path -- file-system-info )
    normalize-path root-directory (file-system-info) ;

:: volume>paths ( string -- array )
    16384 :> names-buf-length
    names-buf-length <ushort-array> :> names
    0 <uint> :> names-length

    string names names-buf-length names-length GetVolumePathNamesForVolumeName :> ret
    ret 0 = [
        ret win32-error-string throw
    ] [
        names names-length *uint ushort heap-size * head
        utf16n alien>string CHAR: \0 split
    ] if ;

: find-first-volume ( -- string handle )
    MAX_PATH 1 + [ <ushort-array> ] keep
    dupd
    FindFirstVolume dup win32-error=0/f
    [ utf16n alien>string ] dip ;

:: find-next-volume ( handle -- string/f )
    MAX_PATH 1 + :> buf-length
    buf-length <ushort-array> :> buf

    handle buf buf-length FindNextVolume :> ret
    ret 0 = [
        GetLastError ERROR_NO_MORE_FILES =
        [ f ] [ win32-error-string throw ] if
    ] [
        buf utf16n alien>string
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
        [ (file-system-info) ]
        [ drop \ file-system-info new swap >>mount-point ] recover
    ] map ;

: file-times ( path -- timestamp timestamp timestamp )
    [
        normalize-path open-read &dispose handle>>
        FILETIME <struct>
        FILETIME <struct>
        FILETIME <struct>
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
