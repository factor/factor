USING: accessors alien alien.c-types arrays assocs compiler.cfg.builder.alien compiler.cfg.builder.alien.boxing
compiler.cfg.builder.alien.params cpu.architecture cpu.ppc.64.varargs
compiler.test kernel namespaces sequences stack-checker.alien system tools.test vectors ;
{ { { 20 double-rep 1 } { 21 double-rep 2 8 } } } [
    [
        V{ 0 } clone ppc64-argument-index set
        1 ppc64-named-count set H{ } clone ppc64-unnamed-vregs set
        { 20 } { } ppc64-record-argument 2drop
        { 21 } { } ppc64-record-argument 2drop
        20 double-rep 1 0 ppc64-shadow-reg-input
        21 double-rep 2 8 ppc64-shadow-reg-input 2array
    ] with-scope
] unit-test

! Both trailing FP arguments need GP shadows, including the final argument.
! Exercise the complete caller rather than manually recording virtual registers.
cpu ppc64? [
    { { { int-rep 3 } { double-rep 1 8 } { double-rep 2 16 } } } [
        void { int double double } cdecl 1 f "varargs-shadow-regression"
        alien-invoke-params boa caller-parameters drop [ rest ] map >array
    ] cfg-unit-test
] when
{ { 20 double-rep 1 } } [
    [ 20 double-rep 1 0 ppc64-shadow-reg-input ] with-scope
] unit-test

! A floating argument on the stack retains its representation alongside the
! virtual register, byte offset and size, matching caller-parameter's contract.
{ t { { 20 double-rep 16 8 } } 24 } [
    [
        t compact-stack-params? set
        16 stack-params set V{ } clone stack-values set
        V{ } clone float-regs set
        20 double-rep t f 8 ppc64-alloc-float-parameter
        stack-values get >array stack-params get
    ] with-scope
] unit-test
