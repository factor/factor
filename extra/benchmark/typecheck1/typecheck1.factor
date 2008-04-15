USING: math kernel ;
IN: benchmark.typecheck1

TUPLE: hello n ;

: foo 0 100000000 [ over hello-n + ] times ;

: typecheck-main 0 hello boa foo 2drop ;

MAIN: typecheck-main
