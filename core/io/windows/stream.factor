! Copyright (C) 2006 Mackenzie Straight, Doug Coleman.

IN: win32-stream
USING: alien errors generic hashtables io-internals kernel
kernel-internals math namespaces prettyprint sequences sequences-internals
io strings threads tools win32-api win32-io-internals ;

TUPLE: win32-stream handle timeout cutoff fileptr file-size eof? ;
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

! Read
: (fill-input) ( stream -- )
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

: fill-input ( count stream -- )
    tuck win32-stream-reader-in buffer-length > [
        (fill-input)
    ] [
        drop
    ] if ;

: stream-eof? ( stream -- ? )
    dup win32-stream-eof? [
        drop t
    ] [
        dup win32-stream-file-size [
            [
                dup win32-stream-file-size
                swap win32-stream-fileptr
                - zero?
            ] keep set-win32-stream-eof?
        ] [
            drop
        ] if
        f
    ] if ;

: unless-done ( stream quot -- value )
    over stream-eof? pick win32-stream-reader-in buffer-empty? and
    [ 2drop f ] [ call ] if ;

: stream-read-part ( count stream -- string )
    [ fill-input ] 2keep
    [ dupd win32-stream-reader-in buffer> ] unless-done nip ;

: stream-read-loop ( count stream sbuf -- )
    pick over length - dup 0 > [
        pick stream-read-part dup [
            dup nappend stream-read-loop
        ] [
            2drop 2drop
        ] if
    ] [
        2drop 2drop
    ] if ;

M: win32-stream-reader stream-read ( n stream -- str/f )
    >r 0 max >fixnum r>
    2dup stream-read-part dup [
        pick over length > [
            pick <sbuf>
            [ swap nappend ] keep
            [ stream-read-loop ] keep
            "" like
        ] [
            2nip
        ] if
    ] [
        2nip
    ] if ;

M: win32-stream-reader stream-read1 ( stream -- ch/f )
    1 over fill-input [ win32-stream-reader-in buffer-pop ] unless-done ;

M: win32-stream-reader stream-close ( stream -- )
    dup win32-stream-reader-in buffer-free
    win32-stream-handle CloseHandle win32-error=0 ;

M: win32-stream-writer stream-flush ( stream -- ) maybe-flush-output ;
M: win32-stream-writer stream-write1 ( ch stream -- ) >r >fixnum r> do-write ;
M: win32-stream-writer stream-write ( str stream -- ) do-write ;
M: win32-stream-writer stream-close ( stream -- )
    dup maybe-flush-output
    dup win32-stream-writer-out buffer-free
    win32-stream-handle CloseHandle win32-error=0 ;

M: win32-stream set-timeout ( n stream -- ) set-win32-stream-timeout ;

: expire ( stream -- )
    dup win32-stream-timeout millis pick win32-stream-cutoff > and [
        win32-stream-handle CancelIo [ win32-error ] unless
    ] [
        drop
    ] if ;

C: win32-stream ( handle -- stream )
    [ set-win32-stream-handle ] keep
    f swap [ set-win32-stream-timeout ] keep
    0 swap [ set-win32-stream-cutoff ] keep
    dup win32-stream-handle f GetFileSize dup -1 = [ drop f ] when
    over set-win32-stream-file-size
    dup win32-stream-file-size zero? [ t over set-win32-stream-eof? ] when
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
    win32-stream-handle CloseHandle drop ;
