! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private namespaces io
strings sequences math generic threads.private classes
io.backend io.streams.lines io.streams.plain io.streams.duplex
io.files continuations ;
IN: io.streams.c

TUPLE: c-writer handle ;

C: <c-writer> c-writer

M: c-writer stream-write1
    >r 1string r> stream-write ;

M: c-writer stream-write
    c-writer-handle fwrite ;

M: c-writer stream-flush
    c-writer-handle fflush ;

M: c-writer dispose
    c-writer-handle fclose ;

TUPLE: c-reader handle ;

C: <c-reader> c-reader

M: c-reader stream-read
    >r >fixnum r> c-reader-handle fread ;

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
    [ swap read-until-loop ] "" make swap
    over empty? over not and [ 2drop f f ] when ;

M: c-reader dispose
    c-reader-handle fclose ;

: <duplex-c-stream> ( in out -- stream )
    >r <c-reader> <line-reader> r>
    <c-writer> <plain-writer>
    <duplex-stream> ;

M: object init-io ;

: stdin-handle 11 getenv ;
: stdout-handle 12 getenv ;
: stderr-handle 38 getenv ;

M: object init-stdio
    stdin-handle stdout-handle <duplex-c-stream> stdio set-global
    stderr-handle <c-writer> <plain-writer> stderr set-global ;

M: object io-multiplex (sleep) ;

M: object <file-reader>
    "rb" fopen <c-reader> <line-reader> ;

M: object <file-writer>
    "wb" fopen <c-writer> <plain-writer> ;

M: object <file-appender>
    "ab" fopen <c-writer> <plain-writer> ;

: show ( msg -- )
    #! A word which directly calls primitives. It is used to
    #! print stuff from contexts where the I/O system would
    #! otherwise not work (tools.deploy.shaker, the I/O
    #! multiplexer thread).
    "\r\n" append stdout-handle fwrite stdout-handle fflush ;
