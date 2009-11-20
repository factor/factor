! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types io.binary io.backend io.files
io.files.types io.buffers io.encodings.utf16n io.ports
io.backend.windows kernel math splitting fry alien.strings
windows windows.kernel32 windows.time calendar combinators
math.functions sequences namespaces make words system
destructors accessors math.bitwise continuations windows.errors
arrays byte-arrays generalizations alien.data ;
IN: io.files.windows

: open-file ( path access-mode create-mode flags -- handle )
    [
        [ share-mode default-security-attributes ] 2dip
        CreateFile-flags f CreateFile opened-file
    ] with-destructors ;

: open-r/w ( path -- win32-file )
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
    [ [ handle>> ] dip d>w/w <uint> ] dip SetFilePointer
    INVALID_SET_FILE_POINTER = [ "SetFilePointer failed" throw ] when ;

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
        [ drop DWORD <c-object> ]
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

SYMBOLS: +read-only+ +hidden+ +system+
+archive+ +device+ +normal+ +temporary+
+sparse-file+ +reparse-point+ +compressed+ +offline+
+not-content-indexed+ +encrypted+ ;

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

: (set-file-times) ( handle timestamp/f timestamp/f timestamp/f -- )
    [ timestamp>FILETIME ] tri@
    SetFileTime win32-error=0/f ;
