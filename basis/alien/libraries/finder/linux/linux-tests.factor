USING: alien.libraries.finder sequences tools.test ;

{ t } [ "m" find-library "libm.so" subsequence? ] unit-test
{ t } [ "c" find-library "libc.so" subsequence? ] unit-test
