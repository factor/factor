! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors tools.test compression.lzw ;
IN: compression.lzw.tests

[ V{ 7 258 8 8 258 6 } ]
[ B{ 7 7 7 8 8 7 7 6 6 } lzw-compress output>> ] unit-test

[ B{ 7 7 7 8 8 7 7 6 6 } ]
[ V{ 7 258 8 8 258 6 } lzw-uncompress output>> ] unit-test
