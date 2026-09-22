! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays calendar combinators colors images
images.tga
io.encodings.binary io.streams.byte-array io.streams.throwing
kernel sequences tools.test ;
IN: images.tga.tests

CONSTANT: tiny-tga B{
    0 0 2 0 0 0 0 0 0 0 0 0 2 0 1 0 24 0
    0 0 255 0 255 0
}

: decode-tga ( bytes -- image )
    binary [ [ read-tga ] throw-on-eof ] with-byte-reader ;

{ { 2 1 } BGR t B{ 0 0 255 0 255 0 } } [
    tiny-tga decode-tga
    { [ dim>> ] [ component-order>> ] [ upside-down?>> ] [ bitmap>> ] } cleave
] unit-test

[ tiny-tga 17 head decode-tga ] must-fail
[ tiny-tga 20 head decode-tga ] must-fail

! Cold footer helpers retain their parsing and validation behavior.
{ 305419896 305419896 } [
    B{ 120 86 52 18 } binary [ read-extension-area-offset ] with-byte-reader
    B{ 120 86 52 18 } binary [ read-developer-directory-offset ] with-byte-reader
] unit-test

{ "AB" "AB" "AB" } [
    B{ 65 66 } 41 0 pad-tail dup dup
    binary [ read-author-name ] with-byte-reader -rot
    binary [ read-job-name ] with-byte-reader swap
    binary [ read-software-id ] with-byte-reader
] unit-test

{ 2026 1 2 10 20 30 } [
    B{ 1 0 2 0 234 7 10 0 20 0 30 0 }
    binary [ read-date-timestamp ] with-byte-reader
    { [ year>> ] [ month>> ] [ day>> ] [ hour>> ] [ minute>> ] [ second>> ] } cleave
] unit-test

[ B{ 13 0 2 0 234 7 10 0 20 0 30 0 }
  binary [ read-date-timestamp ] with-byte-reader ]
[ bad-tga-timestamp? ] must-fail-with

{ 1.5 2.0 } [
    B{ 3 0 2 0 } binary [ read-pixel-aspect-ratio ] with-byte-reader
    B{ 2 0 1 0 } binary [ read-gamma-value ] with-byte-reader
] unit-test

{ t } [ B{ 4 } binary [ read-premultiplied-alpha ] with-byte-reader ] unit-test
{ { 1 2 } } [ B{ 1 0 0 0 2 0 0 0 } binary [ 2 read-scan-line-table ] with-byte-reader ] unit-test
{ { { 7 12 34 } } } [
    B{ 1 0 7 0 12 0 0 0 34 0 0 0 }
    binary [ read-developer-directory ] with-byte-reader
] unit-test
