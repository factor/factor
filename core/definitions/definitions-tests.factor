IN: temporary
USING: tools.test generic kernel definitions sequences ;

TUPLE: combination-1 ;

M: combination-1 perform-combination 2drop { } [ ] each [ ] ;

SYMBOL: generic-1

generic-1 T{ combination-1 } define-generic

[ ] <method> object \ generic-1 define-method

[ ] [ { combination-1 { object generic-1 } } forget-all ] unit-test

GENERIC: some-generic

USE: arrays

M: array some-generic ;

USE: bit-arrays

M: bit-array some-generic ;

USE: byte-arrays

M: byte-array some-generic ;

TUPLE: some-class ;

M: some-class some-generic ;

TUPLE: another-class some-generic ;

[ ] [
    { some-generic some-class { another-class some-generic } }
    forget-all
] unit-test
