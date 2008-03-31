! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generator.fixup io.binary kernel
combinators kernel.private math namespaces parser sequences
words system layouts ;
IN: cpu.x86.assembler

! A postfix assembler for x86 and AMD64.

! In 32-bit mode, { 1234 } is absolute indirect addressing.
! In 64-bit mode, { 1234 } is RIP-relative.
! Beware!

: n, >le % ; inline
: 4, 4 n, ; inline
: 2, 2 n, ; inline
: cell, bootstrap-cell n, ; inline

! Register operands -- eg, ECX
<<

: define-register ( name num size -- )
    >r >r "cpu.x86.assembler" create dup define-symbol r> r>
    >r dupd "register" set-word-prop r>
    "register-size" set-word-prop ;

: define-registers ( names size -- )
    >r dup length r> [ define-register ] curry 2each ;

: REGISTERS:
    scan-word ";" parse-tokens swap define-registers ; parsing

>>

REGISTERS: 8 AL CL DL BL ;

REGISTERS: 16 AX CX DX BX SP BP SI DI ;

REGISTERS: 32 EAX ECX EDX EBX ESP EBP ESI EDI ;

REGISTERS: 64
RAX RCX RDX RBX RSP RBP RSI RDI R8 R9 R10 R11 R12 R13 R14 R15 ;

REGISTERS: 128
XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7
XMM8 XMM9 XMM10 XMM11 XMM12 XMM13 XMM14 XMM15 ;

<PRIVATE

#! Extended AMD64 registers (R8-R15) return true.
GENERIC: extended? ( op -- ? )

M: object extended? drop f ;

PREDICATE: register < word
    "register" word-prop ;

PREDICATE: register-8 < register
    "register-size" word-prop 8 = ;

PREDICATE: register-16 < register
    "register-size" word-prop 16 = ;

PREDICATE: register-32 < register
    "register-size" word-prop 32 = ;

PREDICATE: register-64 < register
    "register-size" word-prop 64 = ;

PREDICATE: register-128 < register
    "register-size" word-prop 128 = ;

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

: <indirect> ( base index scale displacement -- indirect )
    indirect construct-boa dup canonicalize ;

: reg-code "register" word-prop 7 bitand ;

: indirect-base* indirect-base EBP or reg-code ;

: indirect-index* indirect-index ESP or reg-code ;

: indirect-scale* indirect-scale 0 or ;

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
        indirect-displacement {
            { [ dup not ]      [ BIN: 00 ] }
            { [ dup byte? ]    [ BIN: 01 ] }
            { [ dup integer? ] [ BIN: 10 ] }
        } cond nip
    ] [
        drop BIN: 00
    ] if ;

M: register modifier drop BIN: 11 ;

: mod-r/m, ( reg# indirect -- )
    dup modifier 6 shift rot 3 shift rot r/m bitor bitor , ;

: sib, ( indirect -- )
    dup sib-present? [
        dup indirect-base*
        over indirect-index* 3 shift bitor
        swap indirect-scale* 6 shift bitor ,
    ] [
        drop
    ] if ;

GENERIC: displacement, ( op -- )

M: indirect displacement,
    dup indirect-displacement dup [
        swap indirect-base
        [ dup byte? [ , ] [ 4, ] if ] [ 4, ] if
    ] [
        2drop
    ] if ;

M: register displacement, drop ;

: addressing ( reg# indirect -- )
    [ mod-r/m, ] keep [ sib, ] keep displacement, ;

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
    2over rex.w? BIN: 01001000 BIN: 01000000 ?
    swap rex.r swap rex.b
    dup BIN: 01000000 = [ drop ] [ , ] if ;

: 16-prefix ( reg r/m -- )
    [ register-16? ] either? [ HEX: 66 , ] when ;

: prefix ( reg r/m rex.w -- ) 2over 16-prefix rex-prefix ;

: prefix-1 ( reg rex.w -- ) f swap prefix ;

: short-operand ( reg rex.w n -- )
    #! Some instructions encode their single operand as part of
    #! the opcode.
    >r dupd prefix-1 reg-code r> + , ;

: opcode, dup array? [ % ] [ , ] if ;

: extended-opcode ( opcode -- opcode' ) OCT: 17 swap 2array ;

: extended-opcode, ( opcode -- ) extended-opcode opcode, ;

: opcode-or ( opcode mask -- opcode' )
    swap dup array?
    [ 1 cut* first rot bitor add ] [ bitor ] if ;

: 1-operand ( op reg rex.w opcode -- )
    #! The 'reg' is not really a register, but a value for the
    #! 'reg' field of the mod-r/m byte.
    >r >r over r> prefix-1 r> opcode, swap addressing ;

: immediate-1 ( imm dst reg rex.w opcode -- )
    1-operand , ;

: immediate-1/4 ( imm dst reg rex.w opcode -- )
    #! If imm is a byte, compile the opcode and the byte.
    #! Otherwise, set the 32-bit operand flag in the opcode, and
    #! compile the cell. The 'reg' is not really a register, but
    #! a value for the 'reg' field of the mod-r/m byte.
    >r >r pick byte? [
        r> r> BIN: 10 opcode-or immediate-1
    ] [
        r> r> 1-operand 4,
    ] if ;

: (2-operand) ( dst src op -- )
    >r 2dup t rex-prefix r> opcode,
    reg-code swap addressing ;

: direction-bit ( dst src op -- dst' src' op' )
    pick register? [ BIN: 10 opcode-or swapd ] when ;

: operand-size-bit ( dst src op -- dst' src' op' )
    over register-8? [ BIN: 1 opcode-or ] unless ;

: 2-operand ( dst src op -- )
    #! Sets the opcode's direction bit. It is set if the
    #! destination is a direct register operand.
    2over 16-prefix
    direction-bit
    operand-size-bit
    (2-operand) ;

PRIVATE>

: [] ( reg/displacement -- indirect )
    dup integer? [ >r f f f r> ] [ f f f ] if <indirect> ;

: [+] ( reg displacement -- indirect )
    dup integer?
    [ dup zero? [ drop f ] when >r f f r> ]
    [ f f ] if
    <indirect> ;

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

PREDICATE: callable < word register? not ;

GENERIC: MOV ( dst src -- )
M: integer MOV swap (MOV-I) ;
M: callable MOV 0 rot (MOV-I) rc-absolute-cell rel-word ;
M: operand MOV HEX: 88 2-operand ;

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

GENERIC# JUMPcc 1 ( addr opcode -- )
: (JUMPcc) extended-opcode, 0 4, rc-relative ;
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

! Arithmetic

GENERIC: ADD ( dst src -- )
M: integer ADD swap BIN: 000 t HEX: 81 immediate-1/4 ;
M: operand ADD OCT: 000 2-operand ;

GENERIC: OR ( dst src -- )
M: integer OR swap BIN: 001 t HEX: 81 immediate-1/4 ;
M: operand OR OCT: 010 2-operand ;

GENERIC: ADC ( dst src -- )
M: integer ADC swap BIN: 010 t HEX: 81 immediate-1/4 ;
M: operand ADC OCT: 020 2-operand ;

GENERIC: SBB ( dst src -- )
M: integer SBB swap BIN: 011 t HEX: 81 immediate-1/4 ;
M: operand SBB OCT: 030 2-operand ;

GENERIC: AND ( dst src -- )
M: integer AND swap BIN: 100 t HEX: 81 immediate-1/4 ;
M: operand AND OCT: 040 2-operand ;

GENERIC: SUB ( dst src -- )
M: integer SUB swap BIN: 101 t HEX: 81 immediate-1/4 ;
M: operand SUB OCT: 050 2-operand ;

GENERIC: XOR ( dst src -- )
M: integer XOR swap BIN: 110 t HEX: 81 immediate-1/4 ;
M: operand XOR OCT: 060 2-operand ;

GENERIC: CMP ( dst src -- )
M: integer CMP swap BIN: 111 t HEX: 81 immediate-1/4 ;
M: operand CMP OCT: 070 2-operand ;

: NOT  ( dst -- ) BIN: 010 t HEX: f7 1-operand ;
: NEG  ( dst -- ) BIN: 011 t HEX: f7 1-operand ;
: MUL  ( dst -- ) BIN: 100 t HEX: f7 1-operand ;
: IMUL ( src -- ) BIN: 101 t HEX: f7 1-operand ;
: DIV  ( dst -- ) BIN: 110 t HEX: f7 1-operand ;
: IDIV ( src -- ) BIN: 111 t HEX: f7 1-operand ;

: CDQ HEX: 99 , ;
: CQO HEX: 48 , CDQ ;

: ROL ( dst n -- ) swap BIN: 000 t HEX: c1 immediate-1 ;
: ROR ( dst n -- ) swap BIN: 001 t HEX: c1 immediate-1 ;
: RCL ( dst n -- ) swap BIN: 010 t HEX: c1 immediate-1 ;
: RCR ( dst n -- ) swap BIN: 011 t HEX: c1 immediate-1 ;
: SHL ( dst n -- ) swap BIN: 100 t HEX: c1 immediate-1 ;
: SHR ( dst n -- ) swap BIN: 101 t HEX: c1 immediate-1 ;
: SAR ( dst n -- ) swap BIN: 111 t HEX: c1 immediate-1 ;

GENERIC: IMUL2 ( dst src -- )
M: integer IMUL2 swap dup reg-code t HEX: 69 immediate-1/4 ;
M: operand IMUL2 OCT: 257 extended-opcode (2-operand) ;

: MOVSX ( dst src -- )
    dup register-32? OCT: 143 OCT: 276 extended-opcode ?
    over register-16? [ BIN: 1 opcode-or ] when
    swapd
    (2-operand) ;

! Conditional move
: MOVcc ( dst src cc -- ) extended-opcode swapd (2-operand) ;

: CMOVO  HEX: 40 MOVcc ;
: CMOVNO HEX: 41 MOVcc ;
: CMOVB  HEX: 42 MOVcc ;
: CMOVAE HEX: 43 MOVcc ;
: CMOVE  HEX: 44 MOVcc ; ! aka CMOVZ
: CMOVNE HEX: 45 MOVcc ;
: CMOVBE HEX: 46 MOVcc ;
: CMOVA  HEX: 47 MOVcc ;
: CMOVS  HEX: 48 MOVcc ;
: CMOVNS HEX: 49 MOVcc ;
: CMOVP  HEX: 4a MOVcc ;
: CMOVNP HEX: 4b MOVcc ;
: CMOVL  HEX: 4c MOVcc ;
: CMOVGE HEX: 4d MOVcc ;
: CMOVLE HEX: 4e MOVcc ;
: CMOVG  HEX: 4f MOVcc ;

! CPU Identification

: CPUID HEX: a2 extended-opcode, ;

! x87 Floating Point Unit

: FSTPS ( operand -- ) BIN: 011 f HEX: d9 1-operand ;
: FSTPL ( operand -- ) BIN: 011 f HEX: dd 1-operand ;

: FLDS ( operand -- ) BIN: 000 f HEX: d9 1-operand ;
: FLDL ( operand -- ) BIN: 000 f HEX: dd 1-operand ;

! SSE multimedia instructions

<PRIVATE

: direction-bit-sse ( dst src op1 -- dst' src' op1' )
    pick register-128? [ swapd ] [ BIN: 1 bitor ] if ;

: 2-operand-sse ( dst src op1 op2 -- )
    , direction-bit-sse extended-opcode (2-operand) ;

: 2-operand-int/sse ( dst src op1 op2 -- )
    , swapd extended-opcode (2-operand) ;

PRIVATE>

: MOVSS   ( dest src -- ) HEX: 10 HEX: f3 2-operand-sse ;
: MOVSD   ( dest src -- ) HEX: 10 HEX: f2 2-operand-sse ;
: ADDSD   ( dest src -- ) HEX: 58 HEX: f2 2-operand-sse ;
: MULSD   ( dest src -- ) HEX: 59 HEX: f2 2-operand-sse ;
: SUBSD   ( dest src -- ) HEX: 5c HEX: f2 2-operand-sse ;
: DIVSD   ( dest src -- ) HEX: 5e HEX: f2 2-operand-sse ;
: SQRTSD  ( dest src -- ) HEX: 51 HEX: f2 2-operand-sse ;
: UCOMISD ( dest src -- ) HEX: 2e HEX: 66 2-operand-sse ;
: COMISD  ( dest src -- ) HEX: 2f HEX: 66 2-operand-sse ;

: CVTSS2SD ( dest src -- ) HEX: 5a HEX: f3 2-operand-sse ;
: CVTSD2SS ( dest src -- ) HEX: 5a HEX: f2 2-operand-sse ;

: CVTSI2SD  ( dest src -- ) HEX: 2a HEX: f2 2-operand-int/sse ;
: CVTSD2SI  ( dest src -- ) HEX: 2d HEX: f2 2-operand-int/sse ;
: CVTTSD2SI ( dest src -- ) HEX: 2c HEX: f2 2-operand-int/sse ;
