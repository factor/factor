! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.strings alien.syntax calendar
classes.struct continuations destructors fry io.backend
io.directories io.files.windows io.pathnames kernel literals
locals math namespaces sequences splitting system threads windows
windows.errors windows.kernel32 windows.time windows.types ;
IN: io.directories.windows

LIBRARY: factor
FUNCTION: void* factor_begin_file_copy
    ( LPCWSTR source, LPCWSTR destination, HANDLE port, ULONG_PTR key )
FUNCTION: DWORD factor_finish_file_copy ( void* copy )

M:: windows copy-file ( from to -- )
    to make-parent-directories drop
    self :> thread
    [ thread resume ] add-completion-action :> key
    f :> copy!
    [
        from normalize-path to normalize-path
        master-completion-port get-global key
        factor_begin_file_copy dup win32-error=0/f copy!
        "file copy" suspend drop
    ] [
        key remove-completion-action
        copy [
            factor_finish_file_copy
            dup zero? [ drop ] [ throw-windows-error ] if
        ] when*
    ] finally ;

M: windows touch-file
    normalize-path maybe-create-file '[
        _ [ drop ] [ handle>> f now dup (set-file-times) ] if
    ] with-disposal ;

: open-truncate ( path -- win32-file )
    GENERIC_WRITE OPEN_EXISTING 0 open-file 0 >>ptr ;

M: windows truncate-file
    [ normalize-path open-truncate ] dip '[
        [ _ FILE_BEGIN set-file-pointer ] [ set-end-of-file ] bi
    ] with-disposal ;

M: windows move-file
    [ normalize-path ] bi@
    flags{ MOVEFILE_REPLACE_EXISTING MOVEFILE_COPY_ALLOWED }
    MoveFileEx win32-error=0/f ;

M: windows move-file-atomically
    [ normalize-path ] bi@ MOVEFILE_REPLACE_EXISTING
    MoveFileEx win32-error=0/f ;

ERROR: file-delete-failed path error ;

: delete-file-throws ( path -- )
    DeleteFile win32-error=0/f ;

: delete-read-only-file ( path -- )
    [ set-file-normal-attribute ] [ delete-file-throws ] bi ;

: (delete-file) ( path -- )
    dup DeleteFile 0 = [
        GetLastError ERROR_ACCESS_DENIED =
        [ delete-read-only-file ] [ drop win32-error ] if
    ] [ drop ] if ;

M: windows delete-file
    absolute-path
    [ (delete-file) ]
    [ file-delete-failed boa rethrow ] recover ;

M: windows make-directory
    normalize-path
    f CreateDirectory win32-error=0/f ;

M: windows delete-directory
    normalize-path
    RemoveDirectory win32-error=0/f ;

: find-first-file ( path WIN32_FIND_DATA -- WIN32_FIND_DATA HANDLE )
    [ nip ] [ FindFirstFile ] 2bi check-invalid-handle ;

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

M: windows (directory-entries)
    "\\" ?tail drop "\\*" append
    WIN32_FIND_DATA new
    find-first-file over
    [ >windows-directory-entry ] 2dip
    [
        '[
            [ _ _ find-next-file dup ]
            [ >windows-directory-entry ]
            produce nip
            over name>> "." = [ nip ] [ swap prefix ] if
        ]
    ] [ drop '[ _ FindClose win32-error=0/f ] ] 2bi finally ;
