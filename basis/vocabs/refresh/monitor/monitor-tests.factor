USING: tools.test vocabs.refresh.monitor io.pathnames ;
IN: vocabs.refresh.monitor.tests

{ "kernel" } [ "core/kernel/kernel.factor" path>vocab-name ] unit-test
{ "kernel" } [ "core/kernel/" path>vocab-name ] unit-test
{ "kernel" } [ "core/kernel/" resource-path path>vocab-name ] unit-test
