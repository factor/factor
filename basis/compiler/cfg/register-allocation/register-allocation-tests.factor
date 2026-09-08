USING: compiler.cfg.register-allocation kernel namespaces tools.test ;
IN: compiler.cfg.register-allocation.tests

SINGLETON: recording-allocator
SYMBOL: recorded-cfg

M: recording-allocator allocate-cfg drop recorded-cfg set ;

{ linear-scan-allocator } [
    f register-allocator [ current-register-allocator ] with-variable
] unit-test

! Dynamic selection reaches the implementation and restores its caller's
! setting. The CFG is passed through without an implicit SSA-destruction step.
{ 1234 linear-scan-allocator } [
    f register-allocator [
        recording-allocator register-allocator [
            1234 allocate-registers recorded-cfg get
        ] with-variable
        current-register-allocator
    ] with-variable
] unit-test
