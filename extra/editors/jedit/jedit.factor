! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions io kernel math
namespaces parser prettyprint sequences strings words
editors io.files io.sockets io.streams.string io.binary
math.parser ;
IN: editors.jedit

: jedit-server-info ( -- port auth )
    home "/.jedit/server" path+ <file-reader> [
        readln drop
        readln string>number
        readln string>number
    ] with-stream ;

: make-jedit-request ( files -- code )
    [
        "EditServer.handleClient(false,false,false," write
        cwd pprint
        "," write
        "new String[] {" write
        [ pprint "," write ] each
        "null});\n" write
    ] string-out ;

: send-jedit-request ( request -- )
    jedit-server-info swap "localhost" swap <inet> <client> [
        4 >be write
        dup length 2 >be write
        write
    ] with-stream ;

: jedit-location ( file line -- )
    number>string "+line:" swap append 2array
    make-jedit-request send-jedit-request ;

: jedit-file ( file -- )
    1array make-jedit-request send-jedit-request ;

[ jedit-location ] edit-hook set-global
