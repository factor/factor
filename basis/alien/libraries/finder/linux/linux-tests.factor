USING: alien.libraries.finder sequences tools.test
alien.libraries.finder.linux.private ;
IN: alien.libraries.finder.linux

{ t } [ "libm.so" "m" find-library subseq? ] unit-test
{ t } [ "libc.so" "c" find-library subseq? ] unit-test

{ t } [ "libSDL" { "libSDL-1.2.so.0" f f } name-matches? ] unit-test
{ t } [ "libSDL-1" { "libSDL-1.2.so.0" f f } name-matches? ] unit-test
{ t } [ "libSDL-1.2" { "libSDL-1.2.so.0" f f } name-matches? ] unit-test
