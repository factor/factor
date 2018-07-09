! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings
alien.syntax arrays assocs classes.struct combinators
combinators.short-circuit continuations destructors environment io
io.backend io.binary io.buffers io.files io.files.private
io.files.types io.pathnames io.ports io.streams.c io.streams.null
io.timeouts kernel libc literals locals math math.bitwise namespaces
sequences specialized-arrays system threads tr vectors windows
windows.errors windows.handles windows.kernel32 windows.shell32
windows.time windows.types windows.winsock splitting ;
SPECIALIZED-ARRAY: ushort
IN: io.files.windows

SLOT: file

: CreateFile-flags ( DWORD -- DWORD )
    flags{ FILE_FLAG_BACKUP_SEMANTICS FILE_FLAG_OVERLAPPED } bitor ;

HOOK: open-append os ( path -- win32-file )

TUPLE: win32-file < win32-handle ptr ;

: <win32-file> ( handle -- win32-file )
    win32-file new-win32-handle ;

M: win32-file dispose
    [ cancel-operation ] [ call-next-method ] bi ;

CONSTANT: share-mode
    flags{
        FILE_SHARE_READ
        FILE_SHARE_WRITE
        FILE_SHARE_DELETE
    }

: default-security-attributes ( -- obj )
    SECURITY_ATTRIBUTES <struct>
    SECURITY_ATTRIBUTES heap-size >>nLength ;

TUPLE: FileArgs
    hFile lpBuffer nNumberOfBytesToRead
    lpNumberOfBytesRet lpOverlapped ;

C: <FileArgs> FileArgs

! Global variable with assoc mapping overlapped to threads
SYMBOL: pending-overlapped

TUPLE: io-callback port thread ;

C: <io-callback> io-callback

: <completion-port> ( handle existing -- handle )
     f 1 CreateIoCompletionPort dup win32-error=0/f ;

: <master-completion-port> ( -- handle )
    INVALID_HANDLE_VALUE f <completion-port> ;

SYMBOL: master-completion-port

: add-completion ( win32-handle -- win32-handle )
    dup handle>> master-completion-port get-global <completion-port> drop ;

: opened-file ( handle -- win32-file )
    check-invalid-handle <win32-file> |dispose add-completion ;

: eof? ( error -- ? )
    { [ ERROR_HANDLE_EOF = ] [ ERROR_BROKEN_PIPE = ] } 1|| ;

: twiddle-thumbs ( overlapped port -- bytes-transferred )
    [
        drop
        [ self ] dip >c-ptr pending-overlapped get-global set-at
        "I/O" suspend {
            { [ dup integer? ] [ ] }
            { [ dup array? ] [
                first dup eof?
                [ drop 0 ] [ n>win32-error-string throw ] if
            ] }
        } cond
    ] with-timeout ;

:: wait-for-overlapped ( nanos -- bytes-transferred overlapped error? )
    nanos [ 1,000,000 /i ] [ INFINITE ] if* :> timeout
    master-completion-port get-global
    { int void* pointer: OVERLAPPED }
    [ timeout GetQueuedCompletionStatus zero? ] with-out-parameters
    :> ( error? bytes key overlapped )
    bytes overlapped error? ;

: resume-callback ( result overlapped -- )
    >c-ptr pending-overlapped get-global delete-at* drop resume-with ;

: handle-overlapped ( nanos -- ? )
    wait-for-overlapped [
        [
            [ drop GetLastError 1array ] dip resume-callback t
        ] [ drop f ] if*
    ] [ resume-callback t ] if ;

M: win32-handle cancel-operation
    [ handle>> CancelIo win32-error=0/f ] unless-disposed ;

M: windows io-multiplex ( nanos -- )
    handle-overlapped [ 0 io-multiplex ] when ;

M: windows init-io ( -- )
    <master-completion-port> master-completion-port set-global
    H{ } clone pending-overlapped set-global ;

: (handle>file-size) ( handle -- n/f )
    0 ulonglong <ref> [ GetFileSizeEx ] keep swap
    [ drop f ] [ drop ulonglong deref ] if-zero ;

! GetFileSizeEx errors with ERROR_INVALID_FUNCTION if handle is not seekable
: handle>file-size ( handle -- n/f )
    (handle>file-size) [
        GetLastError ERROR_INVALID_FUNCTION =
        [ f ] [ throw-win32-error ] if
    ] unless* ;

ERROR: seek-before-start n ;

: set-seek-ptr ( n handle -- )
    [ dup 0 < [ seek-before-start ] when ] dip ptr<< ;

M: windows tell-handle ( handle -- n ) ptr>> ;

M: windows seek-handle ( n seek-type handle -- )
    swap {
        { seek-absolute [ set-seek-ptr ] }
        { seek-relative [ [ ptr>> + ] keep set-seek-ptr ] }
        { seek-end [ [ handle>> handle>file-size + ] keep set-seek-ptr ] }
        [ bad-seek-type ]
    } case ;

M: windows can-seek-handle? ( handle -- ? )
    handle>> handle>file-size >boolean ;

M: windows handle-length ( handle -- n/f )
    handle>> handle>file-size
    dup { 0 f } member? [ drop f ] when ;

: file-error? ( n -- eof? )
    zero? [
        GetLastError {
            { [ dup expected-io-error? ] [ drop f ] }
            { [ dup eof? ] [ drop t ] }
            [ n>win32-error-string throw ]
        } cond
    ] [ f ] if ;

: wait-for-file ( FileArgs n port -- n )
    swap file-error?
    [ 2drop 0 ] [ [ lpOverlapped>> ] dip twiddle-thumbs ] if ;

: update-file-ptr ( n port -- )
    handle>> dup ptr>> [ rot + >>ptr drop ] [ 2drop ] if* ;

: (make-overlapped) ( -- overlapped-ext )
    OVERLAPPED malloc-struct &free ;

: make-overlapped ( handle -- overlapped-ext )
    (make-overlapped) swap
    ptr>> [ [ 32 bits >>offset ] [ -32 shift >>offset-high ] bi ] when* ;

: make-FileArgs ( port handle -- <FileArgs> )
    [ nip check-disposed handle>> ]
    [
        [ buffer>> dup buffer-length 0 DWORD <ref> ] dip make-overlapped
    ] 2bi <FileArgs> ;

: setup-write ( <FileArgs> -- hFile lpBuffer nNumberOfBytesToWrite lpNumberOfBytesWritten lpOverlapped )
    {
        [ hFile>> ]
        [ lpBuffer>> [ buffer@ ] [ buffer-length ] bi ]
        [ lpNumberOfBytesRet>> ]
        [ lpOverlapped>> ]
    } cleave ;

: finish-write ( n port -- )
    [ update-file-ptr ] [ buffer>> buffer-consume ] 2bi ;

M: object drain ( port handle -- event/f )
    [ make-FileArgs dup setup-write WriteFile ]
    [ drop [ wait-for-file ] [ finish-write ] bi ] 2bi f ;

: setup-read ( <FileArgs> -- hFile lpBuffer nNumberOfBytesToRead lpNumberOfBytesRead lpOverlapped )
    {
        [ hFile>> ]
        [ lpBuffer>> [ buffer-end ] [ buffer-capacity ] bi ]
        [ lpNumberOfBytesRet>> ]
        [ lpOverlapped>> ]
    } cleave ;

: finish-read ( n port -- )
    [ update-file-ptr ] [ buffer>> buffer+ ] 2bi ;

M: object refill ( port handle -- event/f )
    [ make-FileArgs dup setup-read ReadFile ]
    [ drop [ wait-for-file ] [ finish-read ] bi ] 2bi f ;

M: windows (wait-to-write) ( port -- )
    [ dup handle>> drain ] with-destructors drop ;

M: windows (wait-to-read) ( port -- )
    [ dup handle>> refill ] with-destructors drop ;

: make-fd-set ( socket -- fd_set )
    fd_set <struct> swap 1array void* >c-array >>fd_array 1 >>fd_count ;

: select-sets ( socket event -- read-fds write-fds except-fds )
    [ make-fd-set ] dip +input+ = [ f f ] [ f swap f ] if ;

CONSTANT: select-timeval S{ timeval { sec 0 } { usec 1000 } }

M: windows wait-for-fd ( handle event -- )
    [ file>> handle>> 1 swap ] dip select-sets select-timeval
    select drop yield ;

: console-app? ( -- ? ) GetConsoleWindow >boolean ;

M: windows init-stdio
    console-app?
    [ init-c-stdio ]
    [ null-reader null-writer null-writer set-stdio ] if ;

: open-file ( path access-mode create-mode flags -- handle )
    [
        [ share-mode default-security-attributes ] 2dip
        CreateFile-flags f CreateFileW opened-file
    ] with-destructors ;

: open-r/w ( path -- win32-file )
    flags{ GENERIC_READ GENERIC_WRITE }
    OPEN_EXISTING 0 open-file ;

: open-read ( path -- win32-file )
    GENERIC_READ OPEN_EXISTING 0 open-file 0 >>ptr ;

: open-write ( path -- win32-file )
    GENERIC_WRITE CREATE_ALWAYS 0 open-file 0 >>ptr ;

: (open-append) ( path -- win32-file )
    GENERIC_WRITE OPEN_ALWAYS 0 open-file ;

: maybe-create-file ( path -- win32-file ? )
    ! return true if file was just created
    flags{ GENERIC_READ GENERIC_WRITE }
    OPEN_ALWAYS 0 open-file
    GetLastError ERROR_ALREADY_EXISTS = not ;

: set-file-pointer ( handle length method -- )
    [ [ handle>> ] dip d>w/w LONG <ref> ] dip SetFilePointer
    INVALID_SET_FILE_POINTER = [ "SetFilePointer failed" throw ] when ;

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

SLOT: attributes

: read-only? ( file-info -- ? )
    attributes>> +read-only+ swap member? ;

: set-file-attributes ( path flags -- )
    SetFileAttributes win32-error=0/f ;

: set-file-normal-attribute ( path -- )
    FILE_ATTRIBUTE_NORMAL set-file-attributes ;

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
    }
    [ execute( -- y ) mask? [ drop f ] unless ] with { } assoc>map sift ;

: win32-file-type ( n -- symbol )
    FILE_ATTRIBUTE_DIRECTORY mask? +directory+ +regular-file+ ? ;

: (set-file-times) ( handle timestamp/f timestamp/f timestamp/f -- )
    [ timestamp>FILETIME ] tri@
    SetFileTime win32-error=0/f ;

M: windows cwd
    MAX_UNICODE_PATH dup ushort <c-array>
    [ GetCurrentDirectory win32-error=0/f ] keep alien>native-string ;

M: windows cd
    SetCurrentDirectory win32-error=0/f ;

CONSTANT: unicode-prefix "\\\\?\\"

M: windows root-directory? ( path -- ? )
    {
        { [ dup empty? ] [ drop f ] }
        { [ dup [ path-separator? ] all? ] [ drop t ] }
        { [ dup trim-tail-separators { [ length 2 = ]
          [ second CHAR: : = ] } 1&& ] [ drop t ] }
        { [ dup unicode-prefix head? ]
          [ trim-tail-separators length unicode-prefix length 2 + = ] }
        [ drop f ]
    } cond ;

: prepend-unicode-prefix ( string -- string' )
    dup unicode-prefix head? [
        unicode-prefix prepend
    ] unless ;

: remove-unicode-prefix ( string -- string' )
    unicode-prefix ?head drop ;

TR: normalize-separators "/" "\\" ;

<PRIVATE

: unc-path? ( string -- ? )
    [ "//" head? ] [ "\\\\" head? ] bi or ;

PRIVATE>

M: windows canonicalize-path
    remove-unicode-prefix canonicalize-path* ;

M: object root-path remove-unicode-prefix root-path* ;

M: object relative-path remove-unicode-prefix relative-path* ;

M: windows normalize-path ( string -- string' )
    dup unc-path? [
        normalize-separators
    ] [
        absolute-path
        normalize-separators
        prepend-unicode-prefix
    ] if ;

<PRIVATE

: windows-file-size ( path -- size )
    normalize-path 0 WIN32_FILE_ATTRIBUTE_DATA <struct>
    [ GetFileAttributesEx win32-error=0/f ] keep
    [ nFileSizeLow>> ] [ nFileSizeHigh>> ] bi >64bit ;

PRIVATE>

M: windows open-append
    [ dup windows-file-size ] [ drop 0 ] recover
    [ (open-append) ] dip >>ptr ;

M: windows home
    {
        [ "HOMEDRIVE" os-env "HOMEPATH" os-env append-path ]
        [ "USERPROFILE" os-env ]
        [ my-documents ]
    } 0|| ;

: STREAM_DATA>out ( WIN32_FIND_STREAM_DATA -- pair/f )
    [ cStreamName>> alien>native-string ]
    [ StreamSize>> ] bi 2array ;

: file-streams-rest ( streams handle -- streams )
    WIN32_FIND_STREAM_DATA <struct>
    [ FindNextStream ] 2keep
    rot zero? [
        GetLastError ERROR_HANDLE_EOF = [ win32-error ] unless
        2drop
    ] [
        pick push file-streams-rest
    ] if ;

: file-streams ( path -- streams )
    normalize-path
    FindStreamInfoStandard
    WIN32_FIND_STREAM_DATA <struct>
    0
    [ FindFirstStream ] keepd
    over -1 <alien> = [
        2drop throw-win32-error
    ] [
        1vector swap file-streams-rest
    ] if ;

: alternate-file-streams ( path -- streams )
    file-streams [ cStreamName>> alien>native-string "::$DATA" = ] reject ;

: alternate-file-streams? ( path -- streams )
    alternate-file-streams empty? not ;
