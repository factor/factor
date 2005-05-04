! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io-internals
USING: errors kernel kernel-internals namespaces stdio streams
strings threads ;

! Simple wrappers for ANSI C I/O functions, used for
! bootstrapping only.

! Note that c-streams are pretty limited and broken. Namely,
! there is a limit of 1024 characters per line, and lines
! containing \0 are not read properly.

! More elaborate platform-specific I/O code is used on Unix and
! Windows; see library/unix and library/win32.

TUPLE: c-stream in out flush? ;

M: c-stream stream-write-attr ( str style stream -- )
    nip >r dup string? [ ch>string ] unless r>
    c-stream-out fwrite ;

M: c-stream stream-readln ( stream -- str )
    dup stream-flush  c-stream-in dup [ fgets ] when ;

M: c-stream stream-flush ( stream -- )
    c-stream-out [ fflush ] when* ;

M: c-stream stream-auto-flush ( stream -- )
    dup c-stream-flush? [ stream-flush ] [ drop ] ifte ;

M: c-stream stream-close ( stream -- )
    dup c-stream-in [ fclose ] when*
    c-stream-out [ fclose ] when* ;

: init-io ( -- )
    13 getenv  14 getenv  t <c-stream> stdio set ;

IN: streams

: <file-reader> ( path -- stream )
    "rb" fopen f f <c-stream> ;

: <file-writer> ( path -- stream )
    "wb" fopen f swap f <c-stream> ;

TUPLE: client-stream host port ;

: c-stream-error
    "C-streams I/O does not support this feature" throw ;

: <client> c-stream-error ;
: <server> c-stream-error ;
: accept c-stream-error ;

: (stream-copy) ( in out -- )
    4096 pick stream-read [
        over stream-write (stream-copy)
    ] [
        2drop
    ] ifte* ;

: stream-copy ( in out -- )
    [
        2dup (stream-copy)
    ] [
        >r stream-close stream-close r> [ rethrow ] when*
    ] catch ;
