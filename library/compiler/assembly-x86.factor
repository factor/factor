! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
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

IN: compiler
USE: kernel
USE: compiler
USE: math

: EAX 0 ;
: ECX 1 ;
: EDX 2 ;
: EBX 3 ;
: ESP 4 ;
: EBP 5 ;
: ESI 6 ;
: EDI 7 ;

: byte? -128 127 between? ;

: eax/other ( reg quot quot -- )
    #! Execute first quotation if reg is EAX, second quotation
    #! otherwise, leaving reg on the stack.
    pick EAX = [ drop nip call ] [ nip call ] ifte ; inline

: byte/eax/cell ( imm reg byte eax cell -- )
    #! Assemble an instruction with 3 forms; byte operand, any
    #! register; eax register, cell operand; other register,
    #! cell operand.
    >r >r >r >r dup byte? [
        r> r> call r> drop r> drop compile-byte
    ] [
        r> dup EAX = [
            drop r> drop r> call r> drop compile-cell
        ] [
            r> drop r> drop r> call compile-cell
        ] ifte
    ] ifte ; inline

: MOD-R/M ( r/m reg/opcode mod -- )
    #! MOD-R/M is MOD REG/OPCODE R/M
    6 shift swap 3 shift bitor bitor compile-byte ;

: PUSH-R ( reg -- )
    HEX: 50 + compile-byte ;

: PUSH-[R] ( reg -- )
    HEX: ff compile-byte BIN: 110 0 MOD-R/M ;

: PUSH-I ( imm -- )
    HEX: 68 compile-byte compile-cell ;

: PUSH-I/PARTIAL ( -- fixup )
    #! This is potentially bad. In the compilation of
    #! #return-to, we need to push something which is
    #! only known later.
    #!
    #! Returns address of 32-bit immediate.
    HEX: 68 compile-byte  compiled-offset  0 compile-cell ;

: POP-R ( reg -- )
    HEX: 58 + compile-byte ;

: LEAVE ( -- )
    HEX: c9 compile-byte ;

: I>R ( imm reg -- )
    #! MOV <imm> TO <reg>
    HEX: b8 + compile-byte  compile-cell ;

: [I]>R ( imm reg -- )
    #! MOV INDIRECT <imm> TO <reg>
    [
        HEX: a1 compile-byte
    ] [
        HEX: 8b compile-byte
        BIN: 101 swap 0 MOD-R/M
    ] eax/other compile-cell ;

: I>[R] ( imm reg -- )
    #! MOV <imm> TO INDIRECT <reg>
    HEX: c7 compile-byte  compile-byte  compile-cell ;

: R>[I] ( reg imm -- )
    #! MOV <reg> TO INDIRECT <imm>.
    swap [
        HEX: a3 compile-byte
    ] [
        HEX: 89 compile-byte
        BIN: 101 swap 0 MOD-R/M
    ] eax/other compile-cell ;

: R>R ( reg reg -- )
    #! MOV <reg> TO <reg>.
    HEX: 89 compile-byte  swap BIN: 11 MOD-R/M ;

: [R]>R ( reg reg -- )
    #! MOV INDIRECT <reg> TO <reg>.
    HEX: 8b compile-byte  0 MOD-R/M ;

: R>[R] ( reg reg -- )
    #! MOV <reg> TO INDIRECT <reg>.
    HEX: 89 compile-byte  swap 0 MOD-R/M ;

: I+[I] ( imm addr -- )
    #! ADD <imm> TO ADDRESS <addr>
    HEX: 81 compile-byte
    BIN: 101 0 0 MOD-R/M
    compile-cell
    compile-cell ;

: EAX+/PARTIAL ( -- fixup )
    #! This is potentially bad. In the compilation of
    #! generic and 2generic, we need to add something which is
    #! only known later.
    #!
    #! Returns address of 32-bit immediate.
    HEX: 05 compile-byte  compiled-offset  0 compile-cell ;

: R+I ( imm reg -- )
    #! ADD <imm> TO <reg>, STORE RESULT IN <reg>
    [
        HEX: 83 compile-byte
        0 BIN: 11 MOD-R/M
    ] [
        HEX: 05 compile-byte
    ] [
        HEX: 81 compile-byte
        0 BIN: 11 MOD-R/M
    ] byte/eax/cell ;

: R-I ( imm reg -- )
    #! SUBTRACT <imm> FROM <reg>, STORE RESULT IN <reg>
    [
        HEX: 83 compile-byte
        BIN: 101 BIN: 11 MOD-R/M
    ] [
        HEX: 2d compile-byte
    ] [
        HEX: 81 compile-byte
        BIN: 101 BIN: 11 MOD-R/M
    ] byte/eax/cell ;

: R<<I ( imm reg -- )
    #! SHIFT <reg> BY <imm>, STORE RESULT IN <reg>
    HEX: c1 compile-byte
    BIN: 100 BIN: 11 MOD-R/M
    compile-byte ;

: R>>I ( imm reg -- )
    #! SHIFT <reg> BY <imm>, STORE RESULT IN <reg>
    HEX: c1 compile-byte
    BIN: 111 BIN: 11 MOD-R/M
    compile-byte ;

: CMP-I-R ( imm reg -- )
    #! There are three forms of CMP we assemble
    #! 83 f8 03                cmpl   $0x3,%eax
    #! 81 fa 33 33 33 00       cmpl   $0x333333,%edx
    #! 3d 33 33 33 00          cmpl   $0x333333,%eax
    [
        HEX: 83 compile-byte
        BIN: 111 BIN: 11 MOD-R/M
    ] [
        HEX: 3d compile-byte
    ] [
        HEX: 81 compile-byte
        BIN: 111 BIN: 11 MOD-R/M
    ] byte/eax/cell ;

: JUMP-FIXUP ( addr where -- )
    #! Encode a relative offset to addr from where at where.
    #! Add 4 because addr is relative to *after* insn.
    dup >r 4 + - r> set-compiled-cell ;

: (JUMP) ( xt -- fixup )
    #! addr is relative to *after* insn
    compiled-offset  0 compile-cell ;

: JUMP ( -- fixup )
    #! Push address of branch for fixup
    HEX: e9 compile-byte  (JUMP) ;

: JUMP-[R] ( reg -- )
    #! JUMP TO INDIRECT <reg>.
    HEX: ff compile-byte  BIN: 100 0 MOD-R/M ;

: CALL ( -- fixup )
    HEX: e8 compile-byte  (JUMP) ;

: CALL-[R] ( reg -- )
    #! CALL INDIRECT <reg>.
    HEX: ff compile-byte  BIN: 10 0 MOD-R/M ;

: JE ( -- fixup )
    HEX: 0f compile-byte HEX: 84 compile-byte  (JUMP) ;

: JNE ( -- fixup )
    HEX: 0f compile-byte HEX: 85 compile-byte  (JUMP) ;

: RET ( -- )
    HEX: c3 compile-byte ;
