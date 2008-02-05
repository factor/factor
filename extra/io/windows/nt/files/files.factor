USING: continuations destructors io.buffers io.files io.backend
io.nonblocking io.windows io.windows.nt.backend kernel libc math
threads windows windows.kernel32 alien.c-types alien.arrays
sequences combinators combinators.lib ascii splitting alien
strings ;
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
    dup length 2 = [
        dup first Letter?
        swap second CHAR: : = and
    ] [
        drop f
    ] if ;

: root-directory ( string -- string' )
    {
        [ dup length 2 >= ]
        [ dup second CHAR: : = ]
        [ dup first Letter? ]
    } && [ 2 head ] [ "Not an absolute path" throw ] if ;

: prepend-prefix ( string -- string' )
    unicode-prefix swap append ;

: windows-path+ ( cwd path -- newpath )
    {
        ! empty
        { [ dup empty? ] [ "empty path" throw ] }
        ! \\\\?\\c:\\foo
        { [ dup unicode-prefix head? ] [ nip ] }
        ! ..\\foo
        { [ dup "..\\" head? ] [ >r parent-directory r> 2 tail windows-path+ ] }
        ! .\\foo
        { [ dup ".\\" head? ] [ 1 tail append prepend-prefix ] }
        ! \\foo
        { [ dup "\\" head? ] [ >r root-directory r> append prepend-prefix ] }
        ! c:\\foo
        { [ dup second CHAR: : = ] [ nip prepend-prefix ] }
        ! foo.txt
        { [ t ] [ [ first CHAR: \\ = "" "\\" ? ] keep 3append prepend-prefix ] }
    } cond ;

M: windows-nt-io normalize-pathname ( string -- string )
    dup string? [ "pathname must be a string" throw ] unless
    "/" split "\\" join
    cwd swap windows-path+
    [ "/\\." member? ] right-trim
    dup peek CHAR: : = [ "\\" append ] when ;

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
    [ [ (flush-output) ] with-port-timeout ] with-destructors ;

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
    [ [ ((wait-to-read)) ] with-port-timeout ] with-destructors ;
