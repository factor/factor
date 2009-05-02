! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test windows.errors strings ;
IN: windows.errors.tests

[ t ] [ 0 n>win32-error-string string? ] unit-test
