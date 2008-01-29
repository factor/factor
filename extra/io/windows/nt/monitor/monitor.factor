! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types destructors io.windows
io.windows.nt.backend kernel math windows windows.kernel32
windows.types libc assocs alien namespaces continuations
io.monitor io.nonblocking io.buffers io.files io sequences
hashtables sorting arrays ;
IN: io.windows.nt.monitor

TUPLE: monitor path recursive? queue closed? ;

: open-directory ( path -- handle )
    FILE_LIST_DIRECTORY
    share-mode
    f
    OPEN_EXISTING
    FILE_FLAG_BACKUP_SEMANTICS FILE_FLAG_OVERLAPPED bitor
    f
    CreateFile
    dup invalid-handle?
    dup close-later
    dup add-completion
    f <win32-file> ;

M: windows-nt-io <monitor> ( path recursive? -- monitor )
    [
        >r dup open-directory monitor <buffered-port> r> {
            set-monitor-path
            set-delegate
            set-monitor-recursive?
        } monitor construct
    ] with-destructors ;

: check-closed ( monitor -- )
    port-type closed eq? [ "Monitor closed" throw ] when ;

M: windows-nt-io close-monitor ( monitor -- ) stream-close ;

: begin-reading-changes ( monitor -- overlapped )
    dup port-handle win32-file-handle
    over buffer-ptr
    pick buffer-size
    roll monitor-recursive? 1 0 ?
    FILE_NOTIFY_CHANGE_ALL
    0 <uint>
    (make-overlapped)
    [ f ReadDirectoryChangesW win32-error=0/f ] keep ;

: read-changes ( monitor -- bytes )
    [
        dup begin-reading-changes swap [ save-callback ] 2keep
        get-overlapped-result
    ] with-destructors ;

: parse-action-flag ( action mask symbol -- action )
    >r over bitand 0 > [ r> , ] [ r> drop ] if ;

: parse-action ( action -- changes )
    [
        FILE_NOTIFY_CHANGE_FILE +change-file+ parse-action-flag
        FILE_NOTIFY_CHANGE_DIR_NAME +change-name+ parse-action-flag
        FILE_NOTIFY_CHANGE_ATTRIBUTES +change-attributes+ parse-action-flag
        FILE_NOTIFY_CHANGE_SIZE +change-size+ parse-action-flag
        FILE_NOTIFY_CHANGE_LAST_WRITE +change-modified+ parse-action-flag
        FILE_NOTIFY_CHANGE_LAST_ACCESS +change-attributes+ parse-action-flag
        FILE_NOTIFY_CHANGE_EA +change-attributes+ parse-action-flag
        FILE_NOTIFY_CHANGE_CREATION +change-attributes+ parse-action-flag
        FILE_NOTIFY_CHANGE_SECURITY +change-attributes+ parse-action-flag
        FILE_NOTIFY_CHANGE_FILE_NAME +change-name+ parse-action-flag
        drop
    ] { } make ;

: changed-file ( directory buffer -- changes path )
    {
        FILE_NOTIFY_INFORMATION-FileName
        FILE_NOTIFY_INFORMATION-FileNameLength
        FILE_NOTIFY_INFORMATION-Action
    } get-slots >r memory>u16-string path+ r> parse-action swap ;

: (changed-files) ( directory buffer -- )
    2dup changed-file namespace [ append ] change-at
    dup FILE_NOTIFY_INFORMATION-NextEntryOffset dup zero?
    [ 3drop ] [ swap <displaced-alien> (changed-files) ] if ;

: changed-files ( directory buffer len -- assoc )
    [ zero? [ 2drop ] [ (changed-files) ] if ] H{ } make-assoc ;

: fill-queue ( monitor -- )
    dup monitor-path over buffer-ptr pick read-changes
    changed-files
    swap set-monitor-queue ;

M: windows-nt-io next-change ( monitor -- path changes )
    dup check-closed
    dup monitor-queue dup assoc-empty? [
        drop dup fill-queue next-change
    ] [
        nip delete-any prune natural-sort >array
    ] if ;
