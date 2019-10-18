USING: listener io.server ;
IN: tty-server

: tty-server ( port -- )
    local-server
    "tty-server"
    [ listener ] with-server ;

: default-tty-server 9999 tty-server ;

MAIN: default-tty-server