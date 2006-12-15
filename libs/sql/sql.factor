USING: kernel namespaces ;
IN: sql

SYMBOL: db
TUPLE: connection handle ;

! TESTING
"handle" <connection> db set-global


