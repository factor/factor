! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private namespaces make io io.encodings sequences
math generic threads.private classes io.backend io.files
io.encodings.utf8 alien.strings continuations destructors byte-arrays
accessors combinators ;
IN: io.streams.c

TUPLE: c-stream handle disposed ;

M: c-stream dispose* handle>> fclose ;

M: c-stream stream-seek
    handle>> swap {
        { seek-absolute [ 0 ] }
        { seek-relative [ 1 ] }
        { seek-end [ 2 ] }
        [ bad-seek-type ]
    } case fseek ;

TUPLE: c-writer < c-stream ;

: <c-writer> ( handle -- stream ) f c-writer boa ;

M: c-writer stream-element-type drop +byte+ ;

M: c-writer stream-write1 dup check-disposed handle>> fputc ;

M: c-writer stream-write dup check-disposed handle>> fwrite ;

M: c-writer stream-flush dup check-disposed handle>> fflush ;

TUPLE: c-reader < c-stream ;

: <c-reader> ( handle -- stream ) f c-reader boa ;

M: c-reader stream-element-type drop +byte+ ;

M: c-reader stream-read dup check-disposed handle>> fread ;

M: c-reader stream-read-partial stream-read ;

M: c-reader stream-read1 dup check-disposed handle>> fgetc ;

: read-until-loop ( stream delim -- ch )
    over stream-read1 dup [
        dup pick memq? [ 2nip ] [ , read-until-loop ] if
    ] [
        2nip
    ] if ;

M: c-reader stream-read-until
    dup check-disposed
    [ swap read-until-loop ] B{ } make swap
    over empty? over not and [ 2drop f f ] when ;

M: c-io-backend init-io ;

: stdin-handle ( -- alien ) 11 getenv ;
: stdout-handle ( -- alien ) 12 getenv ;
: stderr-handle ( -- alien ) 61 getenv ;

: init-c-stdio ( -- )
    stdin-handle <c-reader>
    stdout-handle <c-writer>
    stderr-handle <c-writer>
    set-stdio ;

M: c-io-backend init-stdio init-c-stdio ;

M: c-io-backend io-multiplex 60 60 * 1000 * 1000 * or (sleep) ;

: fopen ( path mode -- alien )
    [ utf8 string>alien ] bi@ (fopen) ;

M: c-io-backend (file-reader)
    "rb" fopen <c-reader> ;

M: c-io-backend (file-writer)
    "wb" fopen <c-writer> ;

M: c-io-backend (file-appender)
    "ab" fopen <c-writer> ;

: show ( msg -- )
    #! A word which directly calls primitives. It is used to
    #! print stuff from contexts where the I/O system would
    #! otherwise not work (tools.deploy.shaker, the I/O
    #! multiplexer thread).
    "\n" append >byte-array
    stdout-handle fwrite
    stdout-handle fflush ;
