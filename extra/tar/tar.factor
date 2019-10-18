! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators io io.files io.files.links io.directories
io.pathnames io.streams.string kernel math math.parser
continuations namespaces pack prettyprint sequences strings
system tools.hexdump io.encodings.binary summary accessors
io.backend byte-arrays io.streams.byte-array splitting ;
IN: tar

CONSTANT: zero-checksum 256
CONSTANT: block-size 512

TUPLE: tar-header name mode uid gid size mtime checksum typeflag
linkname magic version uname gname devmajor devminor prefix ;

ERROR: checksum-error header ;

: trim-string ( seq -- newseq ) [ "\0 " member? ] trim ;

: read-c-string ( n -- str/f )
    read [ zero? ] trim-tail [ f ] when-empty >string ;

: read-tar-header ( -- obj )
    \ tar-header new
        100 read-c-string >>name
        8 read-c-string trim-string oct> >>mode
        8 read-c-string trim-string oct> >>uid
        8 read-c-string trim-string oct> >>gid
        12 read-c-string trim-string oct> >>size
        12 read-c-string trim-string oct> >>mtime
        8 read-c-string trim-string oct> >>checksum
        read1 >>typeflag
        100 read-c-string >>linkname
        6 read >>magic
        2 read >>version
        32 read-c-string >>uname
        32 read-c-string >>gname
        8 read trim-string oct> >>devmajor
        8 read trim-string oct> >>devminor
        155 read-c-string >>prefix ;

: checksum-header ( seq -- n )
    148 cut-slice 8 tail-slice [ sum ] bi@ + 256 + ;

: read-data-blocks ( tar-header -- )
    dup size>> 0 > [
        block-size read [
            over size>> dup block-size <= [
                head-slice >byte-array write drop
            ] [
                drop write
                [ block-size - ] change-size
                read-data-blocks
            ] if
        ] [
            drop
        ] if*
    ] [
        drop
    ] if ;

: parse-tar-header ( seq -- obj )
    dup checksum-header dup zero-checksum = [
        2drop
        \ tar-header new
            0 >>size
            0 >>checksum
    ] [
        [
            binary [ read-tar-header ] with-byte-reader
            dup checksum>>
        ] dip = [ checksum-error ] unless
    ] if ;

ERROR: unknown-typeflag ch ;

M: unknown-typeflag summary ( obj -- str )
    ch>> [ "Unknown typeflag: " ] dip prefix ;

: read/write-blocks ( tar-header path -- )
    binary [ read-data-blocks ] with-file-writer ;

: prepend-current-directory ( path -- path' )
    current-directory get prepend-path ;

! Normal file
: typeflag-0 ( header -- )
    dup name>> dup "global_pax_header" = [
        drop [ read-data-blocks ] with-string-writer drop
    ] [
        prepend-current-directory read/write-blocks
    ] if ;

! Hard link
: typeflag-1 ( header -- )
    [ name>> ] [ linkname>> ] bi make-hard-link ;

! Symlink
: typeflag-2 ( header -- )
    [ name>> ] [ linkname>> ] bi make-link ;

! character special
: typeflag-3 ( header -- ) unknown-typeflag ;

! Block special
: typeflag-4 ( header -- ) unknown-typeflag ;

! Directory
: typeflag-5 ( header -- )
    name>> prepend-current-directory make-directories ;

! FIFO
: typeflag-6 ( header -- ) unknown-typeflag ;

! Contiguous file
: typeflag-7 ( header -- ) unknown-typeflag ;

! Global extended header
: typeflag-8 ( header -- ) unknown-typeflag ;

! Extended header
: typeflag-9 ( header -- ) unknown-typeflag ;

! Global POSIX header
: typeflag-g ( header -- ) typeflag-0 ;

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
    drop
    ;
    ! <string-writer> [ read-data-blocks ] keep
    ! >string [ zero? ] trim-tail filename set
    ! filename get prepend-current-directory make-directories ;

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

: parse-tar ( -- )
    block-size read dup length block-size = [
        parse-tar-header
        dup typeflag>>
        {
            { 0 [ typeflag-0 ] }
            { CHAR: 0 [ typeflag-0 ] }
            ! { CHAR: 1 [ typeflag-1 ] }
            { CHAR: 2 [ typeflag-2 ] }
            ! { CHAR: 3 [ typeflag-3 ] }
            ! { CHAR: 4 [ typeflag-4 ] }
            { CHAR: 5 [ typeflag-5 ] }
            ! { CHAR: 6 [ typeflag-6 ] }
            ! { CHAR: 7 [ typeflag-7 ] }
            { CHAR: g [ typeflag-g ] }
            ! { CHAR: x [ typeflag-x ] }
            ! { CHAR: A [ typeflag-A ] }
            ! { CHAR: D [ typeflag-D ] }
            ! { CHAR: E [ typeflag-E ] }
            ! { CHAR: I [ typeflag-I ] }
            ! { CHAR: K [ typeflag-K ] }
            { CHAR: L [ typeflag-L ] }
            ! { CHAR: M [ typeflag-M ] }
            ! { CHAR: N [ typeflag-N ] }
            ! { CHAR: S [ typeflag-S ] }
            ! { CHAR: V [ typeflag-V ] }
            ! { CHAR: X [ typeflag-X ] }
            { f [ drop ] }
        } case parse-tar
    ] [
        drop
    ] if ;

: untar ( path -- )
    normalize-path dup parent-directory [
         binary [ parse-tar ] with-file-reader
    ] with-directory ;
