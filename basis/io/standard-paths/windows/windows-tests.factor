! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.standard-paths io.standard-paths.windows sequences
tools.test ;
IN: io.standard-paths.windows.tests

[ t ] [ "cmd.exe" find-in-path "cmd.exe" tail? ] unit-test
