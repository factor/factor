USING: alien.c-types destructors io.windows
io.windows.nt.backend kernel math windows
windows.kernel32 windows.types libc ;
IN: io.windows.directory

: open-directory ( path -- handle )
    [
        FILE_LIST_DIRECTORY
        share-mode
        f
        OPEN_EXISTING
        FILE_FLAG_BACKUP_SEMANTICS FILE_FLAG_OVERLAPPED bitor
        f
        CreateFile
        dup invalid-handle? dup close-later
        dup add-completion
    ] with-destructors ;

: directory-notifications ( -- n )
    FILE_NOTIFY_CHANGE_FILE_NAME FILE_NOTIFY_CHANGE_DIR_NAME bitor ;

: read-directory-changes ( handle -- )
    [
        65536 dup malloc
        swap
        TRUE
        directory-notifications
        0 <int>
        (make-overlapped)
        ! f works here, blocking
        f
        ReadDirectoryChangesW win32-error=0/f
    ] with-destructors ;

