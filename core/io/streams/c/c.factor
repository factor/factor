! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private namespaces io io.encodings
sequences math generic threads.private classes io.backend
io.files continuations destructors byte-arrays accessors ;
IN: io.streams.c

TUPLE: c-writer handle disposed ;

: <c-writer> ( handle -- stream ) f c-writer boa ;

M: c-writer stream-write1
    dup check-disposed
    handle>> fputc ;

M: c-writer stream-write
    dup check-disposed
    handle>> fwrite ;

M: c-writer stream-flush
    dup check-disposed
    handle>> fflush ;

M: c-writer dispose*
    handle>> fclose ;

TUPLE: c-reader handle disposed ;

: <c-reader> ( handle -- stream ) f c-reader boa ;

M: c-reader stream-read
    dup check-disposed
    handle>> fread ;

M: c-reader stream-read-partial
    stream-read ;

M: c-reader stream-read1
    dup check-disposed
    handle>> fgetc ;

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

M: c-reader dispose*
    handle>> fclose ;

M: object init-io ;

: stdin-handle 11 getenv ;
: stdout-handle 12 getenv ;
: stderr-handle 61 getenv ;

M: object (init-stdio)
    stdin-handle <c-reader>
    stdout-handle <c-writer>
    stderr-handle <c-writer> ;

M: object io-multiplex 60 60 * 1000 * or (sleep) ;

M: object (file-reader)
    "rb" fopen <c-reader> ;

M: object (file-writer)
    "wb" fopen <c-writer> ;

M: object (file-appender)
    "ab" fopen <c-writer> ;

: show ( msg -- )
    #! A word which directly calls primitives. It is used to
    #! print stuff from contexts where the I/O system would
    #! otherwise not work (tools.deploy.shaker, the I/O
    #! multiplexer thread).
    "\r\n" append >byte-array
    stdout-handle fwrite
    stdout-handle fflush ;
