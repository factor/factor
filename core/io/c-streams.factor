! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: c-streams
USING: errors kernel kernel-internals namespaces io strings
sequences math ;

! Simple wrappers for ANSI C I/O functions, used for
! bootstrapping only.

! More elaborate platform-specific I/O code is used on Unix and
! Windows; see core/unix and core/win32.

TUPLE: c-stream in out ;

M: c-stream stream-write1
    >r 1string r> stream-write ;

M: c-stream stream-write
    c-stream-out fwrite ;

M: c-stream stream-read
    >r >fixnum r> c-stream-in dup [ fread ] [ 2drop f ] if ;

M: c-stream stream-read1
    c-stream-in dup [ fgetc ] when ;

: read-until-loop ( stream delim -- ch )
    over stream-read1 dup [
        dup pick memq? [ 2nip ] [ , read-until-loop ] if
    ] [
        2nip
    ] if ;

M: c-stream stream-read-until
    [ swap read-until-loop ] "" make swap
    over empty? over not and [ 2drop f f ] when ;

M: c-stream stream-flush
    c-stream-out [ fflush ] when* ;

M: c-stream stream-close
    dup c-stream-in [ fclose ] when*
    c-stream-out [ fclose ] when* ;

: <duplex-c-stream> ( in out -- stream )
    >r f <c-stream> <line-reader> f r> <c-stream> <plain-writer>
    <duplex-stream> ;

: init-c-io ( -- )
    13 getenv 14 getenv <duplex-c-stream> stdio set ;

IN: io-internals

: init-io init-c-io ;

: io-multiplex ( ms -- ) drop ;

IN: io

: <file-reader> ( path -- stream )
    "rb" fopen f <c-stream> <line-reader> ;

: <file-writer> ( path -- stream )
    "wb" fopen f swap <c-stream> <plain-writer> ;

TUPLE: client-stream host port ;

TUPLE: c-stream-error ;
: c-stream-error ( -- * ) <c-stream-error> throw ;

: <client> ( host port -- stream ) c-stream-error ;
: <server> ( port -- server ) c-stream-error ;
: accept ( server -- stream ) c-stream-error ;
