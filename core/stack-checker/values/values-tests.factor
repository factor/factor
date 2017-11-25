USING: accessors kernel namespaces stack-checker.state
stack-checker.values tools.test ;
IN: stack-checker.values.tests

TUPLE: foo-tup a b ;

! known
{ T{ foo-tup f 10 20 } } [
    H{ } clone known-values set
    0 \ <value> set-global
    V{ } clone literals set
    10 20 foo-tup boa 23 set-known
    23 known
] unit-test

! literal
{ T{ foo-tup f 10 20 } } [
    H{ } clone known-values set
    0 \ <value> set-global
    V{ } clone literals set
    10 20 foo-tup boa <literal> make-known
    literal value>>
] unit-test

! set-known
{ H{ { 3 input-parameter } } } [
    H{ } clone known-values set
    input-parameter 3 set-known
    known-values get
] unit-test
