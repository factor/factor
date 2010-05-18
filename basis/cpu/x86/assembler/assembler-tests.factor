USING: cpu.x86.assembler cpu.x86.assembler.operands
kernel tools.test namespaces make layouts ;
IN: cpu.x86.assembler.tests

! small registers
[ { 128 192 12 } ] [ [ AL 12 <byte> ADD ] { } make ] unit-test
[ { 128 196 12 } ] [ [ AH 12 <byte> ADD ] { } make ] unit-test
[ { 176 12 } ] [ [ AL 12 <byte> MOV ] { } make ] unit-test
[ { 180 12 } ] [ [ AH 12 <byte> MOV ] { } make ] unit-test
[ { 198 0 12 } ] [ [ EAX [] 12 <byte> MOV ] { } make ] unit-test
[ { 0 235 } ] [ [ BL CH ADD ] { } make ] unit-test
[ { 136 235 } ] [ [ BL CH MOV ] { } make ] unit-test

! immediate operands
cell 4 = [
    [ { HEX: b9 HEX: 01 HEX: 00 HEX: 00 HEX: 00 } ] [ [ ECX 1 MOV ] { } make ] unit-test
] [
    [ { HEX: b9 HEX: 01 HEX: 00 HEX: 00 HEX: 00 HEX: 00 HEX: 00 HEX: 00 HEX: 00 } ] [ [ ECX 1 MOV ] { } make ] unit-test
] if

[ { HEX: 83 HEX: c1 HEX: 01 } ] [ [ ECX 1 ADD ] { } make ] unit-test
[ { HEX: 81 HEX: c1 HEX: 96 HEX: 00 HEX: 00 HEX: 00 } ] [ [ ECX 150 ADD ] { } make ] unit-test
[ { HEX: f7 HEX: c1 HEX: d2 HEX: 04 HEX: 00 HEX: 00 } ] [ [ ECX 1234 TEST ] { } make ] unit-test

! 64-bit registers
[ { HEX: 40 HEX: 8a HEX: 2a } ] [ [ BPL RDX [] MOV ] { } make ] unit-test

[ { HEX: 49 HEX: 89 HEX: 04 HEX: 24 } ] [ [ R12 [] RAX MOV ] { } make ] unit-test
[ { HEX: 49 HEX: 8b HEX: 06 } ] [ [ RAX R14 [] MOV ] { } make ] unit-test

[ { HEX: 89 HEX: ca } ] [ [ EDX ECX MOV ] { } make ] unit-test
[ { HEX: 4c HEX: 89 HEX: e2 } ] [ [ RDX R12 MOV ] { } make ] unit-test
[ { HEX: 49 HEX: 89 HEX: d4 } ] [ [ R12 RDX MOV ] { } make ] unit-test

! memory address modes
[ { HEX: 8a HEX: 18         } ] [ [ BL RAX [] MOV ] { } make ] unit-test
[ { HEX: 66 HEX: 8b HEX: 18 } ] [ [ BX RAX [] MOV ] { } make ] unit-test
[ { HEX: 8b HEX: 18         } ] [ [ EBX RAX [] MOV ] { } make ] unit-test
[ { HEX: 48 HEX: 8b HEX: 18 } ] [ [ RBX RAX [] MOV ] { } make ] unit-test
[ { HEX: 88 HEX: 18         } ] [ [ RAX [] BL MOV ] { } make ] unit-test
[ { HEX: 66 HEX: 89 HEX: 18 } ] [ [ RAX [] BX MOV ] { } make ] unit-test
[ { HEX: 89 HEX: 18         } ] [ [ RAX [] EBX MOV ] { } make ] unit-test
[ { HEX: 48 HEX: 89 HEX: 18 } ] [ [ RAX [] RBX MOV ] { } make ] unit-test

[ { HEX: 0f HEX: be HEX: c3 } ] [ [ EAX BL MOVSX ] { } make ] unit-test
[ { HEX: 0f HEX: bf HEX: c3 } ] [ [ EAX BX MOVSX ] { } make ] unit-test

[ { HEX: 80 HEX: 08 HEX: 05 } ] [ [ EAX [] 5 <byte> OR ] { } make ] unit-test
[ { HEX: c6 HEX: 00 HEX: 05 } ] [ [ EAX [] 5 <byte> MOV ] { } make ] unit-test

[ { HEX: 49 HEX: 89 HEX: 04 HEX: 1a } ] [ [ R10 RBX [+] RAX MOV ] { } make ] unit-test
[ { HEX: 49 HEX: 89 HEX: 04 HEX: 1b } ] [ [ R11 RBX [+] RAX MOV ] { } make ] unit-test

[ { HEX: 49 HEX: 89 HEX: 04 HEX: 1c } ] [ [ R12 RBX [+] RAX MOV ] { } make ] unit-test
[ { HEX: 48 HEX: 89 HEX: 04 HEX: 1c } ] [ [ RSP RBX [+] RAX MOV ] { } make ] unit-test

[ { HEX: 49 HEX: 89 HEX: 44 HEX: 1d HEX: 00 } ] [ [ R13 RBX [+] RAX MOV ] { } make ] unit-test
[ { HEX: 48 HEX: 89 HEX: 44 HEX: 1d HEX: 00 } ] [ [ RBP RBX [+] RAX MOV ] { } make ] unit-test

[ { HEX: 4a HEX: 89 HEX: 04 HEX: 23 } ] [ [ RBX R12 [+] RAX MOV ] { } make ] unit-test
[ { HEX: 4a HEX: 89 HEX: 04 HEX: 2b } ] [ [ RBX R13 [+] RAX MOV ] { } make ] unit-test

[ { HEX: 4b HEX: 89 HEX: 44 HEX: 25 HEX: 00 } ] [ [ R13 R12 [+] RAX MOV ] { } make ] unit-test
[ { HEX: 4b HEX: 89 HEX: 04 HEX: 2c } ] [ [ R12 R13 [+] RAX MOV ] { } make ] unit-test

[ { HEX: 49 HEX: 89 HEX: 04 HEX: 2c } ] [ [ R12 RBP [+] RAX MOV ] { } make ] unit-test
[ [ R12 RSP [+] RAX MOV ] { } make ] must-fail

[ { HEX: 89 HEX: 1c HEX: 11 } ] [ [ ECX EDX [+] EBX MOV ] { } make ] unit-test
[ { HEX: 89 HEX: 1c HEX: 51 } ] [ [ ECX EDX 1 0 <indirect> EBX MOV ] { } make ] unit-test
[ { HEX: 89 HEX: 1c HEX: 91 } ] [ [ ECX EDX 2 0 <indirect> EBX MOV ] { } make ] unit-test
[ { HEX: 89 HEX: 1c HEX: d1 } ] [ [ ECX EDX 3 0 <indirect> EBX MOV ] { } make ] unit-test
[ { HEX: 89 HEX: 5c HEX: 11 HEX: 64 } ] [ [ ECX EDX 0 100 <indirect> EBX MOV ] { } make ] unit-test
[ { HEX: 89 HEX: 5c HEX: 51 HEX: 64 } ] [ [ ECX EDX 1 100 <indirect> EBX MOV ] { } make ] unit-test
[ { HEX: 89 HEX: 5c HEX: 91 HEX: 64 } ] [ [ ECX EDX 2 100 <indirect> EBX MOV ] { } make ] unit-test
[ { HEX: 89 HEX: 5c HEX: d1 HEX: 64 } ] [ [ ECX EDX 3 100 <indirect> EBX MOV ] { } make ] unit-test

[ { HEX: 48 HEX: 89 HEX: 1c HEX: 11 } ] [ [ RCX RDX [+] RBX MOV ] { } make ] unit-test
[ { HEX: 48 HEX: 89 HEX: 1c HEX: 51 } ] [ [ RCX RDX 1 0 <indirect> RBX MOV ] { } make ] unit-test
[ { HEX: 48 HEX: 89 HEX: 1c HEX: 91 } ] [ [ RCX RDX 2 0 <indirect> RBX MOV ] { } make ] unit-test
[ { HEX: 48 HEX: 89 HEX: 1c HEX: d1 } ] [ [ RCX RDX 3 0 <indirect> RBX MOV ] { } make ] unit-test
[ { HEX: 48 HEX: 89 HEX: 5c HEX: 11 HEX: 64 } ] [ [ RCX RDX 0 100 <indirect> RBX MOV ] { } make ] unit-test
[ { HEX: 48 HEX: 89 HEX: 5c HEX: 51 HEX: 64 } ] [ [ RCX RDX 1 100 <indirect> RBX MOV ] { } make ] unit-test
[ { HEX: 48 HEX: 89 HEX: 5c HEX: 91 HEX: 64 } ] [ [ RCX RDX 2 100 <indirect> RBX MOV ] { } make ] unit-test
[ { HEX: 48 HEX: 89 HEX: 5c HEX: d1 HEX: 64 } ] [ [ RCX RDX 3 100 <indirect> RBX MOV ] { } make ] unit-test

! r-rm / m-r sse instruction
[ { HEX: 0f HEX: 10 HEX: c1 } ] [ [ XMM0 XMM1 MOVUPS ] { } make ] unit-test
[ { HEX: 0f HEX: 10 HEX: 01 } ] [ [ XMM0 ECX [] MOVUPS ] { } make ] unit-test
[ { HEX: 0f HEX: 11 HEX: 08 } ] [ [ EAX [] XMM1 MOVUPS ] { } make ] unit-test

[ { HEX: f3 HEX: 0f HEX: 10 HEX: c1 } ] [ [ XMM0 XMM1 MOVSS ] { } make ] unit-test
[ { HEX: f3 HEX: 0f HEX: 10 HEX: 01 } ] [ [ XMM0 ECX [] MOVSS ] { } make ] unit-test
[ { HEX: f3 HEX: 0f HEX: 11 HEX: 08 } ] [ [ EAX [] XMM1 MOVSS ] { } make ] unit-test

[ { HEX: 66 HEX: 0f HEX: 6f HEX: c1 } ] [ [ XMM0 XMM1 MOVDQA ] { } make ] unit-test
[ { HEX: 66 HEX: 0f HEX: 6f HEX: 01 } ] [ [ XMM0 ECX [] MOVDQA ] { } make ] unit-test
[ { HEX: 66 HEX: 0f HEX: 7f HEX: 08 } ] [ [ EAX [] XMM1 MOVDQA ] { } make ] unit-test

! r-rm only sse instruction
[ { HEX: 66 HEX: 0f HEX: 2e HEX: c1 } ] [ [ XMM0 XMM1 UCOMISD ] { } make ] unit-test
[ { HEX: 66 HEX: 0f HEX: 2e HEX: 01 } ] [ [ XMM0 ECX [] UCOMISD ] { } make ] unit-test
[ [ EAX [] XMM1 UCOMISD ] { } make ] must-fail
[ { HEX: 66 HEX: 0f HEX: 38 HEX: 2a HEX: 01 } ] [ [ XMM0 ECX [] MOVNTDQA ] { } make ] unit-test

! rm-r only sse instructions
[ { HEX: 0f HEX: 2b HEX: 08 } ] [ [ EAX [] XMM1 MOVNTPS ] { } make ] unit-test
[ { HEX: 66 HEX: 0f HEX: e7 HEX: 08 } ] [ [ EAX [] XMM1 MOVNTDQ ] { } make ] unit-test

! three-byte-opcode ssse3 instruction
[ { HEX: 66 HEX: 0f HEX: 38 HEX: 02 HEX: c1 } ] [ [ XMM0 XMM1 PHADDD ] { } make ] unit-test

! int/sse conversion instruction
[ { HEX: f2 HEX: 0f HEX: 2c HEX: c0 } ] [ [ EAX XMM0 CVTTSD2SI ] { } make ] unit-test
[ { HEX: f2 HEX: 48 HEX: 0f HEX: 2c HEX: c0 } ] [ [ RAX XMM0 CVTTSD2SI ] { } make ] unit-test
[ { HEX: f2 HEX: 4c HEX: 0f HEX: 2c HEX: e0 } ] [ [ R12 XMM0 CVTTSD2SI ] { } make ] unit-test
[ { HEX: f2 HEX: 0f HEX: 2a HEX: c0 } ] [ [ XMM0 EAX CVTSI2SD ] { } make ] unit-test
[ { HEX: f2 HEX: 48 HEX: 0f HEX: 2a HEX: c0 } ] [ [ XMM0 RAX CVTSI2SD ] { } make ] unit-test
[ { HEX: f2 HEX: 48 HEX: 0f HEX: 2a HEX: c1 } ] [ [ XMM0 RCX CVTSI2SD ] { } make ] unit-test
[ { HEX: f2 HEX: 48 HEX: 0f HEX: 2a HEX: d9 } ] [ [ XMM3 RCX CVTSI2SD ] { } make ] unit-test
[ { HEX: f2 HEX: 48 HEX: 0f HEX: 2a HEX: c0 } ] [ [ XMM0 RAX CVTSI2SD ] { } make ] unit-test
[ { HEX: f2 HEX: 49 HEX: 0f HEX: 2a HEX: c4 } ] [ [ XMM0 R12 CVTSI2SD ] { } make ] unit-test

! 3-operand r-rm-imm sse instructions
[ { HEX: 66 HEX: 0f HEX: 70 HEX: c1 HEX: 02 } ]
[ [ XMM0 XMM1 2 PSHUFD ] { } make ] unit-test

[ { HEX: 0f HEX: c6 HEX: c1 HEX: 02 } ]
[ [ XMM0 XMM1 2 SHUFPS ] { } make ] unit-test

! shufflers with arrays of indexes
[ { HEX: 66 HEX: 0f HEX: 70 HEX: c1 HEX: 02 } ]
[ [ XMM0 XMM1 { 2 0 0 0 } PSHUFD ] { } make ] unit-test

[ { HEX: 0f HEX: c6 HEX: c1 HEX: 63 } ]
[ [ XMM0 XMM1 { 3 0 2 1 } SHUFPS ] { } make ] unit-test

[ { HEX: 66 HEX: 0f HEX: c6 HEX: c1 HEX: 2 } ]
[ [ XMM0 XMM1 { 0 1 } SHUFPD ] { } make ] unit-test

[ { HEX: 66 HEX: 0f HEX: c6 HEX: c1 HEX: 1 } ]
[ [ XMM0 XMM1 { 1 0 } SHUFPD ] { } make ] unit-test

! scalar register insert/extract sse instructions
[ { HEX: 66 HEX: 0f HEX: c4 HEX: c1 HEX: 02 } ] [ [ XMM0 ECX 2 PINSRW ] { } make ] unit-test
[ { HEX: 66 HEX: 0f HEX: c4 HEX: 04 HEX: 11 HEX: 03 } ] [ [ XMM0 ECX EDX [+] 3 PINSRW ] { } make ] unit-test

[ { HEX: 66 HEX: 0f HEX: c5 HEX: c1 HEX: 02 } ] [ [ EAX XMM1 2 PEXTRW ] { } make ] unit-test
[ { HEX: 66 HEX: 0f HEX: 3a HEX: 15 HEX: 08 HEX: 02 } ] [ [ EAX [] XMM1 2 PEXTRW ] { } make ] unit-test
[ { HEX: 66 HEX: 0f HEX: 3a HEX: 15 HEX: 14 HEX: 08 HEX: 03 } ] [ [ EAX ECX [+] XMM2 3 PEXTRW ] { } make ] unit-test
[ { HEX: 66 HEX: 0f HEX: 3a HEX: 14 HEX: c8 HEX: 02 } ] [ [ EAX XMM1 2 PEXTRB ] { } make ] unit-test
[ { HEX: 66 HEX: 0f HEX: 3a HEX: 14 HEX: 08 HEX: 02 } ] [ [ EAX [] XMM1 2 PEXTRB ] { } make ] unit-test

! sse shift instructions
[ { HEX: 66 HEX: 0f HEX: 71 HEX: d0 HEX: 05 } ] [ [ XMM0 5 PSRLW ] { } make ] unit-test
[ { HEX: 66 HEX: 0f HEX: d1 HEX: c1 } ] [ [ XMM0 XMM1 PSRLW ] { } make ] unit-test

! sse comparison instructions 
[ { HEX: 66 HEX: 0f HEX: c2 HEX: c1 HEX: 02 } ] [ [ XMM0 XMM1 CMPLEPD ] { } make ] unit-test

! unique sse instructions
[ { HEX: 0f HEX: 18 HEX: 00 } ] [ [ EAX [] PREFETCHNTA ] { } make ] unit-test
[ { HEX: 0f HEX: 18 HEX: 08 } ] [ [ EAX [] PREFETCHT0 ] { } make ] unit-test
[ { HEX: 0f HEX: 18 HEX: 10 } ] [ [ EAX [] PREFETCHT1 ] { } make ] unit-test
[ { HEX: 0f HEX: 18 HEX: 18 } ] [ [ EAX [] PREFETCHT2 ] { } make ] unit-test
[ { HEX: 0f HEX: ae HEX: 10 } ] [ [ EAX [] LDMXCSR ] { } make ] unit-test
[ { HEX: 0f HEX: ae HEX: 18 } ] [ [ EAX [] STMXCSR ] { } make ] unit-test

[ { HEX: 0f HEX: c3 HEX: 08 } ] [ [ EAX [] ECX MOVNTI ] { } make ] unit-test

[ { HEX: 0f HEX: 50 HEX: c1 } ] [ [ EAX XMM1 MOVMSKPS ] { } make ] unit-test
[ { HEX: 66 HEX: 0f HEX: 50 HEX: c1 } ] [ [ EAX XMM1 MOVMSKPD ] { } make ] unit-test

[ { HEX: f3 HEX: 0f HEX: b8 HEX: c1 } ] [ [ EAX ECX POPCNT ] { } make ] unit-test
[ { HEX: f3 HEX: 48 HEX: 0f HEX: b8 HEX: c1 } ] [ [ RAX RCX POPCNT ] { } make ] unit-test
[ { HEX: f3 HEX: 0f HEX: b8 HEX: 01 } ] [ [ EAX ECX [] POPCNT ] { } make ] unit-test
[ { HEX: f3 HEX: 0f HEX: b8 HEX: 04 HEX: 11 } ] [ [ EAX ECX EDX [+] POPCNT ] { } make ] unit-test

[ { HEX: f2 HEX: 0f HEX: 38 HEX: f0 HEX: c1 } ] [ [ EAX CL CRC32B ] { } make ] unit-test
[ { HEX: f2 HEX: 0f HEX: 38 HEX: f0 HEX: 01 } ] [ [ EAX ECX [] CRC32B ] { } make ] unit-test
[ { HEX: f2 HEX: 0f HEX: 38 HEX: f1 HEX: c1 } ] [ [ EAX ECX CRC32 ] { } make ] unit-test
[ { HEX: f2 HEX: 0f HEX: 38 HEX: f1 HEX: 01 } ] [ [ EAX ECX [] CRC32 ] { } make ] unit-test

! shifts
[ { HEX: 48 HEX: d3 HEX: e0 } ] [ [ RAX CL SHL ] { } make ] unit-test
[ { HEX: 48 HEX: d3 HEX: e1 } ] [ [ RCX CL SHL ] { } make ] unit-test
[ { HEX: 48 HEX: d3 HEX: e8 } ] [ [ RAX CL SHR ] { } make ] unit-test
[ { HEX: 48 HEX: d3 HEX: e9 } ] [ [ RCX CL SHR ] { } make ] unit-test

[ { HEX: c1 HEX: e0 HEX: 05 } ] [ [ EAX 5 SHL ] { } make ] unit-test
[ { HEX: c1 HEX: e1 HEX: 05 } ] [ [ ECX 5 SHL ] { } make ] unit-test
[ { HEX: c1 HEX: e8 HEX: 05 } ] [ [ EAX 5 SHR ] { } make ] unit-test
[ { HEX: c1 HEX: e9 HEX: 05 } ] [ [ ECX 5 SHR ] { } make ] unit-test

! multiplication
[ { HEX: 4d HEX: 6b HEX: c0 HEX: 03 } ] [ [ R8 R8 3 IMUL3 ] { } make ] unit-test
[ { HEX: 49 HEX: 6b HEX: c0 HEX: 03 } ] [ [ RAX R8 3 IMUL3 ] { } make ] unit-test
[ { HEX: 4c HEX: 6b HEX: c0 HEX: 03 } ] [ [ R8 RAX 3 IMUL3 ] { } make ] unit-test
[ { HEX: 48 HEX: 6b HEX: c1 HEX: 03 } ] [ [ RAX RCX 3 IMUL3 ] { } make ] unit-test
[ { HEX: 48 HEX: 69 HEX: c1 HEX: 44 HEX: 03 HEX: 00 HEX: 00 } ] [ [ RAX RCX HEX: 344 IMUL3 ] { } make ] unit-test

! BT family instructions
[ { HEX: 0f HEX: ba HEX: e0 HEX: 01 } ] [ [ EAX 1 BT ] { } make ] unit-test
[ { HEX: 0f HEX: ba HEX: f8 HEX: 01 } ] [ [ EAX 1 BTC ] { } make ] unit-test
[ { HEX: 0f HEX: ba HEX: e8 HEX: 01 } ] [ [ EAX 1 BTS ] { } make ] unit-test
[ { HEX: 0f HEX: ba HEX: f0 HEX: 01 } ] [ [ EAX 1 BTR ] { } make ] unit-test
[ { HEX: 48 HEX: 0f HEX: ba HEX: e0 HEX: 01 } ] [ [ RAX 1 BT ] { } make ] unit-test
[ { HEX: 0f HEX: ba HEX: 20 HEX: 01 } ] [ [ EAX [] 1 BT ] { } make ] unit-test

[ { HEX: 0f HEX: a3 HEX: d8 } ] [ [ EAX EBX BT ] { } make ] unit-test
[ { HEX: 0f HEX: bb HEX: d8 } ] [ [ EAX EBX BTC ] { } make ] unit-test
[ { HEX: 0f HEX: ab HEX: d8 } ] [ [ EAX EBX BTS ] { } make ] unit-test
[ { HEX: 0f HEX: b3 HEX: d8 } ] [ [ EAX EBX BTR ] { } make ] unit-test
[ { HEX: 0f HEX: a3 HEX: 18 } ] [ [ EAX [] EBX BT ] { } make ] unit-test

! x87 instructions
[ { HEX: D8 HEX: C5 } ] [ [ ST0 ST5 FADD ] { } make ] unit-test
[ { HEX: DC HEX: C5 } ] [ [ ST5 ST0 FADD ] { } make ] unit-test
[ { HEX: D8 HEX: 00 } ] [ [ ST0 EAX [] FADD ] { } make ] unit-test

[ { HEX: D9 HEX: C2 } ] [ [ ST2 FLD  ] { } make ] unit-test
[ { HEX: DD HEX: D2 } ] [ [ ST2 FST  ] { } make ] unit-test
[ { HEX: DD HEX: DA } ] [ [ ST2 FSTP ] { } make ] unit-test

[ { 15 183 195 } ] [ [ EAX BX MOVZX ] { } make ] unit-test

bootstrap-cell 4 = [
    [ { 100 199 5 0 0 0 0 123 0 0 0 } ] [ [ 0 [] FS 123 MOV ] { } make ] unit-test
] when

bootstrap-cell 8 = [
    [ { 72 137 13 123 0 0 0 } ] [ [ 123 [RIP+] RCX MOV ] { } make ] unit-test
    [ { 101 72 137 12 37 123 0 0 0 } ] [ [ 123 [] GS RCX MOV ] { } make ] unit-test
] when
