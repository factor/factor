! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings ascii
calendar classes.struct combinators combinators.short-circuit
continuations destructors fry io.backend io.files.info
io.files.windows kernel libc literals locals math sequences
splitting system windows.errors windows.kernel32 windows.shell32
windows.time windows.types ;
IN: io.files.info.windows

:: round-up-to ( n multiple -- n' )
    n multiple rem [
        n
    ] [
        multiple swap - n +
    ] if-zero ;

TUPLE: windows-file-info < file-info-tuple attributes ;

: get-compressed-file-size ( path -- n )
    { DWORD } [ GetCompressedFileSize ] with-out-parameters
    over INVALID_FILE_SIZE = [ win32-error ] when >64bit ;

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
    WIN32_FIND_DATA new [
        FindFirstFile check-invalid-handle
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
        BY_HANDLE_FILE_INFORMATION new
        [ GetFileInformationByHandle win32-error=0/f ] keep
    ] keep CloseHandle win32-error=0/f ;

: valid-handle? ( handle -- boolean )
    INVALID_HANDLE_VALUE = not ; inline

: open-read-handle ( path -- handle/f )
    ! Parameters of CreateFileW here should match those in open-read.
    GENERIC_READ share-mode f
    OPEN_EXISTING 0 CreateFile-flags f
    CreateFileW [ valid-handle? ] keep f ? ;

: get-file-information-stat ( path -- file-info )
    dup open-read-handle dup [
        nip
        get-file-information BY_HANDLE_FILE_INFORMATION>file-info
    ] [
        drop find-first-file-stat WIN32_FIND_DATA>file-info
    ] if ;

M: windows file-info
    normalize-path
    [ get-file-information-stat ]
    [ set-windows-size-on-disk ] bi ;

M: windows link-info
    file-info ;

: file-executable-type ( path -- executable/f )
    normalize-path dup
    0
    f
    ! hi is zero means old style executable
    0 SHGFI_EXETYPE SHGetFileInfoW
    [
        file-info drop f
    ] [
        nip >lo-hi first2 zero? [
            {
                { 0x5A4D [ +dos-executable+ ] }
                { 0x4550 [ +win32-console-executable+ ] }
                [ drop f ]
            } case
        ] [
            {
                { 0x454C [ +win32-vxd-executable+ ] }
                { 0x454E [ +win32-os2-executable+ ] }
                { 0x4550 [ +win32-nt-executable+ ] }
                [ drop f ]
            } case
        ] if
    ] if-zero ;

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

TUPLE: win32-file-system-info < file-system-info-tuple max-component flags device-serial ;

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

M: windows file-system-info
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
        [ drop f ] [ win32-error ] if
    ] [ alien>native-string ] if ;

: find-volumes ( -- array )
    find-first-volume
    [
        '[
            [ _ find-next-volume dup ] [ ] produce nip
            swap prefix
        ]
    ] [ '[ _ FindVolumeClose win32-error=0/f ] ] bi finally ;

! Windows may return a volume which looks up to path ""
! For now, treat it like there is not a volume here
: (volume>paths) ( string -- array )
    [
        names-buf-length
        [ ushort malloc-array &free ] keep
        0 uint <ref>
        [ GetVolumePathNamesForVolumeName win32-error=0/f ] 3keep nip
        uint deref head but-last-slice
        { 0 } split-slice harvest
        [ { } ] [ [ { 0 } append alien>native-string ] map ] if-empty
    ] with-destructors ;

! Suppress T{ windows-error f 2 "The system cannot find the file specified." }
: volume>paths ( string -- array/f )
    '[ _ (volume>paths) ] [
        { [ windows-error? ] [ n>> ERROR_FILE_NOT_FOUND = ] } 1&&
    ] ignore-error/f ;

! Can error with T{ windows-error f 21 "The device is not ready." }
! if there is a D: that is not ready, for instance. Ignore these drives.
M: windows file-systems
    find-volumes [ volume>paths ] map concat [
        [ (file-system-info) ] [ 2drop f ] recover
    ] map sift ;

: file-times ( path -- timestamp timestamp timestamp )
    [
        normalize-path open-read &dispose handle>>
        { FILETIME FILETIME FILETIME }
        [ GetFileTime win32-error=0/f ]
        with-out-parameters
        [ FILETIME>timestamp >local-time ] tri@
    ] with-destructors ;

: set-file-times ( path timestamp/f timestamp/f timestamp/f -- )
    ! timestamp order: creation access write
    [
        [
            normalize-path open-r/w &dispose handle>>
        ] 3dip (set-file-times)
    ] with-destructors ;

: set-file-create-time ( path timestamp -- )
    f f set-file-times ;

: set-file-access-time ( path timestamp -- )
    [ f ] dip f set-file-times ;

: set-file-write-time ( path timestamp -- )
    [ f f ] dip set-file-times ;

M: windows file-readable?
    normalize-path open-read-handle
    dup [ CloseHandle win32-error=0/f ] when* >boolean ;

M: windows file-writable? file-info attributes>> +read-only+ swap member? not ;
M: windows file-executable? file-executable-type windows-executable? ;
