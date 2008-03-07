USING: listener io.server io.encodings.utf8 ;
IN: tty-server

: tty-server ( port -- )
    local-server
    "tty-server"
    utf8 [ listener ] with-server ;

: default-tty-server 9999 tty-server ;

MAIN: default-tty-server
