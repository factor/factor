! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: jedit
USING: generic kernel listener lists namespaces parser
prettyprint sequences io strings words styles ;

! Wire protocol for jEdit to evaluate Factor code.
! Packets are of the form:
!
! 4 bytes length
! <n> bytes data
!
! jEdit sends a packet with code to eval, it receives the output
! captured with string-out.

: write-len ( seq -- ) length 4 >be write ;

: write-packet ( string -- ) dup write-len write flush ;

: read-packet ( -- string ) 4 read be> read ;

: wire-server ( -- )
    #! Repeatedly read jEdit requests and execute them. Return
    #! on EOF.
    read-packet [ eval>string write-packet wire-server ] when* ;

! Stream protocol for jEdit allows user to interact with a
! Factor listener.
!
! Packets have the following form:
!
! 1 byte -- type. CHAR: w: write, CHAR: r: read CHAR: f flush
! 4 bytes -- for write only -- length of write request
! remaining -- unparsed write request -- string then style

! After a read line request, the server reads a response from
! the client:
! 4 bytes -- length. -1 means EOF
! remaining -- input
: jedit-write-attr ( str style -- )
    CHAR: w write1
    [ drop . f . ] string-out
    dup write-len write ;

TUPLE: jedit-stream ;

M: jedit-stream stream-readln ( stream -- str )
    [ CHAR: r write1 flush 4 read be> read ] with-wrapper ;

M: jedit-stream stream-write-attr ( str style stream -- )
    [ jedit-write-attr ] with-wrapper ;

M: jedit-stream stream-flush ( stream -- )
    [ CHAR: f write1 flush ] with-wrapper ;

C: jedit-stream ( stream -- stream )
    [ >r <wrapper-stream> r> set-delegate ] keep ;

: stream-server ( -- )
    #! Execute this in the inferior Factor.
    stdio [ <jedit-stream> ] change  print-banner ;

: jedit-lookup ( word -- list )
    #! A utility word called by the Factor plugin to get some
    #! required word info.
    dup [
        [
            "vocabulary"
            "name"
            "stack-effect"
        ] [
            dupd word-prop
        ] map >r definer r> cons
    ] when ;

: completions ( str pred -- list | pred: str word -- ? )
    #! Make a list of completions. Each element of the list is
    #! a vocabulary/name/stack-effect triplet list.
    word-subset-with [ jedit-lookup ] map ;
