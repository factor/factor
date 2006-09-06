! Copyright (C) 2004, 2006 Mackenzie Straight, Doug Coleman.

IN: win32-stream
USING: alien generic hashtables io-internals kernel
kernel-internals math namespaces prettyprint sequences
io strings threads win32-api win32-io-internals ;

TUPLE: win32-stream handle in-buffer out-buffer fileptr file-size timeout cutoff ;

: win32-buffer-size 16384 ; inline

: pending-error ( len/status -- len/status )
    dup [ win32-throw-error ] unless ;

: init-overlapped ( fileptr overlapped -- overlapped )
    0 over set-overlapped-ext-internal
    0 over set-overlapped-ext-internal-high
    >r dup 0 ? r> [ set-overlapped-ext-offset ] keep
    0 over set-overlapped-ext-offset-high
    f over set-overlapped-ext-event ;

: update-file-pointer ( whence stream -- )
    dup win32-stream-file-size [
        [ win32-stream-fileptr + ] keep set-win32-stream-fileptr
    ] [
        2drop
    ] if ;

: update-timeout ( stream -- )
    dup win32-stream-timeout
    [ millis + swap set-win32-stream-cutoff ] [ drop ] if* ;

: >string-or-f ( sbuf -- str-or-? )
    dup length zero? [ drop f ] [ >string ] if ;

! Read
: fill-input ( stream -- )
    dup update-timeout
    dup unit
    [
        [ alloc-io-callback ] keep
        win32-stream-fileptr swap init-overlapped >r
    ] append
    over win32-stream-handle unit append
    over win32-stream-in-buffer unit append
    [
        [ buffer@ ] keep 
        buffer-capacity
    ] append
    over win32-stream-file-size unit append
    over win32-stream-fileptr [ - min ] curry
    [ when* f r> ReadFile [ handle-io-error ] unless stop ]
    curry append
    callcc1 pending-error
    [ over win32-stream-in-buffer n>buffer ] keep
    swap update-file-pointer ;

: consume-input ( count stream -- str ) 
    dup win32-stream-in-buffer buffer-length zero? [ dup fill-input ] when
    win32-stream-in-buffer
    [ buffer-size min ] keep
    [ buffer-first-n ] 2keep
    buffer-consume ;

: do-read-count ( stream sbuf count -- str )
    #! Keep reading until count is reached or until stream end (f is returned)
    dup zero? [ 
        drop >string nip
    ] [
        pick dupd consume-input
        dup empty? [
            2drop >string-or-f nip dup f =
            [ "Stream closed" throw ] when ! XXX: what do we do here?
        ] [
            swapd over >r nappend r>
            [ length - ] keep swap do-read-count
        ] if
    ] if ;

! Write
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
    >r 1 r> consume-input >string-or-f first ;
M: win32-stream stream-read ( n stream -- str/f )
    >r [ <sbuf> ] keep r> -rot do-read-count ;

M: win32-stream stream-flush ( stream -- ) maybe-flush-output ;
M: win32-stream stream-write1 ( ch stream -- ) >r >fixnum r> do-write ;
M: win32-stream stream-write ( str stream -- ) do-write ;

M: win32-stream set-timeout ( n stream -- ) set-win32-stream-timeout ;

M: win32-stream expire ( stream -- )
    dup win32-stream-timeout millis pick win32-stream-cutoff > and [
        win32-stream-handle CancelIo [ win32-throw-error ] unless
    ] [
        drop
    ] if ;

C: win32-stream ( handle -- stream )
    [ set-win32-stream-handle ] keep
    win32-buffer-size <buffer> swap [ set-win32-stream-in-buffer ] keep
    win32-buffer-size <buffer> swap [ set-win32-stream-out-buffer ] keep
    0 swap [ set-win32-stream-fileptr ] keep
    dup win32-stream-handle f GetFileSize dup -1 = [ drop f ] when
        swap [ set-win32-stream-file-size ] keep
    f swap [ set-win32-stream-timeout ] keep
    0 swap [ set-win32-stream-cutoff ] keep ;

: <win32-file-reader> ( path -- stream )
    t f win32-open-file <win32-stream> <line-reader> ;

: <win32-file-writer> ( path -- stream )
    f t win32-open-file <win32-stream> <plain-writer> ;

