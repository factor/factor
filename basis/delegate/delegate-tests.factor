USING: delegate kernel arrays tools.test words math definitions
compiler.units parser generic prettyprint io.streams.string
accessors eval ;
IN: delegate.tests

TUPLE: hello this that ;
C: <hello> hello

TUPLE: goodbye these those ;
C: <goodbye> goodbye

GENERIC: foo ( x -- y )
GENERIC: bar ( a -- b )
GENERIC# whoa 1 ( s t -- w )
PROTOCOL: baz foo { bar 0 } { whoa 1 } ;

: hello-test ( hello/goodbye -- array )
    [ hello? ] [ this>> ] [ that>> ] tri 3array ;

CONSULT: baz goodbye these>> ;
M: hello foo this>> ;
M: hello bar hello-test ;
M: hello whoa [ this>> ] dip + ;

GENERIC: bing ( c -- d )
PROTOCOL: bee bing ;
CONSULT: hello goodbye those>> ;
M: hello bing hello-test ;

[ 1 { t 1 0 } ] [ 1 0 <hello> [ foo ] [ bar ] bi ] unit-test
[ { t 1 0 } ] [ 1 0 <hello> bing ] unit-test
[ 1 ] [ 1 0 <hello> f <goodbye> foo ] unit-test
[ { t 1 0 } ] [ 1 0 <hello> f <goodbye> bar ] unit-test
[ 3 ] [ 1 0 <hello> 2 whoa ] unit-test
[ 3 ] [ 1 0 <hello> f <goodbye> 2 whoa ] unit-test

[ ] [ 3 [ "USING: accessors delegate ; IN: delegate.tests CONSULT: baz goodbye these>> ;" eval ] times ] unit-test
[ H{ { goodbye [ these>> ] } } ] [ baz protocol-consult ] unit-test
[ H{ } ] [ bee protocol-consult ] unit-test

[ "USING: delegate ;\nIN: delegate.tests\nPROTOCOL: baz foo bar { whoa 1 } ;\n" ] [ [ baz see ] with-string-writer ] unit-test

GENERIC: one
M: integer one ;
GENERIC: two
M: integer two ;
GENERIC: three
M: integer three ;
GENERIC: four
M: integer four ;

PROTOCOL: alpha one two ;
PROTOCOL: beta three ;

TUPLE: hey value ;
C: <hey> hey
CONSULT: alpha hey value>> 1+ ;
CONSULT: beta hey value>> 1- ;

[ 2 ] [ 1 <hey> one ] unit-test
[ 2 ] [ 1 <hey> two ] unit-test
[ 0 ] [ 1 <hey> three ] unit-test
[ { hey } ] [ alpha protocol-users ] unit-test
[ { hey } ] [ beta protocol-users ] unit-test
[ ] [ "USE: delegate IN: delegate.tests PROTOCOL: alpha one ;" eval ] unit-test
[ f ] [ hey \ two method ] unit-test
[ f ] [ hey \ four method ] unit-test
[ ] [ "USE: delegate IN: delegate.tests PROTOCOL: beta two three four ;" eval ] unit-test
[ { hey } ] [ alpha protocol-users ] unit-test
[ { hey } ] [ beta protocol-users ] unit-test
[ 2 ] [ 1 <hey> one ] unit-test
[ 0 ] [ 1 <hey> two ] unit-test
[ 0 ] [ 1 <hey> three ] unit-test
[ 0 ] [ 1 <hey> four ] unit-test
[ ] [ "USING: math accessors delegate ; IN: delegate.tests CONSULT: beta hey value>> 2 - ;" eval ] unit-test
[ 2 ] [ 1 <hey> one ] unit-test
[ -1 ] [ 1 <hey> two ] unit-test
[ -1 ] [ 1 <hey> three ] unit-test
[ -1 ] [ 1 <hey> four ] unit-test
[ ] [ "IN: delegate.tests FORGET: alpha" eval ] unit-test
[ f ] [ hey \ one method ] unit-test

TUPLE: slot-protocol-test-1 a b ;
TUPLE: slot-protocol-test-2 < slot-protocol-test-1 { c integer } ;

TUPLE: slot-protocol-test-3 d ;

CONSULT: slot-protocol-test-2 slot-protocol-test-3 d>> ;

[ "a" "b" 5 ] [
    T{ slot-protocol-test-3 f T{ slot-protocol-test-2 f "a" "b" 5 } }
    [ a>> ] [ b>> ] [ c>> ] tri
] unit-test
