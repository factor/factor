! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: system io.directories io.encodings.utf16n alien.strings
io.pathnames io.backend io.files.windows destructors
kernel accessors calendar windows windows.errors
windows.kernel32 alien.c-types sequences splitting
fry continuations ;
IN: io.directories.windows

M: windows touch-file ( path -- )
    [
        normalize-path
        maybe-create-file [ &dispose ] dip
        [ drop ] [ handle>> f now dup (set-file-times) ] if
    ] with-destructors ;

M: windows move-file ( from to -- )
    [ normalize-path ] bi@ MoveFile win32-error=0/f ;

M: windows delete-file ( path -- )
    normalize-path DeleteFile win32-error=0/f ;

M: windows copy-file ( from to -- )
    dup parent-directory make-directories
    [ normalize-path ] bi@ 0 CopyFile win32-error=0/f ;

M: windows make-directory ( path -- )
    normalize-path
    f CreateDirectory win32-error=0/f ;

M: windows delete-directory ( path -- )
    normalize-path
    RemoveDirectory win32-error=0/f ;

: find-first-file ( path -- WIN32_FIND_DATA handle )
    "WIN32_FIND_DATA" <c-object>
    [ nip ] [ FindFirstFile ] 2bi
    [ INVALID_HANDLE_VALUE = [ win32-error-string throw ] when ] keep ;

: find-next-file ( path -- WIN32_FIND_DATA/f )
    "WIN32_FIND_DATA" <c-object>
    [ nip ] [ FindNextFile ] 2bi 0 = [
        GetLastError ERROR_NO_MORE_FILES = [
            win32-error
        ] unless drop f
    ] when ;

TUPLE: windows-directory-entry < directory-entry attributes ;

M: windows >directory-entry ( byte-array -- directory-entry )
    [ WIN32_FIND_DATA-cFileName utf16n alien>string ]
    [ WIN32_FIND_DATA-dwFileAttributes win32-file-type ]
    [ WIN32_FIND_DATA-dwFileAttributes win32-file-attributes ]
    tri
    dupd remove windows-directory-entry boa ;

M: windows (directory-entries) ( path -- seq )
    "\\" ?tail drop "\\*" append
    find-first-file [ >directory-entry ] dip
    [
        '[
            [ _ find-next-file dup ]
            [ >directory-entry ]
            produce nip
            over name>> "." = [ nip ] [ swap prefix ] if
        ]
    ] [ '[ _ FindClose win32-error=0/f ] ] bi [ ] cleanup ;

