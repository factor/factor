USING: tools.test generic kernel definitions sequences
compiler.units words ;
IN: definitions.tests

GENERIC: some-generic ( a -- b )

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
    [
        {
            some-generic
            some-class
            { another-class some-generic }
        } forget-all
    ] with-compilation-unit
] unit-test

[ +flushed+ ] [ f +flushed+ strongest-dependency ] unit-test
[ +flushed+ ] [ +flushed+ f strongest-dependency ] unit-test
[ +inlined+ ] [ +flushed+ +inlined+ strongest-dependency ] unit-test
[ +inlined+ ] [ +called+ +inlined+ strongest-dependency ] unit-test
[ +flushed+ ] [ +called+ +flushed+ strongest-dependency ] unit-test
[ +called+ ] [ +called+ f strongest-dependency ] unit-test
