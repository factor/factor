! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.standard-paths io.standard-paths.windows sequences
tools.test ;

{ t } [ "cmd.exe" find-in-path "cmd.exe" tail? ] unit-test
