IN: compiler.tests.redefine16
USING: eval tools.test definitions words compiler.units
quotations stack-checker ;

[ ] [ [ "blah" "compiler.tests.redefine16" lookup forget ] with-compilation-unit ] unit-test

[ ] [ "IN: compiler.tests.redefine16 GENERIC# blah 2 ( foo bar baz -- )" eval( -- ) ] unit-test
[ ] [ "IN: compiler.tests.redefine16 USING: strings math arrays prettyprint ; M: string blah 1 + 3array . ;" eval( -- ) ] unit-test
[ ] [ "IN: compiler.tests.redefine16 GENERIC# blah 2 ( foo bar baz -- x )" eval( -- ) ] unit-test
[ "blah" "compiler.tests.redefine16" lookup 1quotation infer ] must-fail
