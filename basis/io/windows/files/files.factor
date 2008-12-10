! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types io.binary io.backend io.files io.buffers
io.encodings.utf16n io.ports io.windows kernel math splitting
fry alien.strings windows windows.kernel32 windows.time calendar
combinators math.functions sequences namespaces make words
symbols system destructors accessors math.bitwise continuations
windows.errors arrays byte-arrays generalizations ;
IN: io.windows.files

: open-file ( path access-mode create-mode flags -- handle )
    [
        [ share-mode default-security-attributes ] 2dip
        CreateFile-flags f CreateFile opened-file
    ] with-destructors ;

: open-pipe-r/w ( path -- win32-file )
    { GENERIC_READ GENERIC_WRITE } flags
    OPEN_EXISTING 0 open-file ;

: open-read ( path -- win32-file )
    GENERIC_READ OPEN_EXISTING 0 open-file 0 >>ptr ;

: open-write ( path -- win32-file )
    GENERIC_WRITE CREATE_ALWAYS 0 open-file 0 >>ptr ;

: (open-append) ( path -- win32-file )
    GENERIC_WRITE OPEN_ALWAYS 0 open-file ;

: open-existing ( path -- win32-file )
    { GENERIC_READ GENERIC_WRITE } flags
    share-mode
    f
    OPEN_EXISTING
    FILE_FLAG_BACKUP_SEMANTICS
    f CreateFileW dup win32-error=0/f <win32-file> ;

: maybe-create-file ( path -- win32-file ? )
    #! return true if file was just created
    { GENERIC_READ GENERIC_WRITE } flags
    share-mode
    f
    OPEN_ALWAYS
    0 CreateFile-flags
    f CreateFileW dup win32-error=0/f <win32-file>
    GetLastError ERROR_ALREADY_EXISTS = not ;

: set-file-pointer ( handle length method -- )
    [ dupd d>w/w <uint> ] dip SetFilePointer
    INVALID_SET_FILE_POINTER = [
        CloseHandle "SetFilePointer failed" throw
    ] when drop ;

HOOK: open-append os ( path -- win32-file )

TUPLE: FileArgs
    hFile lpBuffer nNumberOfBytesToRead
    lpNumberOfBytesRet lpOverlapped ;

C: <FileArgs> FileArgs

: make-FileArgs ( port -- <FileArgs> )
    {
        [ handle>> check-disposed ]
        [ handle>> handle>> ]
        [ buffer>> ]
        [ buffer>> buffer-length ]
        [ drop "DWORD" <c-object> ]
        [ FileArgs-overlapped ]
    } cleave <FileArgs> ;

: setup-read ( <FileArgs> -- hFile lpBuffer nNumberOfBytesToRead lpNumberOfBytesRead lpOverlapped )
    {
        [ hFile>> ]
        [ lpBuffer>> buffer-end ]
        [ lpBuffer>> buffer-capacity ]
        [ lpNumberOfBytesRet>> ]
        [ lpOverlapped>> ]
    } cleave ;

: setup-write ( <FileArgs> -- hFile lpBuffer nNumberOfBytesToWrite lpNumberOfBytesWritten lpOverlapped )
    {
        [ hFile>> ]
        [ lpBuffer>> buffer@ ]
        [ lpBuffer>> buffer-length ]
        [ lpNumberOfBytesRet>> ]
        [ lpOverlapped>> ]
    } cleave ;

M: windows (file-reader) ( path -- stream )
    open-read <input-port> ;

M: windows (file-writer) ( path -- stream )
    open-write <output-port> ;

M: windows (file-appender) ( path -- stream )
    open-append <output-port> ;

M: windows move-file ( from to -- )
    [ normalize-path ] bi@ MoveFile win32-error=0/f ;

M: windows delete-file ( path -- )
    normalize-path DeleteFile win32-error=0/f ;

M: windows copy-file ( from to -- )
    dup parent-directory make-directories
    [ normalize-path ] bi@ 0 CopyFile win32-error=0/f ;

M: windows make-directory ( path -- )
    normalize-path
    f CreateDirectory win32-error=0/f ;

M: windows delete-directory ( path -- )
    normalize-path
    RemoveDirectory win32-error=0/f ;

: find-first-file ( path -- WIN32_FIND_DATA handle )
    "WIN32_FIND_DATA" <c-object> tuck
    FindFirstFile
    [ INVALID_HANDLE_VALUE = [ win32-error-string throw ] when ] keep ;

: find-next-file ( path -- WIN32_FIND_DATA/f )
    "WIN32_FIND_DATA" <c-object> tuck
    FindNextFile 0 = [
        GetLastError ERROR_NO_MORE_FILES = [
            win32-error
        ] unless drop f
    ] when ;

M: windows (directory-entries) ( path -- seq )
    "\\" ?tail drop "\\*" append
    find-first-file [ >directory-entry ] dip
    [
        '[
            [ _ find-next-file dup ]
            [ >directory-entry ]
            [ drop ] produce
            over name>> "." = [ nip ] [ swap prefix ] if
        ]
    ] [ '[ _ FindClose win32-error=0/f ] ] bi [ ] cleanup ;

SYMBOLS: +read-only+ +hidden+ +system+
+archive+ +device+ +normal+ +temporary+
+sparse-file+ +reparse-point+ +compressed+ +offline+
+not-content-indexed+ +encrypted+ ;

TUPLE: windows-file-info < file-info attributes ;

: win32-file-attribute ( n attr symbol -- )
    rot mask? [ , ] [ drop ] if ;

: win32-file-attributes ( n -- seq )
    [
        {
            [ +read-only+ FILE_ATTRIBUTE_READONLY win32-file-attribute ]
            [ +hidden+ FILE_ATTRIBUTE_HIDDEN win32-file-attribute ]
            [ +system+ FILE_ATTRIBUTE_SYSTEM win32-file-attribute ]
            [ +directory+ FILE_ATTRIBUTE_DIRECTORY win32-file-attribute ]
            [ +archive+ FILE_ATTRIBUTE_ARCHIVE win32-file-attribute ]
            [ +device+ FILE_ATTRIBUTE_DEVICE win32-file-attribute ]
            [ +normal+ FILE_ATTRIBUTE_NORMAL win32-file-attribute ]
            [ +temporary+ FILE_ATTRIBUTE_TEMPORARY win32-file-attribute ]
            [ +sparse-file+ FILE_ATTRIBUTE_SPARSE_FILE win32-file-attribute ]
            [ +reparse-point+ FILE_ATTRIBUTE_REPARSE_POINT win32-file-attribute ]
            [ +compressed+ FILE_ATTRIBUTE_COMPRESSED win32-file-attribute ]
            [ +offline+ FILE_ATTRIBUTE_OFFLINE win32-file-attribute ]
            [ +not-content-indexed+ FILE_ATTRIBUTE_NOT_CONTENT_INDEXED win32-file-attribute ]
            [ +encrypted+ FILE_ATTRIBUTE_ENCRYPTED win32-file-attribute ]
        } cleave
    ] { } make ;

: win32-file-type ( n -- symbol )
    FILE_ATTRIBUTE_DIRECTORY mask? +directory+ +regular-file+ ? ;

TUPLE: windows-directory-entry < directory-entry attributes ;

M: windows >directory-entry ( byte-array -- directory-entry )
    [ WIN32_FIND_DATA-cFileName utf16n alien>string ]
    [ WIN32_FIND_DATA-dwFileAttributes win32-file-type ]
    [ WIN32_FIND_DATA-dwFileAttributes win32-file-attributes ]
    tri
    dupd remove windows-directory-entry boa ;

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

M: winnt file-info ( path -- info )
    normalize-path get-file-information-stat ;

M: winnt link-info ( path -- info )
    file-info ;

HOOK: root-directory os ( string -- string' )

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
    {
        [ dup [ total-space>> ] [ free-space>> ] bi - >>used-space drop ]
        [ ]
    } cleave ;

TUPLE: win32-file-system-info < file-system-info max-component flags device-serial ;

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
            [ _ find-next-volume dup ]
            [ ]
            [ drop ] produce
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

: (set-file-times) ( handle timestamp/f timestamp/f timestamp/f -- )
    [ timestamp>FILETIME ] tri@
    SetFileTime win32-error=0/f ;

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

M: winnt touch-file ( path -- )
    [
        normalize-path
        maybe-create-file [ &dispose ] dip
        [ drop ] [ handle>> f now dup (set-file-times) ] if
    ] with-destructors ;
