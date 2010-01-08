! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel tools.test compression.zlib classes ;
QUALIFIED-WITH: compression.zlib.ffi ffi
IN: compression.zlib.tests

: compress-me ( -- byte-array ) B{ 1 2 3 4 5 } ;

[ t ] [ compress-me [ compress uncompress ] keep = ] unit-test
[ t ] [ compress-me compress compressed instance? ] unit-test

[ ffi:Z_DATA_ERROR zlib-error-message ] [ string>> "data error" = ] must-fail-with
