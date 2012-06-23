! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays math io.backend io.files.info
io.files.windows kernel windows.kernel32
windows.time windows.types windows accessors alien.c-types
combinators generalizations system alien.strings
sequences splitting windows.errors fry
continuations destructors calendar ascii
combinators.short-circuit literals locals classes.struct
specialized-arrays alien.data libc ;
SPECIALIZED-ARRAY: ushort
QUALIFIED: sequences
IN: io.files.info.windows

:: round-up-to ( n multiple -- n' )
    n multiple rem [
        n
    ] [
        multiple swap - n +
    ] if-zero ;

TUPLE: windows-file-info < file-info attributes ;

: get-compressed-file-size ( path -- n )
    { DWORD } [ GetCompressedFileSize ] with-out-parameters
    over INVALID_FILE_SIZE = [ win32-error-string throw ] [ >64bit ] if ;

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

CONSTANT: path-length $[ MAX_PATH 1 + ]

: volume-information ( normalized-path -- volume-name volume-serial max-component flags type )
    { { ushort path-length } DWORD DWORD DWORD { ushort path-length } }
    [ [ path-length ] 4dip path-length GetVolumeInformation win32-error=0/f ]
    with-out-parameters
    [ alien>native-string ] 4dip alien>native-string ;

: file-system-space ( normalized-path -- available-space total-space free-space )
    { ULARGE_INTEGER ULARGE_INTEGER ULARGE_INTEGER }
    [ GetDiskFreeSpaceEx win32-error=0/f ]
    with-out-parameters ;

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
        swap >>free-space
        swap >>total-space
        swap >>available-space
        swap >>type
        swap >>flags
        swap >>max-component
        swap >>device-serial
        swap >>device-name
        swap >>mount-point
    calculate-file-system-info ;

PRIVATE>

M: windows file-system-info ( path -- file-system-info )
    normalize-path root-directory (file-system-info) ;

CONSTANT: names-buf-length 16384

: find-first-volume ( -- string handle )
    { { ushort path-length } }
    [ path-length FindFirstVolume dup win32-error=0/f ]
    with-out-parameters alien>native-string swap ;

: find-next-volume ( handle -- string/f )
    { { ushort path-length } }
    [ path-length FindNextVolume ] with-out-parameters
    swap 0 = [
        GetLastError ERROR_NO_MORE_FILES =
        [ drop f ] [ win32-error-string throw ] if
    ] [ alien>native-string ] if ;

: find-volumes ( -- array )
    find-first-volume
    [
        '[
            [ _ find-next-volume dup ] [ ] produce nip
            swap prefix
        ]
    ] [ '[ _ FindVolumeClose win32-error=0/f ] ] bi [ ] cleanup ;

! Windows may return a volume which looks up to path ""
! For now, treat it like there is not a volume here
: volume>paths ( string -- array )
    [
        names-buf-length
        [ ushort malloc-array &free ] keep
        0 uint <ref>
        [ GetVolumePathNamesForVolumeName win32-error=0/f ] 3keep nip
        uint deref head but-last-slice
        { 0 } split* 
        [ { } ] [ [ alien>native-string ] map ] if-empty
    ] with-destructors ;

M: windows file-systems ( -- array )
    find-volumes [ volume>paths ] map concat [
        (file-system-info)
    ] map ;

: file-times ( path -- timestamp timestamp timestamp )
    [
        normalize-path open-read &dispose handle>>
        { FILETIME FILETIME FILETIME }
        [ GetFileTime win32-error=0/f ]
        with-out-parameters
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
