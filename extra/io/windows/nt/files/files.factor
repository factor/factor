USING: continuations destructors io.buffers io.files io.backend
io.timeouts io.nonblocking io.windows io.windows.nt.backend
kernel libc math threads windows windows.kernel32
alien.c-types alien.arrays sequences combinators combinators.lib
sequences.lib ascii splitting alien strings assocs namespaces ;
IN: io.windows.nt.files

M: windows-nt-io cwd
    MAX_UNICODE_PATH dup "ushort" <c-array>
    [ GetCurrentDirectory win32-error=0/f ] keep
    alien>u16-string ;

M: windows-nt-io cd
    SetCurrentDirectory win32-error=0/f ;

: unicode-prefix ( -- seq )
    "\\\\?\\" ; inline

M: windows-nt-io root-directory? ( path -- ? )
    {
        { [ dup empty? ] [ f ] }
        { [ dup [ path-separator? ] all? ] [ t ] }
        { [ dup right-trim-separators
          { [ dup length 2 = ] [ dup second CHAR: : = ] } && nip ] [
            t
        ] }
        { [ t ] [ f ] }
    } cond nip ;

ERROR: not-absolute-path ;
: root-directory ( string -- string' )
    {
        [ dup length 2 >= ]
        [ dup second CHAR: : = ]
        [ dup first Letter? ]
    } && [ 2 head ] [ not-absolute-path ] if ;

: prepend-prefix ( string -- string' )
    dup unicode-prefix head? [
        unicode-prefix prepend
    ] unless ;

M: windows-nt-io normalize-path ( string -- string' )
    (normalize-path)
    { { CHAR: / CHAR: \\ } } substitute
    prepend-prefix ;

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

: finish-flush ( overlapped port -- )
    dup pending-error
    tuck get-overlapped-result
    dup pick update-file-ptr
    swap buffer-consume ;

: (flush-output) ( port -- )
    dup make-FileArgs
    tuck setup-write WriteFile
    dupd overlapped-error? [
        >r FileArgs-lpOverlapped r>
        [ save-callback ] 2keep
        [ finish-flush ] keep
        dup buffer-empty? [ drop ] [ (flush-output) ] if
    ] [
        2drop
    ] if ;

: flush-output ( port -- )
    [ [ (flush-output) ] with-timeout ] with-destructors ;

M: port port-flush
    dup buffer-empty? [ dup flush-output ] unless drop ;

: finish-read ( overlapped port -- )
    dup pending-error
    tuck get-overlapped-result dup zero? [
        drop t swap set-port-eof?
    ] [
        dup pick n>buffer
        swap update-file-ptr
    ] if ;

: ((wait-to-read)) ( port -- )
    dup make-FileArgs
    tuck setup-read ReadFile
    dupd overlapped-error? [
        >r FileArgs-lpOverlapped r>
        [ save-callback ] 2keep
        finish-read
    ] [ 2drop ] if ;

M: input-port (wait-to-read) ( port -- )
    [ [ ((wait-to-read)) ] with-timeout ] with-destructors ;
