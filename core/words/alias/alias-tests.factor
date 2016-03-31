USING: effects eval math tools.test ;
IN: words.alias.tests

ALIAS: foo +
{ } [ "IN: words.alias.tests CONSTANT: foo 5" eval( -- ) ] unit-test
{ ( -- value ) } [ \ foo stack-effect ] unit-test

ALIAS: MY-H{ H{
{ H{ { 1 2 } } } [
    "IN: words.alias.tests MY-H{ { 1 2 } }" eval( -- x )
] unit-test
