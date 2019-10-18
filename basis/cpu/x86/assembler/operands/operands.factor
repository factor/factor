! Copyright (C) 2008, 2009 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel words math accessors sequences namespaces
assocs layouts cpu.x86.assembler.syntax ;
IN: cpu.x86.assembler.operands

! In 32-bit mode, { 1234 } is absolute indirect addressing.
! In 64-bit mode, { 1234 } is RIP-relative.
! Beware!

REGISTERS: 8 AL CL DL BL SPL BPL SIL DIL R8B R9B R10B R11B R12B R13B R14B R15B ;

ALIAS: AH SPL
ALIAS: CH BPL
ALIAS: DH SIL
ALIAS: BH DIL

REGISTERS: 16 AX CX DX BX SP BP SI DI R8W R9W R10W R11W R12W R13W R14W R15W ;

REGISTERS: 32 EAX ECX EDX EBX ESP EBP ESI EDI R8D R9D R10D R11D R12D R13D R14D R15D ;

REGISTERS: 64
RAX RCX RDX RBX RSP RBP RSI RDI R8 R9 R10 R11 R12 R13 R14 R15 ;

REGISTERS: 128
XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7
XMM8 XMM9 XMM10 XMM11 XMM12 XMM13 XMM14 XMM15 ;

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
    canonicalize-EBP check-ESP ;

: <indirect> ( base index scale displacement -- indirect )
    indirect boa canonicalize ;

! Utilities
UNION: operand register indirect ;

GENERIC: operand-64? ( operand -- ? )

M: indirect operand-64?
    [ base>> ] [ index>> ] bi [ operand-64? ] either? ;

M: register-64 operand-64? drop t ;

M: object operand-64? drop f ;

PRIVATE>

: [] ( reg/displacement -- indirect )
    dup integer? [ [ f f f ] dip ] [ f f f ] if <indirect> ;

: [+] ( reg displacement -- indirect )
    dup integer?
    [ dup zero? [ drop f ] when [ f f ] dip ]
    [ f f ] if
    <indirect> ;

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
