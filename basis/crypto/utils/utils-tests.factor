! Copyright (C) 2025 Zoltán Kéri <z@zolk3ri.name>
! See https://factorcode.org/license.txt for BSD license.

USING: byte-arrays crypto.utils tools.test ;
IN: crypto.utils.tests

!
! constant-time= tests
!

! Equal sequences
{ t } [ B{ 1 2 3 4 } B{ 1 2 3 4 } constant-time= ] unit-test
{ t } [ B{ } B{ } constant-time= ] unit-test
{ t } [ B{ 0 } B{ 0 } constant-time= ] unit-test
{ t } [ B{ 255 255 255 } B{ 255 255 255 } constant-time= ] unit-test

! Unequal sequences - same length
{ f } [ B{ 1 2 3 4 } B{ 1 2 3 5 } constant-time= ] unit-test
{ f } [ B{ 1 2 3 4 } B{ 0 2 3 4 } constant-time= ] unit-test
{ f } [ B{ 0 0 0 0 } B{ 0 0 0 1 } constant-time= ] unit-test
{ f } [ B{ 0 0 0 0 } B{ 1 0 0 0 } constant-time= ] unit-test

! Unequal sequences - different length
{ f } [ B{ 1 2 3 } B{ 1 2 3 4 } constant-time= ] unit-test
{ f } [ B{ 1 2 3 4 } B{ 1 2 3 } constant-time= ] unit-test
{ f } [ B{ } B{ 0 } constant-time= ] unit-test
{ f } [ B{ 0 } B{ } constant-time= ] unit-test

! 16-byte arrays (typical MAC tag size)
{ t }
[
    B{ 0xa8 0x06 0x1d 0xc1 0x30 0x51 0x36 0xc6
       0xc2 0x2b 0x8b 0xaf 0x0c 0x01 0x27 0xa9 }
    B{ 0xa8 0x06 0x1d 0xc1 0x30 0x51 0x36 0xc6
       0xc2 0x2b 0x8b 0xaf 0x0c 0x01 0x27 0xa9 }
    constant-time=
] unit-test

{ f }
[
    B{ 0xa8 0x06 0x1d 0xc1 0x30 0x51 0x36 0xc6
       0xc2 0x2b 0x8b 0xaf 0x0c 0x01 0x27 0xa9 }
    B{ 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00
       0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 }
    constant-time=
] unit-test

!
! constant-time-zero? tests
!

! All zeros
{ t } [ B{ } constant-time-zero? ] unit-test
{ t } [ B{ 0 } constant-time-zero? ] unit-test
{ t } [ B{ 0 0 0 0 } constant-time-zero? ] unit-test
{ t } [ 16 <byte-array> constant-time-zero? ] unit-test

! Non-zero at various positions
{ f } [ B{ 1 } constant-time-zero? ] unit-test
{ f } [ B{ 0 0 0 1 } constant-time-zero? ] unit-test
{ f } [ B{ 1 0 0 0 } constant-time-zero? ] unit-test
{ f } [ B{ 0 1 0 0 } constant-time-zero? ] unit-test
{ f } [ B{ 255 255 255 255 } constant-time-zero? ] unit-test

!
! constant-time-select tests
!

! flag = 1 selects a
{ 42 } [ 1 42 99 constant-time-select ] unit-test
{ 0 } [ 1 0 255 constant-time-select ] unit-test
{ -1 } [ 1 -1 100 constant-time-select ] unit-test

! flag = 0 selects b
{ 99 } [ 0 42 99 constant-time-select ] unit-test
{ 255 } [ 0 0 255 constant-time-select ] unit-test
{ 100 } [ 0 -1 100 constant-time-select ] unit-test

! Edge cases
{ 0 } [ 1 0 0 constant-time-select ] unit-test
{ 0 } [ 0 0 0 constant-time-select ] unit-test
{ -1 } [ 1 -1 -1 constant-time-select ] unit-test
{ -1 } [ 0 -1 -1 constant-time-select ] unit-test
