USING: cpu.arm.64.features kernel namespaces sequences sets tools.test ;
IN: cpu.arm.64.features.tests

{ t } [ arm64-features optional-arm64-features subset? ] unit-test
{ { } } [ optional-arm64-features disabled-arm64-features [ arm64-features ] with-variable ] unit-test
{ { } } [ t "disable-neon-extensions" [ arm64-features ] with-variable ] unit-test
{ f } [ "not-a-cpu-feature" arm64-feature? ] unit-test
{ t } [ { } arm64-features-supported? ] unit-test
