USING: cpu.x86.assembler kernel tools.test namespaces make ;
IN: cpu.x86.assembler.tests

[ { HEX: 49 HEX: 89 HEX: 04 HEX: 24 } ] [ [ R12 [] RAX MOV ] { } make ] unit-test
[ { HEX: 49 HEX: 8b HEX: 06 } ] [ [ RAX R14 [] MOV ] { } make ] unit-test

[ { HEX: 89 HEX: ca } ] [ [ EDX ECX MOV ] { } make ] unit-test
[ { HEX: 4c HEX: 89 HEX: e2 } ] [ [ RDX R12 MOV ] { } make ] unit-test
[ { HEX: 49 HEX: 89 HEX: d4 } ] [ [ R12 RDX MOV ] { } make ] unit-test

[ { HEX: f2 HEX: 0f HEX: 2c HEX: c0 } ] [ [ EAX XMM0 CVTTSD2SI ] { } make ] unit-test
[ { HEX: f2 HEX: 48 HEX: 0f HEX: 2c HEX: c0 } ] [ [ RAX XMM0 CVTTSD2SI ] { } make ] unit-test
[ { HEX: f2 HEX: 4c HEX: 0f HEX: 2c HEX: e0 } ] [ [ R12 XMM0 CVTTSD2SI ] { } make ] unit-test
[ { HEX: f2 HEX: 0f HEX: 2a HEX: c0 } ] [ [ XMM0 EAX CVTSI2SD ] { } make ] unit-test
[ { HEX: f2 HEX: 48 HEX: 0f HEX: 2a HEX: c0 } ] [ [ XMM0 RAX CVTSI2SD ] { } make ] unit-test
[ { HEX: f2 HEX: 48 HEX: 0f HEX: 2a HEX: c1 } ] [ [ XMM0 RCX CVTSI2SD ] { } make ] unit-test
[ { HEX: f2 HEX: 48 HEX: 0f HEX: 2a HEX: d9 } ] [ [ XMM3 RCX CVTSI2SD ] { } make ] unit-test
[ { HEX: f2 HEX: 48 HEX: 0f HEX: 2a HEX: c0 } ] [ [ XMM0 RAX CVTSI2SD ] { } make ] unit-test
[ { HEX: f2 HEX: 49 HEX: 0f HEX: 2a HEX: c4 } ] [ [ XMM0 R12 CVTSI2SD ] { } make ] unit-test

! [ { HEX: f2 HEX: 49 HEX: 0f HEX: 2c HEX: c1 } ] [ [ XMM9 RAX CVTSI2SD ] { } make ] unit-test

! [ { HEX: f2 HEX: 0f HEX: 10 HEX: 00 } ] [ [ XMM0 RAX [] MOVSD ] { } make ] unit-test
! [ { HEX: f2 HEX: 41 HEX: 0f HEX: 10 HEX: 04 HEX: 24 } ] [ [ XMM0 R12 [] MOVSD ] { } make ] unit-test
! [ { HEX: f2 HEX: 0f HEX: 11 HEX: 00 } ] [ [ RAX [] XMM0 MOVSD ] { } make ] unit-test
! [ { HEX: f2 HEX: 41 HEX: 0f HEX: 11 HEX: 04 HEX: 24 } ] [ [ R12 [] XMM0 MOVSD ] { } make ] unit-test

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

[ { HEX: 48 HEX: d3 HEX: e0 } ] [ [ RAX CL SHL ] { } make ] unit-test
[ { HEX: 48 HEX: d3 HEX: e1 } ] [ [ RCX CL SHL ] { } make ] unit-test
[ { HEX: 48 HEX: d3 HEX: e8 } ] [ [ RAX CL SHR ] { } make ] unit-test
[ { HEX: 48 HEX: d3 HEX: e9 } ] [ [ RCX CL SHR ] { } make ] unit-test

[ { HEX: f7 HEX: c1 HEX: d2 HEX: 04 HEX: 00 HEX: 00 } ] [ [ ECX 1234 TEST ] { } make ] unit-test
