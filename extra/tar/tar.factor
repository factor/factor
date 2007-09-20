USING: combinators io io.files io.streams.duplex
io.streams.string kernel math math.parser
namespaces pack prettyprint sequences strings system ;
USING: hexdump tools.interpreter ;
IN: tar

: zero-checksum 256 ;

TUPLE: tar-header name mode uid gid size mtime checksum typeflag
linkname magic version uname gname devmajor devminor prefix ;

: <tar-header> ( -- obj ) tar-header construct-empty ;

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
    148 swap cut-slice 8 tail-slice
    [ 0 [ + ] reduce ] 2apply + 256 + ;

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
    >r stdio get r> <duplex-stream> [
        (read-data-blocks)
    ] with-stream* ;

: parse-tar-header ( seq -- obj )
    [ header-checksum ] keep over zero-checksum = [
        2drop
        \ tar-header construct-empty
        0 over set-tar-header-size
        0 over set-tar-header-checksum
    ] [
        [ read-tar-header ] string-in
        [ tar-header-checksum = [
                \ checksum-error construct-empty throw
            ] unless
        ] keep
    ] if ;

TUPLE: unknown-typeflag str ;
: <unknown-typeflag> ( ch -- obj )
    1string \ unknown-typeflag construct-boa ;

TUPLE: unimplemented-typeflag header ;
: <unimplemented-typeflag> ( header -- obj )
    global [ "Unimplemented typeflag: " print dup . flush ] bind
    tar-header-typeflag
    1string \ unimplemented-typeflag construct-boa ;

: tar-path+ ( path -- newpath )
    base-dir get swap path+ ;

! Normal file
: typeflag-0
  tar-header-name tar-path+ <file-writer>
  [ read-data-blocks ] keep stream-close ;

! Hard link
: typeflag-1 ( header -- )
   <unimplemented-typeflag> throw ;

! Symlink
: typeflag-2 ( header -- )
    <unimplemented-typeflag> throw ;

! character special
: typeflag-3 ( header -- )
    <unimplemented-typeflag> throw ;

! Block special
: typeflag-4 ( header -- )
    <unimplemented-typeflag> throw ;

! Directory
: typeflag-5 ( header -- )
    tar-header-name tar-path+ make-directories ;

! FIFO
: typeflag-6 ( header -- )
    <unimplemented-typeflag> throw ;

! Contiguous file
: typeflag-7 ( header -- )
    <unimplemented-typeflag> throw ;

! Global extended header
: typeflag-8 ( header -- )
    <unimplemented-typeflag> throw ;

! Extended header
: typeflag-9 ( header -- )
    <unimplemented-typeflag> throw ;

! Global POSIX header
: typeflag-g ( header -- )
    <unimplemented-typeflag> throw ;

! Extended POSIX header
: typeflag-x ( header -- )
    <unimplemented-typeflag> throw ;

! Solaris access control list
: typeflag-A ( header -- )
    <unimplemented-typeflag> throw ;

! GNU dumpdir
: typeflag-D ( header -- )
    <unimplemented-typeflag> throw ;

! Solaris extended attribute file
: typeflag-E ( header -- )
    <unimplemented-typeflag> throw ;

! Inode metadata
: typeflag-I ( header -- )
    <unimplemented-typeflag> throw ;

! Long link name
: typeflag-K ( header -- )
    <unimplemented-typeflag> throw ;

! Long file name
: typeflag-L ( header -- )
    <string-writer> [ read-data-blocks ] keep
    >string [ CHAR: \0 = ] rtrim filename set
    global [ "long filename: " write filename get . flush ] bind
    filename get tar-path+ make-directories ;

! Multi volume continuation entry
: typeflag-M ( header -- )
    <unimplemented-typeflag> throw ;

! GNU long file name
: typeflag-N ( header -- )
    <unimplemented-typeflag> throw ;

! Sparse file
: typeflag-S ( header -- )
    <unimplemented-typeflag> throw ;

! Volume header
: typeflag-V ( header -- )
    <unimplemented-typeflag> throw ;

! Vendor extended header type
: typeflag-X ( header -- )
    <unimplemented-typeflag> throw ;

: (parse-tar) ( -- )
    512 read 
    global [ dup hexdump. flush ] bind
    [
        parse-tar-header
        ! global [ dup tar-header-name [ print flush ] when* ] bind 
        dup tar-header-typeflag
        {
            { CHAR: \0 [ typeflag-0 ] }
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
            [ <unknown-typeflag> throw ]
        } case
        ! dup tar-header-size zero? [
            ! out-stream get [ stream-close ] when
            ! out-stream off
            ! drop
        ! ] [
            ! dup tar-header-name
            ! dup parent-dir base-dir swap path+
            ! global [ dup [ . flush ] when* ] bind 
            ! make-directories <file-writer>
            ! out-stream set
            ! read-tar-blocks
        ! ] if
        (parse-tar)
    ] when* ;

: parse-tar ( path -- obj )
    <file-reader> [
        "tar-test" resource-path base-dir set
        global [ nl nl nl "Starting to parse .tar..." print flush ] bind
        global [ "Expanding to: " write base-dir get . flush ] bind
        (parse-tar)
    ] with-stream ;

