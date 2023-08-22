! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io io.encodings.utf8 io.files io.streams.counting kernel
tools.test ;
IN: io.streams.counting.tests

{ 1306 0 } [
    "resource:LICENSE.txt" utf8 <file-reader> [ read-contents ] with-counting-stream nipd
] unit-test
