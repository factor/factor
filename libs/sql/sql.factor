USING: kernel namespaces ;
IN: sql

SYMBOL: db
TUPLE: connection handle ;
TUPLE: persistent id ;

! TESTING
"handle" <connection> db set-global


