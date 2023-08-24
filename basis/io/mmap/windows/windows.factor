USING: accessors destructors windows.privileges
io.files.windows io.mmap io.mmap.private kernel literals
math math.bitwise system windows.errors windows.handles
windows.kernel32 ;
IN: io.mmap.windows

: create-file-mapping ( hFile lpAttributes flProtect dwMaximumSizeHigh dwMaximumSizeLow lpName -- HANDLE )
    CreateFileMapping [ win32-error=0/f ] keep <win32-handle> ;

: map-view-of-file ( hFileMappingObject dwDesiredAccess dwFileOffsetHigh dwFileOffsetLow dwNumberOfBytesToMap -- HANDLE )
    MapViewOfFile [ win32-error=0/f ] keep ;

:: mmap-open ( path length access-mode create-mode protect access -- handle handle address )
    length 32 bits :> lo
    length -32 shift 32 bits :> hi
    { "SeCreateGlobalPrivilege" "SeLockMemoryPrivilege" } [
        path access-mode create-mode 0 open-file |dispose
        dup handle>> f protect hi lo f create-file-mapping |dispose
        dup handle>> access 0 0 0 map-view-of-file
    ] with-privileges ;

TUPLE: win32-mapped-file file mapping ;

M: win32-mapped-file dispose
    [ file>> dispose ] [ mapping>> dispose ] bi ;

C: <win32-mapped-file> win32-mapped-file

M: windows (mapped-file-r/w)
    [
        flags{ GENERIC_WRITE GENERIC_READ }
        OPEN_ALWAYS
        flags{ PAGE_READWRITE SEC_COMMIT }
        FILE_MAP_ALL_ACCESS mmap-open
        -rot <win32-mapped-file>
    ] with-destructors ;

M: windows (mapped-file-reader)
    [
        GENERIC_READ
        OPEN_ALWAYS
        flags{ PAGE_READONLY SEC_COMMIT }
        FILE_MAP_READ mmap-open
        -rot <win32-mapped-file>
    ] with-destructors ;

M: windows close-mapped-file
    [
        [ handle>> &dispose drop ]
        [ address>> UnmapViewOfFile win32-error=0/f ] bi
    ] with-destructors ;
