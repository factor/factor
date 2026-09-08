USING: alien.c-types kernel layouts tools.test unix.types ;
IN: unix.types.linux.tests

{ 128 } [ sigset_t heap-size ] unit-test
{ t } [ sigset_t c-type-align cell = ] unit-test
{ t } [ posix_spawnattr_t c-type-align cell = ] unit-test
{ t } [ off64_t c-type-signed ] unit-test
{ t } [ blkcnt64_t c-type-signed ] unit-test
{ 4 } [ clockid_t heap-size ] unit-test
