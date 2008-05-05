USING: combinators io io.files io.streams.string kernel math
math.parser continuations namespaces pack prettyprint sequences
strings system hexdump io.encodings.binary inspector accessors ;
IN: tar

: zero-checksum 256 ;

TUPLE: tar-header name mode uid gid size mtime checksum typeflag
linkname magic version uname gname devmajor devminor prefix ;

: <tar-header> ( -- obj ) tar-header new ;

: tar-trim ( seq -- newseq )
    [ "\0 " member? ] trim ;

: read-tar-header ( -- obj )
    <tar-header>
    100 read-c-string* over set-tar-header-name
    8 read-c-string* tar-trim oct> over set-tar-header-mode
    8 read-c-string* tar-trim oct> over set-tar-header-uid
    8 read-c-string* tar-trim oct> over set-tar-header-gid
    12 read-c-string* tar-trim oct> over set-tar-header-size
    12 read-c-string* tar-trim oct> over set-tar-header-mtime
    8 read-c-string* tar-trim oct> over set-tar-header-checksum
    read1 over set-tar-header-typeflag
    100 read-c-string* over set-tar-header-linkname
    6 read over set-tar-header-magic
    2 read over set-tar-header-version
    32 read-c-string* over set-tar-header-uname
    32 read-c-string* over set-tar-header-gname
    8 read tar-trim oct> over set-tar-header-devmajor
    8 read tar-trim oct> over set-tar-header-devminor
    155 read-c-string* over set-tar-header-prefix ;

: header-checksum ( seq -- x )
    148 cut-slice 8 tail-slice
    [ sum ] bi@ + 256 + ;

TUPLE: checksum-error ;
TUPLE: malformed-block-error ;

SYMBOL: base-dir
SYMBOL: out-stream
SYMBOL: filename

: (read-data-blocks) ( tar-header -- )
    512 read [
        over tar-header-size dup 512 <= [
            head-slice 
            >string write
            drop
        ] [
            drop
            >string write
            dup tar-header-size 512 - over set-tar-header-size
            (read-data-blocks)
        ] if
    ] [
        drop
    ] if* ;

: read-data-blocks ( tar-header out -- )
    [ (read-data-blocks) ] with-output-stream* ;

: parse-tar-header ( seq -- obj )
    [ header-checksum ] keep over zero-checksum = [
        2drop
        \ tar-header new
        0 over set-tar-header-size
        0 over set-tar-header-checksum
    ] [
        [ read-tar-header ] with-string-reader
        [ tar-header-checksum = [
                \ checksum-error new throw
            ] unless
        ] keep
    ] if ;

ERROR: unknown-typeflag ch ;
M: unknown-typeflag summary ( obj -- str )
    ch>> 1string
    "Unknown typeflag: " prepend ;

: tar-append-path ( path -- newpath )
    base-dir get prepend-path ;

! Normal file
: typeflag-0
  name>> tar-append-path binary <file-writer>
  [ read-data-blocks ] keep dispose ;

! Hard link
: typeflag-1 ( header -- ) unknown-typeflag ;

! Symlink
: typeflag-2 ( header -- ) unknown-typeflag ;

! character special
: typeflag-3 ( header -- ) unknown-typeflag ;

! Block special
: typeflag-4 ( header -- ) unknown-typeflag ;

! Directory
: typeflag-5 ( header -- )
    tar-header-name tar-append-path make-directories ;

! FIFO
: typeflag-6 ( header -- ) unknown-typeflag ;

! Contiguous file
: typeflag-7 ( header -- ) unknown-typeflag ;

! Global extended header
: typeflag-8 ( header -- ) unknown-typeflag ;

! Extended header
: typeflag-9 ( header -- ) unknown-typeflag ;

! Global POSIX header
: typeflag-g ( header -- ) unknown-typeflag ;

! Extended POSIX header
: typeflag-x ( header -- ) unknown-typeflag ;

! Solaris access control list
: typeflag-A ( header -- ) unknown-typeflag ;

! GNU dumpdir
: typeflag-D ( header -- ) unknown-typeflag ;

! Solaris extended attribute file
: typeflag-E ( header -- ) unknown-typeflag ;

! Inode metadata
: typeflag-I ( header -- ) unknown-typeflag ;

! Long link name
: typeflag-K ( header -- ) unknown-typeflag ;

! Long file name
: typeflag-L ( header -- )
    <string-writer> [ read-data-blocks ] keep
    >string [ zero? ] right-trim filename set
    global [ "long filename: " write filename get . flush ] bind
    filename get tar-append-path make-directories ;

! Multi volume continuation entry
: typeflag-M ( header -- ) unknown-typeflag ;

! GNU long file name
: typeflag-N ( header -- ) unknown-typeflag ;

! Sparse file
: typeflag-S ( header -- ) unknown-typeflag ;

! Volume header
: typeflag-V ( header -- ) unknown-typeflag ;

! Vendor extended header type
: typeflag-X ( header -- ) unknown-typeflag ;

: (parse-tar) ( -- )
    512 read 
    global [ dup hexdump. flush ] bind
    [
        parse-tar-header
        ! global [ dup tar-header-name [ print flush ] when* ] bind 
        dup tar-header-typeflag
        {
            { 0 [ typeflag-0 ] }
            { CHAR: 0 [ typeflag-0 ] }
            { CHAR: 1 [ typeflag-1 ] }
            { CHAR: 2 [ typeflag-2 ] }
            { CHAR: 3 [ typeflag-3 ] }
            { CHAR: 4 [ typeflag-4 ] }
            { CHAR: 5 [ typeflag-5 ] }
            { CHAR: 6 [ typeflag-6 ] }
            { CHAR: 7 [ typeflag-7 ] }
            { CHAR: g [ typeflag-g ] }
            { CHAR: x [ typeflag-x ] }
            { CHAR: A [ typeflag-A ] }
            { CHAR: D [ typeflag-D ] }
            { CHAR: E [ typeflag-E ] }
            { CHAR: I [ typeflag-I ] }
            { CHAR: K [ typeflag-K ] }
            { CHAR: L [ typeflag-L ] }
            { CHAR: M [ typeflag-M ] }
            { CHAR: N [ typeflag-N ] }
            { CHAR: S [ typeflag-S ] }
            { CHAR: V [ typeflag-V ] }
            { CHAR: X [ typeflag-X ] }
            [ unknown-typeflag ]
        } case
        ! dup tar-header-size zero? [
            ! out-stream get [ dispose ] when
            ! out-stream off
            ! drop
        ! ] [
            ! dup tar-header-name
            ! dup parent-dir base-dir prepend-path
            ! global [ dup [ . flush ] when* ] bind 
            ! make-directories <file-writer>
            ! out-stream set
            ! read-tar-blocks
        ! ] if
        (parse-tar)
    ] when* ;

: parse-tar ( path -- obj )
    binary [
        "resource:tar-test" base-dir set
        global [ nl nl nl "Starting to parse .tar..." print flush ] bind
        global [ "Expanding to: " write base-dir get . flush ] bind
        (parse-tar)
    ] with-file-writer ;
