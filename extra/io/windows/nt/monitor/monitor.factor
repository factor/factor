! Copyright (C) 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types destructors io.windows kernel math windows
windows.kernel32 windows.types libc assocs alien namespaces
continuations io.monitor ;
IN: io.windows.nt.monitor

TUPLE: monitor handle buffer queue closed? ;

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

M: windows-nt-io <monitor> ( path -- monitor )
    [
        open-directory
        buffer-size malloc dup free-later f
    ] with-destructors
    f monitor construct-boa ;

: check-closed ( monitor -- )
    monitor-closed? [ "Monitor closed" throw ] when ;

: close-monitor ( monitor -- )
    dup check-closed
    dup monitor-buffer free
    dup monitor-handle CloseHandle drop
    t swap set-monitor-closed? ;

: fill-buffer ( monitor -- bytes )
    [
        dup monitor-handle
        swap monitor-buffer
        buffer-size
        TRUE
        FILE_NOTIFY_CHANGE_ALL
        0 <uint> [
            f
            f
            ReadDirectoryChangesW win32-error=0/f
        ] keep *uint
    ] with-destructors ;

: (changed-files) ( buffer -- )
    dup {
        FILE_NOTIFY_INFORMATION-NextEntryOffset
        FILE_NOTIFY_INFORMATION-FileName
        FILE_NOTIFY_INFORMATION-FileNameLength
    } get-slots memory>string dup set
    dup zero? [ 2drop ] [
        swap <displaced-alien> (changed-files)
    ] if ;

: changed-files ( buffer len -- assoc )
    [ zero? [ drop ] [ (changed-files) ] if ] H{ } make-assoc ;

: fill-queue ( monitor -- )
    dup monitor-buffer
    over fill-buffer changed-files
    swap set-monitor-queue ;

M: windows-nt-io next-change ( monitor -- path )
    dup check-closed
    dup monitor-queue dup assoc-empty?
    [ drop dup fill-queue next-change ] [ nip delete-any ] if ;
