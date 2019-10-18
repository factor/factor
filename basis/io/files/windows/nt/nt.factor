USING: accessors alien.c-types alien.strings classes.struct
combinators combinators.short-circuit continuations environment
io.backend io.backend.windows io.encodings.utf16n
io.files.private io.files.windows io.pathnames kernel math
sequences specialized-arrays system tr
windows windows.errors windows.kernel32 windows.shell32
windows.time ;
SPECIALIZED-ARRAY: ushort
IN: io.files.windows.nt

M: winnt cwd
    MAX_UNICODE_PATH dup <ushort-array>
    [ GetCurrentDirectory win32-error=0/f ] keep
    utf16n alien>string ;

M: winnt cd
    SetCurrentDirectory win32-error=0/f ;

CONSTANT: unicode-prefix "\\\\?\\"

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
    absolute-path
    normalize-separators
    prepend-prefix ;

M: winnt CreateFile-flags ( DWORD -- DWORD )
    FILE_FLAG_OVERLAPPED bitor ;

<PRIVATE

: windows-file-size ( path -- size )
    normalize-path 0 WIN32_FILE_ATTRIBUTE_DATA <struct>
    [ GetFileAttributesEx win32-error=0/f ] keep
    [ nFileSizeLow>> ] [ nFileSizeHigh>> ] bi >64bit ;

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
