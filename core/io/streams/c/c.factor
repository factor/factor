! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.strings byte-arrays destructors io
io.backend io.encodings.utf8 io.files kernel kernel.private
make math sequences threads.private ;
IN: io.streams.c

TUPLE: c-stream < disposable handle ;

: new-c-stream ( handle class -- c-stream )
    new-disposable swap >>handle ; inline

M: c-stream dispose* handle>> fclose ;

TUPLE: c-writer < c-stream ;
INSTANCE: c-writer output-stream
INSTANCE: c-writer file-writer

: <c-writer> ( handle -- stream ) c-writer new-c-stream ;

M: c-writer stream-write1 dup check-disposed handle>> fputc ;

M: c-writer stream-write
    dup check-disposed
    [ [ >c-ptr ] [ byte-length ] bi ] [ handle>> ] bi* fwrite ;

M: c-writer stream-flush dup check-disposed handle>> fflush ;

TUPLE: c-reader < c-stream ;
INSTANCE: c-reader input-stream
INSTANCE: c-reader file-reader

: <c-reader> ( handle -- stream ) c-reader new-c-stream ;

M: c-reader stream-read-unsafe dup check-disposed handle>> fread-unsafe ;

M: c-reader stream-read1 dup check-disposed handle>> fgetc ;

: read-until-loop ( stream delim -- ch )
    over stream-read1 dup [
        dup pick member-eq? [ 2nip ] [ , read-until-loop ] if
    ] [
        2nip
    ] if ; inline recursive

M: c-reader stream-read-until
    dup check-disposed
    [ swap read-until-loop ] B{ } make swap
    over empty? over not and [ 2drop f f ] when ;

M: c-io-backend init-io ;

: stdin-handle ( -- alien ) OBJ-STDIN special-object ;
: stdout-handle ( -- alien ) OBJ-STDOUT special-object ;
: stderr-handle ( -- alien ) OBJ-STDERR special-object ;

: init-c-stdio ( -- )
    stdin-handle <c-reader>
    stdout-handle <c-writer>
    stderr-handle <c-writer>
    set-stdio ;

M: c-io-backend init-stdio init-c-stdio ;

M: c-io-backend io-multiplex
    dup 0 = [ drop ] [ 60 60 * 1000 * 1000 * or (sleep) ] if ;

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
    "\n" append >byte-array dup length
    stdout-handle fwrite
    stdout-handle fflush ;
