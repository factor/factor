USING: cpu.x86.assembler kernel tools.test namespaces ;
IN: temporary

[ { HEX: 49 HEX: 89 HEX: 04 HEX: 24 } ] [ [ R12 [] RAX MOV ] { } make ] unit-test
[ { HEX: 49 HEX: 8b HEX: 06 } ] [ [ RAX R14 [] MOV ] { } make ] unit-test

! [ { HEX: 89 HEX: ca } ] [ [ EDX ECX MOV ] { } make ] unit-test
! [ { HEX: 4c HEX: 89 HEX: e2 } ] [ [ RDX R12 MOV ] { } make ] unit-test
! [ { HEX: 49 HEX: 89 HEX: d4 } ] [ [ R12 RDX MOV ] { } make ] unit-test

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
