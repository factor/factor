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

! Read
: fill-input ( -- )
    update-timeout [
        stream get alloc-io-callback init-overlapped >r
        handle get in-buffer get [ buffer@ ] keep 
        buffer-capacity file-size get [ fileptr get - min ] when*
        f r>
        ReadFile [ handle-io-error ] unless stop
    ] callcc1 pending-error
    dup in-buffer get n>buffer update-file-pointer ;

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
: flush-output ( -- ) 
    update-timeout [
        stream get alloc-io-callback init-overlapped >r
        handle get out-buffer get [ buffer@ ] keep buffer-length
        f r> WriteFile [ handle-io-error ] unless stop
    ] callcc1 pending-error
    dup update-file-pointer
    out-buffer get [ buffer-consume ] keep 
    buffer-length 0 > [ flush-output ] when ;

: maybe-flush-output ( buffer -- )
    buffer-length 0 > [ flush-output ] when ;

GENERIC: do-write
M: integer do-write ( buffer integer -- )
    over buffer-capacity zero? [ flush-output ] when
    ch>string swap >buffer ;

M: string do-write ( buffer string -- )
    dup length pick 2dup buffer-capacity <= [
        2drop swap >buffer
    ] [
        2dup buffer-size > [
            extend-buffer 
        ] [
            2drop flush-output
        ] if do-write
    ] if ;

M: win32-stream stream-close ( stream -- )
    win32-stream-this [
        out-buffer get maybe-flush-output
        handle get CloseHandle drop 
        in-buffer get buffer-free 
        out-buffer get buffer-free
    ] bind ;

M: win32-stream stream-read1 ( stream -- ch/f )
    win32-stream-this [
        1 in-buffer get consume-input >string-or-f first
    ] bind ;

M: win32-stream stream-read ( n stream -- str/f )
    win32-stream-this [ dup <sbuf> swap in-buffer get do-read-count ] bind ;

M: win32-stream stream-read ( n stream -- str/f )
    win32-stream-this [ dup <sbuf> swap in-buffer get do-read-count ] bind ;


M: win32-stream stream-flush ( stream -- )
    win32-stream-this [ out-buffer get maybe-flush-output ] bind ;

M: win32-stream stream-write1 ( ch stream -- )
    win32-stream-this [ >r out-buffer get r> >fixnum do-write ] bind ;

M: win32-stream stream-write ( str stream -- )
    win32-stream-this [ >r out-buffer get r> do-write ] bind ;


M: win32-stream set-timeout ( n stream -- )
    win32-stream-this [ timeout set ] bind ;

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

