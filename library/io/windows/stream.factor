! Copyright (C) 2006 Mackenzie Straight, Doug Coleman.

IN: win32-stream
USING: alien errors generic hashtables io-internals kernel
kernel-internals math namespaces prettyprint sequences
io strings threads win32-api win32-io-internals ;

TUPLE: win32-stream handle timeout cutoff fileptr file-size ;
TUPLE: win32-stream-reader in ;
TUPLE: win32-stream-writer out ;
TUPLE: win32-duplex-stream ;

: win32-buffer-size 16384 ; inline

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
    [
        over alloc-io-callback
        over win32-stream-fileptr swap init-overlapped >r
        dup win32-stream-handle
        over win32-stream-reader-in
        [ buffer@ ] keep buffer-capacity
        >r pick r> swap dup win32-stream-file-size
        [ swap win32-stream-fileptr - min ] [ drop ] if*
        f r> ReadFile zero? [ handle-io-error ] when stop
    ] callcc1 [ over win32-stream-reader-in n>buffer ] keep
    swap update-file-pointer ;

: consume-input ( count stream -- str ) 
    dup win32-stream-reader-in buffer-length zero? [ dup fill-input ] when
    win32-stream-reader-in
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
            2drop >string-or-f nip
        ] [
            swapd over >r nappend r>
            [ length - ] keep swap do-read-count
        ] if
    ] if ;

! Write
: flush-output ( stream -- ) 
    dup update-timeout 
    [
        over alloc-io-callback
        over win32-stream-fileptr swap init-overlapped >r
        dup win32-stream-handle
        over win32-stream-writer-out
        [ buffer@ ] keep buffer-length
        f r> WriteFile zero? [ handle-io-error ] when stop
    ] callcc1 [ over update-file-pointer ] keep
    over win32-stream-writer-out [ buffer-consume ] keep 
    buffer-length 0 > [ flush-output ] [ drop ] if ;

: maybe-flush-output ( stream -- )
    dup win32-stream-writer-out buffer-length 0 > [ flush-output ] [ drop ] if ;

G: do-write 1 standard-combination ;
M: integer do-write ( integer stream -- )
    dup win32-stream-writer-out buffer-capacity zero?
    [ dup flush-output ] when
    >r ch>string r> win32-stream-writer-out >buffer ;

M: string do-write ( string stream -- )
    over length over win32-stream-writer-out 2dup buffer-capacity <= [
        2drop win32-stream-writer-out >buffer
    ] [
        2dup buffer-size > [
            extend-buffer 
        ] [
            2drop dup flush-output
        ] if do-write
    ] if ;


M: win32-stream-reader stream-close ( stream -- )
    dup win32-stream-reader-in buffer-free
    win32-stream-handle CloseHandle 0 = [ win32-throw-error ] when ;

M: win32-stream-reader stream-read1 ( stream -- ch/f )
    >r 1 r> consume-input >string-or-f first ;

M: win32-stream-reader stream-read ( n stream -- str/f )
    >r [ <sbuf> ] keep r> -rot do-read-count ;


M: win32-stream-writer stream-close ( stream -- )
    dup maybe-flush-output
    dup win32-stream-writer-out buffer-free
    win32-stream-handle CloseHandle 0 = [ win32-throw-error ] when ;

M: win32-stream-writer stream-flush ( stream -- ) maybe-flush-output ;
M: win32-stream-writer stream-write1 ( ch stream -- ) >r >fixnum r> do-write ;
M: win32-stream-writer stream-write ( str stream -- ) do-write ;

M: win32-stream set-timeout ( n stream -- ) set-win32-stream-timeout ;

: expire ( stream -- )
    dup win32-stream-timeout millis pick win32-stream-cutoff > and [
        win32-stream-handle CancelIo [ win32-throw-error ] unless
    ] [
        drop
    ] if ;

C: win32-stream ( handle -- stream )
    [ set-win32-stream-handle ] keep
    f swap [ set-win32-stream-timeout ] keep
    0 swap [ set-win32-stream-cutoff ] keep
    dup win32-stream-handle f GetFileSize dup -1 = [ drop f ] when
    over set-win32-stream-file-size
    0 swap [ set-win32-stream-fileptr ] keep ;

C: win32-stream-reader ( stream -- stream )
    [ set-delegate ] keep
    win32-buffer-size <buffer> swap [ set-win32-stream-reader-in ] keep ;

C: win32-stream-writer ( stream -- stream )
    [ set-delegate ] keep
    win32-buffer-size <buffer> swap [ set-win32-stream-writer-out ] keep ;

: make-win32-file-reader ( stream -- stream )
    <win32-stream-reader> <line-reader> ;

: <win32-file-reader> ( path -- stream )
    t f win32-open-file <win32-stream> make-win32-file-reader ;

: make-win32-file-writer ( stream -- stream )
    <win32-stream-writer> <plain-writer> ;

: <win32-file-writer> ( path -- stream )
    f t win32-open-file <win32-stream> make-win32-file-writer ;

C: win32-duplex-stream ( stream -- stream )
    >r [ make-win32-file-reader ] keep make-win32-file-writer <duplex-stream> r>
    [ set-delegate ] keep ;

M: win32-duplex-stream stream-close ( stream -- )
    dup duplex-stream-out maybe-flush-output
    dup duplex-stream-out win32-stream-writer-out buffer-free
    dup duplex-stream-in win32-stream-reader-in buffer-free
    duplex-stream-in
    win32-stream-handle CloseHandle drop ; ! 0 = [ win32-throw-error ] when ;

