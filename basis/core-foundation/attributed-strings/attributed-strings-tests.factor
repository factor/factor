! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test core-foundation.attributed-strings
core-foundation ;
IN: core-foundation.attributed-strings.tests

{ } [ "Hello world" H{ } <CFAttributedString> CFRelease ] unit-test
