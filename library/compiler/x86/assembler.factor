! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
USING: arrays compiler errors generic kernel kernel-internals
lists math namespaces parser sequences words ;
IN: assembler

! A postfix assembler for x86 and AMD64.

! In 32-bit mode, { 1234 } is absolute indirect addressing.
! In 64-bit mode, { 1234 } is RIP-relative.
! Beware!

#! Extended AMD64 registers (R8-R15) return true.
GENERIC: extended? ( op -- ? )

M: object extended? drop f ;

( Register operands -- eg, ECX                                 )
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

( Addressing modes                                             )
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
        dup indirect-base swap set-indirect-index
    ] [
        drop
    ] if ;

: canonicalize ( indirect -- )
    #! Modify the indirect to work around certain addressing mode
    #! quirks.
    dup canonicalize-EBP canonicalize-ESP ;

C: indirect ( base index scale displacement -- indirect )
    [ set-indirect-displacement ] keep
    [ set-indirect-scale ] keep
    [ set-indirect-index ] keep
    [ set-indirect-base ] keep
    dup canonicalize ;

: [] ( reg/displacement -- indirect )
    dup integer? [ >r f f f r> ] [ f f f ] if <indirect> ;

: [+] ( reg displacement -- indirect )
    dup integer? [ >r f f r> ] [ f f ] if <indirect> ;

: reg-code "register" word-prop 7 bitand ;

: indirect-base* indirect-base [ EBP ] unless* reg-code ;

: indirect-index* indirect-index [ ESP ] unless* reg-code ;

: indirect-scale* indirect-scale [ 0 ] unless* ;

GENERIC: sib-present?

M: indirect sib-present? ( indirect -- ? )
    dup indirect-base { ESP RSP } memq?
    over indirect-index rot indirect-scale or or ;

M: register sib-present? drop f ;

GENERIC: r/m

M: indirect r/m ( indirect -- r/m )
    dup sib-present?
    [ drop ESP reg-code ] [ indirect-base* ] if ;

M: register r/m ( reg -- r/m ) reg-code ;

: byte? -128 127 between? ;

GENERIC: modifier

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

GENERIC: displacement

M: indirect displacement indirect-displacement ;

M: register displacement drop f ;

: addressing ( reg# indirect -- )
    [ mod-r/m assemble-1 ] keep
    [ sib [ assemble-1 ] when* ] keep
    displacement [ assemble-4 ] when* ;

( Utilities                                                    )
UNION: operand register indirect ;

: rex.w? ( reg mod-r/m rex.w -- ? )
    [ register-64? ] 2apply or and ;

: lhs-prefix
    extended? [ BIN: 00000100 bitor ] when ;

: rhs-prefix
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
    swap lhs-prefix swap rhs-prefix
    dup BIN: 01000000 = [ drop ] [ assemble-1 ] if ;

: 16-prefix ( reg r/m -- )
    [ register-16? ] 2apply or [ HEX: 66 assemble-1 ] when ;

: prefix ( reg r/m rex.w -- ) pick pick 16-prefix rex-prefix ;

: prefix-1 ( reg rex.w -- ) f swap prefix ;

: short-operand ( reg rex.w n -- )
    #! Some instructions encode their single operand as part of
    #! the opcode.
    >r dupd prefix-1 reg-code r> + assemble-1 ;

: 1-operand ( op reg rex.w opcode -- )
    #! The 'reg' is not really a register, but a value for the
    #! 'reg' field of the mod-r/m byte.
    >r >r over r> prefix-1 r> assemble-1 swap addressing ;

: immediate-1 ( imm dst reg rex.w opcode -- )
    1-operand assemble-1 ;

: immediate-1/4 ( imm dst reg rex.w opcode -- )
    #! If imm is a byte, compile the opcode and the byte.
    #! Otherwise, set the 32-bit operand flag in the opcode, and
    #! compile the cell. The 'reg' is not really a register, but
    #! a value for the 'reg' field of the mod-r/m byte.
    >r >r pick byte? [
        r> r> BIN: 10 bitor immediate-1
    ] [
        r> r> 1-operand assemble-4
    ] if ;

: 2-operand ( dst src op -- )
    #! Sets the opcode's direction bit. It is set if the
    #! destination is a direct register operand.
    pick register? [ BIN: 10 bitor swapd ] when
    >r 2dup t prefix r> assemble-1 reg-code swap addressing ;

: from ( addr -- addr )
    #! Relative to after next 32-bit immediate.
    compiled-offset - 4 - ;

PREDICATE: word callable register? not ;

( Moving stuff                                                 )
GENERIC: PUSH ( op -- )
M: register PUSH f HEX: 50 short-operand ;
M: integer PUSH HEX: 68 assemble-1 assemble-4 ;
M: callable PUSH 0 PUSH absolute-4 ;
M: operand PUSH BIN: 110 f HEX: ff 1-operand ;

GENERIC: POP ( op -- )
M: register POP f HEX: 58 short-operand ;
M: operand POP BIN: 000 f HEX: 8f 1-operand ;

! MOV where the src is immediate.
GENERIC: (MOV-I) ( src dst -- )
M: register (MOV-I) t HEX: b8 short-operand assemble-cell ;
M: operand (MOV-I) BIN: 000 t HEX: c7 1-operand assemble-4 ;

GENERIC: MOV ( dst src -- )
M: integer MOV swap (MOV-I) ;
M: callable MOV 0 rot (MOV-I) absolute-cell ;
M: operand MOV HEX: 89 2-operand ;

( Control flow                                                 )
GENERIC: JMP ( op -- )
M: integer JMP HEX: e9 assemble-1 from assemble-4 ;
M: callable JMP 0 JMP relative-4 ;
M: operand JMP BIN: 100 t HEX: ff 1-operand ;

GENERIC: CALL ( op -- )
M: integer CALL HEX: e8 assemble-1 from assemble-4 ;
M: callable CALL 0 CALL relative-4 ;
M: operand CALL BIN: 010 t HEX: ff 1-operand ;

GENERIC: JUMPcc ( opcode addr -- )
M: integer JUMPcc ( opcode addr -- )
    HEX: 0f assemble-1  swap assemble-1  from assemble-4 ;
M: callable JUMPcc ( opcode addr -- )
    >r 0 JUMPcc r> relative-4 ;

: JO  HEX: 80 swap JUMPcc ;
: JNO HEX: 81 swap JUMPcc ;
: JB  HEX: 82 swap JUMPcc ;
: JAE HEX: 83 swap JUMPcc ;
: JE  HEX: 84 swap JUMPcc ; ! aka JZ
: JNE HEX: 85 swap JUMPcc ;
: JBE HEX: 86 swap JUMPcc ;
: JA  HEX: 87 swap JUMPcc ;
: JS  HEX: 88 swap JUMPcc ;
: JNS HEX: 89 swap JUMPcc ;
: JP  HEX: 8a swap JUMPcc ;
: JNP HEX: 8b swap JUMPcc ;
: JL  HEX: 8c swap JUMPcc ;
: JGE HEX: 8d swap JUMPcc ;
: JLE HEX: 8e swap JUMPcc ;
: JG  HEX: 8f swap JUMPcc ;

: RET ( -- ) HEX: c3 assemble-1 ;

( Arithmetic                                                   )

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

: CDQ HEX: 99 assemble-1 ;
: CQO HEX: 48 assemble-1 CDQ ;

: ROL ( dst n -- ) swap BIN: 000 t HEX: c1 immediate-1 ;
: ROR ( dst n -- ) swap BIN: 001 t HEX: c1 immediate-1 ;
: RCL ( dst n -- ) swap BIN: 010 t HEX: c1 immediate-1 ;
: RCR ( dst n -- ) swap BIN: 011 t HEX: c1 immediate-1 ;
: SHL ( dst n -- ) swap BIN: 100 t HEX: c1 immediate-1 ;
: SHR ( dst n -- ) swap BIN: 101 t HEX: c1 immediate-1 ;
: SAR ( dst n -- ) swap BIN: 111 t HEX: c1 immediate-1 ;

( x87 Floating Point Unit )

: FSTPS ( operand -- ) BIN: 011 f HEX: d9 1-operand ;
: FSTPL ( operand -- ) BIN: 011 f HEX: dd 1-operand ;

: FLDS ( operand -- ) BIN: 000 f HEX: d9 1-operand ;
: FLDL ( operand -- ) BIN: 000 f HEX: dd 1-operand ;

( SSE multimedia instructions )

: 2-operand-sse ( dst src op1 op2 -- )
    #! We swap the operands here to make everything consistent
    #! with the integer instructions.
    swap assemble-1 swapd
    >r 2dup t prefix HEX: 0f assemble-1 r>
    assemble-1 reg-code swap addressing ;

: MOVSS ( dest src -- ) HEX: f3 HEX: 10 2-operand-sse ;
: MOVSD ( dest src -- ) HEX: f2 HEX: 10 2-operand-sse ;
: ADDSD ( dest src -- ) HEX: f2 HEX: 58 2-operand-sse ;
: MULSD ( dest src -- ) HEX: f2 HEX: 59 2-operand-sse ;
: SUBSD ( dest src -- ) HEX: f2 HEX: 5c 2-operand-sse ;
: DIVSD ( dest src -- ) HEX: f2 HEX: 5e 2-operand-sse ;
: SQRTSD ( dest src -- ) HEX: f2 HEX: 51 2-operand-sse ;
: UCOMISD ( dest src -- ) HEX: 66 HEX: 2e 2-operand-sse ;
: COMISD ( dest src -- ) HEX: 66 HEX: 2f 2-operand-sse ;
: CVTSI2SD ( dest src -- ) HEX: f2 HEX: 2a 2-operand-sse ;
: CVTSD2SI ( dest src -- ) HEX: f2 HEX: 2d 2-operand-sse ;
