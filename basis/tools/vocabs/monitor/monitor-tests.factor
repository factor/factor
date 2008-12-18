USING: tools.test tools.vocabs.monitor io.pathnames ;
IN: tools.vocabs.monitor.tests

[ "kernel" ] [ "core/kernel/kernel.factor" path>vocab ] unit-test
[ "kernel" ] [ "core/kernel/" path>vocab ] unit-test
[ "kernel" ] [ "core/kernel/" resource-path path>vocab ] unit-test
