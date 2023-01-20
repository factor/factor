! Copyright (C) 2009 Daniel Ehrenberg, Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: byte-vectors io io.private kernel math namespaces sbufs
sequences splitting ;
IN: io.crlf

: crlf ( -- )
    "\r\n" write ;

:: stream-read-crlf ( stream -- seq )
    "\r" stream stream-read-until [
        CHAR: \r assert= stream stream-read1 CHAR: \n assert=
    ] [ f like ] if* ;

: read-crlf ( -- seq )
    input-stream get stream-read-crlf ;

:: stream-read-?crlf ( stream -- seq )
    "\r\n" stream stream-read-until [
        CHAR: \r = [ stream stream-read1 CHAR: \n assert= ] when
    ] [ f like ] if* ;

: read-?crlf ( -- seq )
    input-stream get stream-read-?crlf ;

: crlf>lf ( str -- str' )
    CHAR: \r swap remove ;

! Note: can't use split-lines here
: lf>crlf ( str -- str' )
    "\n" split "\r\n" join ;

:: stream-read1-ignoring-crlf ( stream -- ch )
    stream stream-read1 dup "\r\n" member?
    [ drop stream stream-read1-ignoring-crlf ] when ; inline recursive

: read1-ignoring-crlf ( -- ch )
    input-stream get stream-read1-ignoring-crlf ;

: push-ignoring-crlf ( elt seq -- )
    [ "\r\n" member? not ] swap push-if ;

: push-all-ignoring-crlf ( src dst -- )
    [ push-ignoring-crlf ] curry each ;

:: stream-read-ignoring-crlf ( n stream -- seq/f )
    n stream stream-read dup [
        dup [ "\r\n" member? ] any? [
            stream stream-element-type +byte+ =
            [ n <byte-vector> ] [ n <sbuf> ] if :> accum
            accum push-all-ignoring-crlf

            [ accum length n < and ] [
                n accum length - stream stream-read
                [ accum push-all-ignoring-crlf ] keep
            ] do while

            accum stream stream-exemplar like
        ] when
    ] when ;

: read-ignoring-crlf ( n -- seq/f )
    input-stream get stream-read-ignoring-crlf ;
