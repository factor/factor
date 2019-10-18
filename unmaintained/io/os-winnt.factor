USING: alien calendar errors generic io io-internals kernel
math namespaces nonblocking-io parser quotations sequences
shuffle windows-api words ;
IN: libs-io

: open-append ( path -- handle )
    normalize-pathname
    GENERIC_WRITE share-mode f OPEN_ALWAYS (open-file) ;

: open-existing ( path -- handle )
    normalize-pathname
    GENERIC_WRITE share-mode f OPEN_EXISTING (open-file) ;

: set-file-ptr ( n stream -- )
    delegate port-handle set-win32-file-ptr ;

: open-or-create ( path -- handle length )
    [ file-length ] keep over [
        open-append swap
    ] [
        nip f t open-file 0
    ] if ;

: maybe-create-file ( path -- ? )
    #! returns true if it created a file
    dup file-length [
        drop f
    ] [
        open-append close-handle t
    ] if ;

: <file-appender> ( path -- stream )
    open-or-create <win32-file> <writer> ;

: delete-file ( path -- )
    normalize-pathname
    DeleteFile win32-error=0/f ;

: move-file ( path newpath -- )
    [ normalize-pathname ] 2apply
    MoveFile win32-error=0/f ;


: create-directory ( path -- )
    normalize-pathname
    f CreateDirectory win32-error=0/f ;

: delete-directory ( path -- )
    normalize-pathname
    RemoveDirectory win32-error=0/f ;

: move-directory ( path newpath -- )
    #! not just an alias; might be different on other platforms
    [ normalize-pathname ] 2apply
    move-file ;


: stat* ( path -- WIN32_FIND_DATA )
    "WIN32_FIND_DATA" <c-object>
    [
        FindFirstFile
        [ INVALID_HANDLE_VALUE = [ win32-error ] when ] keep
        FindClose win32-error=0/f
    ] keep ;

: set-file-time ( path timestamp/f timestamp/f timestamp/f -- )
    #! timestamp order: creation access write
    >r >r >r open-existing dup r> r> r>
    [ timestamp>FILETIME ] 3 napply
    SetFileTime win32-error=0/f
    close-handle ;

: set-file-times ( path timestamp/f timestamp/f -- )
    f -rot set-file-time ;

: set-file-create-time ( path timestamp -- )
    f f set-file-time ;

: set-file-access-time ( path timestamp -- )
    >r f r> f set-file-time ;

: set-file-write-time ( path timestamp -- )
    >r f f r> set-file-time ;

: maybe-make-filetime ( ? -- FILETIME/f )
    [ "FILETIME" <c-object> ] [ f ] if ;

: file-time ( path ? ? ? -- FILETIME/f FILETIME/f FILETIME/f )
    >r >r >r open-existing dup r> r> r>
    [ maybe-make-filetime ] 3 napply
    [ GetFileTime win32-error=0/f close-handle ] 3keep ;

: file-times ( path -- FILETIME FILETIME FILETIME )
    t t t file-time [ FILETIME>timestamp ] 3 napply ;

: file-create-time ( path -- FILETIME )
    t f f file-time 2drop FILETIME>timestamp ;

: file-access-time ( path -- FILETIME )
    f t f file-time drop nip FILETIME>timestamp ;

: file-write-time ( path -- FILETIME )
    f f t file-time 2nip FILETIME>timestamp ;

: attrib ( path -- n )
    [ stat* WIN32_FIND_DATA-dwFileAttributes ] catch
    [ drop 0 ] when ;

: (read-only?) ( mode -- ? )
    FILE_ATTRIBUTE_READONLY bit-set? ;

: read-only? ( path -- ? )
    attrib (read-only?) ;

: (hidden?) ( mode -- ? )
    FILE_ATTRIBUTE_HIDDEN bit-set? ;

: hidden? ( path -- ? )
    attrib (hidden?) ;

: (system?) ( mode -- ? )
    FILE_ATTRIBUTE_SYSTEM bit-set? ;

: system? ( path -- ? )
    attrib (system?) ;

: (directory?) ( mode -- ? )
    FILE_ATTRIBUTE_DIRECTORY bit-set? ;

: directory? ( path -- ? )
    attrib (directory?) ;

: (archive?) ( mode -- ? )
    FILE_ATTRIBUTE_ARCHIVE bit-set? ;
    
: archive? ( path -- ? )
    attrib (archive?) ;

! FILE_ATTRIBUTE_DEVICE
! FILE_ATTRIBUTE_NORMAL
! FILE_ATTRIBUTE_TEMPORARY
! FILE_ATTRIBUTE_SPARSE_FILE
! FILE_ATTRIBUTE_REPARSE_POINT
! FILE_ATTRIBUTE_COMPRESSED
! FILE_ATTRIBUTE_OFFLINE
! FILE_ATTRIBUTE_NOT_CONTENT_INDEXED
! FILE_ATTRIBUTE_ENCRYPTED

! Security tokens
!  http://msdn.microsoft.com/msdnmag/issues/05/03/TokenPrivileges/
! LookupPrivilegeValue  OpenThreadToken [ OpenProcessToken DuplicateTokenEx SetThreadToken ] unless AdjustTokenPrivileges 

: thread-token ( -- token )
    GetCurrentThread ;

: (open-process-token) ( handle -- handle )
    TOKEN_ADJUST_PRIVILEGES TOKEN_QUERY bitor "PHANDLE" <c-object>
    [ OpenProcessToken win32-error=0/f ] keep *void* ;

: open-process-token ( -- handle )
    #! remember to handle-close this
    GetCurrentProcess (open-process-token) ;

: with-process-token ( quot -- )
    #! quot: ( token-handle -- token-handle )
    >r open-process-token r>
    1quotation [ keep ] append
    [ close-handle ] cleanup ; inline

: lookup-privilege ( string -- luid )
    >r f r> "LUID" <c-object>
    [ LookupPrivilegeValue win32-error=0/f ] keep ;

! : with-privileges ( array -- )
    ! ;

! clear 10 [ "LUID" <c-object> [ set-LUID-LowPart ] keep ] map "LUID" !

: make-setter ( type -- word )
    >r "set-" r> "-nth" 3append parse first ;

: >c-array ( array type -- c-array )
    [ >r dup length dup r> <c-array> -rot ] keep
    [ \ pick , make-setter , ] [ ] make 2each ;

! DuplicateHandle
! RegCreateKey RegSetValueEx RegCloseKey  GetProcAddress RegDeleteKey
! LookupAccountSid

