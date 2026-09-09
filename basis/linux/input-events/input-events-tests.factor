USING: alien.c-types alien.data arrays kernel linux.input-events math
sequences tools.test ;
IN: linux.input-events.tests

! Devices with more than 64 slots must not be silently truncated. Zero is
! a legitimate slot value, including at the end of the returned array.
{ 101 48 t } [
    48 100 <mt-request> [ length ] [ first ] [ rest [ zero? ] all? ] tri
] unit-test
[ 48 0 <mt-request> ] [ invalid-mt-slot-count? ] must-fail-with
[ 48 4095 <mt-request> ] [ invalid-mt-slot-count? ] must-fail-with
