! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test db2.connections db2.tester ;
IN: db2.connections.tests

! Tests connection

{ 1 0 } [ [ ] with-db ] must-infer-as
