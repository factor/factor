USING: alien alien.c-types combinators io io.backend io.buffers
io.files io.ports io.windows kernel libc math namespaces
prettyprint sequences strings threads threads.private
windows windows.kernel32 io.windows.ce.backend system ;
IN: windows.ce.files

! M: wince normalize-path ( string -- string )
    ! dup 1 tail* CHAR: \\ = [ "*" append ] [ "\\*" append ] if ;

M: wince CreateFile-flags ( DWORD -- DWORD )
    FILE_ATTRIBUTE_NORMAL bitor ;
M: wince FileArgs-overlapped ( port -- f ) drop f ;

: finish-read ( port status bytes-ret -- )
    swap [ drop port-errored ] [ swap n>buffer ] if ;

M: win32-file wince-read
    drop
    dup make-FileArgs dup setup-read ReadFile zero?
    swap FileArgs-lpNumberOfBytesRet *uint dup zero? [
        2drop t swap set-port-eof?
    ] [
        finish-read
    ] if ;

M: win32-file wince-write ( port port-handle -- )
    drop dup make-FileArgs dup setup-write WriteFile zero? [
        drop port-errored
    ] [
        FileArgs-lpNumberOfBytesRet *uint
        swap buffer-consume
    ] if ;
