! Copyright (C) 2004, 2006 Mackenzie Straight, Doug Coleman.

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

: pending-error ( len/status -- len/status )
    dup [ win32-throw-error ] unless ;

: init-overlapped2 ( overlapped -- overlapped )
    0 over set-overlapped-ext-internal
    0 over set-overlapped-ext-internal-high
    fileptr get dup 0 ? over set-overlapped-ext-offset
    0 over set-overlapped-ext-offset-high
    f over set-overlapped-ext-event ;

: init-overlapped ( fileptr overlapped -- overlapped )
    0 over set-overlapped-ext-internal
    0 over set-overlapped-ext-internal-high
    >r dup 0 ? r> [ set-overlapped-ext-offset ] keep
    0 over set-overlapped-ext-offset-high
    f over set-overlapped-ext-event ;

: update-file-pointer2 ( whence -- )
    file-size get [ fileptr [ + ] change ] [ drop ] if ;

: update-file-pointer ( whence stream -- )
    dup win32-stream-file-size [
        [ win32-stream-fileptr + ] keep set-win32-stream-fileptr
    ] [
        2drop
    ] if ;

: update-timeout ( stream -- )
    dup win32-stream-timeout
    [ millis + swap set-win32-stream-cutoff ] [ drop ] if* ;

: update-timeout2 ( stream -- )
    timeout get [ millis + cutoff set ] when* ;

! Read
: fill-input ( -- )
    update-timeout2 [
        stream get alloc-io-callback init-overlapped2 >r
        handle get in-buffer get [ buffer@ ] keep 
        buffer-capacity file-size get [ fileptr get - min ] when*
        f r>
        ReadFile [ handle-io-error ] unless stop
    ] callcc1 pending-error
    dup in-buffer get n>buffer update-file-pointer2 ;

: consume-input ( count buffer -- str ) 
    dup buffer-length zero? [ fill-input ] when
    [ buffer-size min ] keep
    [ buffer-first-n ] 2keep
    buffer-consume ;

: >string-or-f ( sbuf -- str-or-? )
    dup length zero? [ drop f ] [ >string ] if ;

: do-read-count ( buffer sbuf count -- str )
    #! Keep reading until count is reached or until stream end (f is returned)
    dup zero? [ 
        drop >string nip
    ] [
        pick dupd consume-input
        dup empty? [
            2drop >string-or-f nip
        ] [
            rot [ nappend ] 2keep
            >r length - r> swap do-read-count
        ] if
    ] if ;

! Write
USE: errors
: flush-output ( stream -- ) 
    dup update-timeout 
    dup unit
    [
        [ alloc-io-callback ] keep
        win32-stream-fileptr swap init-overlapped >r
    ] append
    over win32-stream-handle unit append
    over win32-stream-out-buffer unit append
    [ 
        [ buffer@ ] keep buffer-length
        f r> WriteFile [ handle-io-error ] unless stop
    ] append
    callcc1 pending-error
    dup pick update-file-pointer
    over win32-stream-out-buffer [ buffer-consume ] keep 
    buffer-length 0 > [ flush-output ] [ drop ] if ;

: maybe-flush-output ( stream -- )
    dup win32-stream-out-buffer buffer-length 0 > [ flush-output ] [ drop ] if ;

G: do-write 1 standard-combination ;
M: integer do-write ( integer stream -- )
    dup win32-stream-out-buffer buffer-capacity zero?
    [ dup flush-output ] when
    >r ch>string r> win32-stream-out-buffer >buffer ;

M: string do-write ( string stream -- )
    over length over win32-stream-out-buffer 2dup buffer-capacity <= [
        2drop win32-stream-out-buffer >buffer
    ] [
        2dup buffer-size > [
            extend-buffer 
        ] [
            2drop dup flush-output
        ] if do-write
    ] if ;

M: win32-stream stream-close ( stream -- )
    dup maybe-flush-output
    dup win32-stream-handle CloseHandle 0 = [ win32-throw-error ] when
    dup win32-stream-in-buffer buffer-free
    win32-stream-out-buffer buffer-free ;

M: win32-stream stream-read1 ( stream -- ch/f )
    win32-stream-this [
        1 in-buffer get consume-input >string-or-f first
    ] bind ;

M: win32-stream stream-read ( n stream -- str/f )
    win32-stream-this [ dup <sbuf> swap in-buffer get do-read-count ] bind ;

M: win32-stream stream-read ( n stream -- str/f )
    win32-stream-this [ dup <sbuf> swap in-buffer get do-read-count ] bind ;


M: win32-stream stream-flush ( stream -- ) maybe-flush-output ;
M: win32-stream stream-write1 ( ch stream -- ) >r >fixnum r> do-write ;
M: win32-stream stream-write ( str stream -- ) do-write ;

M: win32-stream set-timeout ( n stream -- ) set-win32-stream-timeout ;
M: win32-stream expire ( stream -- )
    win32-stream-this [
        timeout get [ millis cutoff get > [ handle get CancelIo ] when ] when
    ] bind ;

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
    f t win32-open-file make-win32-stream <plain-writer> ;

IN: scratchpad
: gg
    "omgomg.txt" <file-writer> [ "zomg" write ] with-stream ;
 
