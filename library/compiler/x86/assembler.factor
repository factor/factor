! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2005 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

USE: compiler
IN: assembler
USE: words
USE: kernel
USE: parser
USE: generic
USE: lists
USE: math
USE: errors
USE: sequences

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
    dup length 1 = [ car register? ] [ drop f ] ifte ;

M: indirect modifier drop BIN: 00 ;
M: indirect register
    car register dup BIN: 101 = [
        "x86 does not support [ EBP ]. Use [ EBP 0 ] instead."
        throw
    ] when ;
M: indirect displacement drop ;

( Displaced indirect register operands -- eg, [ EAX 4 ]        )
PREDICATE: cons displaced
    dup length 2 = [
        2unlist integer? swap register? and
    ] [
        drop f
    ] ifte ;

M: displaced modifier cdr car byte? BIN: 01 BIN: 10 ? ;
M: displaced register car register ;
M: displaced displacement
    cdr car dup byte? [ compile-byte ] [ compile-cell ] ifte ;

( Displacement-only operands -- eg, [ 1234 ]                   )
PREDICATE: cons disp-only
    dup length 1 = [ car integer? ] [ drop f ] ifte ;

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
    >r dup modifier 6 shift over register bitor r> 3 shift bitor
    compile-byte displacement ;

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
    ] ifte ;

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

: patch ( addr where -- )
    #! Encode a relative offset to addr from where at where.
    #! Add 4 because addr is relative to *after* insn.
    dup >r 4 + - r> set-compiled-cell ;

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

GENERIC: CALL ( op -- )
M: integer CALL HEX: e8 compile-byte from compile-cell ;
M: operand CALL HEX: ff compile-byte BIN: 010 1-operand ;

: JUMPcc ( addr opcode -- )
    HEX: 0f compile-byte  compile-byte  from compile-cell ;

: JO  HEX: 80 JUMPcc ;
: JNO HEX: 81 JUMPcc ;
: JB  HEX: 82 JUMPcc ;
: JAE HEX: 83 JUMPcc ;
: JE  HEX: 84 JUMPcc ;
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

: RET ( -- ) HEX: c3 compile-byte ;

( Arithmetic                                                   )

GENERIC: ADD ( dst src -- )
M: integer ADD HEX: 81 BIN: 000 immediate-8/32 ;
M: operand ADD HEX: 01 2-operand ;

GENERIC: SUB ( dst src -- )
M: integer SUB HEX: 81 BIN: 101 immediate-8/32 ;
M: operand SUB HEX: 29 2-operand ;

GENERIC: AND ( dst src -- )
M: integer AND HEX: 81 BIN: 100 immediate-8/32 ;
M: operand AND HEX: 21 2-operand ;

: IMUL ( dst src -- )
    HEX: 0f compile-byte HEX: af 2-operand ;

: IDIV ( src -- )
    #! IDIV is weird on x86. Only the divisor is given as an
    #! explicit operand. The quotient is stored in EAX, the
    #! remainder in EDX.
    HEX: f7 compile-byte BIN: 111 1-operand ;

: CDQ HEX: 99 compile-byte ;

: SHL ( dst src -- ) HEX: c1 BIN: 100 immediate-8 ;

: SHR ( dst src -- ) HEX: c1 BIN: 101 immediate-8 ;

GENERIC: CMP ( dst src -- )
M: integer CMP HEX: 81 BIN: 111 immediate-8/32 ;
M: operand CMP HEX: 39 2-operand ;

: LEA ( dst src -- )
    HEX: 8d compile-byte swap register 1-operand ;
