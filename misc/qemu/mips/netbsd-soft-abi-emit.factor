! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays assocs byte-arrays compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params cpu.architecture cpu.mips cpu.mips.abi cpu.mips.assembler cpu.mips.assembler.registers environment io.encodings.binary io.files io.pathnames kernel locals make math namespaces sequences strings system vectors ;
QUALIFIED-WITH: alien.c-types c
IN: mips.netbsd-soft-abi-probe
CONSTANT: base-types { c:long c:double c:float c:long c:double c:float c:long c:double c:float c:double c:long c:float }
SYMBOLS: active-types vararg-start native-result-rep ;
:: argument-layout ( -- registers stack )
  f param-regs init-regs
  V{ } clone reg-values set V{ } clone stack-values set
  0 stack-params set 0 stack-group-remaining set
  0 int-reg-reps set 0 float-reg-reps set
  active-types get [| type i |
    vararg-start get [ i swap >= ] [ f ] if* varargs-parameter? set
    type lookup-c-type flatten-scalar-parameter first
  ] map-index
  [| tuple index |
     tuple prepare-parameter-group
     index tuple first3 tuple param-natural-size next-parameter
  ] each-index
  reg-values get clone stack-values get clone ;
:: load-value ( index -- reg rep )
  index active-types get nth lookup-c-type c-type-rep :> rep
  rep int-rep eq? [ R12 ] [ F0 ] if :> register
  register R13 index 8 * rep f load-memory
  register rep ;
:: carrier ( index abi-rep -- register )
  index load-value :> ( register source-rep )
  abi-rep int-rep eq? source-rep int-rep eq? not and [
    R12 register source-rep %scalar>integer R12
  ] [ register ] if ;
:: outgoing ( -- )
  argument-layout :> ( registers stack )
  SP SP -48 DADDIU RA SP 40 SD
  R14 A0 MOV R13 A1 MOV
  stack [| tuple |
    tuple first tuple second carrier tuple clone :> copy
    0 copy set-nth copy store-stack-argument
  ] each
  registers [| tuple |
    tuple first tuple second carrier tuple second tuple third store-reg-param
  ] each
  T9 R14 MOV T9 CALL
  F0 native-result-rep get dup return-reg load-reg-param
  F0 native-result-rep get dup return-reg store-reg-param
  RA SP 40 LD SP SP 48 DADDIU RET ;
:: callback ( -- )
  mips-soft-float-abi? [ A0 A1 ] [ F12 F13 ] if :> ( double-reg float-reg )
  F0 double-rep double-reg load-reg-param
  F2 float-rep float-reg load-reg-param
  F2 F2 %single>double-float F0 F0 F2 %add-float
  F0 double-rep double-rep return-reg store-reg-param RET ;
:: unary-call ( rep -- )
  SP SP -16 DADDIU RA SP 8 SD T9 A0 MOV
  F0 rep A1 load-reg-param F0 rep A0 store-reg-param T9 CALL
  F0 rep rep return-reg load-reg-param F0 rep rep return-reg store-reg-param
  RA SP 8 LD SP SP 16 DADDIU RET ;
:: float-callback ( -- )
  F0 float-rep A0 load-reg-param F2 double-rep A1 load-reg-param
  F0 F0 %single>double-float F0 F0 F2 %add-float
  F0 F0 %double>single-float F0 float-rep float-rep return-reg store-reg-param RET ;
:: float-pair-return ( -- )
  F0 float-rep A0 load-reg-param F2 float-rep A1 load-reg-param
  return-regs float-regs of :> registers
  F0 float-rep registers first store-reg-param
  F2 float-rep registers second store-reg-param RET ;
:: pair-return ( -- )
  mips-soft-float-abi? [ A0 A1 ] [ F12 F13 ] if :> ( first-reg second-reg )
  F0 double-rep first-reg load-reg-param F2 double-rep second-reg load-reg-param
  return-regs float-regs of :> registers
  F0 double-rep registers first store-reg-param
  F2 double-rep registers second store-reg-param RET ;
:: emit-one ( operating-system name quotation -- )
  operating-system \ os [ mips.64 \ cpu [ t mips-big-endian? [
    base-types active-types set f vararg-start set double-rep native-result-rep set
    [ quotation call( -- ) ] B{ } make
  ] with-variable ] with-variable ] with-variable
  "FACTOR_MIPS_SOFT_ABI_OUTPUT" os-env
  [ name ".bin" append append-path binary set-file-contents ]
  [ "Set FACTOR_MIPS_SOFT_ABI_OUTPUT to an existing directory" throw ] if* ;
netbsd "soft-outgoing" [ outgoing ] emit-one
linux "hard-outgoing" [ outgoing ] emit-one
netbsd "soft-callback" [ callback ] emit-one
linux "hard-callback" [
  F12 ZERO double-rep %integer>scalar F13 ZERO float-rep %integer>scalar
  V0 ZERO MOV callback
] emit-one
netbsd "soft-pair" [ pair-return ] emit-one
linux "hard-pair" [
  F12 ZERO double-rep %integer>scalar F13 ZERO double-rep %integer>scalar
  V0 ZERO MOV pair-return
] emit-one

netbsd "soft-float-outgoing" [ float-rep native-result-rep set outgoing ] emit-one
netbsd "soft-float-callback" [ float-callback ] emit-one
netbsd "soft-variadic-outgoing" [
  { c:long c:double c:double c:double c:double c:double c:double c:double c:double c:double c:double } active-types set
  1 vararg-start set outgoing
] emit-one

netbsd "soft-float-pair" [ float-pair-return ] emit-one

netbsd "soft-unary-double" [ double-rep unary-call ] emit-one
netbsd "soft-unary-float" [ float-rep unary-call ] emit-one
