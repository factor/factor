USING: compiler.cfg alien.c-types cpu.architecture cpu.arm.32 cpu.arm.32.assembler
cpu.arm.32.compiler-assembler compiler.codegen.relocation compiler.codegen.labels compiler.codegen.gc-maps compiler.cfg.instructions compiler.cfg.comparisons compiler.cfg.stack-frame arrays generic kernel layouts literals make namespaces sequences system tools.test locals vectors ;
IN: cpu.arm.32.tests
{ { 0xe0902001 0xe0523001 0xe1a03211 0xe1a03251 } }
[ f emit-bytecode? [ [ [ R2 R0 R1 M\ arm.32 %add execute R3 R2 R1 M\ arm.32 %sub execute R3 R1 R2 M\ arm.32 %shl execute R3 R1 R2 M\ arm.32 %sar execute ] { } make ] call ] with-variable ] unit-test
{ { 0xee300b01 0xeeb71ac0 0xeeb72bc3 } }
[ f emit-bytecode? [ [ [ D0 D0 D1 M\ arm.32 %add-float execute D1 D0 M\ arm.32 %single>double-float execute D2 D3 M\ arm.32 %double>single-float execute ] { } make ] call ] with-variable ] unit-test
{ { 0xe24dd008 0xe92d4800 0xe1a0b00d 0xe8bd4800 0xe28dd008 } }
[ f emit-bytecode? [ [ [ 16 M\ arm.32 %prologue execute 16 M\ arm.32 %epilogue execute ] { } make ] call ] with-variable ] unit-test

! Signed C loads and narrowing conversions must retain the sign bit.
{ { 0xe300c000 0xe340c000 0xe080c00c 0xe1dc00d0 } }
[ f emit-bytecode? [ [ R0 R0 0 int-rep char M\ arm.32 %load-memory-imm execute ] { } make ] with-variable ] unit-test
{ { 0xe1a00800 0xe1a00840 } }
[ f emit-bytecode? [ [ R0 R0 short M\ arm.32 %convert-integer execute ] { } make ] with-variable ] unit-test

{ { 0xe5980010 0xe2800070 } }
[ f emit-bytecode? [ 4 \ cell [ [ R0 M\ arm.32 %callback-stack execute ] { } make ] with-variable ] with-variable ] unit-test
{ { 0xe5984010 0xe5944070 0xe1a00004 } }
[ f emit-bytecode? [ 4 \ cell [ [ R0 int-rep 0 4 %load-stack-param ] { } make ] with-variable ] with-variable ] unit-test
{ { 0xe5984010 0xed94fb1e 0xeeb00b4f } }
[ f emit-bytecode? [ 4 \ cell [ [ D0 double-rep 8 8 %load-stack-param ] { } make ] with-variable ] with-variable ] unit-test

! Non-fixnum comparisons load a relocated object pointer, not tagged arithmetic.
{ { 0xe59fc000 0xea000000 0 0 0 0 } { "reference" } 4 }
[ f emit-bytecode? [ 4 \ cell [ init-relocation [ R12 "reference" load-tagged-immediate ] { } make
  literal-table get >array relocation-table get length ] with-variable ] with-variable ] unit-test
{ { 0xe3a0c001 } { } 0 }
[ f emit-bytecode? [ init-relocation [ R12 f load-tagged-immediate ] { } make
  literal-table get >array relocation-table get length ] with-variable ] unit-test

! ARM encodes immediate right shift #0 as #32, so zero uses an ordinary move.
{ { 0xe1a00001 0xe1a02003 } }
[ f emit-bytecode? [ [ R0 R1 0 M\ arm.32 %shr-imm execute
    R2 R3 0 M\ arm.32 %sar-imm execute ] { } make ] with-variable ] unit-test

! CPU initialization survives the temporary namespace used by vocab loading.
! Branch offsets and targets are byte offsets after that scope has returned.
:: emission-after-enabling ( -- code labels flags )
    emit-bytecode? get-global :> old-byte
    have-BX? get-global :> old-bx
    have-BLX? get-global :> old-blx
    [ M\ arm.32 enable-cpu-features execute ] with-scope
    init-relocation V{ } clone label-table set
    [
        <label> :> done
        done M\ arm.32 %jump-label execute
        R0 R0 MOV done resolve-label
        M\ arm.32 %return execute
    ] B{ } make
    label-table get compute-labels
    emit-bytecode? get have-BX? get have-BLX? get 3array
    old-byte emit-bytecode? set-global
    old-bx have-BX? set-global
    old-blx have-BLX? set-global ;
{ B{ 0 0 0 234 0 0 160 225 30 255 47 225 } { 3 4 8 } { t t t } }
[ emission-after-enabling ] unit-test

! The true literal load takes the scratch register before the relocation value.
{ 32 t 4 }
[ 4 \ cell [
    init-relocation
    [ emit-bytecode? on
      [ R0 R1 7 cc= R2 M\ arm.32 %compare-integer-imm execute ] B{ } make
    ] with-scope length
    literal-table get first \ t = relocation-table get length
] with-variable ] unit-test

! A 24-byte spill area plus the frame header must round 40 up to 48.
{ 48 }
[ T{ stack-frame { spill-area-base 16 } { spill-area-size 8 } }
  M\ arm.32 stack-frame-size execute ] unit-test

! BLX returns at byte 8 of the 16-byte inline Factor call template.
{ 16 8 0 }
[ arm.32 \ cpu [
    emit-bytecode? on init-relocation
    V{ } clone return-addresses set V{ } clone gc-maps set
    [ T{ gc-map { gc-roots { 0 } } { derived-roots H{ } } }
      %call-gc ] B{ } make length
    return-addresses get first extra-offset get
] with-variable ] unit-test
! Native helper calls return at the end of LDR/B/literal followed by BLX.
{ 16 16 }
[ arm.32 \ cpu [
    emit-bytecode? on have-BLX? on init-relocation
    V{ } clone return-addresses set V{ } clone gc-maps set
    [ "box_signed_cell" f
      T{ gc-map { gc-roots { 0 } } { derived-roots H{ } } }
      %c-invoke ] B{ } make length
    return-addresses get first
] with-variable ] unit-test

! Native stack-argument calls preserve the target in IP while computing R4.
{ { 0xe3004008 0xe3404000 0xe08d4004 } }
[ f emit-bytecode? [ [ 24 native-call-frame ] { } make ] with-variable ] unit-test
{ 32 }
[ arm.32 \ cpu [
    emit-bytecode? on have-BLX? on init-relocation
    [ R4 24 f %invoke-indirect ] B{ } make length
] with-variable ] unit-test

! Exercise the public hook: source and frame size must retain their order.
{ { 0xe59dc018 0xe3004008 0xe3404000 0xe08d4004
    0xe59fe000 0xea000000 0 0 0 0 0xe12fff3e } }
[ f emit-bytecode? [ T{ cfg { stack-frame T{ stack-frame { spill-area-base 0 } } } } \ cfg [
    arm.32 \ cpu [
        have-BLX? on init-relocation
        [ T{ spill-slot { n 24 } } f { } { } { } { } 0 24 f
          %alien-indirect ] { } make
    ] with-variable
] with-variable ] with-variable ] unit-test
{ { 0xe59dc018 0xe12fff3a } }
[ f emit-bytecode? [ T{ cfg { stack-frame T{ stack-frame { spill-area-base 0 } } } } \ cfg [
    arm.32 \ cpu [
        have-BLX? on init-relocation
        [ T{ spill-slot { n 24 } } f { } { } { } { } 0 0 f
          %alien-indirect ] { } make
    ] with-variable
] with-variable ] with-variable ] unit-test

! ABI return placeholders use S lanes; double spills must select the D view.
{ { 0xed8d0b04 0xed9d0b04 0xed8d1a04 0xed9d1a04 } }
[ f emit-bytecode? [ T{ cfg { stack-frame T{ stack-frame { spill-area-base 0 } } } } \ cfg [
    [ T{ spill-slot { n 16 } } S0 double-rep M\ arm.32 %copy execute
      S0 T{ spill-slot { n 16 } } double-rep M\ arm.32 %copy execute
      T{ spill-slot { n 16 } } D1 float-rep M\ arm.32 %copy execute
      D1 T{ spill-slot { n 16 } } float-rep M\ arm.32 %copy execute ] { } make
] with-variable ] with-variable ] unit-test
