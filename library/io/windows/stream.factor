! Copyright (C) 2004, 2005 Mackenzie Straight.

IN: win32-stream
USING: alien generic hashtables io-internals kernel
kernel-internals math namespaces prettyprint sequences
io strings threads win32-api win32-io-internals ;

TUPLE: win32-stream handle in-buffer out-buffer fileptr file-size timeout cutoff this ;

! remove these symbols
SYMBOL: the-hash
SYMBOL: stream

SYMBOL: handle
SYMBOL: in-buffer
SYMBOL: out-buffer
SYMBOL: fileptr
SYMBOL: file-size
SYMBOL: timeout
SYMBOL: cutoff



GENERIC: do-write

: pending-error ( len/status -- len/status )
    dup [ win32-throw-error ] unless ;

: init-overlapped ( overlapped -- overlapped )
    0 over set-overlapped-ext-internal
    0 over set-overlapped-ext-internal-high
    fileptr get dup 0 ? over set-overlapped-ext-offset
    0 over set-overlapped-ext-offset-high
    f over set-overlapped-ext-event ;

: update-file-pointer ( whence -- )
    file-size get [ fileptr [ + ] change ] [ drop ] if ;

: update-timeout ( -- )
    timeout get [ millis + cutoff set ] when* ;

: flush-output ( -- ) 
    update-timeout [
        stream get alloc-io-callback init-overlapped >r
        handle get out-buffer get [ buffer@ ] keep buffer-length
        f r> WriteFile [ handle-io-error ] unless stop
    ] callcc1 pending-error

    dup update-file-pointer
    out-buffer get [ buffer-consume ] keep 
    buffer-length 0 > [ flush-output ] when ;

! : maybe-flush-output ( buffer -- )
: maybe-flush-output ( -- )
    out-buffer get buffer-length 0 > [ flush-output ] when ;

M: integer do-write
    out-buffer get [ buffer-capacity zero? [ flush-output ] when ] keep
    >r ch>string r> >buffer ;

M: string do-write
    dup length out-buffer get buffer-capacity <= [
        out-buffer get >buffer
    ] [
        dup length out-buffer get buffer-size > [
            dup length out-buffer get extend-buffer do-write
        ] [ flush-output do-write ] if
    ] if ;

: fill-input ( -- ) 
    update-timeout [
        stream get alloc-io-callback init-overlapped >r
        handle get in-buffer get [ buffer@ ] keep 
        buffer-capacity file-size get [ fileptr get - min ] when*
        f r>
        ReadFile [ handle-io-error ] unless stop
    ] callcc1 pending-error

    dup in-buffer get n>buffer update-file-pointer ;

: consume-input ( count -- str ) 
    in-buffer get buffer-length zero? [ fill-input ] when
    in-buffer get buffer-size min
    dup in-buffer get buffer-first-n
    swap in-buffer get buffer-consume ;

: >string-or-f ( sbuf -- str-or-? )
    dup length 0 > [ >string ] [ drop f ] if ;

: do-read-count ( sbuf count -- str )
    dup zero? [ 
        drop >string 
    ] [
        dup consume-input
        dup length dup zero? [
            3drop >string-or-f
        ] [
            >r swap r> - >r swap [ swap nappend ] keep r> do-read-count
        ] if
    ] if ;






! : peek-input ( -- str ) 1 in-buffer get buffer-first-n ;

: synch-win32-stream ( win32-stream -- )
    win32-stream-this the-hash set
    ;







M: win32-stream stream-write ( str stream -- )
    win32-stream-this [ do-write ] bind
    ;

M: win32-stream stream-write1 ( ch stream -- )
    win32-stream-this [ >fixnum do-write ] bind ;

M: win32-stream stream-read ( n stream -- str/f )
    win32-stream-this [ dup <sbuf> swap do-read-count ] bind ;

M: win32-stream stream-read1 ( stream -- ch/f )
    win32-stream-this [
        1 consume-input dup length zero? [ drop f ] when first 
    ] bind ;

M: win32-stream stream-readln ( stream -- str )
    win32-stream-this [ readln ] bind ;
    ! win32-stream-in-buffer readln ;

M: win32-stream stream-terpri ( stream -- )
    win32-stream-this [ CHAR: \n do-write ] bind ;

M: win32-stream stream-flush ( stream -- )
    win32-stream-this [ maybe-flush-output ] bind ;

M: win32-stream stream-close ( stream -- )
    win32-stream-this [
        maybe-flush-output
        handle get CloseHandle drop 
        in-buffer get buffer-free 
        out-buffer get buffer-free
    ] bind
    ;

M: win32-stream stream-format ( str style stream -- )
    win32-stream-this [ drop do-write ] bind ;

M: win32-stream set-timeout ( n stream -- )
    win32-stream-this [ timeout set ] bind ;

M: win32-stream expire ! not a generic
    win32-stream-this [
        timeout get [ millis cutoff get > [ handle get CancelIo ] when ] when
    ] bind ;

M: win32-stream with-nested-stream ( quot style stream -- )
    win32-stream-this [ drop stream get swap with-stream* ] bind ;

: make-win32-stream ( handle -- stream )
    [
        dup f GetFileSize dup -1 = not [
            file-size set
        ] [ drop f file-size set ] if
        handle set 
        4096 <buffer> in-buffer set 
        4096 <buffer> out-buffer set
        0 fileptr set 
    ] make-hash
    the-hash set
    handle the-hash get hash
    in-buffer the-hash get hash
    out-buffer the-hash get hash
    fileptr the-hash get hash
    file-size the-hash get hash
    f 0 the-hash get
    <win32-stream> dup stream set ;

: <win32-file-reader> ( path -- stream )
    t f win32-open-file make-win32-stream <line-reader> ;

: <win32-file-writer> ( path -- stream )
    f t win32-open-file make-win32-stream ;

