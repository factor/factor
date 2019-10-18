USING: assembler-x86 kernel test namespaces ;
IN: temporary

[ { HEX: 49 HEX: 89 HEX: 04 HEX: 24 } ] [ [ R12 [] RAX MOV ] { } make ] unit-test

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
