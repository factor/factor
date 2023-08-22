! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel tools.test compression.zlib classes ;
QUALIFIED-WITH: compression.zlib.ffi ffi

{ t } [ B{ 1 2 3 4 5 } [ compress uncompress ] keep = ] unit-test

[ ffi:Z_DATA_ERROR zlib-error-message ] [ string>> "data error" = ] must-fail-with
