! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel tools.test windows.advapi32 windows.registry ;
IN: windows.registry.tests

[ ]
[ HKEY_CURRENT_USER "SOFTWARE\\\\Microsoft" read-registry drop ] unit-test
