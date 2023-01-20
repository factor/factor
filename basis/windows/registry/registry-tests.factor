! Copyright (C) 2010 Doug Coleman.
! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays io.encodings.string io.encodings.utf16
kernel sequences tools.test windows.advapi32 windows.kernel32
windows.registry ;
IN: windows.registry.tests

[ ]
[ HKEY_CURRENT_USER "SOFTWARE\\\\Microsoft" read-registry drop ] unit-test

[ t ]
[
    HKEY_CURRENT_USER "Environment" KEY_SET_VALUE [
        "factor-test" "value" utf16n encode dup length set-reg-sz
    ] with-open-registry-key
    HKEY_CURRENT_USER "Environment" "factor-test" [
        "test-string" ";" glue
    ] change-registry-value
    HKEY_CURRENT_USER "Environment" KEY_QUERY_VALUE [
        "factor-test" f f MAX_PATH <byte-array> reg-query-value-ex
        utf16n decode "value;test-string\0" =
    ] with-open-registry-key
    HKEY_CURRENT_USER "Environment" KEY_SET_VALUE [
        "factor-test" delete-value
    ] with-open-registry-key
] unit-test
