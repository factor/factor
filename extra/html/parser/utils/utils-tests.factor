USING: assocs combinators continuations hashtables
hashtables.private io kernel math
namespaces prettyprint quotations sequences splitting
strings tools.test html.parser.utils quoting ;
IN: html.parser.utils.tests

[ "'Rome'" ] [ "Rome" single-quote ] unit-test
[ "\"Roma\"" ] [ "Roma" double-quote ] unit-test
[ "'Firenze'" ] [ "Firenze" quote ] unit-test
[ "\"Caesar's\"" ] [ "Caesar's" quote ] unit-test
[ "'Italy'" ] [ "Italy" ?quote ] unit-test
[ "'Italy'" ] [ "'Italy'" ?quote ] unit-test
[ "\"Italy\"" ] [ "\"Italy\"" ?quote ] unit-test
[ "Italy" ] [ "Italy" unquote ] unit-test
[ "Italy" ] [ "'Italy'" unquote ] unit-test
[ "Italy" ] [ "\"Italy\"" unquote ] unit-test

