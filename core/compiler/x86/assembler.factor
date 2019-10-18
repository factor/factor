! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generator errors generic io kernel
kernel-internals math namespaces parser sequences words ;
IN: assembler-x86

! A postfix assembler for x86 and AMD64.

! In 32-bit mode, { 1234 } is absolute indirect addressing.
! In 64-bit mode, { 1234 } is RIP-relative.
! Beware!

: n, >le % ; inline
: 4, 4 n, ; inline
: 2, 2 n, ; inline
: cell, cell n, ; inline

#! Extended AMD64 registers (R8-R15) return true.
GENERIC: extended? ( op -- ? )

M: object extended? drop f ;

! Register operands -- eg, ECX
: define-register ( symbol num size -- )
    >r dupd "register" set-word-prop r>
    "register-size" set-word-prop ;

! x86 registers
SYMBOL: AX \ AX 0 16 define-register
SYMBOL: CX \ CX 1 16 define-register
SYMBOL: DX \ DX 2 16 define-register
SYMBOL: BX \ BX 3 16 define-register
SYMBOL: SP \ SP 4 16 define-register
SYMBOL: BP \ BP 5 16 define-register
SYMBOL: SI \ SI 6 16 define-register
SYMBOL: DI \ DI 7 16 define-register

SYMBOL: EAX \ EAX 0 32 define-register
SYMBOL: ECX \ ECX 1 32 define-register
SYMBOL: EDX \ EDX 2 32 define-register
SYMBOL: EBX \ EBX 3 32 define-register
SYMBOL: ESP \ ESP 4 32 define-register
SYMBOL: EBP \ EBP 5 32 define-register
SYMBOL: ESI \ ESI 6 32 define-register
SYMBOL: EDI \ EDI 7 32 define-register

SYMBOL: XMM0 \ XMM0 0 128 define-register
SYMBOL: XMM1 \ XMM1 1 128 define-register
SYMBOL: XMM2 \ XMM2 2 128 define-register
SYMBOL: XMM3 \ XMM3 3 128 define-register
SYMBOL: XMM4 \ XMM4 4 128 define-register
SYMBOL: XMM5 \ XMM5 5 128 define-register
SYMBOL: XMM6 \ XMM6 6 128 define-register
SYMBOL: XMM7 \ XMM7 7 128 define-register

! AMD64 registers
SYMBOL: RAX \ RAX 0  64 define-register
SYMBOL: RCX \ RCX 1  64 define-register
SYMBOL: RDX \ RDX 2  64 define-register
SYMBOL: RBX \ RBX 3  64 define-register
SYMBOL: RSP \ RSP 4  64 define-register
SYMBOL: RBP \ RBP 5  64 define-register
SYMBOL: RSI \ RSI 6  64 define-register
SYMBOL: RDI \ RDI 7  64 define-register
SYMBOL: R8  \ R8  8  64 define-register
SYMBOL: R9  \ R9  9  64 define-register
SYMBOL: R10 \ R10 10 64 define-register
SYMBOL: R11 \ R11 11 64 define-register
SYMBOL: R12 \ R12 12 64 define-register
SYMBOL: R13 \ R13 13 64 define-register
SYMBOL: R14 \ R14 14 64 define-register
SYMBOL: R15 \ R15 15 64 define-register

SYMBOL: XMM8 \ XMM8 8 128 define-register
SYMBOL: XMM9 \ XMM9 9 128 define-register
SYMBOL: XMM10 \ XMM10 10 128 define-register
SYMBOL: XMM11 \ XMM11 11 128 define-register
SYMBOL: XMM12 \ XMM12 12 128 define-register
SYMBOL: XMM13 \ XMM13 13 128 define-register
SYMBOL: XMM14 \ XMM14 14 128 define-register
SYMBOL: XMM15 \ XMM15 15 128 define-register

PREDICATE: word register "register" word-prop ;

PREDICATE: register register-16 "register-size" word-prop 16 = ;
PREDICATE: register register-32 "register-size" word-prop 32 = ;
PREDICATE: register register-64 "register-size" word-prop 64 = ;
PREDICATE: register register-128 "register-size" word-prop 128 = ;

M: register extended? "register" word-prop 7 > ;

! Addressing modes
TUPLE: indirect base index scale displacement ;

M: indirect extended? indirect-base extended? ;

: canonicalize-EBP
    #! { EBP } ==> { EBP 0 }
    dup indirect-base { EBP RBP R13 } memq? [
        dup indirect-displacement [
            drop
        ] [
            0 swap set-indirect-displacement
        ] if
    ] [
        drop
    ] if ;

: canonicalize-ESP
    #! { ESP } ==> { ESP ESP }
    dup indirect-base { ESP RSP R12 } memq? [
        ESP swap set-indirect-index
    ] [
        drop
    ] if ;

: canonicalize ( indirect -- )
    #! Modify the indirect to work around certain addressing mode
    #! quirks.
    dup canonicalize-EBP
    canonicalize-ESP ;

C: indirect ( base index scale displacement -- indirect )
    [ set-indirect-displacement ] keep
    [ set-indirect-scale ] keep
    [ set-indirect-index ] keep
    [ set-indirect-base ] keep
    dup canonicalize ;

: [] ( reg/displacement -- indirect )
    dup integer? [ >r f f f r> ] [ f f f ] if <indirect> ;

: [+] ( reg displacement -- indirect )
    dup integer?
    [ dup zero? [ drop f ] when >r f f r> ]
    [ f f ] if
    <indirect> ;

: reg-code "register" word-prop 7 bitand ;

: indirect-base* indirect-base [ EBP ] unless* reg-code ;

: indirect-index* indirect-index [ ESP ] unless* reg-code ;

: indirect-scale* indirect-scale [ 0 ] unless* ;

GENERIC: sib-present? ( op -- ? )

M: indirect sib-present?
    dup indirect-base { ESP RSP } memq?
    over indirect-index rot indirect-scale or or ;

M: register sib-present? drop f ;

GENERIC: r/m ( operand -- n )

M: indirect r/m
    dup sib-present?
    [ drop ESP reg-code ] [ indirect-base* ] if ;

M: register r/m reg-code ;

: byte? -128 127 between? ;

GENERIC: modifier ( op -- n )

M: indirect modifier
    dup indirect-base [
        indirect-displacement BIN: 10 BIN: 00 ?
    ] [
        drop BIN: 00
    ] if ;

M: register modifier drop BIN: 11 ;

: mod-r/m ( reg# indirect -- byte )
    dup modifier 6 shift rot 3 shift rot r/m bitor bitor ;

: sib ( indirect -- byte )
    dup sib-present? [
        dup indirect-base*
        over indirect-index* 3 shift bitor
        swap indirect-scale* 6 shift bitor
    ] [
        drop f
    ] if ;

GENERIC: displacement ( op -- n )

M: indirect displacement indirect-displacement ;

M: register displacement drop f ;

: addressing ( reg# indirect -- )
    [ mod-r/m , ] keep
    [ sib [ , ] when* ] keep
    displacement [ 4, ] when* ;

! Utilities
UNION: operand register indirect ;

: operand-64? ( operand -- ? )
    dup indirect? [
        dup indirect-base register-64?
        swap indirect-index register-64? or
    ] [
        register-64?
    ] if ;

: rex.w? ( rex.w reg r/m -- ? )
    {
        { [ dup register-128? ] [ drop operand-64? ] }
        { [ dup not ] [ drop operand-64? ] }
        { [ t ] [ nip operand-64? ] }
    } cond and ;

: rex.r
    extended? [ BIN: 00000100 bitor ] when ;

: rex.b
    [ extended? [ BIN: 00000001 bitor ] when ] keep
    dup indirect? [
        indirect-index extended?
        [ BIN: 00000010 bitor ] when
    ] [
        drop
    ] if ;

: rex-prefix ( reg r/m rex.w -- )
    #! Compile an AMD64 REX prefix.
    pick pick rex.w? BIN: 01001000 BIN: 01000000 ?
    swap rex.r swap rex.b
    dup BIN: 01000000 = [ drop ] [ , ] if ;

: 16-prefix ( reg r/m -- )
    [ register-16? ] either? [ HEX: 66 , ] when ;

: prefix ( reg r/m rex.w -- ) pick pick 16-prefix rex-prefix ;

: prefix-1 ( reg rex.w -- ) f swap prefix ;

: short-operand ( reg rex.w n -- )
    #! Some instructions encode their single operand as part of
    #! the opcode.
    >r dupd prefix-1 reg-code r> + , ;

: 1-operand ( op reg rex.w opcode -- )
    #! The 'reg' is not really a register, but a value for the
    #! 'reg' field of the mod-r/m byte.
    >r >r over r> prefix-1 r> , swap addressing ;

: immediate-1 ( imm dst reg rex.w opcode -- )
    1-operand , ;

: immediate-1/4 ( imm dst reg rex.w opcode -- )
    #! If imm is a byte, compile the opcode and the byte.
    #! Otherwise, set the 32-bit operand flag in the opcode, and
    #! compile the cell. The 'reg' is not really a register, but
    #! a value for the 'reg' field of the mod-r/m byte.
    >r >r pick byte? [
        r> r> BIN: 10 bitor immediate-1
    ] [
        r> r> 1-operand 4,
    ] if ;

: 2-operand ( dst src op -- )
    #! Sets the opcode's direction bit. It is set if the
    #! destination is a direct register operand.
    >r 2dup t prefix r>
    pick register? [ BIN: 10 bitor swapd ] when ,
    reg-code swap addressing ;

! Moving stuff
GENERIC: PUSH ( op -- )
M: register PUSH f HEX: 50 short-operand ;
M: integer PUSH HEX: 68 , 4, ;
M: operand PUSH BIN: 110 f HEX: ff 1-operand ;

GENERIC: POP ( op -- )
M: register POP f HEX: 58 short-operand ;
M: operand POP BIN: 000 f HEX: 8f 1-operand ;

! MOV where the src is immediate.
GENERIC: (MOV-I) ( src dst -- )
M: register (MOV-I) t HEX: b8 short-operand cell, ;
M: operand (MOV-I) BIN: 000 t HEX: c7 1-operand 4, ;

PREDICATE: word callable register? not ;

GENERIC: MOV ( dst src -- )
M: integer MOV swap (MOV-I) ;
M: callable MOV 0 rot (MOV-I) rc-absolute-cell rel-word ;
M: operand MOV HEX: 89 2-operand ;

: LEA ( dst src -- ) swap HEX: 8d 2-operand ;

! Control flow
GENERIC: JMP ( op -- )
: (JMP) HEX: e9 , 0 4, rc-relative ;
M: callable JMP (JMP) rel-word ;
M: label JMP (JMP) label-fixup ;
M: operand JMP BIN: 100 t HEX: ff 1-operand ;

GENERIC: CALL ( op -- )
: (CALL) HEX: e8 , 0 4, rc-relative ;
M: callable CALL (CALL) rel-word ;
M: label CALL (CALL) label-fixup ;
M: operand CALL BIN: 010 t HEX: ff 1-operand ;

G: JUMPcc ( addr opcode -- ) 1 standard-combination ;
: (JUMPcc) HEX: 0f , , 0 4, rc-relative ;
M: callable JUMPcc (JUMPcc) rel-word ;
M: label JUMPcc (JUMPcc) label-fixup ;

: JO  HEX: 80 JUMPcc ;
: JNO HEX: 81 JUMPcc ;
: JB  HEX: 82 JUMPcc ;
: JAE HEX: 83 JUMPcc ;
: JE  HEX: 84 JUMPcc ; ! aka JZ
: JNE HEX: 85 JUMPcc ;
: JBE HEX: 86 JUMPcc ;
: JA  HEX: 87 JUMPcc ;
: JS  HEX: 88 JUMPcc ;
: JNS HEX: 89 JUMPcc ;
: JP  HEX: 8a JUMPcc ;
: JNP HEX: 8b JUMPcc ;
: JL  HEX: 8c JUMPcc ;
: JGE HEX: 8d JUMPcc ;
: JLE HEX: 8e JUMPcc ;
: JG  HEX: 8f JUMPcc ;

: LEAVE ( -- ) HEX: c9 , ;

: RET ( n -- )
    dup zero? [ drop HEX: c3 , ] [ HEX: C2 , 2, ] if ;

: CPUID ( -- ) HEX: 0f , HEX: a2 , ;

! Arithmetic

GENERIC: ADD ( dst src -- )
M: integer ADD swap BIN: 000 t HEX: 81 immediate-1/4 ;
M: operand ADD OCT: 001 2-operand ;

GENERIC: OR ( dst src -- )
M: integer OR swap BIN: 001 t HEX: 81 immediate-1/4 ;
M: operand OR OCT: 011 2-operand ;

GENERIC: ADC ( dst src -- )
M: integer ADC swap BIN: 010 t HEX: 81 immediate-1/4 ;
M: operand ADC OCT: 021 2-operand ;

GENERIC: SBB ( dst src -- )
M: integer SBB swap BIN: 011 t HEX: 81 immediate-1/4 ;
M: operand SBB OCT: 031 2-operand ;

GENERIC: AND ( dst src -- )
M: integer AND swap BIN: 100 t HEX: 81 immediate-1/4 ;
M: operand AND OCT: 041 2-operand ;

GENERIC: SUB ( dst src -- )
M: integer SUB swap BIN: 101 t HEX: 81 immediate-1/4 ;
M: operand SUB OCT: 051 2-operand ;

GENERIC: XOR ( dst src -- )
M: integer XOR swap BIN: 110 t HEX: 81 immediate-1/4 ;
M: operand XOR OCT: 061 2-operand ;

GENERIC: CMP ( dst src -- )
M: integer CMP swap BIN: 111 t HEX: 81 immediate-1/4 ;
M: operand CMP OCT: 071 2-operand ;

: NOT  ( dst -- ) BIN: 010 t HEX: f7 1-operand ;
: NEG  ( dst -- ) BIN: 011 t HEX: f7 1-operand ;
: MUL  ( dst -- ) BIN: 100 t HEX: f7 1-operand ;
: IMUL ( src -- ) BIN: 101 t HEX: f7 1-operand ;
: DIV  ( dst -- ) BIN: 110 t HEX: f7 1-operand ;
: IDIV ( src -- ) BIN: 111 t HEX: f7 1-operand ;

GENERIC: IMUL2 ( dst src -- )

M: integer IMUL2 swap dup reg-code t HEX: 69 immediate-1/4 ;

M: operand IMUL2
    2dup t prefix
    OCT: 017 , OCT: 257 ,
    reg-code swap addressing ;

: CDQ HEX: 99 , ;
: CQO HEX: 48 , CDQ ;

: ROL ( dst n -- ) swap BIN: 000 t HEX: c1 immediate-1 ;
: ROR ( dst n -- ) swap BIN: 001 t HEX: c1 immediate-1 ;
: RCL ( dst n -- ) swap BIN: 010 t HEX: c1 immediate-1 ;
: RCR ( dst n -- ) swap BIN: 011 t HEX: c1 immediate-1 ;
: SHL ( dst n -- ) swap BIN: 100 t HEX: c1 immediate-1 ;
: SHR ( dst n -- ) swap BIN: 101 t HEX: c1 immediate-1 ;
: SAR ( dst n -- ) swap BIN: 111 t HEX: c1 immediate-1 ;

! CPU Identification

: CPUID HEX: 0f , HEX: a2 ,  ;

! x87 Floating Point Unit

: FSTPS ( operand -- ) BIN: 011 f HEX: d9 1-operand ;
: FSTPL ( operand -- ) BIN: 011 f HEX: dd 1-operand ;

: FLDS ( operand -- ) BIN: 000 f HEX: d9 1-operand ;
: FLDL ( operand -- ) BIN: 000 f HEX: dd 1-operand ;

! SSE multimedia instructions

: (2-operand-sse)
    >r 2dup t prefix HEX: 0f , r>
    , reg-code swap addressing ;

: 2-operand-sse ( dst src op1 op2 -- )
    , pick register-128? [ swapd ] [ 1 bitor ] if
    (2-operand-sse) ;

: MOVSS   ( dest src -- ) HEX: 10 HEX: f3 2-operand-sse ;
: MOVSD   ( dest src -- ) HEX: 10 HEX: f2 2-operand-sse ;
: ADDSD   ( dest src -- ) HEX: 58 HEX: f2 2-operand-sse ;
: MULSD   ( dest src -- ) HEX: 59 HEX: f2 2-operand-sse ;
: SUBSD   ( dest src -- ) HEX: 5c HEX: f2 2-operand-sse ;
: DIVSD   ( dest src -- ) HEX: 5e HEX: f2 2-operand-sse ;
: SQRTSD  ( dest src -- ) HEX: 51 HEX: f2 2-operand-sse ;
: UCOMISD ( dest src -- ) HEX: 2e HEX: 66 2-operand-sse ;
: COMISD  ( dest src -- ) HEX: 2f HEX: 66 2-operand-sse ;

: 2-operand-int/sse ( dst src op1 op2 -- )
    , swapd (2-operand-sse) ;

: CVTSI2SD  ( dest src -- ) HEX: 2a HEX: f2 2-operand-int/sse ;
: CVTSD2SI  ( dest src -- ) HEX: 2d HEX: f2 2-operand-int/sse ;
: CVTTSD2SI ( dest src -- ) HEX: 2c HEX: f2 2-operand-int/sse ;
