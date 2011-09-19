! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces prettyprint system tools.test
environment strings sequences ;
IN: environment.tests

[ ] [ os-envs . ] unit-test

os unix? [
    [ ] [ os-envs "envs" set ] unit-test
    [ ] [ { { "A" "B" } } set-os-envs ] unit-test
    [ "B" ] [ "A" os-env ] unit-test
    [ ] [ "envs" get set-os-envs ] unit-test
    [ t ] [ os-envs "envs" get = ] unit-test
] when

[ ] [ "factor-test-key-1" unset-os-env ] unit-test
[ ] [ "ps3" "factor-test-key-1" set-os-env ] unit-test
[ "ps3" ] [ "factor-test-key-1" os-env ] unit-test
[ ] [ "factor-test-key-1" unset-os-env ] unit-test
[ f ] [ "factor-test-key-1" os-env ] unit-test

[ ] [
    32766 CHAR: a <string> "factor-test-key-long" set-os-env
] unit-test
[ 32766 ] [ "factor-test-key-long" os-env length ] unit-test
[ ] [ "factor-test-key-long" unset-os-env ] unit-test
