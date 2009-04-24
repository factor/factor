USING: continuations destructors io.buffers io.files io.backend
io.timeouts io.ports io.pathnames io.files.private
io.backend.windows io.files.windows io.encodings.utf16n windows
windows.kernel32 kernel libc math threads system environment
alien.c-types alien.arrays alien.strings sequences combinators
combinators.short-circuit ascii splitting alien strings assocs
namespaces make accessors tr windows.time windows.shell32 ;
IN: io.files.windows.nt

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
        { [ dup empty? ] [ drop f ] }
        { [ dup [ path-separator? ] all? ] [ drop t ] }
        { [ dup trim-tail-separators { [ length 2 = ]
          [ second CHAR: : = ] } 1&& ] [ drop t ] }
        { [ dup unicode-prefix head? ]
          [ trim-tail-separators length unicode-prefix length 2 + = ] }
        [ drop f ]
    } cond ;

: prepend-prefix ( string -- string' )
    dup unicode-prefix head? [
        unicode-prefix prepend
    ] unless ;

TR: normalize-separators "/" "\\" ;

M: winnt normalize-path ( string -- string' )
    (normalize-path)
    normalize-separators
    prepend-prefix ;

M: winnt CreateFile-flags ( DWORD -- DWORD )
    FILE_FLAG_OVERLAPPED bitor ;

<PRIVATE

: windows-file-size ( path -- size )
    normalize-path 0 "WIN32_FILE_ATTRIBUTE_DATA" <c-object>
    [ GetFileAttributesEx win32-error=0/f ] keep
    [ WIN32_FILE_ATTRIBUTE_DATA-nFileSizeLow ]
    [ WIN32_FILE_ATTRIBUTE_DATA-nFileSizeHigh ] bi >64bit ;

PRIVATE>

M: winnt open-append
    [ dup windows-file-size ] [ drop 0 ] recover
    [ (open-append) ] dip >>ptr ;

M: winnt home
    {
        [ "HOMEDRIVE" os-env "HOMEPATH" os-env append-path ]
        [ "USERPROFILE" os-env ]
        [ my-documents ]
    } 0|| ;
