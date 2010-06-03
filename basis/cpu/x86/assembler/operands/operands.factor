! Copyright (C) 2008, 2010 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words math accessors sequences namespaces
assocs layouts cpu.x86.assembler.syntax ;
IN: cpu.x86.assembler.operands

REGISTERS: 8 AL CL DL BL SPL BPL SIL DIL R8B R9B R10B R11B R12B R13B R14B R15B ;

HI-REGISTERS: 8 AH CH DH BH ;

REGISTERS: 16 AX CX DX BX SP BP SI DI R8W R9W R10W R11W R12W R13W R14W R15W ;

REGISTERS: 32 EAX ECX EDX EBX ESP EBP ESI EDI R8D R9D R10D R11D R12D R13D R14D R15D ;

REGISTERS: 64 RAX RCX RDX RBX RSP RBP RSI RDI R8 R9 R10 R11 R12 R13 R14 R15 ;

REGISTERS: 128
XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7
XMM8 XMM9 XMM10 XMM11 XMM12 XMM13 XMM14 XMM15 ;

REGISTERS: 80 ST0 ST1 ST2 ST3 ST4 ST5 ST6 ST7 ;

: shuffle-down ( STn -- STn+1 )
    "register" word-prop 1 + 80 registers get at nth ;

PREDICATE: register < word
    "register" word-prop ;

<PRIVATE

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

GENERIC: extended? ( op -- ? )

M: object extended? drop f ;

M: register extended? "register" word-prop 7 > ;

! Addressing modes
TUPLE: indirect base index scale displacement ;

M: indirect extended? base>> extended? ;

: canonicalize-displacement ( indirect -- indirect )
    dup [ base>> ] [ displacement>> 0 = ] bi and
    [ f >>displacement ] when ;

: canonicalize-EBP ( indirect -- indirect )
    #! { EBP } ==> { EBP 0 }
    dup [ base>> { EBP RBP R13 } member? ] [ displacement>> not ] bi and
    [ 0 >>displacement ] when ;

ERROR: bad-index indirect ;

: check-ESP ( indirect -- indirect )
    dup index>> { ESP RSP } member-eq? [ bad-index ] when ;

: canonicalize ( indirect -- indirect )
    #! Modify the indirect to work around certain addressing mode
    #! quirks.
    canonicalize-displacement canonicalize-EBP check-ESP ;

! Utilities
UNION: operand register indirect ;

GENERIC: operand-64? ( operand -- ? )

M: indirect operand-64?
    [ base>> ] [ index>> ] bi [ operand-64? ] either? ;

M: register-64 operand-64? drop t ;

M: object operand-64? drop f ;

PRIVATE>

: <indirect> ( base index scale displacement -- indirect )
    indirect boa canonicalize ;

: [] ( base/displacement -- indirect )
    dup integer?
    [ [ f f bootstrap-cell 8 = 0 f ? ] dip <indirect> ]
    [ f f f <indirect> ]
    if ;

: [RIP+] ( displacement -- indirect )
    [ f f f ] dip <indirect> ;

: [+] ( base index/displacement -- indirect )
    dup integer?
    [ [ f f ] dip ]
    [ f f ] if
    <indirect> ;

: [++] ( base index displacement -- indirect )
    [ f ] dip <indirect> ;

: [+*2+] ( base index displacement -- indirect )
    [ 1 ] dip <indirect> ;

: [+*4+] ( base index displacement -- indirect )
    [ 2 ] dip <indirect> ;

: [+*8+] ( base index displacement -- indirect )
    [ 3 ] dip <indirect> ;

TUPLE: byte value ;

C: <byte> byte

: extended-8-bit-register? ( register -- ? )
    { SPL BPL SIL DIL } member-eq? ;

: n-bit-version-of ( register n -- register' )
    ! Certain 8-bit registers don't exist in 32-bit mode...
    [ "register" word-prop ] dip registers get at nth
    dup extended-8-bit-register? cell 4 = and
    [ drop f ] when ;

: 8-bit-version-of ( register -- register' ) 8 n-bit-version-of ;
: 16-bit-version-of ( register -- register' ) 16 n-bit-version-of ;
: 32-bit-version-of ( register -- register' ) 32 n-bit-version-of ;
: 64-bit-version-of ( register -- register' ) 64 n-bit-version-of ;
: native-version-of ( register -- register' ) cell-bits n-bit-version-of ;
