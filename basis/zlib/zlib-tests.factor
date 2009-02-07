! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel tools.test zlib classes ;
IN: zlib.tests

: compress-me ( -- byte-array ) B{ 1 2 3 4 5 } ;

[ t ] [ compress-me [ compress uncompress ] keep = ] unit-test
[ t ] [ compress-me compress compressed instance? ] unit-test
