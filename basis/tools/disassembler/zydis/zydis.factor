! Copyright (C) 2026 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.libraries
alien.libraries.finder
alien.strings alien.syntax arrays classes.struct combinators
hex-strings io.files kernel layouts locals make math math.bitwise namespaces
sequences system tools.disassembler.private tools.memory ;
IN: tools.disassembler.zydis

C-LIBRARY: libzydis {
    { windows "Zydis.dll" }
    { macos "libZydis.dylib" }
    { linux "libZydis.so.4.1" }
    { unix "libZydis.so" }
}

<<
"libzydis" "Zydis" cdecl ?update-library

! Also support Homebrew and MacPorts without requiring DYLD_LIBRARY_PATH.
os macos? "libzydis" lookup-library dll>> dll-valid? not and [
    {
        "/opt/homebrew/lib/libZydis.dylib"
        "/usr/local/lib/libZydis.dylib"
        "/opt/local/lib/libZydis.dylib"
    } [ file-exists? ] find nip
    [ "libzydis" swap cdecl update-library ] when*
] when
>>

LIBRARY: libzydis

ENUM: ZydisMachineMode
    ZYDIS_MACHINE_MODE_LONG_64
    ZYDIS_MACHINE_MODE_LONG_COMPAT_32
    ZYDIS_MACHINE_MODE_LONG_COMPAT_16
    ZYDIS_MACHINE_MODE_LEGACY_32
    ZYDIS_MACHINE_MODE_LEGACY_16
    ZYDIS_MACHINE_MODE_REAL_16 ;

! Structure layouts for Zydis 4.1. Enum fields other than machine mode
! are represented by their underlying C int type.
STRUCT: ZydisDecodedOperandReg
    { value int } ;

STRUCT: ZydisDecodedOperandMemDisp
    { has_displacement uchar }
    { value int64_t } ;

STRUCT: ZydisDecodedOperandMem
    { type int }
    { segment int }
    { base int }
    { index int }
    { scale uint8_t }
    { disp ZydisDecodedOperandMemDisp } ;

STRUCT: ZydisDecodedOperandPtr
    { segment uint16_t }
    { offset uint32_t } ;

UNION-STRUCT: ZydisDecodedOperandImmValue
    { u uint64_t }
    { s int64_t } ;

STRUCT: ZydisDecodedOperandImm
    { is_signed uchar }
    { is_relative uchar }
    { value ZydisDecodedOperandImmValue } ;

UNION-STRUCT: ZydisDecodedOperandValueUnion
    { reg ZydisDecodedOperandReg }
    { mem ZydisDecodedOperandMem }
    { ptr ZydisDecodedOperandPtr }
    { imm ZydisDecodedOperandImm } ;

STRUCT: ZydisDecodedOperand
    { id uint8_t }
    { visibility int }
    { actions uint8_t }
    { encoding int }
    { size uint16_t }
    { element_type int }
    { element_size uint16_t }
    { element_count uint16_t }
    { attributes uint8_t }
    { type int }
    { value ZydisDecodedOperandValueUnion } ;

STRUCT: ZydisAccessedFlags
    { tested uint32_t }
    { modified uint32_t }
    { set_0 uint32_t }
    { set_1 uint32_t }
    { undefined uint32_t } ;

STRUCT: ZydisDecodedInstructionRawRex
    { W uint8_t }
    { R uint8_t }
    { X uint8_t }
    { B uint8_t }
    { offset uint8_t } ;

STRUCT: ZydisDecodedInstructionRawXop
    { R uint8_t }
    { X uint8_t }
    { B uint8_t }
    { m_mmmm uint8_t }
    { W uint8_t }
    { vvvv uint8_t }
    { L uint8_t }
    { pp uint8_t }
    { offset uint8_t } ;

STRUCT: ZydisDecodedInstructionRawVex
    { R uint8_t }
    { X uint8_t }
    { B uint8_t }
    { m_mmmm uint8_t }
    { W uint8_t }
    { vvvv uint8_t }
    { L uint8_t }
    { pp uint8_t }
    { offset uint8_t }
    { size uint8_t } ;

STRUCT: ZydisDecodedInstructionRawEvex
    { R uint8_t }
    { X uint8_t }
    { B uint8_t }
    { R2 uint8_t }
    { mmm uint8_t }
    { W uint8_t }
    { vvvv uint8_t }
    { pp uint8_t }
    { z uint8_t }
    { L2 uint8_t }
    { L uint8_t }
    { b uint8_t }
    { V2 uint8_t }
    { aaa uint8_t }
    { offset uint8_t } ;

STRUCT: ZydisDecodedInstructionRawMvex
    { R uint8_t }
    { X uint8_t }
    { B uint8_t }
    { R2 uint8_t }
    { mmmm uint8_t }
    { W uint8_t }
    { vvvv uint8_t }
    { pp uint8_t }
    { E uint8_t }
    { SSS uint8_t }
    { V2 uint8_t }
    { kkk uint8_t }
    { offset uint8_t } ;

STRUCT: ZydisDecodedInstructionAvxMask
    { mode int }
    { reg int } ;

STRUCT: ZydisDecodedInstructionAvxBroadcast
    { is_static uchar }
    { mode int } ;

STRUCT: ZydisDecodedInstructionAvxRounding
    { mode int } ;

STRUCT: ZydisDecodedInstructionAvxSwizzle
    { mode int } ;

STRUCT: ZydisDecodedInstructionAvxConversion
    { mode int } ;

STRUCT: ZydisDecodedInstructionAvx
    { vector_length uint16_t }
    { mask ZydisDecodedInstructionAvxMask }
    { broadcast ZydisDecodedInstructionAvxBroadcast }
    { rounding ZydisDecodedInstructionAvxRounding }
    { swizzle ZydisDecodedInstructionAvxSwizzle }
    { conversion ZydisDecodedInstructionAvxConversion }
    { has_sae uchar }
    { has_eviction_hint uchar } ;

STRUCT: ZydisDecodedInstructionMeta
    { category int }
    { isa_set int }
    { isa_ext int }
    { branch_type int }
    { exception_class int } ;

STRUCT: ZydisDecodedInstructionRawPrefixes
    { type int }
    { value uint8_t } ;

UNION-STRUCT: ZydisDecodedInstructionRawValueUnion
    { rex ZydisDecodedInstructionRawRex }
    { xop ZydisDecodedInstructionRawXop }
    { vex ZydisDecodedInstructionRawVex }
    { evex ZydisDecodedInstructionRawEvex }
    { mvex ZydisDecodedInstructionRawMvex } ;

STRUCT: ZydisDecodedInstructionModRm
    { mod uint8_t }
    { reg uint8_t }
    { rm uint8_t }
    { offset uint8_t } ;

STRUCT: ZydisDecodedInstructionRawSib
    { scale uint8_t }
    { index uint8_t }
    { base uint8_t }
    { offset uint8_t } ;

STRUCT: ZydisDecodedInstructionRawDisp
    { value int64_t }
    { size uint8_t }
    { offset uint8_t } ;

UNION-STRUCT: ZydisDecodedInstructionRawImmValue
    { u uint64_t }
    { s int64_t } ;

STRUCT: ZydisDecodedInstructionRawImm
    { is_signed uchar }
    { is_relative uchar }
    { value ZydisDecodedInstructionRawImmValue }
    { size uint8_t }
    { offset uint8_t } ;

STRUCT: ZydisDecodedInstructionRaw
    { prefix_count uint8_t }
    { prefixes ZydisDecodedInstructionRawPrefixes[15] }
    { encoding2 int }
    { value ZydisDecodedInstructionRawValueUnion }
    { modrm ZydisDecodedInstructionModRm }
    { sib ZydisDecodedInstructionRawSib }
    { disp ZydisDecodedInstructionRawDisp }
    { imm ZydisDecodedInstructionRawImm[2] } ;

STRUCT: ZydisDecodedInstruction
    { machine_mode int }
    { mnemonic int }
    { length uint8_t }
    { encoding int }
    { opcode_map int }
    { opcode uint8_t }
    { stack_width uint8_t }
    { operand_width uint8_t }
    { address_width uint8_t }
    { operand_count uint8_t }
    { operand_count_visible uint8_t }
    { attributes uint64_t }
    { cpu_flags ZydisAccessedFlags* }
    { fpu_flags ZydisAccessedFlags* }
    { avx ZydisDecodedInstructionAvx }
    { meta ZydisDecodedInstructionMeta }
    { raw ZydisDecodedInstructionRaw } ;

STRUCT: ZydisDisassembledInstruction
    { runtime_address uint64_t }
    { info ZydisDecodedInstruction }
    { operands ZydisDecodedOperand[10] }
    { text char[96] } ;

FUNCTION: uint64_t ZydisGetVersion ( )
FUNCTION: uint32_t ZydisDisassembleIntel ( ZydisMachineMode machine_mode, uint64_t runtime_address, void* buffer, size_t length, ZydisDisassembledInstruction* instruction )
FUNCTION: uint32_t ZydisDisassembleATT ( ZydisMachineMode machine_mode, uint64_t runtime_address, void* buffer, size_t length, ZydisDisassembledInstruction* instruction )

SINGLETON: zydis-disassembler

<PRIVATE

ERROR: unsupported-zydis-version version ;

: check-zydis-version ( -- )
    ZydisGetVersion dup -32 shift 0x00040001 =
    [ drop ] [ unsupported-zydis-version ] if ;

: zydis-machine-mode ( -- mode )
    cell-bits 64 =
    ZYDIS_MACHINE_MODE_LONG_64 ZYDIS_MACHINE_MODE_LEGACY_32 ? ;

:: make-disassembly ( from to -- lines )
    check-zydis-version
    ZydisDisassembledInstruction <struct> :> instruction
    from :> address!
    [
        [ address to < ] [
            zydis-machine-mode address address <alien>
            to address - instruction ZydisDisassembleIntel
            0x80000000 bitand zero? [
                instruction info>> length>> :> size
                address
                address <alien> size memory>byte-array bytes>hex-string
                instruction text>> alien>native-string 3array ,
                address size + address!
            ] [ to address! ] if
        ] while
    ] { } make ;

PRIVATE>

M: zydis-disassembler disassemble*
    [ make-disassembly dup empty? [ drop ] [ write-disassembly ] if ]
    with-code-blocks ;

zydis-disassembler disassembler-backend set-global
