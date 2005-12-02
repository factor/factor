! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: arrays compiler errors generic kernel kernel-internals
lists math parser sequences words ;

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
M: object operand-64? drop cell 8 = ;

( Register operands -- eg, ECX                                 )
: REGISTER:
    CREATE dup define-symbol
    dup scan-word "register" set-word-prop
    scan-word "register-size" set-word-prop ; parsing

! x86 registers
REGISTER: AX 0 16
REGISTER: CX 1 16
REGISTER: DX 2 16
REGISTER: BX 3 16
REGISTER: SP 4 16
REGISTER: BP 5 16
REGISTER: SI 6 16
REGISTER: DI 7 16

REGISTER: EAX 0 32
REGISTER: ECX 1 32
REGISTER: EDX 2 32
REGISTER: EBX 3 32
REGISTER: ESP 4 32
REGISTER: EBP 5 32
REGISTER: ESI 6 32
REGISTER: EDI 7 32

! AMD64 registers
REGISTER: RAX 0 64
REGISTER: RCX 1 64
REGISTER: RDX 2 64
REGISTER: RBX 3 64
REGISTER: RSP 4 64
REGISTER: RBP 5 64
REGISTER: RSI 6 64
REGISTER: RDI 7 64

REGISTER: R8 8 64
REGISTER: R9 9 64
REGISTER: R10 10 64
REGISTER: R11 11 64
REGISTER: R12 12 64
REGISTER: R13 13 64
REGISTER: R14 14 64
REGISTER: R15 15 64

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
M: indirect extended? register extended? ;
M: indirect operand-64? register register-64? ;

( Displaced indirect register operands -- eg, { EAX 4 }        )
PREDICATE: array displaced
    dup length 2 =
    [ first2 integer? swap register? and ] [ drop f ] if ;

M: displaced modifier second byte? BIN: 01 BIN: 10 ? ;
M: displaced register first register ;
M: displaced displacement
    second dup byte? [ compile-byte ] [ compile-cell ] if ;
M: displaced canonicalize
    dup first EBP = not over second 0 = and
    [ first 1array ] when ;
M: displaced extended? register extended? ;
M: displaced operand-64? register register-64? ;

( Displacement-only operands -- eg, { 1234 }                   )
PREDICATE: array disp-only
    dup length 1 = [ first integer? ] [ drop f ] if ;

M: disp-only modifier drop BIN: 00 ;
M: disp-only register
    #! x86 encodes displacement-only as { EBP }.
    drop BIN: 101 ;
M: disp-only displacement
    first compile-cell ;

( Utilities                                                    )
UNION: operand register indirect displaced disp-only ;

: rex.w? ( reg mod-r/m rex.w -- ? )
    [ register-64? ] 2apply and and ;

: rex-prefix ( reg mod-r/m rex.w -- n )
    #! Compile an AMD64 REX prefix.
    pick pick rex.w? HEX: 01001000 HEX: 01000000 ?
    swap extended? [ HEX: 00000001 bitor ] when
    swap extended? [ HEX: 00000100 bitor ] when
    dup HEX: 01000000 = [ drop ] [ compile-byte ] if ;

: 1-operand-short ( reg n -- )
    #! Some instructions encode their single operand as part of
    #! the opcode.
    swap register + compile-byte ;

: 1-operand ( op reg -- )
    >r canonicalize dup modifier 6 shift over register bitor r>
    3 shift bitor compile-byte displacement ;

: immediate-8/32 ( dst imm code reg -- )
    #! If imm is a byte, compile the opcode and the byte.
    #! Otherwise, set the 32-bit operand flag in the opcode, and
    #! compile the cell. The 'reg' is not really a register, but
    #! a value for the 'reg' field of the mod-r/m byte.
    >r over byte? [
        BIN: 10 bitor compile-byte swap r> 1-operand
        compile-byte
    ] [
        compile-byte swap r> 1-operand
        compile-cell
    ] if ;

: immediate-8 ( dst imm code reg -- )
    #! The 'reg' is not really a register, but a value for the
    #! 'reg' field of the mod-r/m byte.
    >r compile-byte swap r> 1-operand compile-byte ;

: 2-operand ( dst src op -- )
    #! Sets the opcode's direction bit. It is set if the
    #! destination is a direct register operand.
    pick register? [ BIN: 10 bitor swapd ] when
    >r 2dup t rex-prefix r> compile-byte register 1-operand ;

: from ( addr -- addr )
    #! Relative to after next 32-bit immediate.
    compiled-offset - 4 - ;

( Moving stuff                                                 )
GENERIC: PUSH ( op -- )
M: register PUSH HEX: 50 1-operand-short ;
M: integer PUSH HEX: 68 compile-byte compile-cell ;
M: operand PUSH HEX: ff compile-byte BIN: 110 1-operand ;

GENERIC: POP ( op -- )
M: register POP HEX: 58 1-operand-short ;
M: operand POP HEX: 8f compile-byte BIN: 000 1-operand ;

! MOV where the src is immediate.
GENERIC: (MOV-I) ( src dst -- )
M: register (MOV-I) HEX: b8 1-operand-short  compile-cell ;
M: operand (MOV-I)
    HEX: c7 compile-byte  0 1-operand compile-cell ;

GENERIC: MOV ( dst src -- )
M: integer MOV swap (MOV-I) ;
M: operand MOV HEX: 89 2-operand ;

( Control flow                                                 )
GENERIC: JMP ( op -- )
M: integer JMP HEX: e9 compile-byte from compile-cell ;
M: operand JMP HEX: ff compile-byte BIN: 100 1-operand ;
M: word JMP 0 JMP relative ;

GENERIC: CALL ( op -- )
M: integer CALL HEX: e8 compile-byte from compile-cell ;
M: operand CALL HEX: ff compile-byte BIN: 010 1-operand ;
M: word CALL 0 CALL relative ;

GENERIC: JUMPcc ( opcode addr -- )
M: integer JUMPcc ( opcode addr -- )
    HEX: 0f compile-byte  swap compile-byte  from compile-cell ;
M: word JUMPcc ( opcode addr -- )
    >r 0 JUMPcc r> relative ;

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

: RET ( -- ) HEX: c3 compile-byte ;

( Arithmetic                                                   )

GENERIC: ADD ( dst src -- )
M: integer ADD HEX: 81 BIN: 000 immediate-8/32 ;
M: operand ADD OCT: 001 2-operand ;

GENERIC: OR ( dst src -- )
M: integer OR HEX: 81 BIN: 001 immediate-8/32 ;
M: operand OR OCT: 011 2-operand ;

GENERIC: ADC ( dst src -- )
M: integer ADC HEX: 81 BIN: 010 immediate-8/32 ;
M: operand ADC OCT: 021 2-operand ;

GENERIC: SBB ( dst src -- )
M: integer SBB HEX: 81 BIN: 011 immediate-8/32 ;
M: operand SBB OCT: 031 2-operand ;

GENERIC: AND ( dst src -- )
M: integer AND HEX: 81 BIN: 100 immediate-8/32 ;
M: operand AND OCT: 041 2-operand ;

GENERIC: SUB ( dst src -- )
M: integer SUB HEX: 81 BIN: 101 immediate-8/32 ;
M: operand SUB OCT: 051 2-operand ;

GENERIC: XOR ( dst src -- )
M: integer XOR HEX: 81 BIN: 110 immediate-8/32 ;
M: operand XOR OCT: 061 2-operand ;

GENERIC: CMP ( dst src -- )
M: integer CMP HEX: 81 BIN: 111 immediate-8/32 ;
M: operand CMP OCT: 071 2-operand ;

: NOT ( dst -- ) HEX: f7 compile-byte BIN: 010 1-operand ;
: NEG ( dst -- ) HEX: f7 compile-byte BIN: 011 1-operand ;
: MUL ( dst -- ) HEX: f7 compile-byte BIN: 100 1-operand ;
: IMUL ( src -- ) HEX: f7 compile-byte BIN: 101 1-operand ;
: DIV ( dst -- ) HEX: f7 compile-byte BIN: 110 1-operand ;
: IDIV ( src -- ) HEX: f7 compile-byte BIN: 111 1-operand ;

: CDQ HEX: 99 compile-byte ;

: ROL ( dst n -- ) HEX: c1 BIN: 000 immediate-8 ;
: ROR ( dst n -- ) HEX: c1 BIN: 001 immediate-8 ;
: RCL ( dst n -- ) HEX: c1 BIN: 010 immediate-8 ;
: RCR ( dst n -- ) HEX: c1 BIN: 011 immediate-8 ;
: SHL ( dst n -- ) HEX: c1 BIN: 100 immediate-8 ;
: SHR ( dst n -- ) HEX: c1 BIN: 101 immediate-8 ;
: SAR ( dst n -- ) HEX: c1 BIN: 111 immediate-8 ;

: LEA ( dst src -- )
    HEX: 8d compile-byte swap register 1-operand ;

( x87 Floating Point Unit )

: FSTPS ( operand -- )
    HEX: d9 compile-byte HEX: 1c compile-byte
    BIN: 100 1-operand ;

: FSTPL ( operand -- )
    HEX: dd compile-byte HEX: 1c compile-byte
    BIN: 100 1-operand ;
