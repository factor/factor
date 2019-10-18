USING: continuations destructors io.buffers io.nonblocking io.windows
io.windows.nt io.windows.nt.backend kernel libc math
threads windows windows.kernel32 ;
IN: io.windows.nt.files

M: windows-nt-io CreateFile-flags ( DWORD -- DWORD )
    FILE_FLAG_OVERLAPPED bitor ;

M: windows-nt-io FileArgs-overlapped ( port -- overlapped )
    make-overlapped ;

: update-file-ptr ( n port -- )
    port-handle
    dup win32-file-ptr [
        rot + swap set-win32-file-ptr
    ] [
        2drop
    ] if* ;

: finish-flush ( port -- )
    dup pending-error
    dup get-overlapped-result
    dup pick update-file-ptr
    swap buffer-consume ;

: save-overlapped-and-callback ( fileargs port -- )
    swap FileArgs-lpOverlapped over set-port-overlapped
    save-callback ;

: (flush-output) ( port -- )
    dup touch-port
    dup make-FileArgs
    tuck setup-write WriteFile
    dupd overlapped-error? [
        [ save-overlapped-and-callback ] keep
        [ finish-flush ] keep
        dup buffer-empty? [ drop ] [ (flush-output) ] if
    ] [
        2drop
    ] if ;

: flush-output ( port -- )
    [ (flush-output) ] with-destructors ;

M: port port-flush
    dup buffer-empty? [ dup flush-output ] unless drop ;

: finish-read ( port -- )
    dup pending-error
    dup get-overlapped-result dup zero? [
        drop t swap set-port-eof?
    ] [
        dup pick n>buffer
        swap update-file-ptr
    ] if ;

: ((wait-to-read)) ( port -- )
    dup touch-port
    dup make-FileArgs
    tuck setup-read ReadFile
    dupd overlapped-error? [
        [ save-overlapped-and-callback ] keep
        finish-read
    ] [
        2drop
    ] if ;

M: input-port (wait-to-read) ( port -- )
    [ ((wait-to-read)) ] with-destructors ;

