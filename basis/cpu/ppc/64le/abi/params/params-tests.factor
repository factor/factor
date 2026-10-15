USING: alien.c-types alien.syntax arrays classes.struct
compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
cpu.architecture cpu.ppc.64le.abi.params generic kernel locals
namespaces sequences system tools.test vectors ;
IN: cpu.ppc.64le.abi.params.tests

STRUCT: ppc-hfa-eight-floats { values float[8] } ;

: prepare-hfa ( rep -- )
    ppc64 \ prepare-abi-parameter-group lookup-method
    execute( rep -- ) ;

:: allocate-hfa ( vreg rep -- )
    vreg rep f f rep rep-size
    ppc64 \ alloc-abi-parameter lookup-method
    execute( vreg rep on-stack? odd-register? size -- handled? )
    [ ] [ "HFA allocator declined a member" throw ] if ;

: init-hfa-test ( float-registers -- )
    reverse >vector float-regs set
    { 3 4 5 6 7 8 9 10 } reverse >vector int-regs set
    V{ } clone reg-values set V{ } clone stack-values set
    0 stack-params set ;

{ 32 { 7 8 9 10 } { 1 2 3 4 5 6 7 8 } } [
    [
        { 1 2 3 4 5 6 7 8 9 10 11 12 13 } init-hfa-test
        { float-rep f f 4 0 8 32 } prepare-hfa
        8 <iota> [ float-rep allocate-hfa ] each
        stack-params get
        int-regs get reverse >array
        reg-values get [ third ] map >array
    ] with-scope
] unit-test

{ { 7 8 9 10 11 12 13 } { 7 float-rep 84 4 } } [
    [
        { 7 8 9 10 11 12 13 } init-hfa-test
        ! Pointer plus six doubles precede the HFA in the native split probe.
        56 stack-params set
        V{ 10 } clone int-regs set
        { float-rep f f 4 0 8 32 } prepare-hfa
        8 <iota> [ float-rep allocate-hfa ] each
        reg-values get [ third ] map >array
        stack-values get first
    ] with-scope
] unit-test

{ 16 { 5 6 7 8 9 10 } } [
    [
        { 1 2 3 4 5 6 7 8 9 10 11 12 13 } init-hfa-test
        { float-rep f f 4 0 3 12 } prepare-hfa
        3 <iota> [ float-rep allocate-hfa ] each
        stack-params get int-regs get reverse >array
    ] with-scope
] unit-test

{ 7 8 32 } [
    [
        0 int-reg-reps set 0 float-reg-reps set
        ppc-hfa-eight-floats ppc64le-hfa-param-reps first
        [ length ] [ 5 swap nth ] [ 6 swap nth ] tri
    ] with-scope
] unit-test

{ f } [
    0 int-rep f f 8 object \ alloc-abi-parameter lookup-method
    execute( vreg rep on-stack? odd-register? size -- handled? )
] unit-test
