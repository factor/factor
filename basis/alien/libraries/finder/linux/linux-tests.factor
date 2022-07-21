USING: alien.libraries.finder sequences tools.test ;

{ t } [ "m" find-library "libm.so" find-subseq? ] unit-test
{ t } [ "c" find-library "libc.so" find-subseq? ] unit-test
