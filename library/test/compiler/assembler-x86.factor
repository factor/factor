IN: temporary
USING: assembler kernel test ;

[ t ] [ { EBP } indirect? >boolean ] unit-test
[ { EBP 0 } ] [ { EBP } canonicalize ] unit-test
[ t ] [ { EAX 3 } displaced? >boolean ] unit-test
[ { EAX } ] [ { EAX 0 } canonicalize ] unit-test
[ { EAX } ] [ { EAX } canonicalize ] unit-test
[ { EAX 3 } ] [ { EAX 3 } canonicalize ] unit-test
