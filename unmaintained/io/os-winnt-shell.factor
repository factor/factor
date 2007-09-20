USING: alien calendar io io-internals kernel libs-io math
namespaces prettyprint sequences windows-api ;
IN: shell

TUPLE: winnt-shell ;

T{ winnt-shell } \ shell set-global

TUPLE: file name size mtime attributes ;

: ((directory*)) ( handle -- )
    "WIN32_FIND_DATA" <c-object> [ FindNextFile ] 2keep
    rot zero? [ 2drop ] [ , ((directory*)) ] if ;

: (directory*) ( path -- )
    "WIN32_FIND_DATA" <c-object> [
        FindFirstFile dup INVALID_HANDLE_VALUE = [
            win32-error
        ] when
    ] keep ,
    [ ((directory*)) ] keep FindClose win32-error=0/f ;

: append-star ( path -- path )
    dup peek CHAR: \\ = "*" "\\*" ? append ;

M: winnt-shell directory* ( path -- seq )
    normalize-pathname append-star [ (directory*) ] { } make ;

: WIN32_FIND_DATA>file-size ( WIN32_FILE_ATTRIBUTE_DATA -- n )
    [ WIN32_FIND_DATA-nFileSizeLow ] keep
    WIN32_FIND_DATA-nFileSizeHigh 32 shift + ; 

M: winnt-shell make-file ( WIN32_FIND_DATA -- file )
    [ WIN32_FIND_DATA-cFileName alien>u16-string ] keep
    [ WIN32_FIND_DATA>file-size ] keep
    [
        WIN32_FIND_DATA-ftCreationTime
        FILETIME>timestamp >local-time
    ] keep
    WIN32_FIND_DATA-dwFileAttributes <file> ;

M: winnt-shell file. ( file -- )
    [ [ file-attributes >oct write ] keep ] with-cell
    [ bl ] with-cell
    [ [ file-size unparse write ] keep ] with-cell
    [ bl ] with-cell
    [ [ file-mtime file-time-string write ] keep ] with-cell
    [ bl ] with-cell
    [ file-name write ] with-cell ;

M: winnt-shell touch-file ( path -- )
    #! Set the file write time to 'now'
    normalize-pathname
    dup maybe-create-file [ drop ] [ now set-file-write-time ] if ;

