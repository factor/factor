! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test db2.statements kernel ;
IN: db2.statements.tests

{ 1 0 } [ [ drop ] statement-each ] must-infer-as
{ 1 1 } [ [ ] statement-map ] must-infer-as

[ ]
[
    "insert into computer (name, os) values('rocky', 'mac');"
    
] unit-test
