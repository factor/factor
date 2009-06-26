! (c)2009 Joe Groff bsd license
USING: kernel math tools.test variants ;
IN: variants.tests

VARIANT: list
    nil
    cons: { { first object } { rest list } }
    ;

[ t ] [ nil list? ] unit-test
[ t ] [ 1 nil <cons> list? ] unit-test
[ f ] [ 1 list? ] unit-test

: list-length ( list -- length )
    {
        { nil  [ 0 ] }
        { cons [ nip list-length 1 + ] }
    } match ;

[ 4 ]
[ 5 6 7 8 nil <cons> <cons> <cons> <cons> list-length ] unit-test
