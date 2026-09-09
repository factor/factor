USING: accessors alien.c-types arrays classes.struct kernel libc
linux.input-events.ffi sequences tools.test ;
IN: linux.input-events.ffi.tests

{ t } [ 22 "unsupported" \ libc-error boa unsupported-ioctl? ] unit-test
{ f } [ 9 "bad descriptor" \ libc-error boa unsupported-ioctl? ] unit-test
{ f } [ 13 "permission denied" \ libc-error boa unsupported-ioctl? ] unit-test
{ f } [ "not an operating-system error" unsupported-ioctl? ] unit-test
[ -1 8 B{ 0 0 0 0 } evdev-get-mt-slots ]
[ invalid-mt-request-size? ] must-fail-with
[ -1 0 0 evdev-get-event-mask ]
[ invalid-event-mask-length? ] must-fail-with
[ -1 0 4 evdev-get-event-mask ]
[ dup libc-error? [ errno>> 9 = ] [ drop f ] if ] must-fail-with

{ { 0 7 8 15 16 } } [ B{ 129 129 1 } seq>explode-positions >array ] unit-test
{ { 1 128 256 32768 65536 } } [ B{ 129 129 1 } seq>explode-values >array ] unit-test
{ 4 4 } [ input_mt_request_layout heap-size "values" input_mt_request_layout offset-of ] unit-test
{ 0x80184540 } [ CHAR: E 0x40 input_absinfo IOR drop ] unit-test
{ 0x401845c0 } [ CHAR: E 0xc0 input_absinfo new IOW drop ] unit-test
{ 0x40044581 } [ CHAR: E 0x81 int heap-size IOW-size ] unit-test

! An invalid descriptor must reach ioctl and return EBADF, not fail
! while constructing the request. No input device is opened or changed.
[ -1 0 input_absinfo new evdev-set-abs ]
[ dup libc-error? [ errno>> 9 = ] [ drop f ] if ] must-fail-with
[ -1 7 evdev-unset-force-feedback ]
[ dup libc-error? [ errno>> 9 = ] [ drop f ] if ] must-fail-with
