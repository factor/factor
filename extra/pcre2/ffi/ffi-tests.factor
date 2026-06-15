USING: alien.strings byte-arrays io.encodings.utf8 kernel
pcre2.ffi sequences splitting tools.test ;
IN: pcre2.ffi.tests

! The version string looks like "10.42 2022-12-11".
{ 2 } [
    PCRE2_CONFIG_VERSION 24 <byte-array>
    [ pcre2_config drop ] keep utf8 alien>string split-words length
] unit-test
