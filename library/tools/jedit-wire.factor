! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: jedit
USING: generic kernel listener lists namespaces parser
prettyprint stdio streams strings words ;

! Wire protocol for jEdit to evaluate Factor code.
! Packets are of the form:
!
! 4 bytes length
! <n> bytes data
!
! jEdit sends a packet with code to eval, it receives the output
! captured with with-string.

: write-packet ( string -- )
    dup string-length write-big-endian-32 write flush ;

: read-packet ( -- string )
    read-big-endian-32 read ;

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
    CHAR: w write
    [ swap . . ] with-string
    dup string-length write-big-endian-32
    write ;

TUPLE: jedit-stream ;

M: jedit-stream stream-readln ( stream -- str )
    wrapper-stream-scope
    [ CHAR: r write flush read-big-endian-32 read ] bind ;

M: jedit-stream stream-write-attr ( str style stream -- )
    wrapper-stream-scope [ jedit-write-attr ] bind ;

M: jedit-stream stream-flush ( stream -- )
    wrapper-stream-scope
    [ CHAR: f write flush ] bind ;

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

: completions ( str anywhere vocabs -- list )
    #! Make a list of completions. Each element of the list is
    #! a name/vocabulary pair.
    [
        [
            >r 2dup r> swap [
                vocab-apropos
            ] [
                vocab-completions
            ] ifte [ jedit-lookup , ] each
        ] each
    ] make-list ;
