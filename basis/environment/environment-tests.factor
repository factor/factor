! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: environment kernel namespaces prettyprint sequences
strings system tools.test ;

{ } [ os-envs . ] unit-test

os unix? [
    [ ] [ os-envs "envs" set ] unit-test
    [ ] [ { { "A" "B" } } set-os-envs ] unit-test
    [ "B" ] [ "A" os-env ] unit-test
    [ ] [ "envs" get set-os-envs ] unit-test
    [ t ] [ os-envs "envs" get = ] unit-test
] when

{ } [ "factor-test-key-1" unset-os-env ] unit-test
{ } [ "ps3" "factor-test-key-1" set-os-env ] unit-test
{ "ps3" } [ "factor-test-key-1" os-env ] unit-test
{ } [ "factor-test-key-1" unset-os-env ] unit-test
{ f } [ "factor-test-key-1" os-env ] unit-test

{ } [
    32766 CHAR: a <string> "factor-test-key-long" set-os-env
] unit-test
{ 32766 } [ "factor-test-key-long" os-env length ] unit-test
{ } [ "factor-test-key-long" unset-os-env ] unit-test

{ "abc" } [
    "a" "factor-test-key-change" set-os-env
    "factor-test-key-change" [ "bc" append ] change-os-env
    "factor-test-key-change" os-env
] unit-test
{ } [ "factor-test-key-change" unset-os-env ] unit-test

! Issue #794, setting something to ``f`` is a memory protection fault on mac
{ } [ f "dummy-env-variable-for-factor-test" set-os-env ] unit-test

{ f "value" f } [
    "factor-test-key" os-env
    "value" "factor-test-key" [ "factor-test-key" os-env ] with-os-env
    "factor-test-key" os-env
] unit-test
