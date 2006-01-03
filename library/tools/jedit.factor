! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: jedit
USING: arrays errors io kernel listener lists math namespaces
parser prettyprint sequences strings words ;

! Some words to send requests to a running jEdit instance to
! edit files and position the cursor on a specific line number.

: jedit-server-info ( -- port auth )
    "~" get "/.jedit/server" append <file-reader> [
        readln drop
        readln string>number
        readln string>number
    ] with-stream ;

: make-jedit-request ( files params -- code )
    [
        "EditServer.handleClient(false,false,false,null," write
        "new String[] {" write
        [ pprint "," write ] each
        "null});\n" write
    ] string-out ;

: send-jedit-request ( request -- )
    jedit-server-info swap "localhost" swap <client> [
        4 >be write
        dup length 2 >be write
        write
    ] with-stream ;

: jedit-line/file ( file line -- )
    number>string "+line:" swap append 2array
    make-jedit-request send-jedit-request ;

: jedit-file ( file -- )
    1array make-jedit-request send-jedit-request ;

: jedit ( word -- )
    #! Note that line numbers here start from 1
    dup word-file swap "line" word-prop jedit-line/file ;

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

: eval>string ( str -- )
    [
        [ [ <string-reader> "Input" parse-stream call ] keep ] try drop
    ] string-out ;

: wire-server ( -- )
    #! Repeatedly read jEdit requests and execute them. Return
    #! on EOF.
    read-packet [ eval>string write-packet wire-server ] when* ;

: jedit-lookup ( word -- list )
    #! A utility word called by the Factor plugin to get some
    #! required word info.
    dup [
        [
            dup definer ,
            dup word-vocabulary ,
            dup word-name ,
            "stack-effect" word-prop ,
        ] [ ] make
    ] when ;

: completions ( str pred -- list | pred: str word -- ? )
    #! Make a list of completions. Each element of the list is
    #! a vocabulary/name/stack-effect triplet list.
    word-subset-with [ jedit-lookup ] map ;

! The telnet server is for the jEdit plugin.
: telnetd ( port -- )
    \ telnetd [ print-banner listener ] with-server ;

: search ( name vocabs -- word )
    dupd [ lookup ] find-with nip lookup ;

IN: shells

: telnet
    "telnetd-port" get string>number telnetd ;

! This is a string since we string>number it above.
global [ "9999" "telnetd-port" set ] bind
