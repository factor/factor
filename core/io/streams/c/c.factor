! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private namespaces io
strings sequences math generic threads.private classes
io.backend io.streams.lines io.streams.plain io.streams.duplex
io.files ;
IN: io.streams.c

TUPLE: c-writer handle ;

C: <c-writer> c-writer

M: c-writer stream-write1
    >r 1string r> stream-write ;

M: c-writer stream-write
    c-writer-handle fwrite ;

M: c-writer stream-flush
    c-writer-handle fflush ;

M: c-writer stream-close
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

M: c-reader stream-close
    c-reader-handle fclose ;

: <duplex-c-stream> ( in out -- stream )
    >r <c-reader> <line-reader> r>
    <c-writer> <plain-writer>
    <duplex-stream> ;

M: object init-io ;

: stdin 11 getenv ;

: stdout 12 getenv ;

M: object init-stdio
    stdin stdout <duplex-c-stream> stdio set ;

M: object io-multiplex (sleep) ;

M: object <file-reader>
    "rb" fopen <c-reader> <line-reader> ;

M: object <file-writer>
    "wb" fopen <c-writer> <plain-writer> ;

M: object <file-appender>
    "ab" fopen <c-writer> <plain-writer> ;
