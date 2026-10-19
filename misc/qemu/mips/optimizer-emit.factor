! Run with the host VM after refreshing source added since its seed image.
USING: accessors alien alien.c-types arrays assocs byte-arrays compiler.cfg compiler.cfg.instructions
compiler.cfg.stack-frame compiler.cfg.builder.alien.params compiler.cfg.comparisons
compiler.codegen.labels compiler.codegen.relocation compiler.constants
cpu.architecture cpu.mips cpu.mips.abi cpu.mips.assembler
cpu.mips.assembler.registers io.encodings.binary io.encodings.utf8
io.files kernel layouts locals make math math.parser namespaces sequences
system vectors ;
IN: mips.optimizer-probe

:: emit-probe ( name quot -- )
    [
        init-relocation V{ } clone label-table set
        0 extra-offset set
        quot B{ } make :> code
        "/tmp/mips-optimizer-artifacts/" mips-cpu name>> append
        "-" append name append :> path
        code path ".bin" append binary set-file-contents
        relocation-table get path ".relocs" append binary set-file-contents
        label-table get [| fixup |
            fixup offset>> number>string " " append
            fixup label>> offset>> number>string append
        ] map path ".labels" append utf8 set-file-lines
    ] with-scope ; inline
:: emit-integer-call ( -- )
    <label> drop
    f f <basic-block> <cfg> T{ stack-frame { spill-area-base 64 } } >>stack-frame cfg set
    192 %prologue
    12 <iota> [| i | temp1 i 1 + cell-li temp1 SP i mips-cells 64 + cell-store ] each
    mips-cpu mips32? 4 8 ? :> register-count
    f param-regs int-regs swap at :> argument-regs
    register-count <iota> [| i |
        i mips-cells <spill-slot> int-rep i argument-regs nth 3array
    ] map :> inputs
    12 register-count - <iota> [| i |
        i register-count + mips-cells <spill-slot>
        int-rep i mips-cells mips-cpu mips32? 16 0 ? + mips-cell 4array
    ] map :> stack-inputs
    12 register-count - mips-cells mips-cpu mips32? 16 0 ? + 16 align 32 + :> size
    f inputs stack-inputs { } { } 0 size "native-int12" f f %alien-invoke
    192 %epilogue RET ;

:: store-double-bits ( value offset -- )
    mips-cpu mips32? [
        mips-big-endian? get [ value -32 shift value ] [ value value -32 shift ] if :> ( first second )
        temp1 first cell-li temp1 SP offset 64 + cell-store
        temp1 second cell-li temp1 SP offset 68 + cell-store
    ] [ temp1 value cell-li temp1 SP offset 64 + cell-store ] if ;
:: emit-mixed-call ( leading? -- )
    f f <basic-block> <cfg> T{ stack-frame { spill-area-base 64 } } >>stack-frame cfg set
    160 %prologue
    temp1 3 cell-li temp1 SP 64 cell-store
    temp1 5 cell-li temp1 SP 80 cell-store
    0x3ff4000000000000 8 store-double-bits
    0x4004000000000000 24 store-double-bits
    mips-cpu mips32? :> o32?
    leading? [
        8 <spill-slot> double-rep F12 3array
        24 <spill-slot> double-rep o32? F14 F13 ? 3array
        o32? [ 2array 0 <spill-slot> int-rep 16 4 4array 1array 64 ] [
            0 <spill-slot> int-rep A2 3array 3array { } 0
        ] if
    ] [
        0 <spill-slot> int-rep A0 3array
        o32? [
            8 <spill-slot> int-rep A2 3array 12 <spill-slot> int-rep A3 3array 3array
            16 <spill-slot> int-rep 16 4 4array
            24 <spill-slot> double-rep 24 8 4array 2array 64
        ] [
            8 <spill-slot> double-rep F13 3array
            16 <spill-slot> int-rep A2 3array
            24 <spill-slot> double-rep F15 3array 4array { } 0
        ] if
    ] if :> ( inputs stacks size )
    f inputs stacks { } { } 0 size leading? "native-leading" "native-mixed" ? f f %alien-invoke
    160 %epilogue RET ;

:: emit-callback-io ( -- )
    f f <basic-block> <cfg> T{ stack-frame { spill-area-base 64 } } >>stack-frame cfg set
    112 %prologue
    { } 0 <spill-slot> int-rep mips-cpu mips32? 16 0 ? mips-cell 4array 1array %callback-inputs
    0 <spill-slot> int-rep V0 3array 1array %callback-outputs
    112 %epilogue RET ;

:: emit-all ( target -- )
    target \ cpu [
        mips-cell \ cell [
        target { mips.32 mips.64 } member? mips-big-endian? [
            "native-int12" [ emit-integer-call ] emit-probe
            "native-mixed" [ f emit-mixed-call ] emit-probe
            "native-leading" [ t emit-mixed-call ] emit-probe
            "add" [ V0 A0 A1 %add RET ] emit-probe
            "mul" [ V0 A0 A1 %mul RET ] emit-probe
            "neg" [ V0 A0 %neg RET ] emit-probe
            "min-alias" [ A0 A0 A1 %min V0 A0 MOV RET ] emit-probe
            "max-alias" [ A1 A0 A1 %max V0 A1 MOV RET ] emit-probe
            "shift" [ V0 A0 A1 %sar RET ] emit-probe
            "frame" [ 48 %prologue V0 A0 A1 %add 48 %epilogue RET ] emit-probe
            "callback-io" [ emit-callback-io ] emit-probe
            "callback-stack" [ V0 %callback-stack RET ] emit-probe
            "unbox-alias" [ A0 A0 %unbox-any-c-ptr V0 A0 MOV RET ] emit-probe
            "box-alias" [ A0 A0 V1 %box-alien V0 A0 MOV RET ] emit-probe
            "displaced-alias" [ A0 A1 A0 V1 f %box-displaced-alien V0 A0 MOV RET ] emit-probe
            "negative-mask" [ V0 A0 -256 %and-imm RET ] emit-probe
            "large-offset" [ V0 A0 70000 %add-imm RET ] emit-probe
            "unaligned-half" [ V0 A0 0 int-rep ushort %load-memory-imm RET ] emit-probe
            "unaligned-word-alias" [ A0 A0 0 int-rep uint %load-memory-imm V0 A0 MOV RET ] emit-probe
            "unaligned-cell" [ V0 A0 0 int-rep f %load-memory-imm RET ] emit-probe
            "unaligned-cell-store" [ A1 A0 0 int-rep f %store-memory-imm RET ] emit-probe
            "unaligned-double" [ F0 A0 0 double-rep f %load-memory-imm RET ] emit-probe
            "unaligned-double-store" [ F12 target mips32? A2 A1 ? 0 double-rep f %store-memory-imm RET ] emit-probe
            "unaligned-float" [ F2 A0 0 float-rep f %load-memory-imm F0 F2 %single>double-float RET ] emit-probe
            "unaligned-float-store" [ F12 A1 0 float-rep f %store-memory-imm RET ] emit-probe
            "unsigned-byte" [ V0 A0 0 int-rep uchar %load-memory-imm RET ] emit-probe
            "signed-byte" [ V0 A0 0 int-rep char %load-memory-imm RET ] emit-probe
            "unsigned-word" [ V0 A0 0 int-rep uint %load-memory-imm RET ] emit-probe
            "float-add" [ F0 F12 target mips32? F14 F13 ? %add-float RET ] emit-probe
            "integer-float" [ F0 A0 %integer>float RET ] emit-probe
            "float-integer" [ V0 F12 %float>integer RET ] emit-probe
            "float-less" [ V0 F12 target mips32? F14 F13 ? cc< float-bit RET ] emit-probe
            "float-neq" [ V0 F12 target mips32? F14 F13 ? cc<> float-bit RET ] emit-probe
            "float-unordered" [ V0 F12 target mips32? F14 F13 ? cc/<>= float-bit RET ] emit-probe
        ] with-variable
        ] with-variable
    ] with-variable ;
{ mips.32 mipsel.32 mips.64 mipsel.64 } [ emit-all ] each
