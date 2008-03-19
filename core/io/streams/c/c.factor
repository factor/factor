! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private namespaces io io.encodings
sequences math generic threads.private classes io.backend
io.streams.duplex io.files continuations byte-arrays ;
IN: io.streams.c

TUPLE: c-writer handle ;

C: <c-writer> c-writer

M: c-writer stream-write1
    c-writer-handle fputc ;

M: c-writer stream-write
    c-writer-handle fwrite ;

M: c-writer stream-flush
    c-writer-handle fflush ;

M: c-writer dispose
    c-writer-handle fclose ;

TUPLE: c-reader handle ;

C: <c-reader> c-reader

M: c-reader stream-read
    c-reader-handle fread ;

M: c-reader stream-read-partial
    stream-read ;

M: c-reader stream-read1
    c-reader-handle fgetc ;

: read-until-loop ( stream delim -- ch )
    over stream-read1 dup [
        dup pick memq? [ 2nip ] [ , read-until-loop ] if
    ] [
        2nip
    ] if ;

M: c-reader stream-read-until
    [ swap read-until-loop ] B{ } make swap
    over empty? over not and [ 2drop f f ] when ;

M: c-reader dispose
    c-reader-handle fclose ;

M: object init-io ;

: stdin-handle 11 getenv ;
: stdout-handle 12 getenv ;
: stderr-handle 38 getenv ;

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
