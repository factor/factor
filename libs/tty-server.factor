
USING: shells loopback-server ;

IN: tty-server

: tty-server ( port -- ) \ tty-server [ tty ] with-loopback-server ;