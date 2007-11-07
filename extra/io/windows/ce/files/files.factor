USING: alien alien.c-types combinators io io.backend io.buffers
io.files io.nonblocking io.windows kernel libc math namespaces
prettyprint sequences strings threads threads.private
windows windows.kernel32 io.windows.ce.backend ;
IN: windows.ce.files

! M: windows-ce-io normalize-pathname ( string -- string )
    ! dup 1 tail* CHAR: \\ = [ "*" append ] [ "\\*" append ] if ;

M: windows-ce-io CreateFile-flags ( -- DWORD ) FILE_ATTRIBUTE_NORMAL ;
M: windows-ce-io FileArgs-overlapped ( port -- f ) drop f ;

M: win32-file wince-read
    drop dup make-FileArgs dup setup-read ReadFile zero? [
        drop port-errored
    ] [
        FileArgs-lpNumberOfBytesRet *uint dup zero? [
            drop
            t swap set-port-eof?
        ] [
            swap n>buffer
        ] if
    ] if ;

M: win32-file wince-write ( port port-handle -- )
    drop dup make-FileArgs dup setup-write WriteFile zero? [
        drop port-errored
    ] [
        FileArgs-lpNumberOfBytesRet *uint ! *DWORD
        over delegate [ buffer-consume ] keep
        buffer-length 0 > [
            flush-output
        ] [
            drop
        ] if
    ] if ;
