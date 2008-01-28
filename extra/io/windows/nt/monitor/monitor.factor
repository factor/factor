! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types destructors io.windows kernel math windows
windows.kernel32 windows.types libc assocs alien namespaces
continuations io.monitor sequences hashtables sorting arrays ;
IN: io.windows.nt.monitor

TUPLE: monitor handle recursive? buffer queue closed? ;

: open-directory ( path -- handle )
    [
        FILE_LIST_DIRECTORY
        share-mode
        f
        OPEN_EXISTING
        FILE_FLAG_BACKUP_SEMANTICS FILE_FLAG_OVERLAPPED bitor
        f
        CreateFile dup invalid-handle? dup close-later
    ] with-destructors ;

: buffer-size 65536 ; inline

M: windows-nt-io <monitor> ( path recursive? -- monitor )
    [
        >r open-directory r>
        buffer-size malloc dup free-later f
    ] with-destructors
    f monitor construct-boa ;

: check-closed ( monitor -- )
    monitor-closed? [ "Monitor closed" throw ] when ;

M: windows-nt-io close-monitor ( monitor -- )
    dup check-closed
    dup monitor-buffer free
    dup monitor-handle CloseHandle drop
    t swap set-monitor-closed? ;

: fill-buffer ( monitor -- bytes )
    [
        dup monitor-handle
        over monitor-buffer
        buffer-size
        roll monitor-recursive? 1 0 ?
        FILE_NOTIFY_CHANGE_ALL
        0 <uint> [
            f
            f
            ReadDirectoryChangesW win32-error=0/f
        ] keep *uint
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

: changed-file ( buffer -- changes path )
    {
        FILE_NOTIFY_INFORMATION-FileName
        FILE_NOTIFY_INFORMATION-FileNameLength
        FILE_NOTIFY_INFORMATION-Action
    } get-slots parse-action -rot memory>u16-string ;

: (changed-files) ( buffer -- )
    dup changed-file namespace [ append ] change-at
    dup FILE_NOTIFY_INFORMATION-NextEntryOffset
    dup zero? [ 2drop ] [
        swap <displaced-alien> (changed-files)
    ] if ;

: changed-files ( buffer len -- assoc )
    [
        zero? [ drop ] [ (changed-files) ] if
    ] H{ } make-assoc ;

: fill-queue ( monitor -- )
    dup monitor-buffer
    over fill-buffer changed-files
    swap set-monitor-queue ;

M: windows-nt-io next-change ( monitor -- path changes )
    dup check-closed
    dup monitor-queue dup assoc-empty? [
    drop dup fill-queue next-change
    ] [
        nip delete-any prune natural-sort >array
    ] if ;
