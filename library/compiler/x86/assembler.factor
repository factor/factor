! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: arrays compiler errors generic kernel kernel-internals
lists math namespaces parser sequences words ;

! A postfix assembler for x86 and AMD64.

: byte? -128 127 between? ;

GENERIC: modifier ( op -- mod )
GENERIC: register ( op -- reg )
GENERIC: displacement ( op -- )
GENERIC: canonicalize ( op -- op )

#! Extended AMD64 registers return true.
GENERIC: extended? ( op -- ? )
#! 64-bit registers return true.
GENERIC: operand-64? ( op -- ? )

M: object canonicalize ;
M: object extended? drop f ;
M: object operand-64? drop cell get 8 = ;

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

PREDICATE: word register "register" word-prop ;

PREDICATE: register register-32 "register-size" word-prop 32 = ;
PREDICATE: register register-64 "register-size" word-prop 64 = ;

M: register modifier drop BIN: 11 ;
M: register register "register" word-prop 7 bitand ;
M: register displacement drop ;
M: register extended? "register" word-prop 7 > ;
M: register operand-64? register-64? ;

( Indirect register operands -- eg, { ECX }                    )
PREDICATE: array indirect
    dup length 1 = [ first register? ] [ drop f ] if ;

M: indirect modifier drop BIN: 00 ;
M: indirect register first register ;
M: indirect displacement drop ;
M: indirect canonicalize dup first EBP = [ drop { EBP 0 } ] when ;
M: indirect extended? first extended? ;
M: indirect operand-64? first register-64? ;

( Displaced indirect register operands -- eg, { EAX 4 }        )
PREDICATE: array displaced
    dup length 2 =
    [ first2 integer? swap register? and ] [ drop f ] if ;

M: displaced modifier second byte? BIN: 01 BIN: 10 ? ;
M: displaced register first register ;
M: displaced displacement
    second dup byte? [ assemble-1 ] [ assemble-cell ] if ;
M: displaced canonicalize
    dup first EBP = not over second 0 = and
    [ first 1array ] when ;
M: displaced extended? first extended? ;
M: displaced operand-64? first register-64? ;

( Displacement-only operands -- eg, { 1234 }                   )
PREDICATE: array disp-only
    dup length 1 = [ first integer? ] [ drop f ] if ;

M: disp-only modifier drop BIN: 00 ;
M: disp-only register
    #! x86 encodes displacement-only as { EBP }.
    drop BIN: 101 ;
M: disp-only displacement
    first assemble-cell ;

( Utilities                                                    )
UNION: operand register indirect displaced disp-only ;

: rex.w? ( reg mod-r/m rex.w -- ? )
    [ register-64? ] 2apply or and ;

: rex-prefix ( reg r/m rex.w -- )
    #! Compile an AMD64 REX prefix.
    pick pick rex.w? BIN: 01001000 BIN: 01000000 ?
    swap extended? [ BIN: 00000100 bitor ] when
    swap extended? [ BIN: 00000001 bitor ] when
    dup BIN: 01000000 = [ drop ] [ assemble-1 ] if ;

: rex-prefix-1 ( reg rex.w -- ) f swap rex-prefix ;

: short-operand ( reg rex.w n -- )
    #! Some instructions encode their single operand as part of
    #! the opcode.
    >r dupd rex-prefix-1 register r> + assemble-1 ;

: mod-r/m ( op reg -- )
    >r canonicalize dup modifier 6 shift over register bitor r>
    3 shift bitor assemble-1 displacement ;

: 1-operand ( op reg rex.w opcode -- )
    >r >r over r> rex-prefix-1 r> assemble-1 mod-r/m ;

: immediate-1 ( imm dst reg rex.w opcode -- )
    #! The 'reg' is not really a register, but a value for the
    #! 'reg' field of the mod-r/m byte.
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
    >r 2dup t rex-prefix r> assemble-1 register mod-r/m ;

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

: (FSTP) BIN: 100 f HEX: 1c 1-operand ;
: FSTPS ( operand -- ) HEX: d9 assemble-1 (FSTP) ;
: FSTPL ( operand -- ) HEX: dd assemble-1 (FSTP) ;
