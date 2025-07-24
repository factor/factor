! Copyright (C) 2005, 2010 Slava Pestov, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays endian kernel combinators
combinators.short-circuit math math.bitwise locals namespaces
make sequences words system layouts math.order accessors
cpu.x86.assembler.operands cpu.x86.assembler.operands.private ;
IN: cpu.x86.assembler

! A postfix assembler for x86-32 and x86-64.

<PRIVATE

: reg-code ( reg -- n ) "register" word-prop 7 bitand ;

: indirect-base* ( op -- n ) base>> EBP or reg-code ;

: indirect-index* ( op -- n ) index>> ESP or reg-code ;

: indirect-scale* ( op -- n ) scale>> 0 or ;

GENERIC: sib-present? ( op -- ? )

M: indirect sib-present?
    {
        [ base>> { ESP RSP R12 } member? ]
        [ index>> ]
        [ scale>> ]
    } 1|| ;

M: register sib-present? drop f ;

GENERIC: r/m ( operand -- n )

M: indirect r/m
    dup sib-present?
    [ drop ESP reg-code ] [ indirect-base* ] if ;

M: register r/m reg-code ;

! Immediate operands
UNION: immediate byte integer ;

GENERIC: fits-in-byte? ( value -- ? )

M: byte fits-in-byte? drop t ;

M: integer fits-in-byte? -128 127 between? ;

GENERIC: modifier ( op -- n )

M: indirect modifier
    dup base>> [
        displacement>> {
            { [ dup not ] [ 0b00 ] }
            { [ dup fits-in-byte? ] [ 0b01 ] }
            { [ dup immediate? ] [ 0b10 ] }
        } cond nip
    ] [
        drop 0b00
    ] if ;

M: register modifier drop 0b11 ;

GENERIC#: n, 1 ( value n -- )

M: integer n, >le % ;
M: byte n, [ value>> ] dip n, ;
: 1, ( n -- ) 1 n, ; inline
: 4, ( n -- ) 4 n, ; inline
: 2, ( n -- ) 2 n, ; inline
: cell, ( n -- ) bootstrap-cell n, ; inline

: mod-r/m, ( reg operand -- )
    [ 3 shift ] [ [ modifier 6 shift ] [ r/m ] bi ] bi* bitor bitor , ;

: sib, ( operand -- )
    dup sib-present? [
        [ indirect-base* ]
        [ indirect-index* 3 shift ]
        [ indirect-scale* 6 shift ] tri bitor bitor ,
    ] [
        drop
    ] if ;

GENERIC: displacement, ( op -- )

M: indirect displacement,
    dup displacement>> dup [
        swap base>>
        [ dup fits-in-byte? [ , ] [ 4, ] if ] [ 4, ] if
    ] [ 2drop ] if ;

M: register displacement, drop ;

: addressing ( reg operand -- )
    [ mod-r/m, ] [ sib, ] [ displacement, ] tri ;

: rex.w? ( rex.w reg r/m -- ? )
    {
        { [ over register-128? ] [ nip operand-64? ] }
        { [ over not ] [ nip operand-64? ] }
        [ drop operand-64? ]
    } cond and ;

: rex.r ( m op -- n )
    extended? [ 0b00000100 bitor ] when ;

: rex.b ( m op -- n )
    [ extended? [ 0b00000001 bitor ] when ] keep
    dup indirect? [ index>> extended? [ 0b00000010 bitor ] when ] [ drop ] if ;

: no-prefix? ( prefix reg r/m -- ? )
    [ 0b01000000 = ]
    [ extended-8-bit-register? not ]
    [ extended-8-bit-register? not ] tri*
    and and ;

:: rex-prefix ( reg r/m rex.w -- )
    ! Compile an AMD64 REX prefix.
    rex.w reg r/m rex.w? 0b01001000 0b01000000 ?
    reg rex.r
    r/m rex.b
    dup reg r/m no-prefix? [ drop ] [ , ] if ;

: 16-prefix ( reg -- )
    register-16? [ 0x66 , ] when ;

: prefix-1 ( reg rex.w -- )
    [ drop 16-prefix ] [ [ f ] 2dip rex-prefix ] 2bi ;

: short-operand ( reg rex.w n -- )
    ! Some instructions encode their single operand as part of
    ! the opcode.
    [ dupd prefix-1 reg-code ] dip + , ;

: opcode, ( opcode -- ) dup array? [ % ] [ , ] if ;

: extended-opcode ( opcode -- opcode' )
    dup array? [ 0o17 prefix ] [ 0o17 swap 2array ] if ;

: extended-opcode, ( opcode -- ) extended-opcode opcode, ;

: opcode-or ( opcode mask -- opcode' )
    over array?
    [ [ unclip-last ] dip bitor suffix ] [ bitor ] if ;

: 1-operand ( operand reg,rex.w,opcode -- )
    ! The 'reg' is not really a register, but a value for the
    ! 'reg' field of the mod-r/m byte.
    first3 [ overd prefix-1 ] dip opcode, swap addressing ;

: immediate-operand-size-bit ( dst imm reg,rex.w,opcode -- imm dst reg,rex.w,opcode )
    over integer? [ first3 0b1 opcode-or 3array ] when ;

: immediate-1* ( dst imm reg,rex.w,opcode -- )
    swap [ 1-operand ] dip 1, ;

: immediate-1 ( dst imm reg,rex.w,opcode -- )
    immediate-operand-size-bit immediate-1* ;

: immediate-4 ( dst imm reg,rex.w,opcode -- )
    immediate-operand-size-bit swap [ 1-operand ] dip 4, ;

: immediate-fits-in-size-bit ( dst imm reg,rex.w,opcode -- imm dst reg,rex.w,opcode )
    over integer? [ first3 0b10 opcode-or 3array ] when ;

: immediate-1/4 ( dst imm reg,rex.w,opcode -- )
    over fits-in-byte? [
        immediate-fits-in-size-bit immediate-1
    ] [
        immediate-4
    ] if ;

: (2-operand) ( reg operand op -- )
    [ 2dup t rex-prefix ] dip opcode,
    [ reg-code ] dip addressing ;

: direction-bit ( dst src op -- reg operand op' )
    pick register? pick register? not and
    [ 0b10 opcode-or ] [ swapd ] if ;

: operand-size-bit ( reg operand op -- reg operand op' )
    pick register-8? [ 0b1 opcode-or ] unless ;

: 2-operand ( dst src op -- )
    direction-bit operand-size-bit
    pick 16-prefix
    (2-operand) ;

PRIVATE>

! Segment override prefixes
: CS ( -- ) 0x2e , ;
: ES ( -- ) 0x26 , ;
: SS ( -- ) 0x36 , ;
: FS ( -- ) 0x64 , ;
: GS ( -- ) 0x65 , ;

! Moving stuff
GENERIC: PUSH ( op -- )
M: register PUSH f 0x50 short-operand ;
M: immediate PUSH 0x68 , 4, ;
M: operand PUSH { 0b110 f 0xff } 1-operand ;

GENERIC: POP ( op -- )
M: register POP f 0x58 short-operand ;
M: operand POP { 0b000 f 0x8f } 1-operand ;

<PRIVATE

: zero-extendable? ( imm -- ? )
    0 32 2^ 1 - between? ;

: maybe-zero-extend ( reg imm -- reg' imm )
    dup zero-extendable? [ [ 32-bit-version-of ] dip ] when ;

GENERIC#: (MOV-I) 1 ( dst src -- )

M: register (MOV-I)
    {
        {
            [ dup byte? ]
            [ [ t 0xb0 short-operand ] [ 1, ] bi* ]
        }
        {
            [ dup zero-extendable? ]
            [ [ 32-bit-version-of t 0xb8 short-operand ] [ 4, ] bi* ]
        }
        [ [ t 0xb8 short-operand ] [ cell, ] bi* ]
    } cond ;

M: operand (MOV-I)
    { 0b000 t 0xc6 }
    over byte? [ immediate-1 ] [ immediate-4 ] if ;

PRIVATE>

GENERIC: MOV ( dst src -- )
M: immediate MOV (MOV-I) ;
M: operand MOV 0x88 2-operand ;

ERROR: bad-movabs-operands dst src ;

GENERIC: MOVABS ( dst src -- )
M: object MOVABS bad-movabs-operands ;
M: register MOVABS
    {
        { AL [ 0xa2 , cell, ] }
        { AX [ 0x66 , 0xa3 , cell, ] }
        { EAX [ 0xa3 , cell, ] }
        { RAX [ 0x48 , 0xa3 , cell, ] }
        [ swap bad-movabs-operands ]
    } case ;
M: integer MOVABS
    swap {
        { AL [ 0xa0 , cell, ] }
        { AX [ 0x66 , 0xa1 , cell, ] }
        { EAX [ 0xa1 , cell, ] }
        { RAX [ 0x48 , 0xa1 , cell, ] }
        [ swap bad-movabs-operands ]
    } case ;

: LEA ( dst src -- ) swap 0x8d 2-operand ;

! Control flow
GENERIC: JMP ( op -- )
M: integer JMP 0xe9 , 4, ;
M: operand JMP { 0b100 t 0xff } 1-operand ;

GENERIC: CALL ( op -- )
M: integer CALL 0xe8 , 4, ;
M: operand CALL { 0b010 t 0xff } 1-operand ;

<PRIVATE

GENERIC#: JUMPcc 1 ( addr opcode -- )
M: integer JUMPcc extended-opcode, 4, ;

: SETcc ( dst opcode -- )
    { 0b000 t } swap suffix 1-operand ;

PRIVATE>

: JO  ( dst -- ) 0x80 JUMPcc ;
: JNO ( dst -- ) 0x81 JUMPcc ;
: JB  ( dst -- ) 0x82 JUMPcc ;
: JAE ( dst -- ) 0x83 JUMPcc ;
: JE  ( dst -- ) 0x84 JUMPcc ; ! aka JZ
: JNE ( dst -- ) 0x85 JUMPcc ;
: JBE ( dst -- ) 0x86 JUMPcc ;
: JA  ( dst -- ) 0x87 JUMPcc ;
: JS  ( dst -- ) 0x88 JUMPcc ;
: JNS ( dst -- ) 0x89 JUMPcc ;
: JP  ( dst -- ) 0x8a JUMPcc ;
: JNP ( dst -- ) 0x8b JUMPcc ;
: JL  ( dst -- ) 0x8c JUMPcc ;
: JGE ( dst -- ) 0x8d JUMPcc ;
: JLE ( dst -- ) 0x8e JUMPcc ;
: JG  ( dst -- ) 0x8f JUMPcc ;

: SETO  ( dst -- ) { 0x0f 0x90 } SETcc ;
: SETNO ( dst -- ) { 0x0f 0x91 } SETcc ;
: SETB  ( dst -- ) { 0x0f 0x92 } SETcc ;
: SETAE ( dst -- ) { 0x0f 0x93 } SETcc ;
: SETE  ( dst -- ) { 0x0f 0x94 } SETcc ;
: SETNE ( dst -- ) { 0x0f 0x95 } SETcc ;
: SETBE ( dst -- ) { 0x0f 0x96 } SETcc ;
: SETA  ( dst -- ) { 0x0f 0x97 } SETcc ;
: SETS  ( dst -- ) { 0x0f 0x98 } SETcc ;
: SETNS ( dst -- ) { 0x0f 0x99 } SETcc ;
: SETP  ( dst -- ) { 0x0f 0x9a } SETcc ;
: SETNP ( dst -- ) { 0x0f 0x9b } SETcc ;
: SETL  ( dst -- ) { 0x0f 0x9c } SETcc ;
: SETGE ( dst -- ) { 0x0f 0x9d } SETcc ;
: SETLE ( dst -- ) { 0x0f 0x9e } SETcc ;
: SETG  ( dst -- ) { 0x0f 0x9f } SETcc ;

: LEAVE ( -- ) 0xc9 , ;

: RET ( n -- ) [ 0xc3 , ] [ 0xc2 , 2, ] if-zero ;

! Arithmetic

GENERIC: ADD ( dst src -- )
M: immediate ADD { 0b000 t 0x80 } immediate-1/4 ;
M: operand ADD 0o000 2-operand ;

GENERIC: OR ( dst src -- )
M: immediate OR { 0b001 t 0x80 } immediate-1/4 ;
M: operand OR 0o010 2-operand ;

GENERIC: ADC ( dst src -- )
M: immediate ADC { 0b010 t 0x80 } immediate-1/4 ;
M: operand ADC 0o020 2-operand ;

GENERIC: SBB ( dst src -- )
M: immediate SBB { 0b011 t 0x80 } immediate-1/4 ;
M: operand SBB 0o030 2-operand ;

GENERIC: AND ( dst src -- )
M: immediate AND
    maybe-zero-extend { 0b100 t 0x80 } immediate-1/4 ;
M: operand AND 0o040 2-operand ;

GENERIC: SUB ( dst src -- )
M: immediate SUB { 0b101 t 0x80 } immediate-1/4 ;
M: operand SUB 0o050 2-operand ;

: INC ( dst -- )
    { 0b000 t 0xff } 1-operand ;

: DEC ( dst -- )
    { 0b001 t 0xff } 1-operand ;

GENERIC: XOR ( dst src -- )
M: immediate XOR { 0b110 t 0x80 } immediate-1/4 ;
M: operand XOR 0o060 2-operand ;

GENERIC: CMP ( dst src -- )
M: immediate CMP { 0b111 t 0x80 } immediate-1/4 ;
M: operand CMP 0o070 2-operand ;

GENERIC: TEST ( dst src -- )
M: immediate TEST maybe-zero-extend { 0b0 t 0xf7 } immediate-4 ;
M: operand TEST 0o204 2-operand ;

: XCHG ( dst src -- ) 0o207 2-operand ;

: BSR ( dst src -- ) { 0x0f 0xbd } (2-operand) ;

GENERIC: BT ( value n -- )
M: immediate BT { 0b100 t { 0x0f 0xba } } immediate-1* ;
M: operand   BT swap { 0x0f 0xa3 } (2-operand) ;

GENERIC: BTC ( value n -- )
M: immediate BTC { 0b111 t { 0x0f 0xba } } immediate-1* ;
M: operand   BTC swap { 0x0f 0xbb } (2-operand) ;

GENERIC: BTR ( value n -- )
M: immediate BTR { 0b110 t { 0x0f 0xba } } immediate-1* ;
M: operand   BTR swap { 0x0f 0xb3 } (2-operand) ;

GENERIC: BTS ( value n -- )
M: immediate BTS { 0b101 t { 0x0f 0xba } } immediate-1* ;
M: operand   BTS swap { 0x0f 0xab } (2-operand) ;

: NOT  ( dst -- ) { 0b010 t 0xf7 } 1-operand ;
: NEG  ( dst -- ) { 0b011 t 0xf7 } 1-operand ;
: MUL  ( dst -- ) { 0b100 t 0xf7 } 1-operand ;
: IMUL ( src -- ) { 0b101 t 0xf7 } 1-operand ;
: DIV  ( dst -- ) { 0b110 t 0xf7 } 1-operand ;
: IDIV ( src -- ) { 0b111 t 0xf7 } 1-operand ;

: CDQ ( -- ) 0x99 , ;
: CQO ( -- ) 0x48 , CDQ ;

<PRIVATE

:: (SHIFT) ( dst src op -- )
    src CL eq? [
        dst { op t 0xd3 } 1-operand
    ] [
        dst src { op t 0xc0 } immediate-1
    ] if ; inline

PRIVATE>

: ROL ( dst n -- ) 0b000 (SHIFT) ;
: ROR ( dst n -- ) 0b001 (SHIFT) ;
: RCL ( dst n -- ) 0b010 (SHIFT) ;
: RCR ( dst n -- ) 0b011 (SHIFT) ;
: SHL ( dst n -- ) 0b100 (SHIFT) ;
: SHR ( dst n -- ) 0b101 (SHIFT) ;
: SAR ( dst n -- ) 0b111 (SHIFT) ;

: IMUL2 ( dst src -- )
    0o257 extended-opcode (2-operand) ;

: IMUL3 ( dst src imm -- )
    dup fits-in-byte? [
        [ swap 0x6b 2-operand ] dip 1,
    ] [
        [ swap 0x69 2-operand ] dip 4,
    ] if ;

: MOVSX ( dst src -- )
    dup register-32? 0o143 0o276 extended-opcode ?
    over register-16? [ 0b1 opcode-or ] when
    (2-operand) ;

: MOVZX ( dst src -- )
    0o266 extended-opcode
    over register-16? [ 0b1 opcode-or ] when
    (2-operand) ;

! Conditional move
: MOVcc ( dst src cc -- ) extended-opcode (2-operand) ;

: CMOVO  ( dst src -- ) 0x40 MOVcc ;
: CMOVNO ( dst src -- ) 0x41 MOVcc ;
: CMOVB  ( dst src -- ) 0x42 MOVcc ;
: CMOVAE ( dst src -- ) 0x43 MOVcc ;
: CMOVE  ( dst src -- ) 0x44 MOVcc ; ! aka CMOVZ
: CMOVNE ( dst src -- ) 0x45 MOVcc ;
: CMOVBE ( dst src -- ) 0x46 MOVcc ;
: CMOVA  ( dst src -- ) 0x47 MOVcc ;
: CMOVS  ( dst src -- ) 0x48 MOVcc ;
: CMOVNS ( dst src -- ) 0x49 MOVcc ;
: CMOVP  ( dst src -- ) 0x4a MOVcc ;
: CMOVNP ( dst src -- ) 0x4b MOVcc ;
: CMOVL  ( dst src -- ) 0x4c MOVcc ;
: CMOVGE ( dst src -- ) 0x4d MOVcc ;
: CMOVLE ( dst src -- ) 0x4e MOVcc ;
: CMOVG  ( dst src -- ) 0x4f MOVcc ;

! CPU Identification

: CPUID ( -- ) 0xa2 extended-opcode, ;

! Misc

: NOP ( -- ) 0x90 , ;
: PAUSE ( -- ) 0xf3 , 0x90 , ;

: RDTSC ( -- ) 0x0f , 0x31 , ;
: RDMSR ( -- ) 0x0f , 0x32 , ; ! Only available in privileged level 0
: RDPMC ( -- ) 0x0f , 0x33 , ;

: RDRAND ( dst -- ) { 0b110 t { 0x0f 0xc7 } } 1-operand ;

! x87 Floating Point Unit

: FSTPS ( operand -- ) { 0b011 f 0xd9 } 1-operand ;
: FSTPL ( operand -- ) { 0b011 f 0xdd } 1-operand ;

: FLDS ( operand -- ) { 0b000 f 0xd9 } 1-operand ;
: FLDL ( operand -- ) { 0b000 f 0xdd } 1-operand ;

: FNSTCW ( operand -- ) { 0b111 f 0xd9 } 1-operand ;
: FNSTSW ( operand -- ) { 0b111 f 0xdd } 1-operand ;
: FLDCW ( operand -- ) { 0b101 f 0xd9 } 1-operand ;

: FNCLEX ( -- ) 0xdb , 0xe2 , ;
: FNINIT ( -- ) 0xdb , 0xe3 , ;

ERROR: bad-x87-operands ;

<PRIVATE

:: (x87-op) ( operand opcode reg -- )
    opcode ,
    0b1100,0000 reg
    3 shift bitor
    operand reg-code bitor , ;

:: x87-st0-op ( src opcode reg -- )
    src register?
    [ src opcode reg (x87-op) ]
    [ bad-x87-operands ] if ;

:: x87-m-st0/n-op ( dst src opcode reg -- )
    {
        { [ dst ST0 = src indirect? and ] [
            src { reg f opcode } 1-operand
        ] }
        { [ dst ST0 = src register? and ] [
            src opcode reg (x87-op)
        ] }
        { [ src ST0 = dst register? and ] [
            dst opcode 4 + reg (x87-op)
        ] }
        [ bad-x87-operands ]
    } cond ;

PRIVATE>

: F2XM1 ( -- ) { 0xD9 0xF0 } % ;
: FABS ( -- ) { 0xD9 0xE1 } % ;
: FADD ( dst src -- ) 0xD8 0 x87-m-st0/n-op ;
: FCHS ( -- ) { 0xD9 0xE0 } % ;

: FCMOVB   ( src -- ) 0xDA 0 x87-st0-op ;
: FCMOVE   ( src -- ) 0xDA 1 x87-st0-op ;
: FCMOVBE  ( src -- ) 0xDA 2 x87-st0-op ;
: FCMOVU   ( src -- ) 0xDA 3 x87-st0-op ;
: FCMOVNB  ( src -- ) 0xDB 0 x87-st0-op ;
: FCMOVNE  ( src -- ) 0xDB 1 x87-st0-op ;
: FCMOVNBE ( src -- ) 0xDB 2 x87-st0-op ;
: FCMOVNU  ( src -- ) 0xDB 3 x87-st0-op ;

: FCOMI ( src -- ) 0xDB 6 x87-st0-op ;
: FUCOMI ( src -- ) 0xDB 5 x87-st0-op ;
: FCOS ( -- ) { 0xD9 0xFF } % ;
: FDECSTP ( -- ) { 0xD9 0xF6 } % ;
: FINCSTP ( -- ) { 0xD9 0xF7 } % ;
: FDIV  ( dst src -- ) 0xD8 6 x87-m-st0/n-op ;
: FDIVR ( dst src -- ) 0xD8 7 x87-m-st0/n-op ;

: FILDD ( src -- )  { 0b000 f 0xDB } 1-operand ;
: FILDQ ( src -- )  { 0b101 f 0xDF } 1-operand ;
: FISTPD ( dst -- ) { 0b011 f 0xDB } 1-operand ;
: FISTPQ ( dst -- ) { 0b111 f 0xDF } 1-operand ;
: FISTTPD ( dst -- ) { 0b001 f 0xDB } 1-operand ;
: FISTTPQ ( dst -- ) { 0b001 f 0xDF } 1-operand ;

: FLD    ( src -- ) 0xD9 0 x87-st0-op ;
: FLD1   ( -- ) { 0xD9 0xE8 } % ;
: FLDL2T ( -- ) { 0xD9 0xE9 } % ;
: FLDL2E ( -- ) { 0xD9 0xEA } % ;
: FLDPI  ( -- ) { 0xD9 0xEB } % ;
: FLDLG2 ( -- ) { 0xD9 0xEC } % ;
: FLDLN2 ( -- ) { 0xD9 0xED } % ;
: FLDZ   ( -- ) { 0xD9 0xEE } % ;

: FMUL ( dst src -- ) 0xD8 1 x87-m-st0/n-op ;
: FNOP ( -- ) { 0xD9 0xD0 } % ;
: FPATAN ( -- ) { 0xD9 0xF3 } % ;
: FPREM  ( -- ) { 0xD9 0xF8 } % ;
: FPREM1 ( -- ) { 0xD9 0xF5 } % ;
: FRNDINT ( -- ) { 0xD9 0xFC } % ;
: FSCALE ( -- ) { 0xD9 0xFD } % ;
: FSIN ( -- ) { 0xD9 0xFE } % ;
: FSINCOS ( -- ) { 0xD9 0xFB } % ;
: FSQRT ( -- ) { 0xD9 0xFA } % ;

: FSUB  ( dst src -- ) 0xD8 0x4 x87-m-st0/n-op ;
: FSUBR ( dst src -- ) 0xD8 0x5 x87-m-st0/n-op ;

: FST  ( src -- ) 0xDD 2 x87-st0-op ;
: FSTP ( src -- ) 0xDD 3 x87-st0-op ;

: FXAM ( -- ) { 0xD9 0xE5 } % ;
: FXCH ( src -- ) 0xD9 1 x87-st0-op ;

: FXTRACT ( -- ) { 0xD9 0xF4 } % ;
: FYL2X ( -- ) { 0xD9 0xF1 } % ;
: FYL2XP1 ( -- ) { 0xD9 0xF9 } % ;

! SSE multimedia instructions

<PRIVATE

: direction-bit-sse ( dst src op1 -- dst' src' op1' )
    pick register-128? [ swapd 0b1 bitor ] unless ;

: 2-operand-sse ( dst src op1 op2 -- )
    [ , ] when* direction-bit-sse extended-opcode (2-operand) ;

: direction-op-sse ( dst src op1s -- dst' src' op1' )
    pick register-128? [ first ] [ swapd second ] if ;

: 2-operand-rm-mr-sse ( dst src op1{rm,mr} op2 -- )
    [ , ] when* direction-op-sse extended-opcode (2-operand) ;

: 2-operand-rm-mr-sse* ( dst src op12{rm,mr} -- )
    direction-op-sse first2 [ , ] when* extended-opcode (2-operand) ;

: 2-operand-rm-sse ( dst src op1 op2 -- )
    [ , ] when* extended-opcode (2-operand) ;

: 2-operand-mr-sse ( dst src op1 op2 -- )
    [ , ] when* extended-opcode swapd (2-operand) ;

: 2-operand-int/sse ( dst src op1 op2 -- )
    [ , ] when* extended-opcode (2-operand) ;

:: 3-operand-rm-sse ( dst src imm op1 op2 -- )
    dst src op1 op2 2-operand-rm-sse imm , ;

:: 3-operand-mr-sse ( dst src imm op1 op2 -- )
    dst src op1 op2 2-operand-mr-sse imm , ;

:: 3-operand-rm-mr-sse ( dst src imm op1 op2 -- )
    dst src op1 op2 2-operand-rm-mr-sse imm , ;

: 2-operand-sse-cmp ( dst src cmp op1 op2 -- )
    3-operand-rm-sse ; inline

: 2-operand-sse-shift ( dst imm reg op1 op2 -- )
    [ , ] when*
    [ f 0x0f ] dip 2array 3array
    swapd 1-operand , ;

PRIVATE>

: MOVUPS     ( dest src -- ) 0x10 f       2-operand-sse ;
: MOVUPD     ( dest src -- ) 0x10 0x66 2-operand-sse ;
: MOVSD      ( dest src -- ) 0x10 0xf2 2-operand-sse ;
: MOVSS      ( dest src -- ) 0x10 0xf3 2-operand-sse ;
: MOVLPS     ( dest src -- ) 0x12 f       2-operand-sse ;
: MOVLPD     ( dest src -- ) 0x12 0x66 2-operand-sse ;
: MOVDDUP    ( dest src -- ) 0x12 0xf2 2-operand-rm-sse ;
: MOVSLDUP   ( dest src -- ) 0x12 0xf3 2-operand-rm-sse ;
: UNPCKLPS   ( dest src -- ) 0x14 f       2-operand-rm-sse ;
: UNPCKLPD   ( dest src -- ) 0x14 0x66 2-operand-rm-sse ;
: UNPCKHPS   ( dest src -- ) 0x15 f       2-operand-rm-sse ;
: UNPCKHPD   ( dest src -- ) 0x15 0x66 2-operand-rm-sse ;
: MOVHPS     ( dest src -- ) 0x16 f       2-operand-sse ;
: MOVHPD     ( dest src -- ) 0x16 0x66 2-operand-sse ;
: MOVSHDUP   ( dest src -- ) 0x16 0xf3 2-operand-rm-sse ;

ALIAS: MOVHLPS MOVLPS
ALIAS: MOVLHPS MOVHPS

: PREFETCHNTA ( mem -- )  { 0b000 f { 0x0f 0x18 } } 1-operand ;
: PREFETCHT0  ( mem -- )  { 0b001 f { 0x0f 0x18 } } 1-operand ;
: PREFETCHT1  ( mem -- )  { 0b010 f { 0x0f 0x18 } } 1-operand ;
: PREFETCHT2  ( mem -- )  { 0b011 f { 0x0f 0x18 } } 1-operand ;

: MOVAPS     ( dest src -- ) 0x28 f       2-operand-sse ;
: MOVAPD     ( dest src -- ) 0x28 0x66 2-operand-sse ;
: CVTSI2SD   ( dest src -- ) 0x2a 0xf2 2-operand-int/sse ;
: CVTSI2SS   ( dest src -- ) 0x2a 0xf3 2-operand-int/sse ;
: MOVNTPS    ( dest src -- ) 0x2b f       2-operand-mr-sse ;
: MOVNTPD    ( dest src -- ) 0x2b 0x66 2-operand-mr-sse ;
: CVTTSD2SI  ( dest src -- ) 0x2c 0xf2 2-operand-int/sse ;
: CVTTSS2SI  ( dest src -- ) 0x2c 0xf3 2-operand-int/sse ;
: CVTSD2SI   ( dest src -- ) 0x2d 0xf2 2-operand-int/sse ;
: CVTSS2SI   ( dest src -- ) 0x2d 0xf3 2-operand-int/sse ;
: UCOMISS    ( dest src -- ) 0x2e f       2-operand-rm-sse ;
: UCOMISD    ( dest src -- ) 0x2e 0x66 2-operand-rm-sse ;
: COMISS     ( dest src -- ) 0x2f f       2-operand-rm-sse ;
: COMISD     ( dest src -- ) 0x2f 0x66 2-operand-rm-sse ;

: PSHUFB     ( dest src -- ) { 0x38 0x00 } 0x66 2-operand-rm-sse ;
: PHADDW     ( dest src -- ) { 0x38 0x01 } 0x66 2-operand-rm-sse ;
: PHADDD     ( dest src -- ) { 0x38 0x02 } 0x66 2-operand-rm-sse ;
: PHADDSW    ( dest src -- ) { 0x38 0x03 } 0x66 2-operand-rm-sse ;
: PMADDUBSW  ( dest src -- ) { 0x38 0x04 } 0x66 2-operand-rm-sse ;
: PHSUBW     ( dest src -- ) { 0x38 0x05 } 0x66 2-operand-rm-sse ;
: PHSUBD     ( dest src -- ) { 0x38 0x06 } 0x66 2-operand-rm-sse ;
: PHSUBSW    ( dest src -- ) { 0x38 0x07 } 0x66 2-operand-rm-sse ;
: PSIGNB     ( dest src -- ) { 0x38 0x08 } 0x66 2-operand-rm-sse ;
: PSIGNW     ( dest src -- ) { 0x38 0x09 } 0x66 2-operand-rm-sse ;
: PSIGND     ( dest src -- ) { 0x38 0x0a } 0x66 2-operand-rm-sse ;
: PMULHRSW   ( dest src -- ) { 0x38 0x0b } 0x66 2-operand-rm-sse ;
: PBLENDVB   ( dest src -- ) { 0x38 0x10 } 0x66 2-operand-rm-sse ;
: BLENDVPS   ( dest src -- ) { 0x38 0x14 } 0x66 2-operand-rm-sse ;
: BLENDVPD   ( dest src -- ) { 0x38 0x15 } 0x66 2-operand-rm-sse ;
: PTEST      ( dest src -- ) { 0x38 0x17 } 0x66 2-operand-rm-sse ;
: PABSB      ( dest src -- ) { 0x38 0x1c } 0x66 2-operand-rm-sse ;
: PABSW      ( dest src -- ) { 0x38 0x1d } 0x66 2-operand-rm-sse ;
: PABSD      ( dest src -- ) { 0x38 0x1e } 0x66 2-operand-rm-sse ;
: PMOVSXBW   ( dest src -- ) { 0x38 0x20 } 0x66 2-operand-rm-sse ;
: PMOVSXBD   ( dest src -- ) { 0x38 0x21 } 0x66 2-operand-rm-sse ;
: PMOVSXBQ   ( dest src -- ) { 0x38 0x22 } 0x66 2-operand-rm-sse ;
: PMOVSXWD   ( dest src -- ) { 0x38 0x23 } 0x66 2-operand-rm-sse ;
: PMOVSXWQ   ( dest src -- ) { 0x38 0x24 } 0x66 2-operand-rm-sse ;
: PMOVSXDQ   ( dest src -- ) { 0x38 0x25 } 0x66 2-operand-rm-sse ;
: PMULDQ     ( dest src -- ) { 0x38 0x28 } 0x66 2-operand-rm-sse ;
: PCMPEQQ    ( dest src -- ) { 0x38 0x29 } 0x66 2-operand-rm-sse ;
: MOVNTDQA   ( dest src -- ) { 0x38 0x2a } 0x66 2-operand-rm-sse ;
: PACKUSDW   ( dest src -- ) { 0x38 0x2b } 0x66 2-operand-rm-sse ;
: PMOVZXBW   ( dest src -- ) { 0x38 0x30 } 0x66 2-operand-rm-sse ;
: PMOVZXBD   ( dest src -- ) { 0x38 0x31 } 0x66 2-operand-rm-sse ;
: PMOVZXBQ   ( dest src -- ) { 0x38 0x32 } 0x66 2-operand-rm-sse ;
: PMOVZXWD   ( dest src -- ) { 0x38 0x33 } 0x66 2-operand-rm-sse ;
: PMOVZXWQ   ( dest src -- ) { 0x38 0x34 } 0x66 2-operand-rm-sse ;
: PMOVZXDQ   ( dest src -- ) { 0x38 0x35 } 0x66 2-operand-rm-sse ;
: PCMPGTQ    ( dest src -- ) { 0x38 0x37 } 0x66 2-operand-rm-sse ;
: PMINSB     ( dest src -- ) { 0x38 0x38 } 0x66 2-operand-rm-sse ;
: PMINSD     ( dest src -- ) { 0x38 0x39 } 0x66 2-operand-rm-sse ;
: PMINUW     ( dest src -- ) { 0x38 0x3a } 0x66 2-operand-rm-sse ;
: PMINUD     ( dest src -- ) { 0x38 0x3b } 0x66 2-operand-rm-sse ;
: PMAXSB     ( dest src -- ) { 0x38 0x3c } 0x66 2-operand-rm-sse ;
: PMAXSD     ( dest src -- ) { 0x38 0x3d } 0x66 2-operand-rm-sse ;
: PMAXUW     ( dest src -- ) { 0x38 0x3e } 0x66 2-operand-rm-sse ;
: PMAXUD     ( dest src -- ) { 0x38 0x3f } 0x66 2-operand-rm-sse ;
: PMULLD     ( dest src -- ) { 0x38 0x40 } 0x66 2-operand-rm-sse ;
: PHMINPOSUW ( dest src -- ) { 0x38 0x41 } 0x66 2-operand-rm-sse ;
: CRC32B     ( dest src -- ) { 0x38 0xf0 } 0xf2 2-operand-rm-sse ;
: CRC32      ( dest src -- ) { 0x38 0xf1 } 0xf2 2-operand-rm-sse ;

: ROUNDPS    ( dest src imm -- ) { 0x3a 0x08 } 0x66 3-operand-rm-sse ;
: ROUNDPD    ( dest src imm -- ) { 0x3a 0x09 } 0x66 3-operand-rm-sse ;
: ROUNDSS    ( dest src imm -- ) { 0x3a 0x0a } 0x66 3-operand-rm-sse ;
: ROUNDSD    ( dest src imm -- ) { 0x3a 0x0b } 0x66 3-operand-rm-sse ;
: BLENDPS    ( dest src imm -- ) { 0x3a 0x0c } 0x66 3-operand-rm-sse ;
: BLENDPD    ( dest src imm -- ) { 0x3a 0x0d } 0x66 3-operand-rm-sse ;
: PBLENDW    ( dest src imm -- ) { 0x3a 0x0e } 0x66 3-operand-rm-sse ;
: PALIGNR    ( dest src imm -- ) { 0x3a 0x0f } 0x66 3-operand-rm-sse ;

: PEXTRB     ( dest src imm -- ) { 0x3a 0x14 } 0x66 3-operand-mr-sse ;

<PRIVATE
: (PEXTRW-sse1) ( dest src imm -- ) 0xc5 0x66 3-operand-rm-sse ;
: (PEXTRW-sse4) ( dest src imm -- ) { 0x3a 0x15 } 0x66 3-operand-mr-sse ;
PRIVATE>

: PEXTRW     ( dest src imm -- ) pick indirect? [ (PEXTRW-sse4) ] [ (PEXTRW-sse1) ] if ;
: PEXTRD     ( dest src imm -- ) { 0x3a 0x16 } 0x66 3-operand-mr-sse ;
ALIAS: PEXTRQ PEXTRD
: EXTRACTPS  ( dest src imm -- ) { 0x3a 0x17 } 0x66 3-operand-mr-sse ;

: PINSRB     ( dest src imm -- ) { 0x3a 0x20 } 0x66 3-operand-rm-sse ;
: INSERTPS   ( dest src imm -- ) { 0x3a 0x21 } 0x66 3-operand-rm-sse ;
: PINSRD     ( dest src imm -- ) { 0x3a 0x22 } 0x66 3-operand-rm-sse ;
ALIAS: PINSRQ PINSRD
: DPPS       ( dest src imm -- ) { 0x3a 0x40 } 0x66 3-operand-rm-sse ;
: DPPD       ( dest src imm -- ) { 0x3a 0x41 } 0x66 3-operand-rm-sse ;
: MPSADBW    ( dest src imm -- ) { 0x3a 0x42 } 0x66 3-operand-rm-sse ;
: PCMPESTRM  ( dest src imm -- ) { 0x3a 0x60 } 0x66 3-operand-rm-sse ;
: PCMPESTRI  ( dest src imm -- ) { 0x3a 0x61 } 0x66 3-operand-rm-sse ;
: PCMPISTRM  ( dest src imm -- ) { 0x3a 0x62 } 0x66 3-operand-rm-sse ;
: PCMPISTRI  ( dest src imm -- ) { 0x3a 0x63 } 0x66 3-operand-rm-sse ;

: MOVMSKPS   ( dest src -- ) 0x50 f       2-operand-int/sse ;
: MOVMSKPD   ( dest src -- ) 0x50 0x66 2-operand-int/sse ;
: SQRTPS     ( dest src -- ) 0x51 f       2-operand-rm-sse ;
: SQRTPD     ( dest src -- ) 0x51 0x66 2-operand-rm-sse ;
: SQRTSD     ( dest src -- ) 0x51 0xf2 2-operand-rm-sse ;
: SQRTSS     ( dest src -- ) 0x51 0xf3 2-operand-rm-sse ;
: RSQRTPS    ( dest src -- ) 0x52 f       2-operand-rm-sse ;
: RSQRTSS    ( dest src -- ) 0x52 0xf3 2-operand-rm-sse ;
: RCPPS      ( dest src -- ) 0x53 f       2-operand-rm-sse ;
: RCPSS      ( dest src -- ) 0x53 0xf3 2-operand-rm-sse ;
: ANDPS      ( dest src -- ) 0x54 f       2-operand-rm-sse ;
: ANDPD      ( dest src -- ) 0x54 0x66 2-operand-rm-sse ;
: ANDNPS     ( dest src -- ) 0x55 f       2-operand-rm-sse ;
: ANDNPD     ( dest src -- ) 0x55 0x66 2-operand-rm-sse ;
: ORPS       ( dest src -- ) 0x56 f       2-operand-rm-sse ;
: ORPD       ( dest src -- ) 0x56 0x66 2-operand-rm-sse ;
: XORPS      ( dest src -- ) 0x57 f       2-operand-rm-sse ;
: XORPD      ( dest src -- ) 0x57 0x66 2-operand-rm-sse ;
: ADDPS      ( dest src -- ) 0x58 f       2-operand-rm-sse ;
: ADDPD      ( dest src -- ) 0x58 0x66 2-operand-rm-sse ;
: ADDSD      ( dest src -- ) 0x58 0xf2 2-operand-rm-sse ;
: ADDSS      ( dest src -- ) 0x58 0xf3 2-operand-rm-sse ;
: MULPS      ( dest src -- ) 0x59 f       2-operand-rm-sse ;
: MULPD      ( dest src -- ) 0x59 0x66 2-operand-rm-sse ;
: MULSD      ( dest src -- ) 0x59 0xf2 2-operand-rm-sse ;
: MULSS      ( dest src -- ) 0x59 0xf3 2-operand-rm-sse ;
: CVTPS2PD   ( dest src -- ) 0x5a f       2-operand-rm-sse ;
: CVTPD2PS   ( dest src -- ) 0x5a 0x66 2-operand-rm-sse ;
: CVTSD2SS   ( dest src -- ) 0x5a 0xf2 2-operand-rm-sse ;
: CVTSS2SD   ( dest src -- ) 0x5a 0xf3 2-operand-rm-sse ;
: CVTDQ2PS   ( dest src -- ) 0x5b f       2-operand-rm-sse ;
: CVTPS2DQ   ( dest src -- ) 0x5b 0x66 2-operand-rm-sse ;
: CVTTPS2DQ  ( dest src -- ) 0x5b 0xf3 2-operand-rm-sse ;
: SUBPS      ( dest src -- ) 0x5c f       2-operand-rm-sse ;
: SUBPD      ( dest src -- ) 0x5c 0x66 2-operand-rm-sse ;
: SUBSD      ( dest src -- ) 0x5c 0xf2 2-operand-rm-sse ;
: SUBSS      ( dest src -- ) 0x5c 0xf3 2-operand-rm-sse ;
: MINPS      ( dest src -- ) 0x5d f       2-operand-rm-sse ;
: MINPD      ( dest src -- ) 0x5d 0x66 2-operand-rm-sse ;
: MINSD      ( dest src -- ) 0x5d 0xf2 2-operand-rm-sse ;
: MINSS      ( dest src -- ) 0x5d 0xf3 2-operand-rm-sse ;
: DIVPS      ( dest src -- ) 0x5e f       2-operand-rm-sse ;
: DIVPD      ( dest src -- ) 0x5e 0x66 2-operand-rm-sse ;
: DIVSD      ( dest src -- ) 0x5e 0xf2 2-operand-rm-sse ;
: DIVSS      ( dest src -- ) 0x5e 0xf3 2-operand-rm-sse ;
: MAXPS      ( dest src -- ) 0x5f f       2-operand-rm-sse ;
: MAXPD      ( dest src -- ) 0x5f 0x66 2-operand-rm-sse ;
: MAXSD      ( dest src -- ) 0x5f 0xf2 2-operand-rm-sse ;
: MAXSS      ( dest src -- ) 0x5f 0xf3 2-operand-rm-sse ;
: PUNPCKLBW  ( dest src -- ) 0x60 0x66 2-operand-rm-sse ;
: PUNPCKLWD  ( dest src -- ) 0x61 0x66 2-operand-rm-sse ;
: PUNPCKLDQ  ( dest src -- ) 0x62 0x66 2-operand-rm-sse ;
: PACKSSWB   ( dest src -- ) 0x63 0x66 2-operand-rm-sse ;
: PCMPGTB    ( dest src -- ) 0x64 0x66 2-operand-rm-sse ;
: PCMPGTW    ( dest src -- ) 0x65 0x66 2-operand-rm-sse ;
: PCMPGTD    ( dest src -- ) 0x66 0x66 2-operand-rm-sse ;
: PACKUSWB   ( dest src -- ) 0x67 0x66 2-operand-rm-sse ;
: PUNPCKHBW  ( dest src -- ) 0x68 0x66 2-operand-rm-sse ;
: PUNPCKHWD  ( dest src -- ) 0x69 0x66 2-operand-rm-sse ;
: PUNPCKHDQ  ( dest src -- ) 0x6a 0x66 2-operand-rm-sse ;
: PACKSSDW   ( dest src -- ) 0x6b 0x66 2-operand-rm-sse ;
: PUNPCKLQDQ ( dest src -- ) 0x6c 0x66 2-operand-rm-sse ;
: PUNPCKHQDQ ( dest src -- ) 0x6d 0x66 2-operand-rm-sse ;

: MOVD       ( dest src -- ) { 0x6e 0x7e } 0x66 2-operand-rm-mr-sse ;
: MOVDQA     ( dest src -- ) { 0x6f 0x7f } 0x66 2-operand-rm-mr-sse ;
: MOVDQU     ( dest src -- ) { 0x6f 0x7f } 0xf3 2-operand-rm-mr-sse ;

: MOVQ       ( dest src -- )
    { { 0x7e 0xf3 } { 0xd6 0x66 } } 2-operand-rm-mr-sse* ;

<PRIVATE

: 2shuffler ( indexes/mask -- mask )
    dup integer? [ first2 { 1 0 } bitfield ] unless ;
: 4shuffler ( indexes/mask -- mask )
    dup integer? [ first4 { 6 4 2 0 } bitfield ] unless ;

PRIVATE>

: PSHUFD     ( dest src imm -- ) 4shuffler 0x70 0x66 3-operand-rm-sse ;
: PSHUFLW    ( dest src imm -- ) 4shuffler 0x70 0xf2 3-operand-rm-sse ;
: PSHUFHW    ( dest src imm -- ) 4shuffler 0x70 0xf3 3-operand-rm-sse ;

<PRIVATE

: (PSRLW-imm) ( dest imm -- ) 0b010 0x71 0x66 2-operand-sse-shift ;
: (PSRAW-imm) ( dest imm -- ) 0b100 0x71 0x66 2-operand-sse-shift ;
: (PSLLW-imm) ( dest imm -- ) 0b110 0x71 0x66 2-operand-sse-shift ;
: (PSRLD-imm) ( dest imm -- ) 0b010 0x72 0x66 2-operand-sse-shift ;
: (PSRAD-imm) ( dest imm -- ) 0b100 0x72 0x66 2-operand-sse-shift ;
: (PSLLD-imm) ( dest imm -- ) 0b110 0x72 0x66 2-operand-sse-shift ;
: (PSRLQ-imm) ( dest imm -- ) 0b010 0x73 0x66 2-operand-sse-shift ;
: (PSLLQ-imm) ( dest imm -- ) 0b110 0x73 0x66 2-operand-sse-shift ;

: (PSRLW-reg) ( dest src -- ) 0xd1 0x66 2-operand-rm-sse ;
: (PSRLD-reg) ( dest src -- ) 0xd2 0x66 2-operand-rm-sse ;
: (PSRLQ-reg) ( dest src -- ) 0xd3 0x66 2-operand-rm-sse ;
: (PSRAW-reg) ( dest src -- ) 0xe1 0x66 2-operand-rm-sse ;
: (PSRAD-reg) ( dest src -- ) 0xe2 0x66 2-operand-rm-sse ;
: (PSLLW-reg) ( dest src -- ) 0xf1 0x66 2-operand-rm-sse ;
: (PSLLD-reg) ( dest src -- ) 0xf2 0x66 2-operand-rm-sse ;
: (PSLLQ-reg) ( dest src -- ) 0xf3 0x66 2-operand-rm-sse ;

PRIVATE>

: PSRLW ( dest src -- ) dup integer? [ (PSRLW-imm) ] [ (PSRLW-reg) ] if ;
: PSRAW ( dest src -- ) dup integer? [ (PSRAW-imm) ] [ (PSRAW-reg) ] if ;
: PSLLW ( dest src -- ) dup integer? [ (PSLLW-imm) ] [ (PSLLW-reg) ] if ;
: PSRLD ( dest src -- ) dup integer? [ (PSRLD-imm) ] [ (PSRLD-reg) ] if ;
: PSRAD ( dest src -- ) dup integer? [ (PSRAD-imm) ] [ (PSRAD-reg) ] if ;
: PSLLD ( dest src -- ) dup integer? [ (PSLLD-imm) ] [ (PSLLD-reg) ] if ;
: PSRLQ ( dest src -- ) dup integer? [ (PSRLQ-imm) ] [ (PSRLQ-reg) ] if ;
: PSLLQ ( dest src -- ) dup integer? [ (PSLLQ-imm) ] [ (PSLLQ-reg) ] if ;

: PSRLDQ     ( dest imm -- ) 0b011 0x73 0x66 2-operand-sse-shift ;
: PSLLDQ     ( dest imm -- ) 0b111 0x73 0x66 2-operand-sse-shift ;

: PCMPEQB    ( dest src -- ) 0x74 0x66 2-operand-rm-sse ;
: PCMPEQW    ( dest src -- ) 0x75 0x66 2-operand-rm-sse ;
: PCMPEQD    ( dest src -- ) 0x76 0x66 2-operand-rm-sse ;
: HADDPD     ( dest src -- ) 0x7c 0x66 2-operand-rm-sse ;
: HADDPS     ( dest src -- ) 0x7c 0xf2 2-operand-rm-sse ;
: HSUBPD     ( dest src -- ) 0x7d 0x66 2-operand-rm-sse ;
: HSUBPS     ( dest src -- ) 0x7d 0xf2 2-operand-rm-sse ;

: FXSAVE     ( dest -- ) { 0b000 f { 0x0f 0xae } } 1-operand ;
: FXRSTOR    ( src -- )  { 0b001 f { 0x0f 0xae } } 1-operand ;
: LDMXCSR    ( src -- )  { 0b010 f { 0x0f 0xae } } 1-operand ;
: STMXCSR    ( dest -- ) { 0b011 f { 0x0f 0xae } } 1-operand ;
: LFENCE     ( -- ) 0x0f , 0xae , 0o350 , ;
: MFENCE     ( -- ) 0x0f , 0xae , 0o360 , ;
: SFENCE     ( -- ) 0x0f , 0xae , 0o370 , ;
: CLFLUSH    ( dest -- ) { 0b111 f { 0x0f 0xae } } 1-operand ;

: POPCNT     ( dest src -- ) 0xb8 0xf3 2-operand-rm-sse ;

: CMPEQPS    ( dest src -- ) 0 0xc2 f       2-operand-sse-cmp ;
: CMPLTPS    ( dest src -- ) 1 0xc2 f       2-operand-sse-cmp ;
: CMPLEPS    ( dest src -- ) 2 0xc2 f       2-operand-sse-cmp ;
: CMPUNORDPS ( dest src -- ) 3 0xc2 f       2-operand-sse-cmp ;
: CMPNEQPS   ( dest src -- ) 4 0xc2 f       2-operand-sse-cmp ;
: CMPNLTPS   ( dest src -- ) 5 0xc2 f       2-operand-sse-cmp ;
: CMPNLEPS   ( dest src -- ) 6 0xc2 f       2-operand-sse-cmp ;
: CMPORDPS   ( dest src -- ) 7 0xc2 f       2-operand-sse-cmp ;

: CMPEQPD    ( dest src -- ) 0 0xc2 0x66 2-operand-sse-cmp ;
: CMPLTPD    ( dest src -- ) 1 0xc2 0x66 2-operand-sse-cmp ;
: CMPLEPD    ( dest src -- ) 2 0xc2 0x66 2-operand-sse-cmp ;
: CMPUNORDPD ( dest src -- ) 3 0xc2 0x66 2-operand-sse-cmp ;
: CMPNEQPD   ( dest src -- ) 4 0xc2 0x66 2-operand-sse-cmp ;
: CMPNLTPD   ( dest src -- ) 5 0xc2 0x66 2-operand-sse-cmp ;
: CMPNLEPD   ( dest src -- ) 6 0xc2 0x66 2-operand-sse-cmp ;
: CMPORDPD   ( dest src -- ) 7 0xc2 0x66 2-operand-sse-cmp ;

: CMPEQSD    ( dest src -- ) 0 0xc2 0xf2 2-operand-sse-cmp ;
: CMPLTSD    ( dest src -- ) 1 0xc2 0xf2 2-operand-sse-cmp ;
: CMPLESD    ( dest src -- ) 2 0xc2 0xf2 2-operand-sse-cmp ;
: CMPUNORDSD ( dest src -- ) 3 0xc2 0xf2 2-operand-sse-cmp ;
: CMPNEQSD   ( dest src -- ) 4 0xc2 0xf2 2-operand-sse-cmp ;
: CMPNLTSD   ( dest src -- ) 5 0xc2 0xf2 2-operand-sse-cmp ;
: CMPNLESD   ( dest src -- ) 6 0xc2 0xf2 2-operand-sse-cmp ;
: CMPORDSD   ( dest src -- ) 7 0xc2 0xf2 2-operand-sse-cmp ;

: CMPEQSS    ( dest src -- ) 0 0xc2 0xf3 2-operand-sse-cmp ;
: CMPLTSS    ( dest src -- ) 1 0xc2 0xf3 2-operand-sse-cmp ;
: CMPLESS    ( dest src -- ) 2 0xc2 0xf3 2-operand-sse-cmp ;
: CMPUNORDSS ( dest src -- ) 3 0xc2 0xf3 2-operand-sse-cmp ;
: CMPNEQSS   ( dest src -- ) 4 0xc2 0xf3 2-operand-sse-cmp ;
: CMPNLTSS   ( dest src -- ) 5 0xc2 0xf3 2-operand-sse-cmp ;
: CMPNLESS   ( dest src -- ) 6 0xc2 0xf3 2-operand-sse-cmp ;
: CMPORDSS   ( dest src -- ) 7 0xc2 0xf3 2-operand-sse-cmp ;

: MOVNTI     ( dest src -- ) swap { 0x0f 0xc3 } (2-operand) ;

: PINSRW     ( dest src imm -- ) 0xc4 0x66 3-operand-rm-sse ;
: SHUFPS     ( dest src imm -- ) 4shuffler 0xc6 f       3-operand-rm-sse ;
: SHUFPD     ( dest src imm -- ) 2shuffler 0xc6 0x66 3-operand-rm-sse ;

: ADDSUBPD   ( dest src -- ) 0xd0 0x66 2-operand-rm-sse ;
: ADDSUBPS   ( dest src -- ) 0xd0 0xf2 2-operand-rm-sse ;
: PADDQ      ( dest src -- ) 0xd4 0x66 2-operand-rm-sse ;
: PMULLW     ( dest src -- ) 0xd5 0x66 2-operand-rm-sse ;
: PMOVMSKB   ( dest src -- ) 0xd7 0x66 2-operand-int/sse ;
: PSUBUSB    ( dest src -- ) 0xd8 0x66 2-operand-rm-sse ;
: PSUBUSW    ( dest src -- ) 0xd9 0x66 2-operand-rm-sse ;
: PMINUB     ( dest src -- ) 0xda 0x66 2-operand-rm-sse ;
: PAND       ( dest src -- ) 0xdb 0x66 2-operand-rm-sse ;
: PADDUSB    ( dest src -- ) 0xdc 0x66 2-operand-rm-sse ;
: PADDUSW    ( dest src -- ) 0xdd 0x66 2-operand-rm-sse ;
: PMAXUB     ( dest src -- ) 0xde 0x66 2-operand-rm-sse ;
: PANDN      ( dest src -- ) 0xdf 0x66 2-operand-rm-sse ;
: PAVGB      ( dest src -- ) 0xe0 0x66 2-operand-rm-sse ;
: PAVGW      ( dest src -- ) 0xe3 0x66 2-operand-rm-sse ;
: PMULHUW    ( dest src -- ) 0xe4 0x66 2-operand-rm-sse ;
: PMULHW     ( dest src -- ) 0xe5 0x66 2-operand-rm-sse ;
: CVTTPD2DQ  ( dest src -- ) 0xe6 0x66 2-operand-rm-sse ;
: CVTPD2DQ   ( dest src -- ) 0xe6 0xf2 2-operand-rm-sse ;
: CVTDQ2PD   ( dest src -- ) 0xe6 0xf3 2-operand-rm-sse ;

: MOVNTDQ    ( dest src -- ) 0xe7 0x66 2-operand-mr-sse ;

: PSUBSB     ( dest src -- ) 0xe8 0x66 2-operand-rm-sse ;
: PSUBSW     ( dest src -- ) 0xe9 0x66 2-operand-rm-sse ;
: PMINSW     ( dest src -- ) 0xea 0x66 2-operand-rm-sse ;
: POR        ( dest src -- ) 0xeb 0x66 2-operand-rm-sse ;
: PADDSB     ( dest src -- ) 0xec 0x66 2-operand-rm-sse ;
: PADDSW     ( dest src -- ) 0xed 0x66 2-operand-rm-sse ;
: PMAXSW     ( dest src -- ) 0xee 0x66 2-operand-rm-sse ;
: PXOR       ( dest src -- ) 0xef 0x66 2-operand-rm-sse ;
: LDDQU      ( dest src -- ) 0xf0 0xf2 2-operand-rm-sse ;
: PMULUDQ    ( dest src -- ) 0xf4 0x66 2-operand-rm-sse ;
: PMADDWD    ( dest src -- ) 0xf5 0x66 2-operand-rm-sse ;
: PSADBW     ( dest src -- ) 0xf6 0x66 2-operand-rm-sse ;
: MASKMOVDQU ( dest src -- ) 0xf7 0x66 2-operand-rm-sse ;
: PSUBB      ( dest src -- ) 0xf8 0x66 2-operand-rm-sse ;
: PSUBW      ( dest src -- ) 0xf9 0x66 2-operand-rm-sse ;
: PSUBD      ( dest src -- ) 0xfa 0x66 2-operand-rm-sse ;
: PSUBQ      ( dest src -- ) 0xfb 0x66 2-operand-rm-sse ;
: PADDB      ( dest src -- ) 0xfc 0x66 2-operand-rm-sse ;
: PADDW      ( dest src -- ) 0xfd 0x66 2-operand-rm-sse ;
: PADDD      ( dest src -- ) 0xfe 0x66 2-operand-rm-sse ;

! x86-64 branch prediction hints

: HWNT ( -- ) 0x2e , ; ! Hint branch Weakly Not Taken
: HST  ( -- ) 0x3e , ; ! Hint branch Strongly Taken

! interrupt instructions

: INT ( n -- ) dup 3 = [ drop 0xcc , ] [ 0xcd , 1, ] if ;

! push/pop flags

: PUSHF ( -- ) 0x9c , ;
: POPF  ( -- ) 0x9d , ;
