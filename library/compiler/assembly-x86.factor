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
USE: stack
USE: combinators

: EAX 0 ;
: ECX 1 ;
: EDX 2 ;
: EBX 3 ;
: ESP 4 ;
: EBP 5 ;
: ESI 6 ;
: EDI 7 ;

: MOD-R/M ( r/m reg/opcode mod -- )
    6 shift swap 3 shift bitor bitor compile-byte ;

: PUSH-R ( reg -- )
    HEX: 50 + compile-byte ;

: PUSH-I ( imm -- )
    HEX: 68 compile-byte compile-cell ;

: POP-R ( reg -- )
    HEX: 58 + compile-byte ;

: LEAVE ( -- )
    HEX: c9 compile-byte ;

: I>R ( imm reg -- )
    #! MOV <imm> TO <reg>
    HEX: b8 + compile-byte  compile-cell ;

: [I]>R ( imm reg -- )
    #! MOV INDIRECT <imm> TO <reg>
    dup EAX = [
        drop HEX: a1 compile-byte
    ] [
        HEX: 8b compile-byte
        BIN: 101 swap 0 MOD-R/M
    ] ifte compile-cell ;

: I>[R] ( imm reg -- )
    #! MOV <imm> TO INDIRECT <reg>
    HEX: c7 compile-byte  compile-byte  compile-cell ;

: R>[I] ( reg imm -- )
    #! MOV <reg> TO INDIRECT <imm>.
    over EAX = [
        nip HEX: a3 compile-byte
    ] [
        HEX: 89 compile-byte
        swap BIN: 101 swap 0 MOD-R/M
    ] ifte compile-cell ;

: R>R ( reg reg -- )
    #! MOV <reg> TO <reg>.
    HEX: 89 compile-byte  swap BIN: 11 MOD-R/M ;

: [R]>R ( reg reg -- )
    #! MOV INDIRECT <reg> TO <reg>.
    HEX: 8b compile-byte  swap 0 MOD-R/M ;

: R>[R] ( reg reg -- )
    #! MOV <reg> TO INDIRECT <reg>.
    HEX: 89 compile-byte  swap 0 MOD-R/M ;

: I+[I] ( imm addr -- )
    #! ADD <imm> TO ADDRESS <addr>
    HEX: 81 compile-byte
    BIN: 101 0 0 MOD-R/M
    compile-cell
    compile-cell ;

: R+I ( imm reg -- )
    #! ADD <imm> TO <reg>, STORE RESULT IN <reg>
    over -128 127 between? [
        HEX: 83 compile-byte
        0 BIN: 11 MOD-R/M
        compile-byte
    ] [
        dup EAX = [
            drop HEX: 05 compile-byte
        ] [
            HEX: 81 compile-byte
            0 BIN: 11 MOD-R/M
        ] ifte
        compile-cell
    ] ifte ;

: R-I ( imm reg -- )
    #! SUBTRACT <imm> FROM <reg>, STORE RESULT IN <reg>
    over -128 127 between? [
        HEX: 83 compile-byte
        BIN: 101 BIN: 11 MOD-R/M
        compile-byte
    ] [
        dup EAX = [
            drop HEX: 2d compile-byte
        ] [
            HEX: 81 compile-byte
            BIN: 101 BIN: 11 MOD-R/M
        ] ifte
        compile-cell
    ] ifte ;

: CMP-I-[R] ( imm reg -- )
    #! There are two forms of CMP we assemble
    #! 83 38 03                cmpl   $0x3,(%eax)
    #! 81 38 33 33 33 00       cmpl   $0x333333,(%eax)
    over -128 127 between? [
        HEX: 83 compile-byte
        BIN: 111 0 MOD-R/M
        compile-byte
    ] [
        HEX: 81 compile-byte
        BIN: 111 0 MOD-R/M
        compile-cell
    ] ifte ;

: fixup ( addr where -- )
    #! Encode a relative offset to addr from where at where.
    #! Add 4 because addr is relative to *after* insn.
    dup >r 4 + - r> set-compiled-cell ;

: (JUMP) ( xt -- fixup )
    #! addr is relative to *after* insn
    compiled-offset dup >r 4 + - compile-cell r> ;

: JUMP ( xt -- fixup )
    #! Push address of branch for fixup
    HEX: e9 compile-byte  (JUMP) ;

: CALL ( xt -- fixup )
    HEX: e8 compile-byte  (JUMP) ;

: JE ( xt -- fixup )
    HEX: 0f compile-byte HEX: 84 compile-byte (JUMP) ;

: RET ( -- )
    HEX: c3 compile-byte ;
