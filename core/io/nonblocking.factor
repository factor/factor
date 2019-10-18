! Copyright (C) 2007 Slava Pestov, Doug Coleman
! See http://factorcode.org/license.txt for BSD license.
IN: nonblocking-io
USING: math kernel io sequences buffers generic sbufs
errors ;

: default-buffer-size 64 1024 * ; inline

! Common delegate of native stream readers and writers
TUPLE: port handle error timeout cutoff type eof? ;

SYMBOL: input
SYMBOL: output
SYMBOL: closed

PREDICATE: port input-port port-type input eq? ;
PREDICATE: port output-port port-type output eq? ;

GENERIC: init-handle ( handle -- )

C: port ( handle buffer -- port )
    pick init-handle
    [ set-delegate ] keep
    [ set-port-handle ] keep
    [ 0 swap set-port-timeout ] keep
    [ 0 swap set-port-cutoff ] keep ;

: <buffered-port> ( handle -- port )
    default-buffer-size <buffer> <port> ;

: <reader> ( handle -- stream )
    <buffered-port> input over set-port-type <line-reader> ;

: <writer> ( handle -- stream )
    <buffered-port> output over set-port-type <plain-writer> ;

: touch-port ( port -- )
    dup port-timeout dup zero?
    [ 2drop ] [ millis + swap set-port-cutoff ] if ;

: timeout? ( port -- ? )
    port-cutoff dup zero? not swap millis < and ;

: pending-error ( port -- )
    dup port-error f rot set-port-error [ throw ] when* ;

M: port set-timeout
    [ set-port-timeout ] keep touch-port ;

GENERIC: (wait-to-read) ( port -- )

: wait-to-read ( count port -- )
    tuck buffer-length > [ (wait-to-read) ] [ drop ] if ;

: wait-to-read1 ( port -- )
    1 swap wait-to-read ;

: unless-eof ( port quot -- value )
    >r dup buffer-empty? over port-eof? and
    [ f swap set-port-eof? f ] r> if ; inline

M: input-port stream-read1
    dup wait-to-read1 [ buffer-pop ] unless-eof ;

: read-step ( count port -- string/f )
    [ wait-to-read ] 2keep
    [ dupd buffer> ] unless-eof nip ;

: read-loop ( count port sbuf -- )
    pick over length - dup 0 > [
        pick read-step dup [
            over push-all read-loop
        ] [
            2drop 2drop
        ] if
    ] [
        2drop 2drop
    ] if ;

M: input-port stream-read
    >r 0 max >fixnum r>
    2dup read-step dup [
        pick over length > [
            pick <sbuf>
            [ push-all ] keep
            [ read-loop ] keep
            "" like
        ] [
            2nip
        ] if
    ] [
        2nip
    ] if ;

: read-until-step ( seps port -- str/f sep/f )
    #! If we reached EOF, output f f, otherwise scan the buffer
    #! for separators and output a string. If a separator is
    #! found, output it, otherwise f.
    dup wait-to-read1
    dup port-eof? [
        f swap set-port-eof? drop f f
    ] [
        buffer-until
    ] if ;

: read-until-loop ( seps port sbuf -- sep/f )
    #! Keep reading until either we hit a separator, or EOF.
    #! Append results to the sbuf.
    pick pick read-until-step over [
        >r over push-all r> dup [
            >r 3drop r>
        ] [
            drop read-until-loop
        ] if
    ] [
        >r 2drop 2drop r>
    ] if ;

M: input-port stream-read-until ( seps port -- str/f sep/f )
    #! If one read gives us all we need, return immediately,
    #! otherwise begin building up an sbuf.
    2dup read-until-step dup [
        2swap 2drop
    ] [
        over [
            drop >sbuf [ read-until-loop ] keep "" like swap
        ] [
            2swap 2drop
        ] if
    ] if ;

: can-write? ( len writer -- ? )
    #! If the buffer is empty and the string is too long,
    #! extend the buffer.
    dup buffer-empty? [
        2drop t
    ] [
        [ buffer-fill + ] keep buffer-capacity <=
    ] if ;

: wait-to-write ( len port -- )
    tuck can-write? [ drop ] [ stream-flush ] if ;

M: output-port stream-write1
    1 over wait-to-write ch>buffer ;

M: output-port stream-write
    over length over wait-to-write >buffer ;

