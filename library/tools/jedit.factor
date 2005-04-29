! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: jedit
USING: files kernel lists namespaces parser sequences stdio
streams strings unparser words ;

: jedit-server-file ( -- path )
    "jedit-server-file" get
    [ "~" get "/.jedit/server" cat2 ] unless* ;

: jedit-server-info ( -- port auth )
    jedit-server-file <file-reader> [
        read-line drop
        read-line parse-number
        read-line parse-number
    ] with-stream ;

: make-jedit-request ( files params -- code )
    [
        "EditServer.handleClient(false,false,false,null," ,
        "new String[] {" ,
        [ unparse , "," , ] each
        "null});\n" ,
    ] make-string ;

: send-jedit-request ( request -- )
    jedit-server-info swap "localhost" swap <client> [
        write-big-endian-32
        dup length write-big-endian-16
        write flush
    ] with-stream ;

: jedit-line/file ( file line -- )
    unparse "+line:" swap cat2 2list
    make-jedit-request send-jedit-request ;

: jedit-file ( file -- )
    unit make-jedit-request send-jedit-request ;

: jedit ( word -- )
    #! Note that line numbers here start from 1
    dup word-file dup [
        swap "line" word-prop jedit-line/file
    ] [
        2drop "Unknown source" print
    ] ifte ;
