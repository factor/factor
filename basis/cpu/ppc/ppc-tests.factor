USING: byte-arrays compiler.cfg.instructions compiler.cfg.registers
compiler.codegen compiler.codegen.gc-maps compiler.codegen.relocation
cpu.architecture cpu.ppc cpu.ppc.assembler kernel layouts make
namespaces sequences system tools.test vectors ;
IN: cpu.ppc.tests

cpu ppc? [
    ! Cross-block calls use a full address even when the code heap exceeds 32MiB.
    { t } [
        init-relocation
        [ \ drop %call ] B{ } make
        [ 12 0 %load-cell-imm 12 MTCTR BCTRL ] B{ } make =
    ] unit-test
    { t } [
        init-relocation
        [ \ drop %jump ] B{ } make
        [
            6 0 %load-cell-imm
            12 0 %load-cell-imm 12 MTCTR BCTR
        ] B{ } make =
    ] unit-test
    ! Tagged values outside LI's signed 16-bit range need the full loader.
    { t } [
        [ 65536 T{ ds-loc } %replace-imm ] B{ } make
        [ 30 65536 tag-fixnum %load-cell-imm 30 14 0 %store-cell ]
        B{ } make =
    ] unit-test

    { t } [
        [ -65536 T{ ds-loc } %replace-imm ] B{ } make
        [ 30 -65536 tag-fixnum %load-cell-imm 30 14 0 %store-cell ]
        B{ } make =
    ] unit-test

    ! A heap literal must relocate a full load sequence, before the store.
    { t t } [
        init-relocation
        [ "literal" T{ ds-loc } %replace-imm ] B{ } make
        [ 30 0 %load-cell-imm 30 14 0 %store-cell ] B{ } make =
        literal-table get first "literal" =
    ] unit-test
    ! The GC map must identify the actual faulting store, after address loading.
    { t t } [
        init-relocation
        V{ } clone return-addresses set V{ } clone gc-maps set
        [
            8 <byte-array> %
            T{ ##safepoint { gc-map T{ gc-map { gc-roots { 1 } } } } }
            generate-insn
        ] B{ } make
        dup length 4 - return-addresses get first =
        swap 4 tail* [ 30 30 0 STW ] B{ } make =
    ] unit-test
    cpu ppc.32? [
        { t } [
            [ t { { 0 double-rep 1 } } ppc-varargs-indicator ] B{ } make
            [ 6 CRSET ] B{ } make =
        ] unit-test
        { t } [
            [ t { { 0 int-rep 3 } } ppc-varargs-indicator ] B{ } make
            [ 6 CRCLR ] B{ } make =
        ] unit-test
        { B{ } } [
            [ f { { 0 double-rep 1 } } ppc-varargs-indicator ] B{ } make
        ] unit-test
        ! Indirect calls must forward the variadic flag to the shared emitter.
        { t } [
            init-relocation
            [ 3 t { } { } { } { } f 0 f %alien-indirect ] B{ } make
            [ 6 CRCLR 12 3 MR 12 MTCTR BCTRL ] B{ } make =
        ] unit-test
    ] when
] when
