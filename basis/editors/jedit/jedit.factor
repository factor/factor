! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays editors io io.binary io.encodings.ascii
io.encodings.binary io.encodings.utf8 io.files io.files.private
io.pathnames io.sockets io.streams.byte-array kernel locals
math.parser namespaces prettyprint sequences ;
IN: editors.jedit

: jedit-server-file ( -- server-files )
    home ".jedit/server" append-path
    home "Library/jEdit/server" append-path 2array
    [ exists? ] find nip ;

: jedit-server-info ( server-file -- port auth )
    ascii [
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

:: send-jedit-request ( request -- )
    jedit-server-file jedit-server-info :> ( port auth )
    "localhost" port <inet> binary [
        auth 4 >be write
        request length 2 >be write
        request write
    ] with-client ;

: jedit-location ( file line -- )
    number>string "+line:" prepend 2array
    make-jedit-request send-jedit-request ;

: jedit-file ( file -- )
    1array make-jedit-request send-jedit-request ;

[ jedit-location ] edit-hook set-global
