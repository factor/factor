! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: core-foundation.strings core-foundation tools.test kernel
strings ;
IN: core-foundation

{ } [ "Hello" <CFString> CFRelease ] unit-test
{ "Hello" } [ "Hello" <CFString> [ CF>string ] [ CFRelease ] bi ] unit-test
{ "Hello\u003456" } [ "Hello\u003456" <CFString> [ CF>string ] [ CFRelease ] bi ] unit-test
{ "Hello\u013456" } [ "Hello\u013456" <CFString> [ CF>string ] [ CFRelease ] bi ] unit-test
{ } [ "\0" <CFString> CFRelease ] unit-test
{ "\0" } [ "\0" <CFString> [ CF>string ] [ CFRelease ] bi ] unit-test

! This shouldn't fail
{ } [ { 0x123456 } >string <CFString> CFRelease ] unit-test
