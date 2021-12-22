USING: pcre.ffi sequences splitting tools.test ;
IN: pcre.ffi.tests

{ 2 } [ pcre_version split-words length ] unit-test
