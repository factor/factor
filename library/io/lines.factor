! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: errors generic io kernel math namespaces sequences ;

TUPLE: line-reader cr ;

C: line-reader ( stream -- line ) [ set-delegate ] keep ;

: cr> dup line-reader-cr f rot set-line-reader-cr ;

: (read-line) ( ? line -- ? )
    #! The flag is set after the first character is read.
    dup delegate stream-read1 dup [
        >r >r drop t r> r> dup CHAR: \r = [
            drop t swap set-line-reader-cr
        ] [
            dup CHAR: \n = [
                drop dup cr> [ (read-line) ] [ drop ] ifte
            ] [
                , (read-line)
            ] ifte
        ] ifte
    ] [
        2drop
    ] ifte ;

M: line-reader stream-readln ( line -- string )
    [ f swap (read-line) ] make-string
    dup empty? [ f ? ] [ nip ] ifte ;

M: line-reader stream-read ( count line -- string )
    [ delegate stream-read ] keep dup cr> [
        over empty? [
            drop
        ] [
            >r 1 swap tail r> stream-read1 [ add ] when*
        ] ifte
    ] [
        drop
    ] ifte ;

! Reading lines and counting line numbers.
SYMBOL: line-number
SYMBOL: parser-stream

: next-line ( -- str )
    parser-stream get stream-readln
    line-number [ 1 + ] change ;

: read-lines ( stream quot -- )
    #! Apply a quotation to each line as its read. Close the
    #! stream.
    swap [
        parser-stream set 0 line-number set [ next-line ] while
    ] [
        parser-stream get stream-close rethrow
    ] catch ;
