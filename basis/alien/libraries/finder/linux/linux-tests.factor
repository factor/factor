USING: alien.libraries.finder sequences tools.test ;

{ t } [ "m" find-library "libm.so" subseq-of? ] unit-test
{ t } [ "c" find-library "libc.so" subseq-of? ] unit-test
