! Copyright (C) 2009 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: cgi cgi.private kernel linked-assocs tools.test ;

{ LH{ } } [ "" query-string ] unit-test

{ LH{ { "a" { "1" } } { "b" { "2" } } } }
[ "a=1&b=2" query-string ] unit-test

{ LH{ { "a" { "1" } } { "b" { "2" "3" } } } }
[ "a=1&b=2&b=3" query-string ] unit-test

{ LH{ } "text/html" } [ "text/html" content-type ] unit-test

{ LH{ { "charset" { "utf-8" } } } "text/html" }
[ "text/html; charset=utf-8" content-type ] unit-test
