! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: system io.directories alien.strings
io.pathnames io.backend io.files.windows destructors
kernel accessors calendar windows windows.errors
windows.kernel32 alien.c-types sequences splitting
fry continuations classes.struct windows.time ;
IN: io.directories.windows

M: windows touch-file ( path -- )
    [
        normalize-path
        maybe-create-file [ &dispose ] dip
        [ drop ] [ handle>> f now dup (set-file-times) ] if
    ] with-destructors ;

M: windows move-file ( from to -- )
    [ normalize-path ] bi@ MoveFile win32-error=0/f ;

M: windows move-file-atomically ( from to -- )
    [ normalize-path ] bi@ 0 MoveFileEx win32-error=0/f ;

ERROR: file-delete-failed path error ;

: delete-file-throws ( path -- )
    DeleteFile win32-error=0/f ;

: delete-read-only-file ( path -- )
    [ set-file-normal-attribute ] [ delete-file-throws ] bi ;

: (delete-file) ( path -- )
    dup DeleteFile 0 = [
        GetLastError ERROR_ACCESS_DENIED =
        [ delete-read-only-file ] [ throw-win32-error ] if
    ] [ drop ] if ;

M: windows delete-file ( path -- )
    absolute-path
    [ (delete-file) ]
    [ \ file-delete-failed boa rethrow ] recover ;

M: windows make-directory ( path -- )
    normalize-path
    f CreateDirectory win32-error=0/f ;

M: windows delete-directory ( path -- )
    normalize-path
    RemoveDirectory win32-error=0/f ;

: find-first-file ( path WIN32_FIND_DATA -- WIN32_FIND_DATA HANDLE )
    [ nip ] [ FindFirstFile ] 2bi
    [ INVALID_HANDLE_VALUE = [ win32-error-string throw ] when ] keep ;

: find-next-file ( HANDLE WIN32_FIND_DATA -- WIN32_FIND_DATA/f )
    [ nip ] [ FindNextFile ] 2bi 0 = [
        GetLastError ERROR_NO_MORE_FILES = [
            win32-error
        ] unless drop f
    ] when ;

TUPLE: windows-directory-entry < directory-entry attributes size ;

C: <windows-directory-entry> windows-directory-entry

: >windows-directory-entry ( WIN32_FIND_DATA -- directory-entry )
    [ cFileName>> alien>native-string ]
    [
        dwFileAttributes>>
        [ win32-file-type ] [ win32-file-attributes ] bi
        dupd remove
    ]
    [ [ nFileSizeLow>> ] [ nFileSizeHigh>> ] bi >64bit ] tri
    <windows-directory-entry> ; inline

M: windows (directory-entries) ( path -- seq )
    "\\" ?tail drop "\\*" append
    WIN32_FIND_DATA <struct>
    find-first-file over
    [ >windows-directory-entry ] 2dip
    [
        '[
            [ _ _ find-next-file dup ]
            [ >windows-directory-entry ]
            produce nip
            over name>> "." = [ nip ] [ swap prefix ] if
        ]
    ] [ drop '[ _ FindClose win32-error=0/f ] ] 2bi [ ] cleanup ;
