USING: accessors alien alien.data alien.strings classes.struct
destructors io.streams.string kernel libc locals math namespaces
sequences tools.disassembler tools.disassembler.private
tools.disassembler.zydis tools.disassembler.zydis.private tools.test ;
IN: tools.disassembler.zydis.tests

:: decode ( bytes mode -- status instruction )
    check-zydis-version
    ZydisDisassembledInstruction <struct> :> instruction
    mode 0x1000 bytes bytes length instruction
    ZydisDisassembleIntel instruction ;

{ 0x100000 3 "mov rbp, rsp" } [
    B{ 0x48 0x89 0xe5 } ZYDIS_MACHINE_MODE_LONG_64 decode
    [ info>> length>> ] [ text>> alien>native-string ] bi
] unit-test

{ 0x100000 1 "dec eax" } [
    B{ 0x48 } ZYDIS_MACHINE_MODE_LEGACY_32 decode
    [ info>> length>> ] [ text>> alien>native-string ] bi
] unit-test

{ 0x100000 "call 0x0000000000001005" } [
    B{ 0xe8 0 0 0 0 } ZYDIS_MACHINE_MODE_LONG_64 decode
    text>> alien>native-string
] unit-test

: disassembly-lines ( bytes -- lines )
    [
        [ malloc-byte-array &free alien-address ] [ length ] bi
        over + make-disassembly
    ] with-destructors ;

{ { { "90" "nop" } { "c3" "ret" } } } [
    B{ 0x90 0xc3 } disassembly-lines [ rest ] map
] unit-test

{ 1 1 } [
    B{ 0x90 0x90 0xc3 } disassembly-lines
    [ first ] map
    [ [ second ] [ first ] bi - ]
    [ [ third ] [ second ] bi - ] bi
] unit-test

! Stop at an invalid or truncated instruction, retaining earlier lines.
{ { { "90" "nop" } } } [
    B{ 0x90 0x0f } disassembly-lines [ rest ] map
] unit-test

{ { } } [ B{ 0x0f } disassembly-lines ] unit-test
{ { } } [ B{ 0xf0 0x90 } disassembly-lines ] unit-test
{ { } } [ B{ } disassembly-lines ] unit-test

{ "" } [
    zydis-disassembler disassembler-backend [
        [ B{ } disassemble ] with-string-writer
    ] with-variable
] unit-test
