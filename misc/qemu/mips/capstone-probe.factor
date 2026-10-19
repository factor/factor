USING: accessors alien.c-types alien.data alien.destructors alien.enums
alien.strings byte-arrays classes.struct continuations destructors io kernel locals
sequences system tools.disassembler.capstone
tools.disassembler.capstone.private ;
IN: mips.capstone-probe

:: decode-mips ( target bytes mnemonic -- )
    target capstone-arch-mode 0 csh <ref> :> handle
    [
        handle cs_open CS_ERR_OK assert=
        handle &cs_close drop
        handle csh deref bytes 4 0 1
        { void* } [ cs_disasm ] with-out-parameters
        swap 1 assert= :> insns
        [
            insns 1 <direct-cs_insn-array> first :> insn
            mnemonic insn mnemonic>> alien>native-string assert=
            4 insn size>> assert=
            0 insn address>> assert=
        ] [ insns 1 cs_free ] finally
    ] with-destructors ;

CS_ARCH_MIPS enum>number cs_support t assert=
[ drop ] with-csh
mipsel.32 B{ 33 16 133 0 } "addu" decode-mips
mips.32 B{ 0 133 16 33 } "addu" decode-mips
mipsel.64 B{ 45 16 133 0 } "daddu" decode-mips
mips.64 B{ 0 133 16 45 } "daddu" decode-mips
"Four MIPS Capstone CPU modes PASS" print
