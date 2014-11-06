USING: fuel.xref kernel sequences tools.test ;
IN: fuel.xref.tests

{ t } [
    "fuel" apropos-xref empty? not
] unit-test

{ t } [
    "fuel" vocab-xref length 2 =
] unit-test

{ { } } [
    "i-dont-exist!" callees-xref
] unit-test
