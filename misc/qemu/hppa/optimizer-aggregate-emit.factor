! Emit the actual aggregate component CFG through the HPPA code generator.
! The fixture assigns its known live ranges explicitly; it does not run the
! whole optimizer or register allocator. Native probes check the emitted bytes.
USING: accessors byte-arrays command-line compiler.cfg.builder.alien.boxing
compiler.cfg.instructions compiler.codegen compiler.test cpu.architecture
cpu.hppa cpu.hppa.abi cpu.hppa.assembler cpu.hppa.assembler.registers
io.encodings.binary io.files io.pathnames kernel layouts locals make
math math.parser namespaces sequences strings system vectors ;
IN: cpu.hppa.aggregate-emit
4 \ cell set
:: map-load-insn ( insn -- )
    insn ##load-integer? [ insn RETURN >>dst drop ] [
        insn ##load-memory-imm? [ insn arg2 >>dst arg1 >>base drop ] [
            insn ##shl-imm? [ insn arg2 >>dst arg2 >>src1 drop ]
            [ insn RETURN >>dst RETURN >>src1 arg2 >>src2 drop ] if
        ] if
    ] if ;
:: map-store-insn ( insn -- )
    insn ##shr-imm? [ insn temp >>dst arg2 >>src1 drop ]
    [ insn temp >>src arg1 >>base drop ] if ;
:: emit-part ( count store? -- bytes )
    init-cfg-test
    store? [ [ 2 42 0 int-rep count <hppa-struct-part> store-struct-component ] V{ } make ]
    [ [ 42 0 int-rep count <hppa-struct-part> load-struct-component drop ] V{ } make ] if
    :> instructions
    instructions [ store? [ map-store-insn ] [ map-load-insn ] if ] each
    [ IP1 NATIVE-SP -24 STW temp1 NATIVE-SP -20 STW
      instructions [ generate-insn ] each
      store? [ RETURN arg2 COPY ] when
      IP1 NATIVE-SP -24 LDW temp1 NATIVE-SP -20 LDW RET ] B{ } make ;
:: save-part ( count store? -- )
    count store? emit-part count number>string
    store? "hppa-part-store-" "hppa-part-load-" ? prepend ".bin" append
    command-line get first prepend-path binary set-file-contents ;
hppa.32 \ cpu [ 4 <iota> [ 1 + dup f save-part t save-part ] each ] with-variable
