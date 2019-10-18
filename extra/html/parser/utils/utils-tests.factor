USING: html.parser.utils quoting tools.test ;

{ "'Rome'" } [ "Rome" single-quote ] unit-test
{ "\"Roma\"" } [ "Roma" double-quote ] unit-test
{ "'Firenze'" } [ "Firenze" quote ] unit-test
{ "\"Caesar's\"" } [ "Caesar's" quote ] unit-test
{ "'Italy'" } [ "Italy" ?quote ] unit-test
{ "'Italy'" } [ "'Italy'" ?quote ] unit-test
{ "\"Italy\"" } [ "\"Italy\"" ?quote ] unit-test
{ "Italy" } [ "Italy" unquote ] unit-test
{ "Italy" } [ "'Italy'" unquote ] unit-test
{ "Italy" } [ "\"Italy\"" unquote ] unit-test
