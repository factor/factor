! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.
USING: compiler.errors fuel.pprint io.streams.string tools.test ;
IN: fuel.pprint.tests

{ "(source-file-error nil \"hi\")" } [
    [ "hi" "there" <compiler-error> fuel-pprint ] with-string-writer
] unit-test
