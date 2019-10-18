USING: tools.test vocabs.refresh.monitor io.pathnames ;
IN: vocabs.refresh.monitor.tests

[ "kernel" ] [ "core/kernel/kernel.factor" path>vocab ] unit-test
[ "kernel" ] [ "core/kernel/" path>vocab ] unit-test
[ "kernel" ] [ "core/kernel/" resource-path path>vocab ] unit-test
