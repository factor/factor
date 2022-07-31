USING: alien.libraries.finder sequences tools.test ;

{ t } [ "m" find-library "libm.so" subseq-index? ] unit-test
{ t } [ "c" find-library "libc.so" subseq-index? ] unit-test
