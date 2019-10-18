USING: kernel rosetta-code.conjugate-transpose tools.test ;
IN: rosetta-code.conjugate-transpose

{ f t f } [
    { { C{ 1 2 } 0 } { 0 C{ 3 4 } } }
    [ hermitian-matrix? ]
    [ normal-matrix? ]
    [ unitary-matrix? ] tri
] unit-test
