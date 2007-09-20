USING: continuations destructors io.buffers io.nonblocking io.windows
io.windows.nt io.windows.nt.backend kernel libc math
threads windows windows.kernel32 ;
IN: io.windows.nt.files

M: windows-nt-io CreateFile-flags ( -- DWORD )
    FILE_FLAG_OVERLAPPED ;

M: windows-nt-io FileArgs-overlapped ( port -- overlapped )
    make-overlapped ;

: update-file-ptr ( n port -- )
    port-handle
    dup win32-file-ptr [
        rot + swap set-win32-file-ptr
    ] [
        2drop
    ] if* ;

DEFER: (flush-output)
: finish-flush ( port -- )
    dup pending-error
    dup get-overlapped-result
    [ over update-file-ptr ] keep
    over delegate [ buffer-consume ] keep
    buffer-length 0 > [
        (flush-output)
    ] [
        drop
    ] if ;

: (flush-output) ( port -- )
    dup touch-port
    dup make-FileArgs
    [ setup-write WriteFile ] keep
    >r dupd overlapped-error? r> swap [
        FileArgs-lpOverlapped over set-port-overlapped
        dup save-callback
        finish-flush
    ] [
        2drop
    ] if ;

M: windows-nt-io flush-output ( port -- )
    [ (flush-output) ] with-destructors ;

: finish-read ( port -- )
    dup pending-error
    dup get-overlapped-result dup zero? [
        drop t swap set-port-eof?
    ] [
        [ over n>buffer ] keep
        swap update-file-ptr
    ] if ;

: ((wait-to-read)) ( port -- )
    dup touch-port
    dup make-FileArgs
    [ setup-read ReadFile ] keep
    >r dupd overlapped-error? r> swap [
        FileArgs-lpOverlapped over set-port-overlapped
        dup save-callback
        finish-read
    ] [
        2drop
    ] if ;

M: input-port (wait-to-read) ( port -- )
    [ ((wait-to-read)) ] with-destructors ;

