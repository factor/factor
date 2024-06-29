! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.files.acls.macos io.pathnames system tools.test ;
IN: io.files.acls.macos.tests

{ } [ vm-path acls. ] unit-test
{ } [ "~/Pictures" acls. ] unit-test
