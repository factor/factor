! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types destructors io.windows
io.windows.nt.backend kernel math windows windows.kernel32
windows.types libc assocs alien namespaces continuations
io.monitors io.monitors.private io.nonblocking io.buffers
io.files io.timeouts io sequences hashtables sorting arrays
combinators math.bitfields strings system ;
IN: io.windows.nt.monitors

: open-directory ( path -- handle )
    FILE_LIST_DIRECTORY
    share-mode
    f
    OPEN_EXISTING
    { FILE_FLAG_BACKUP_SEMANTICS FILE_FLAG_OVERLAPPED } flags
    f
    CreateFile
    dup invalid-handle?
    dup close-later
    dup add-completion
    f <win32-file> ;

TUPLE: win32-monitor path recursive? ;

: <win32-monitor> ( path recursive? port -- monitor )
    (monitor) {
        set-win32-monitor-path
        set-win32-monitor-recursive?
        set-delegate
    } win32-monitor construct ;

M: winnt <monitor> ( path recursive? -- monitor )
    [
        over open-directory win32-monitor <buffered-port>
        <win32-monitor>
    ] with-destructors ;

: begin-reading-changes ( monitor -- overlapped )
    dup port-handle win32-file-handle
    over buffer-ptr
    pick buffer-size
    roll win32-monitor-recursive? 1 0 ?
    FILE_NOTIFY_CHANGE_ALL
    0 <uint>
    (make-overlapped)
    [ f ReadDirectoryChangesW win32-error=0/f ] keep ;

: read-changes ( monitor -- bytes )
    [
        [
            dup begin-reading-changes
            swap [ save-callback ] 2keep
            dup check-monitor ! we may have closed it...
            get-overlapped-result
        ] with-timeout
    ] with-destructors ;

: parse-action ( action -- changed )
    {
        { \ FILE_ACTION_ADDED [ +add-file+ ] }
        { \ FILE_ACTION_REMOVED [ +remove-file+ ] }
        { \ FILE_ACTION_MODIFIED [ +modify-file+ ] }
        { \ FILE_ACTION_RENAMED_OLD_NAME [ +rename-file+ ] }
        { \ FILE_ACTION_RENAMED_NEW_NAME [ +rename-file+ ] }
        [ drop +modify-file+ ]
    } case ;

: memory>u16-string ( alien len -- string )
    [ memory>byte-array ] keep 2/ c-ushort-array> >string ;

: parse-file-notify ( buffer -- changed path )
    {
        FILE_NOTIFY_INFORMATION-FileName
        FILE_NOTIFY_INFORMATION-FileNameLength
        FILE_NOTIFY_INFORMATION-Action
    } get-slots parse-action 1array -rot memory>u16-string ;

: (changed-files) ( buffer -- )
    dup parse-file-notify changed-file
    dup FILE_NOTIFY_INFORMATION-NextEntryOffset dup zero?
    [ 2drop ] [ swap <displaced-alien> (changed-files) ] if ;

M: win32-monitor fill-queue ( monitor -- )
    dup buffer-ptr over read-changes
    [ zero? [ drop ] [ (changed-files) ] if ] H{ } make-assoc
    swap set-monitor-queue ;
