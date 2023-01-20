! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.data arrays classes.struct
combinators continuations destructors fry io.backend
io.encodings.string io.encodings.utf16 io.files.windows
io.monitors io.pathnames io.ports kernel literals locals make
math sequences system threads windows.errors windows.kernel32
windows.types ;
IN: io.monitors.windows

: open-directory ( path -- handle )
    normalize-path
    FILE_LIST_DIRECTORY
    share-mode
    f
    OPEN_EXISTING
    flags{ FILE_FLAG_BACKUP_SEMANTICS FILE_FLAG_OVERLAPPED }
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
    0 DWORD <ref>
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
        [ FileName>> ] [ FileNameLength>> ] bi memory>u16-string
    ] [ Action>> parse-action ] bi ;

: (file-notify-records) ( buffer -- buffer )
    FILE_NOTIFY_INFORMATION memory>struct
    dup ,
    dup NextEntryOffset>> zero? [
        [ NextEntryOffset>> ] [ >c-ptr <displaced-alien> ] bi
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
    dup port>> check-disposed
    [ buffer>> ptr>> ] [ read-changes zero? ] bi
    [ 2dup parse-notify-records ] unless
    2drop ;

: (fill-queue-thread) ( monitor -- )
    dup fill-queue (fill-queue-thread) ;

: fill-queue-thread ( monitor -- )
    '[ _ dup fill-queue (fill-queue-thread) ]
    [ already-disposed? ] ignore-error ;

M:: windows (monitor) ( path recursive? mailbox -- monitor )
    [
        path normalize-path mailbox win32-monitor new-monitor
            path open-directory \ win32-monitor-port <buffered-port>
                recursive? >>recursive
            >>port
        dup [ fill-queue-thread ] curry
        "Windows monitor thread" spawn drop
    ] with-destructors ;

M: win32-monitor dispose
    [ port>> dispose ] [ call-next-method ] bi ;
