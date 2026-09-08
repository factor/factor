USING: tools.test vocabs.refresh.monitor io.pathnames ;
IN: vocabs.refresh.monitor.tests

{ "kernel" } [ "core/kernel/kernel.factor" path>vocab-name ] unit-test
{ "kernel" } [ "core/kernel/" path>vocab-name ] unit-test
{ "kernel" } [ "core/kernel/" resource-path path>vocab-name ] unit-test

! Windows alternate data stream notifications are not vocab names (#2250).
{ f } [
    "extra/ui/render/test/reference.bmp:Zone.Identifier" path>vocab-name
] unit-test

{ f } [
    "core/kernel/kernel.factor:Zone.Identifier" resource-path path>vocab-name
] unit-test
