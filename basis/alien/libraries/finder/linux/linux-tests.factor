USING: alien.libraries.finder sequences tools.test ;
IN: alien.libraries.fidner.linux

{ t } [ "m" find-library "libm.so" subseq? ] unit-test
{ t } [ "c" find-library "libc.so" subseq? ] unit-test
