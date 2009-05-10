! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings libc destructors locals
kernel math assocs namespaces make continuations sequences
hashtables sorting arrays combinators math.bitwise strings
system accessors threads splitting io.backend io.backend.windows
io.backend.windows.nt io.files.windows.nt io.monitors io.ports
io.buffers io.files io.timeouts io.encodings.string
io.encodings.utf16n io windows.errors windows.kernel32 windows.types
io.pathnames ;
IN: io.monitors.windows.nt

: open-directory ( path -- handle )
    normalize-path
    FILE_LIST_DIRECTORY
    share-mode
    f
    OPEN_EXISTING
    { FILE_FLAG_BACKUP_SEMANTICS FILE_FLAG_OVERLAPPED } flags
    f
    CreateFile opened-file ;

TUPLE: win32-monitor-port < input-port recursive ;

TUPLE: win32-monitor < monitor port ;

: begin-reading-changes ( port -- overlapped )
    {
        [ handle>> handle>> ]
        [ buffer>> ptr>> ]
        [ buffer>> size>> ]
        [ recursive>> 1 0 ? ]
    } cleave
    FILE_NOTIFY_CHANGE_ALL
    0 <uint>
    (make-overlapped)
    [ f ReadDirectoryChangesW win32-error=0/f ] keep ;

: read-changes ( port -- bytes-transferred )
    [
        [ begin-reading-changes ] [ twiddle-thumbs ] bi
    ] with-destructors ;

: parse-action ( action -- changed )
    {
        { FILE_ACTION_ADDED [ +add-file+ ] }
        { FILE_ACTION_REMOVED [ +remove-file+ ] }
        { FILE_ACTION_MODIFIED [ +modify-file+ ] }
        { FILE_ACTION_RENAMED_OLD_NAME [ +rename-file+ ] }
        { FILE_ACTION_RENAMED_NEW_NAME [ +rename-file+ ] }
        [ drop +modify-file+ ]
    } case 1array ;

: memory>u16-string ( alien len -- string )
    memory>byte-array utf16n decode ;

: parse-notify-record ( buffer -- path changed )
    [
        [ FILE_NOTIFY_INFORMATION-FileName ]
        [ FILE_NOTIFY_INFORMATION-FileNameLength ]
        bi memory>u16-string
    ]
    [ FILE_NOTIFY_INFORMATION-Action parse-action ] bi ;

: (file-notify-records) ( buffer -- buffer )
    dup ,
    dup FILE_NOTIFY_INFORMATION-NextEntryOffset zero? [
        [ FILE_NOTIFY_INFORMATION-NextEntryOffset ] keep <displaced-alien>
        (file-notify-records)
    ] unless ;

: file-notify-records ( buffer -- seq )
    [ (file-notify-records) drop ] { } make ;

:: parse-notify-records ( monitor buffer -- )
    buffer file-notify-records [
        parse-notify-record
        [ monitor path>> prepend-path normalize-path ] dip
        monitor queue-change
    ] each ;

: fill-queue ( monitor -- )
    dup port>> dup check-disposed
    [ buffer>> ptr>> ] [ read-changes zero? ] bi
    [ 2dup parse-notify-records ] unless
    2drop ;

: (fill-queue-thread) ( monitor -- )
    dup fill-queue (fill-queue-thread) ;

: fill-queue-thread ( monitor -- )
    [ dup fill-queue (fill-queue-thread) ]
    [ dup already-disposed? [ 2drop ] [ rethrow ] if ] recover ;

M:: winnt (monitor) ( path recursive? mailbox -- monitor )
    [
        path normalize-path mailbox win32-monitor new-monitor
            path open-directory \ win32-monitor-port <buffered-port>
                recursive? >>recursive
            >>port
        dup [ fill-queue-thread ] curry
        "Windows monitor thread" spawn drop
    ] with-destructors ;

M: win32-monitor dispose
    port>> dispose ;
