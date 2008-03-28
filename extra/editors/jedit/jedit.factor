! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions io kernel math
namespaces parser prettyprint sequences strings words
editors io.files io.sockets io.streams.byte-array io.binary
math.parser io.encodings.ascii io.encodings.binary
io.encodings.utf8 ;
IN: editors.jedit

: jedit-server-info ( -- port auth )
    home ".jedit/server" append-path ascii [
        readln drop
        readln string>number
        readln string>number
    ] with-file-reader ;

: make-jedit-request ( files -- code )
    utf8 [
        "EditServer.handleClient(false,false,false," write
        cwd pprint
        "," write
        "new String[] {" write
        [ pprint "," write ] each
        "null});\n" write
    ] with-byte-writer ;

: send-jedit-request ( request -- )
    jedit-server-info "localhost" rot <inet> binary <client> [
        4 >be write
        dup length 2 >be write
        write
    ] with-stream ;

: jedit-location ( file line -- )
    number>string "+line:" prepend 2array
    make-jedit-request send-jedit-request ;

: jedit-file ( file -- )
    1array make-jedit-request send-jedit-request ;

[ jedit-location ] edit-hook set-global
