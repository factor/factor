! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io-internals
USING: errors kernel kernel-internals namespaces io
strings threads ;

! Simple wrappers for ANSI C I/O functions, used for
! bootstrapping only.

! More elaborate platform-specific I/O code is used on Unix and
! Windows; see library/unix and library/win32.

TUPLE: c-stream in out flush? ;

M: c-stream stream-write1 ( char stream -- )
    >r ch>string r> c-stream-out fwrite ;

M: c-stream stream-write-attr ( str style stream -- )
    nip c-stream-out fwrite ;

M: c-stream stream-read1 ( stream -- char/f )
    c-stream-in dup [ fgetc ] when ;

M: c-stream stream-flush ( stream -- )
    c-stream-out [ fflush ] when* ;

M: c-stream stream-finish ( stream -- )
    dup c-stream-flush? [ stream-flush ] [ drop ] ifte ;

M: c-stream stream-close ( stream -- )
    dup c-stream-in [ fclose ] when*
    c-stream-out [ fclose ] when* ;

: init-io ( -- )
    13 getenv  14 getenv  t <c-stream> <line-reader> stdio set ;

IN: io

: <file-reader> ( path -- stream )
    "rb" fopen f f <c-stream> <line-reader> ;

: <file-writer> ( path -- stream )
    "wb" fopen f swap f <c-stream> ;

TUPLE: client-stream host port ;

: c-stream-error
    "C-streams I/O does not support this feature" throw ;

: <client> c-stream-error ;
: <server> c-stream-error ;
: accept c-stream-error ;
