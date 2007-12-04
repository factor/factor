USING: assocs combinators continuations hashtables
hashtables.private io kernel math
namespaces prettyprint quotations sequences splitting
state-parser strings tools.test ;
USING: html.parser.utils ;
IN: temporary

[ "'Rome'" ] [ "Rome" single-quote ] unit-test
[ "\"Roma\"" ] [ "Roma" double-quote ] unit-test
[ "'Firenze'" ] [ "Firenze" quote ] unit-test
[ "\"Caesar's\"" ] [ "Caesar's" quote ] unit-test
[ f ] [ "" quoted? ] unit-test
[ t ] [ "''" quoted? ] unit-test
[ t ] [ "\"\"" quoted? ] unit-test
[ t ] [ "\"Circus Maximus\"" quoted? ] unit-test
[ t ] [ "'Circus Maximus'" quoted? ] unit-test
[ f ] [ "Circus Maximus" quoted? ] unit-test
[ "'Italy'" ] [ "Italy" ?quote ] unit-test
[ "'Italy'" ] [ "'Italy'" ?quote ] unit-test
[ "\"Italy\"" ] [ "\"Italy\"" ?quote ] unit-test
[ "Italy" ] [ "Italy" unquote ] unit-test
[ "Italy" ] [ "'Italy'" unquote ] unit-test
[ "Italy" ] [ "\"Italy\"" unquote ] unit-test

