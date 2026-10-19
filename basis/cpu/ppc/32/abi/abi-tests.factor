USING: compiler.cfg.builder.alien.params cpu.architecture
cpu.ppc.32.abi kernel namespaces system tools.test ;

! The FPR bank can end after integer arguments leave a four-byte stack hole.
{ 48 56 } [
    [
        44 stack-params set
        double-rep 8 M\ ppc.32 alloc-abi-stack-param execute
        stack-params get
    ] with-scope
] unit-test

! An already aligned spilled double retains its position.
{ 48 56 } [
    [
        48 stack-params set
        double-rep 8 M\ ppc.32 alloc-abi-stack-param execute
        stack-params get
    ] with-scope
] unit-test
