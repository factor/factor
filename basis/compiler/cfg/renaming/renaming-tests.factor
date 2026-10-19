USING: accessors assocs compiler.cfg.instructions
compiler.cfg.renaming cpu.architecture kernel namespaces tools.test ;
IN: compiler.cfg.renaming.tests

{ { { 20 double-rep 1 } { 21 double-rep 2 56 } } } [
    [
        H{ { 10 20 } { 11 21 } } renamings set
        T{ ##alien-invoke
            { reg-inputs { { 10 double-rep 1 } { 11 double-rep 2 56 } } }
            { stack-inputs { } } }
        dup rename-insn-uses reg-inputs>>
    ] with-scope
] unit-test

! Preserve stack ABI metadata while changing only the virtual register.
{ { { 20 int-rep 0 8 } { 21 int-rep 8 4 float-rep } } } [
    [
        H{ { 10 20 } { 11 21 } } renamings set
        T{ ##alien-invoke
            { reg-inputs { } }
            { stack-inputs { { 10 int-rep 0 8 } { 11 int-rep 8 4 float-rep } } } }
        dup rename-insn-uses stack-inputs>>
    ] with-scope
] unit-test
{ { { 20 int-rep 0 8 } { 21 int-rep 8 4 float-rep } } } [
    [
        H{ { 10 20 } { 11 21 } } renamings set
        T{ ##callback-inputs
            { reg-outputs { } }
            { stack-outputs { { 10 int-rep 0 8 } { 11 int-rep 8 4 float-rep } } } }
        dup rename-insn-defs stack-outputs>>
    ] with-scope
] unit-test
