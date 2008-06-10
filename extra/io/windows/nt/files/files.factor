USING: continuations destructors io.buffers io.files io.backend
io.timeouts io.ports io.windows io.windows.files
io.windows.nt.backend windows windows.kernel32
kernel libc math threads system
alien.c-types alien.arrays alien.strings sequences combinators
combinators.lib sequences.lib ascii splitting alien strings
assocs namespaces io.files.private accessors ;
IN: io.windows.nt.files

M: winnt cwd
    MAX_UNICODE_PATH dup "ushort" <c-array>
    [ GetCurrentDirectory win32-error=0/f ] keep
    utf16n alien>string ;

M: winnt cd
    SetCurrentDirectory win32-error=0/f ;

: unicode-prefix ( -- seq )
    "\\\\?\\" ; inline

M: winnt root-directory? ( path -- ? )
    {
        { [ dup empty? ] [ f ] }
        { [ dup [ path-separator? ] all? ] [ t ] }
        { [ dup right-trim-separators
          { [ dup length 2 = ] [ dup second CHAR: : = ] } 0&& nip ] [
            t
        ] }
        [ f ]
    } cond nip ;

ERROR: not-absolute-path ;

: root-directory ( string -- string' )
    {
        [ dup length 2 >= ]
        [ dup second CHAR: : = ]
        [ dup first Letter? ]
    } 0&& [ 2 head ] [ not-absolute-path ] if ;

: prepend-prefix ( string -- string' )
    dup unicode-prefix head? [
        unicode-prefix prepend
    ] unless ;

M: winnt normalize-path ( string -- string' )
    (normalize-path)
    { { CHAR: / CHAR: \\ } } substitute
    prepend-prefix ;

M: winnt CreateFile-flags ( DWORD -- DWORD )
    FILE_FLAG_OVERLAPPED bitor ;

M: winnt FileArgs-overlapped ( port -- overlapped )
    make-overlapped ;

M: winnt open-append
    [ dup file-info size>> ] [ drop 0 ] recover
    >r (open-append) r> >>ptr ;
