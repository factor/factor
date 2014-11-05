USING: fuel.xref kernel sequences tools.test ;
IN: fuel.xref.tests

{ t } [
    "fuel" apropos-xref empty? not
] unit-test
