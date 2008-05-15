USING: continuations destructors io.buffers io.files io.backend
io.timeouts io.ports io.windows io.windows.nt.backend
kernel libc math threads windows windows.kernel32 system
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
          { [ dup length 2 = ] [ dup second CHAR: : = ] } && nip ] [
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
    } && [ 2 head ] [ not-absolute-path ] if ;

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
    >r (open-append) r> ;

: update-file-ptr ( n port -- )
    handle>> dup ptr>> [ rot + >>ptr drop ] [ 2drop ] if* ;

: finish-flush ( n port -- )
    [ update-file-ptr ] [ buffer>> buffer-consume ] 2bi ;

: ((wait-to-write)) ( port -- )
    dup make-FileArgs
    tuck setup-write WriteFile
    dupd overlapped-error? [
        >r lpOverlapped>> r>
        [ twiddle-thumbs ] keep
        [ finish-flush ] keep
        dup buffer>> buffer-empty? [ drop ] [ ((wait-to-write)) ] if
    ] [
        2drop
    ] if ;

M: winnt (wait-to-write)
    [ [ ((wait-to-write)) ] with-timeout ] with-destructors ;

: finish-read ( n port -- )
    over zero? [
        t >>eof 2drop
    ] [
        [ buffer>> n>buffer ] [ update-file-ptr ] bi
    ] if ;

: ((wait-to-read)) ( port -- )
    dup make-FileArgs
    tuck setup-read ReadFile
    dupd overlapped-error? [
        >r lpOverlapped>> r>
        [ twiddle-thumbs ] [ finish-read ] bi
    ] [ 2drop ] if ;

M: winnt (wait-to-read) ( port -- )
    [ [ ((wait-to-read)) ] with-timeout ] with-destructors ;
