! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: compiler errors generic kernel lists math parser
sequences words ;

! A postfix assembler.
!
! x86 is a convoluted mess, so this code will be hard to
! understand unless you already know the instruction set.
!
! Syntax is: destination source opcode. For example, to add
! 3 to EAX:
!
! EAX 3 ADD
!
! The general format of an x86 instruction is:
!
! - 1-4 bytes: prefix. not supported.
! - 1-2 bytes: opcode. if the first byte is 0x0f, then opcode is
! 2 bytes.
! - 1 byte (optional): mod-r/m byte, specifying operands
! - 1/4 bytes (optional): displacement
! - 1 byte (optional): scale/index/displacement byte. not
! supported.
! - 1/4 bytes (optional): immediate operand
!
! mod-r/m has three bit fields:
! - 0-2: r/m
! - 3-5: reg
! - 6-7: mod
!
! If the direction bit (bin mask 10) in the opcode is set, then
! the source is reg, the destination is r/m. Otherwise, it is
! the opposite. x86 does this because reg can only encode a
! direct register operand, while r/m can encode other addressing
! modes in conjunction with the mod field.
!
! The mod field has this encoding:
! - BIN: 00 indirect
! - BIN: 01 1-byte displacement is present after mod-r/m field
! - BIN: 10 4-byte displacement is present after mod-r/m field
! - BIN: 11 direct register operand
!
! To encode displacement only (eg, [ 1234 ] EAX MOV), the
! r/m field stores the code for the EBP register, mod is 00, and
! a 4-byte displacement field is given. Usually if mod is 00, no
! displacement field is present.

: byte? -128 127 between? ;

GENERIC: modifier ( op -- mod )
GENERIC: register ( op -- reg )
GENERIC: displacement ( op -- )
GENERIC: canonicalize ( op -- op )

M: object canonicalize ;

( Register operands -- eg, ECX                                 )
: REGISTER:
    CREATE dup define-symbol
    scan-word "register" set-word-prop ; parsing

REGISTER: EAX 0
REGISTER: ECX 1
REGISTER: EDX 2
REGISTER: EBX 3
REGISTER: ESP 4
REGISTER: EBP 5
REGISTER: ESI 6
REGISTER: EDI 7

PREDICATE: word register "register" word-prop ;

M: register modifier drop BIN: 11 ;
M: register register "register" word-prop ;
M: register displacement drop ;

( Indirect register operands -- eg, [ ECX ]                    )
PREDICATE: cons indirect
    dup cdr [ drop f ] [ car register? ] if ;

M: indirect modifier drop BIN: 00 ;
M: indirect register car register ;
M: indirect displacement drop ;
M: indirect canonicalize dup car EBP = [ drop [ EBP 0 ] ] when ;

( Displaced indirect register operands -- eg, [ EAX 4 ]        )
PREDICATE: cons displaced
    dup length 2 =
    [ first2 integer? swap register? and ] [ drop f ] if ;

M: displaced modifier second byte? BIN: 01 BIN: 10 ? ;
M: displaced register car register ;
M: displaced displacement
    second dup byte? [ compile-byte ] [ compile-cell ] if ;
M: displaced canonicalize
    dup first EBP = not over second 0 = and [ first unit ] when ;

( Displacement-only operands -- eg, [ 1234 ]                   )
PREDICATE: cons disp-only
    dup length 1 = [ car integer? ] [ drop f ] if ;

M: disp-only modifier drop BIN: 00 ;
M: disp-only register
    #! x86 encodes displacement-only as [ EBP ].
    drop BIN: 101 ;
M: disp-only displacement
    car compile-cell ;

( Utilities                                                    )
UNION: operand register indirect displaced disp-only ;

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
    compile-byte register 1-operand ;

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
