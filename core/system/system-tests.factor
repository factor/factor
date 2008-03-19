USING: math tools.test system prettyprint namespaces kernel ;
IN: system.tests

wince? [
    [ ] [ os-envs . ] unit-test
] unless

unix? [
    [ ] [ os-envs "envs" set ] unit-test
    [ ] [ { { "A" "B" } } set-os-envs ] unit-test
    [ "B" ] [ "A" os-env ] unit-test
    [ ] [ "envs" get set-os-envs ] unit-test
    [ t ] [ os-envs "envs" get = ] unit-test
] when
