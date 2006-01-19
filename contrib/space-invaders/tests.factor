! Copyright (C) 2006 Chris Double.
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
USING: kernel cpu-8080 test lazy parser-combinators math hashtables lists sequences words ;

! Test read-byte from ROM
[ 0 ] [ HEX: 50 <cpu> read-byte ] unit-test

! Test read-byte out of RAM range
! [ HEX: FF ] [ HEX: 4001 <cpu> read-byte ] unit-test

! Test write-byte to ROM
[ 0 ] [ <cpu> 1 HEX: 1000 pick write-byte HEX: 1000 swap read-byte ] unit-test
  
! Test write-byte to RAM
[ 1 ] [ <cpu> 1 HEX: 2000 pick write-byte HEX: 2000 swap read-byte ] unit-test

! Test write-byte out of range
! [ HEX: FF ] [ <cpu> 1 HEX: 4001 pick write-byte HEX: 4001 swap read-byte ] unit-test
 
! Test write-word/read-word
[ HEX: 2021 ] [
  <cpu>
  HEX: 2021 HEX: 2000 pick write-word HEX: 2000 swap read-word 
] unit-test

! Test AF
[ HEX: 1020 ] [
  <cpu> 
  [ HEX: 10 swap set-cpu-a ] keep
  [ HEX: 20 swap set-cpu-f ] keep
  cpu-af 
] unit-test

[ HEX: 10 HEX: 20 ] [
  <cpu> HEX: 1020 over set-cpu-af
        dup cpu-a
        swap cpu-f
] unit-test

[ t t ] [
  <cpu> 
  [ HEX: 10 swap set-cpu-a ] keep
  [ HEX: 20 swap set-cpu-f ] keep
  [ cpu-af ] keep
  [ set-cpu-af ] keep
  [ cpu-a HEX: 10 = ] keep
  cpu-f HEX: 20 =
] unit-test

! Test BC
[ HEX: 1020 ] [
  <cpu> 
  [ HEX: 10 swap set-cpu-b ] keep
  [ HEX: 20 swap set-cpu-c ] keep
  cpu-bc
] unit-test

[ HEX: 10 HEX: 20 ] [
  <cpu> HEX: 1020 over set-cpu-bc
        dup cpu-b
        swap cpu-c
] unit-test

[ t t ] [
  <cpu> 
  [ HEX: 10 swap set-cpu-b ] keep
  [ HEX: 20 swap set-cpu-c ] keep
  [ cpu-bc ] keep
  [ set-cpu-bc ] keep
  [ cpu-b HEX: 10 = ] keep
  cpu-c HEX: 20 =
] unit-test

! Test DE
[ HEX: 1020 ] [
  <cpu> 
  [ HEX: 10 swap set-cpu-d ] keep
  [ HEX: 20 swap set-cpu-e ] keep
  cpu-de
] unit-test

[ HEX: 10 HEX: 20 ] [
  <cpu> HEX: 1020 over set-cpu-de
        dup cpu-d
        swap cpu-e
] unit-test

[ t t ] [
  <cpu> 
  [ HEX: 10 swap set-cpu-d ] keep
  [ HEX: 20 swap set-cpu-e ] keep
  [ cpu-de ] keep
  [ set-cpu-de ] keep
  [ cpu-d HEX: 10 = ] keep
  cpu-e HEX: 20 =
] unit-test

! Test HL
[ HEX: 1020 ] [
  <cpu> 
  [ HEX: 10 swap set-cpu-h ] keep
  [ HEX: 20 swap set-cpu-l ] keep
  cpu-hl
] unit-test

[ HEX: 10 HEX: 20 ] [
  <cpu> HEX: 1020 over set-cpu-hl
        dup cpu-h
        swap cpu-l
] unit-test

[ t t ] [
  <cpu> 
  [ HEX: 10 swap set-cpu-h ] keep
  [ HEX: 20 swap set-cpu-l ] keep
  [ cpu-hl ] keep
  [ set-cpu-hl ] keep
  [ cpu-h HEX: 10 = ] keep
  cpu-l HEX: 20 =
] unit-test

! Rom loading
[ HEX: 221 ] [
  <cpu> "invaders.rom" over load-rom 
  HEX: 0100 swap read-word
] unit-test
  
: instruction-parse-test ( args type instruction -- )
  >r patterns hash replace-patterns unit r> 
  [ instruction-quotations ] cons unit-test ;

{ } "NOP" "NOP" instruction-parse-test
{ cpu-bc set-cpu-bc } "LD-RR,NN" "LD BC,nn" instruction-parse-test
{ cpu-bc set-cpu-bc cpu-a set-cpu-a } "LD-(RR),R" "LD (BC),A" instruction-parse-test
{ cpu-bc set-cpu-bc } "INC-RR" "INC BC" instruction-parse-test
{ cpu-a set-cpu-a } "INC-R" "INC A" instruction-parse-test
{ cpu-a set-cpu-a } "DEC-R" "DEC A" instruction-parse-test
{ cpu-b set-cpu-b } "LD-R,N" "LD B,n" instruction-parse-test
{ } "RLCA" "RLCA" instruction-parse-test
{ cpu-hl set-cpu-hl cpu-bc set-cpu-bc } "ADD-RR,RR" "ADD HL,BC" instruction-parse-test
{ cpu-a set-cpu-a cpu-bc set-cpu-bc } "LD-R,(RR)" "LD A,(BC)" instruction-parse-test
{ cpu-bc set-cpu-bc } "DEC-RR" "DEC BC" instruction-parse-test
{ cpu-c set-cpu-c } "INC-R" "INC C" instruction-parse-test
{ cpu-c set-cpu-c } "DEC-R" "DEC C" instruction-parse-test
{ cpu-c set-cpu-c } "LD-R,N" "LD C,n" instruction-parse-test
{ } "RRCA" "RRCA" instruction-parse-test
{ cpu-de set-cpu-de } "LD-RR,NN" "LD DE,nn" instruction-parse-test
{ cpu-de set-cpu-de cpu-a set-cpu-a } "LD-(RR),R" "LD (DE),A" instruction-parse-test
{ cpu-de set-cpu-de } "INC-RR" "INC DE" instruction-parse-test
{ cpu-d set-cpu-d } "INC-R" "INC D" instruction-parse-test
{ cpu-d set-cpu-d } "DEC-R" "DEC D" instruction-parse-test
{ cpu-d set-cpu-d } "LD-R,N" "LD D,n" instruction-parse-test
{ } "RLA" "RLA" instruction-parse-test
{ cpu-hl set-cpu-hl cpu-de set-cpu-de } "ADD-RR,RR" "ADD HL,DE" instruction-parse-test
{ cpu-a set-cpu-a cpu-de set-cpu-de } "LD-R,(RR)" "LD A,(DE)" instruction-parse-test
{ cpu-de set-cpu-de } "DEC-RR" "DEC DE" instruction-parse-test
{ cpu-e set-cpu-e } "INC-R" "INC E" instruction-parse-test
{ cpu-e set-cpu-e } "DEC-R" "DEC E" instruction-parse-test
{ cpu-e set-cpu-e } "LD-R,N" "LD E,n" instruction-parse-test
{ } "RRA" "RRA" instruction-parse-test
{ cpu-hl set-cpu-hl } "LD-RR,NN" "LD HL,nn" instruction-parse-test
{ cpu-hl set-cpu-hl } "LD-(NN),RR" "LD (nn),HL" instruction-parse-test
{ cpu-hl set-cpu-hl } "INC-RR" "INC HL" instruction-parse-test
{ cpu-h set-cpu-h } "INC-R" "INC H" instruction-parse-test
{ cpu-h set-cpu-h } "DEC-R" "DEC H" instruction-parse-test
{ cpu-h set-cpu-h } "LD-R,N" "LD H,n" instruction-parse-test
{ } "DAA" "DAA" instruction-parse-test
{ cpu-hl set-cpu-hl cpu-hl set-cpu-hl } "ADD-RR,RR" "ADD HL,HL" instruction-parse-test
{ cpu-hl set-cpu-hl } "LD-RR,(NN)" "LD HL,(nn)" instruction-parse-test
{ cpu-hl set-cpu-hl } "DEC-RR" "DEC HL" instruction-parse-test
{ cpu-l set-cpu-l } "INC-R" "INC L" instruction-parse-test
{ cpu-l set-cpu-l } "DEC-R" "DEC L" instruction-parse-test
{ cpu-l set-cpu-l } "LD-R,N" "LD L,n" instruction-parse-test
{ } "CPL" "CPL" instruction-parse-test
{ cpu-sp set-cpu-sp } "LD-RR,NN" "LD SP,nn" instruction-parse-test
{ cpu-a set-cpu-a } "LD-(NN),R" "LD (nn),A" instruction-parse-test
{ cpu-sp set-cpu-sp } "INC-RR" "INC SP" instruction-parse-test
{ cpu-hl set-cpu-hl } "INC-(RR)" "INC (HL)" instruction-parse-test
{ cpu-hl set-cpu-hl } "DEC-(RR)" "DEC (HL)" instruction-parse-test
{ cpu-hl set-cpu-hl } "LD-(RR),N" "LD (HL),n" instruction-parse-test
{ } "SCF" "SCF" instruction-parse-test
{ cpu-hl set-cpu-hl cpu-sp set-cpu-sp } "ADD-RR,RR" "ADD HL,SP" instruction-parse-test
{ cpu-a set-cpu-a } "LD-R,(NN)" "LD A,(nn)" instruction-parse-test
{ cpu-sp set-cpu-sp } "DEC-RR" "DEC SP" instruction-parse-test
{ cpu-a set-cpu-a } "INC-R" "INC A" instruction-parse-test
{ cpu-a set-cpu-a } "DEC-R" "DEC A" instruction-parse-test
{ cpu-a set-cpu-a } "LD-R,N" "LD A,n" instruction-parse-test
{ } "CCF" "CCF" instruction-parse-test
{ cpu-b set-cpu-b cpu-b set-cpu-b } "LD-R,R" "LD B,B" instruction-parse-test
{ cpu-b set-cpu-b cpu-c set-cpu-c } "LD-R,R" "LD B,C" instruction-parse-test
{ cpu-b set-cpu-b cpu-d set-cpu-d } "LD-R,R" "LD B,D" instruction-parse-test
{ cpu-b set-cpu-b cpu-e set-cpu-e } "LD-R,R" "LD B,E" instruction-parse-test
{ cpu-b set-cpu-b cpu-h set-cpu-h } "LD-R,R" "LD B,H" instruction-parse-test
{ cpu-b set-cpu-b cpu-l set-cpu-l } "LD-R,R" "LD B,L" instruction-parse-test
{ cpu-b set-cpu-b cpu-hl set-cpu-hl } "LD-R,(RR)" "LD B,(HL)" instruction-parse-test
{ cpu-b set-cpu-b cpu-a set-cpu-a } "LD-R,R" "LD B,A" instruction-parse-test
{ cpu-c set-cpu-c cpu-b set-cpu-b } "LD-R,R" "LD C,B" instruction-parse-test
{ cpu-c set-cpu-c cpu-c set-cpu-c } "LD-R,R" "LD C,C" instruction-parse-test
{ cpu-c set-cpu-c cpu-d set-cpu-d } "LD-R,R" "LD C,D" instruction-parse-test
{ cpu-c set-cpu-c cpu-e set-cpu-e } "LD-R,R" "LD C,E" instruction-parse-test
{ cpu-c set-cpu-c cpu-h set-cpu-h } "LD-R,R" "LD C,H" instruction-parse-test
{ cpu-c set-cpu-c cpu-l set-cpu-l } "LD-R,R" "LD C,L" instruction-parse-test
{ cpu-c set-cpu-c cpu-hl set-cpu-hl } "LD-R,(RR)" "LD C,(HL)" instruction-parse-test
{ cpu-c set-cpu-c cpu-a set-cpu-a } "LD-R,R" "LD C,A" instruction-parse-test
{ cpu-d set-cpu-d cpu-b set-cpu-b } "LD-R,R" "LD D,B" instruction-parse-test
{ cpu-d set-cpu-d cpu-c set-cpu-c } "LD-R,R" "LD D,C" instruction-parse-test
{ cpu-d set-cpu-d cpu-d set-cpu-d } "LD-R,R" "LD D,D" instruction-parse-test
{ cpu-d set-cpu-d cpu-e set-cpu-e } "LD-R,R" "LD D,E" instruction-parse-test
{ cpu-d set-cpu-d cpu-h set-cpu-h } "LD-R,R" "LD D,H" instruction-parse-test
{ cpu-d set-cpu-d cpu-l set-cpu-l } "LD-R,R" "LD D,L" instruction-parse-test
{ cpu-d set-cpu-d cpu-hl set-cpu-hl } "LD-R,(RR)" "LD D,(HL)" instruction-parse-test
{ cpu-d set-cpu-d cpu-a set-cpu-a } "LD-R,R" "LD D,A" instruction-parse-test
{ cpu-e set-cpu-e cpu-b set-cpu-b } "LD-R,R" "LD E,B" instruction-parse-test
{ cpu-e set-cpu-e cpu-c set-cpu-c } "LD-R,R" "LD E,C" instruction-parse-test
{ cpu-e set-cpu-e cpu-d set-cpu-d } "LD-R,R" "LD E,D" instruction-parse-test
{ cpu-e set-cpu-e cpu-e set-cpu-e } "LD-R,R" "LD E,E" instruction-parse-test
{ cpu-e set-cpu-e cpu-h set-cpu-h } "LD-R,R" "LD E,H" instruction-parse-test
{ cpu-e set-cpu-e cpu-l set-cpu-l } "LD-R,R" "LD E,L" instruction-parse-test
{ cpu-e set-cpu-e cpu-hl set-cpu-hl } "LD-R,(RR)" "LD E,(HL)" instruction-parse-test
{ cpu-e set-cpu-e cpu-a set-cpu-a } "LD-R,R" "LD E,A" instruction-parse-test
{ cpu-h set-cpu-h cpu-b set-cpu-b } "LD-R,R" "LD H,B" instruction-parse-test
{ cpu-h set-cpu-h cpu-c set-cpu-c } "LD-R,R" "LD H,C" instruction-parse-test
{ cpu-h set-cpu-h cpu-d set-cpu-d } "LD-R,R" "LD H,D" instruction-parse-test
{ cpu-h set-cpu-h cpu-e set-cpu-e } "LD-R,R" "LD H,E" instruction-parse-test
{ cpu-h set-cpu-h cpu-h set-cpu-h } "LD-R,R" "LD H,H" instruction-parse-test
{ cpu-h set-cpu-h cpu-l set-cpu-l } "LD-R,R" "LD H,L" instruction-parse-test
{ cpu-h set-cpu-h cpu-hl set-cpu-hl } "LD-R,(RR)" "LD H,(HL)" instruction-parse-test
{ cpu-h set-cpu-h cpu-a set-cpu-a } "LD-R,R" "LD H,A" instruction-parse-test
{ cpu-l set-cpu-l cpu-b set-cpu-b } "LD-R,R" "LD L,B" instruction-parse-test
{ cpu-l set-cpu-l cpu-c set-cpu-c } "LD-R,R" "LD L,C" instruction-parse-test
{ cpu-l set-cpu-l cpu-d set-cpu-d } "LD-R,R" "LD L,D" instruction-parse-test
{ cpu-l set-cpu-l cpu-e set-cpu-e } "LD-R,R" "LD L,E" instruction-parse-test
{ cpu-l set-cpu-l cpu-h set-cpu-h } "LD-R,R" "LD L,H" instruction-parse-test
{ cpu-l set-cpu-l cpu-l set-cpu-l } "LD-R,R" "LD L,L" instruction-parse-test
{ cpu-l set-cpu-l cpu-hl set-cpu-hl } "LD-R,(RR)" "LD L,(HL)" instruction-parse-test
{ cpu-l set-cpu-l cpu-a set-cpu-a } "LD-R,R" "LD L,A" instruction-parse-test
{ cpu-hl set-cpu-hl cpu-b set-cpu-b } "LD-(RR),R" "LD (HL),B" instruction-parse-test
{ cpu-hl set-cpu-hl cpu-c set-cpu-c } "LD-(RR),R" "LD (HL),C" instruction-parse-test
{ cpu-hl set-cpu-hl cpu-d set-cpu-d } "LD-(RR),R" "LD (HL),D" instruction-parse-test
{ cpu-hl set-cpu-hl cpu-e set-cpu-e } "LD-(RR),R" "LD (HL),E" instruction-parse-test
{ cpu-hl set-cpu-hl cpu-h set-cpu-h } "LD-(RR),R" "LD (HL),H" instruction-parse-test
{ cpu-hl set-cpu-hl cpu-l set-cpu-l } "LD-(RR),R" "LD (HL),L" instruction-parse-test
{ } "HALT" "HALT" instruction-parse-test
{ cpu-hl set-cpu-hl cpu-a set-cpu-a } "LD-(RR),R" "LD (HL),A" instruction-parse-test
{ cpu-a set-cpu-a cpu-b set-cpu-b } "LD-R,R" "LD A,B" instruction-parse-test
{ cpu-a set-cpu-a cpu-c set-cpu-c } "LD-R,R" "LD A,C" instruction-parse-test
{ cpu-a set-cpu-a cpu-d set-cpu-d } "LD-R,R" "LD A,D" instruction-parse-test
{ cpu-a set-cpu-a cpu-e set-cpu-e } "LD-R,R" "LD A,E" instruction-parse-test
{ cpu-a set-cpu-a cpu-h set-cpu-h } "LD-R,R" "LD A,H" instruction-parse-test
{ cpu-a set-cpu-a cpu-l set-cpu-l } "LD-R,R" "LD A,L" instruction-parse-test
{ cpu-a set-cpu-a cpu-hl set-cpu-hl } "LD-R,(RR)" "LD A,(HL)" instruction-parse-test
{ cpu-a set-cpu-a cpu-a set-cpu-a } "LD-R,R" "LD A,A" instruction-parse-test
{ cpu-a set-cpu-a cpu-b set-cpu-b } "ADD-R,R" "ADD A,B" instruction-parse-test
{ cpu-a set-cpu-a cpu-c set-cpu-c } "ADD-R,R" "ADD A,C" instruction-parse-test
{ cpu-a set-cpu-a cpu-d set-cpu-d } "ADD-R,R" "ADD A,D" instruction-parse-test
{ cpu-a set-cpu-a cpu-e set-cpu-e } "ADD-R,R" "ADD A,E" instruction-parse-test
{ cpu-a set-cpu-a cpu-h set-cpu-h } "ADD-R,R" "ADD A,H" instruction-parse-test
{ cpu-a set-cpu-a cpu-l set-cpu-l } "ADD-R,R" "ADD A,L" instruction-parse-test
{ cpu-a set-cpu-a cpu-hl set-cpu-hl } "ADD-R,(RR)" "ADD A,(HL)" instruction-parse-test
{ cpu-a set-cpu-a cpu-a set-cpu-a } "ADD-R,R" "ADD A,A" instruction-parse-test
{ cpu-a set-cpu-a cpu-b set-cpu-b } "ADC-R,R" "ADC A,B" instruction-parse-test
{ cpu-a set-cpu-a cpu-c set-cpu-c } "ADC-R,R" "ADC A,C" instruction-parse-test
{ cpu-a set-cpu-a cpu-d set-cpu-d } "ADC-R,R" "ADC A,D" instruction-parse-test
{ cpu-a set-cpu-a cpu-e set-cpu-e } "ADC-R,R" "ADC A,E" instruction-parse-test
{ cpu-a set-cpu-a cpu-h set-cpu-h } "ADC-R,R" "ADC A,H" instruction-parse-test
{ cpu-a set-cpu-a cpu-l set-cpu-l } "ADC-R,R" "ADC A,L" instruction-parse-test
{ cpu-a set-cpu-a cpu-hl set-cpu-hl } "ADC-R,(RR)" "ADC A,(HL)" instruction-parse-test
{ cpu-a set-cpu-a cpu-a set-cpu-a } "ADC-R,R" "ADC A,A" instruction-parse-test
{ cpu-b set-cpu-b } "SUB-R" "SUB B" instruction-parse-test
{ cpu-c set-cpu-c } "SUB-R" "SUB C" instruction-parse-test
{ cpu-d set-cpu-d } "SUB-R" "SUB D" instruction-parse-test
{ cpu-e set-cpu-e } "SUB-R" "SUB E" instruction-parse-test
{ cpu-h set-cpu-h } "SUB-R" "SUB H" instruction-parse-test
{ cpu-l set-cpu-l } "SUB-R" "SUB L" instruction-parse-test
{ cpu-hl set-cpu-hl } "SUB-(RR)" "SUB (HL)" instruction-parse-test
{ cpu-a set-cpu-a } "SUB-R" "SUB A" instruction-parse-test
{ cpu-a set-cpu-a cpu-b set-cpu-b } "SBC-R,R" "SBC A,B" instruction-parse-test
{ cpu-a set-cpu-a cpu-c set-cpu-c } "SBC-R,R" "SBC A,C" instruction-parse-test
{ cpu-a set-cpu-a cpu-d set-cpu-d } "SBC-R,R" "SBC A,D" instruction-parse-test
{ cpu-a set-cpu-a cpu-e set-cpu-e } "SBC-R,R" "SBC A,E" instruction-parse-test
{ cpu-a set-cpu-a cpu-h set-cpu-h } "SBC-R,R" "SBC A,H" instruction-parse-test
{ cpu-a set-cpu-a cpu-l set-cpu-l } "SBC-R,R" "SBC A,L" instruction-parse-test
{ cpu-a set-cpu-a cpu-hl set-cpu-hl } "SBC-R,(RR)" "SBC A,(HL)" instruction-parse-test
{ cpu-a set-cpu-a cpu-a set-cpu-a } "SBC-R,R" "SBC A,A" instruction-parse-test
{ cpu-b set-cpu-b } "AND-R" "AND B" instruction-parse-test
{ cpu-c set-cpu-c } "AND-R" "AND C" instruction-parse-test
{ cpu-d set-cpu-d } "AND-R" "AND D" instruction-parse-test
{ cpu-e set-cpu-e } "AND-R" "AND E" instruction-parse-test
{ cpu-h set-cpu-h } "AND-R" "AND H" instruction-parse-test
{ cpu-l set-cpu-l } "AND-R" "AND L" instruction-parse-test
{ cpu-hl set-cpu-hl } "AND-(RR)" "AND (HL)" instruction-parse-test
{ cpu-a set-cpu-a } "AND-A" "AND A" instruction-parse-test
{ cpu-b set-cpu-b } "XOR-R" "XOR B" instruction-parse-test
{ cpu-c set-cpu-c } "XOR-R" "XOR C" instruction-parse-test
{ cpu-d set-cpu-d } "XOR-R" "XOR D" instruction-parse-test
{ cpu-e set-cpu-e } "XOR-R" "XOR E" instruction-parse-test
{ cpu-h set-cpu-h } "XOR-R" "XOR H" instruction-parse-test
{ cpu-l set-cpu-l } "XOR-R" "XOR L" instruction-parse-test
{ cpu-hl set-cpu-hl } "XOR-(RR)" "XOR (HL)" instruction-parse-test
{ cpu-a set-cpu-a } "XOR-R" "XOR A" instruction-parse-test
{ cpu-b set-cpu-b } "OR-R" "OR B" instruction-parse-test
{ cpu-c set-cpu-c } "OR-R" "OR C" instruction-parse-test
{ cpu-d set-cpu-d } "OR-R" "OR D" instruction-parse-test
{ cpu-e set-cpu-e } "OR-R" "OR E" instruction-parse-test
{ cpu-h set-cpu-h } "OR-R" "OR H" instruction-parse-test
{ cpu-l set-cpu-l } "OR-R" "OR L" instruction-parse-test
{ cpu-hl set-cpu-hl } "OR-(RR)" "OR (HL)" instruction-parse-test
{ cpu-a set-cpu-a } "OR-R" "OR A" instruction-parse-test
{ cpu-b set-cpu-b } "CP-R" "CP B" instruction-parse-test
{ cpu-c set-cpu-c } "CP-R" "CP C" instruction-parse-test
{ cpu-d set-cpu-d } "CP-R" "CP D" instruction-parse-test
{ cpu-e set-cpu-e } "CP-R" "CP E" instruction-parse-test
{ cpu-h set-cpu-h } "CP-R" "CP H" instruction-parse-test
{ cpu-l set-cpu-l } "CP-R" "CP L" instruction-parse-test
{ cpu-hl set-cpu-hl } "CP-(RR)" "CP (HL)" instruction-parse-test
{ cpu-a set-cpu-a } "CP-R" "CP A" instruction-parse-test
{ flag-nz? } "RET-F|FF" "RET NZ" instruction-parse-test
{ cpu-bc set-cpu-bc } "POP-RR" "POP BC" instruction-parse-test
{ flag-nz? } "JP-F|FF,NN" "JP NZ,nn" instruction-parse-test
{ } "JP-NN" "JP nn" instruction-parse-test
{ flag-nz? } "CALL-F|FF,NN" "CALL NZ,nn" instruction-parse-test
{ cpu-bc set-cpu-bc } "PUSH-RR" "PUSH BC" instruction-parse-test
{ cpu-a set-cpu-a } "ADD-R,N" "ADD A,n" instruction-parse-test
{ } "RST-0" "RST 0" instruction-parse-test
{ flag-z? } "RET-F|FF" "RET Z" instruction-parse-test
{ } "RET-NN" "RET nn" instruction-parse-test
{ flag-z? } "JP-F|FF,NN" "JP Z,nn" instruction-parse-test
{ } "CALL-NN" "CALL nn" instruction-parse-test
{ cpu-a set-cpu-a } "ADC-R,N" "ADC A,n" instruction-parse-test
{ } "RST-8" "RST 8" instruction-parse-test
{ flag-nc? } "RET-F|FF" "RET NC" instruction-parse-test
{ cpu-de set-cpu-de } "POP-RR" "POP DE" instruction-parse-test
{ flag-nc? } "JP-F|FF,NN" "JP NC,nn" instruction-parse-test
{ cpu-a set-cpu-a } "OUT-(N),R" "OUT (n),A" instruction-parse-test
{ flag-nc? } "CALL-F|FF,NN" "CALL NC,nn" instruction-parse-test
{ cpu-de set-cpu-de } "PUSH-RR" "PUSH DE" instruction-parse-test
{ } "SUB-N" "SUB n" instruction-parse-test
{ } "RST-10H" "RST 10H" instruction-parse-test
{ flag-c? } "RET-F|FF" "RET C" instruction-parse-test
{ flag-c? } "JP-F|FF,NN" "JP C,nn" instruction-parse-test
{ cpu-a set-cpu-a } "IN-R,(N)" "IN A,(n)" instruction-parse-test
{ flag-c? } "CALL-F|FF,NN" "CALL C,nn" instruction-parse-test
{ cpu-a set-cpu-a } "SBC-R,N" "SBC A,n" instruction-parse-test
{ } "RST-18H" "RST 18H" instruction-parse-test
{ flag-po? } "RET-F|FF" "RET PO" instruction-parse-test
{ cpu-hl set-cpu-hl } "POP-RR" "POP HL" instruction-parse-test
{ flag-po? } "JP-F|FF,NN" "JP PO,nn" instruction-parse-test
{ cpu-sp set-cpu-sp cpu-hl set-cpu-hl } "EX-(RR),RR" "EX (SP),HL" instruction-parse-test
{ flag-po? } "CALL-F|FF,NN" "CALL PO,nn" instruction-parse-test
{ cpu-hl set-cpu-hl } "PUSH-RR" "PUSH HL" instruction-parse-test
{ } "AND-N" "AND n" instruction-parse-test
{ } "RST-20H" "RST 20H" instruction-parse-test
{ flag-pe? } "RET-F|FF" "RET PE" instruction-parse-test
{ cpu-hl set-cpu-hl } "JP-(RR)" "JP (HL)" instruction-parse-test
{ flag-pe? } "JP-F|FF,NN" "JP PE,nn" instruction-parse-test
{ cpu-de set-cpu-de cpu-hl set-cpu-hl } "EX-RR,RR" "EX DE,HL" instruction-parse-test
{ flag-pe? } "CALL-F|FF,NN" "CALL PE,nn" instruction-parse-test
{ } "XOR-N" "XOR n" instruction-parse-test
{ } "RST-28H" "RST 28H" instruction-parse-test
{ flag-p? } "RET-F|FF" "RET P" instruction-parse-test
{ cpu-af set-cpu-af } "POP-RR" "POP AF" instruction-parse-test
{ flag-p? } "JP-F|FF,NN" "JP P,nn" instruction-parse-test
{ } "DI" "DI" instruction-parse-test
{ flag-p? } "CALL-F|FF,NN" "CALL P,nn" instruction-parse-test
{ cpu-af set-cpu-af } "PUSH-RR" "PUSH AF" instruction-parse-test
{ } "OR-N" "OR n" instruction-parse-test
{ } "RST-30H" "RST 30H" instruction-parse-test
{ flag-m? } "RET-F|FF" "RET M" instruction-parse-test
{ cpu-sp set-cpu-sp cpu-hl set-cpu-hl } "LD-RR,RR" "LD SP,HL" instruction-parse-test
{ flag-m? } "JP-F|FF,NN" "JP M,nn" instruction-parse-test
{ } "EI" "EI" instruction-parse-test
{ flag-m? } "CALL-F|FF,NN" "CALL M,nn" instruction-parse-test
{ } "CP-N" "CP n" instruction-parse-test
{ } "RST-38H" "RST 38H" instruction-parse-test


! LD-R,(RR) Testing
[ HEX: 42 ] [
  <cpu> HEX: 42 HEX: 2000 pick write-byte 
        HEX: 2000 over set-cpu-af
        dup "LD A,(AF)" instruction-quotations call 
        cpu-a
] unit-test

[ HEX: 42 ] [
  <cpu> HEX: 42 HEX: 2000 pick write-byte 
        HEX: 2000 over set-cpu-bc
        dup "LD A,(BC)" instruction-quotations call 
        cpu-a
] unit-test

[ HEX: 42 ] [
  <cpu> HEX: 42 HEX: 2000 pick write-byte 
        HEX: 2000 over set-cpu-de
        dup "LD A,(DE)" instruction-quotations call 
        cpu-a
] unit-test

[ HEX: 42 ] [
  <cpu> HEX: 42 HEX: 2000 pick write-byte 
        HEX: 2000 over set-cpu-hl
        dup "LD A,(HL)" instruction-quotations call 
        cpu-a
] unit-test

[ HEX: 42 ] [
  <cpu> HEX: 42 HEX: 2000 pick write-byte 
        HEX: 2000 over set-cpu-sp
        dup "LD A,(SP)" instruction-quotations call 
        cpu-a
] unit-test

! LD-RR,NN Testing
[ HEX: 1FF ] [
  <cpu> HEX: 1FF HEX: 2000 pick write-word 
        HEX: 2000 over set-cpu-pc
        dup "LD SP,nn" instruction-quotations call 
        cpu-sp
] unit-test

[ HEX: 1FF ] [
  <cpu> HEX: 1FF HEX: 2000 pick write-word 
        HEX: 2000 over set-cpu-pc
        dup "LD AF,nn" instruction-quotations call 
        cpu-af
] unit-test

[ HEX: 1FF ] [
  <cpu> HEX: 1FF HEX: 2000 pick write-word 
        HEX: 2000 over set-cpu-pc
        dup "LD BC,nn" instruction-quotations call 
        cpu-bc
] unit-test

[ HEX: 1FF ] [
  <cpu> HEX: 1FF HEX: 2000 pick write-word 
        HEX: 2000 over set-cpu-pc
        dup "LD DE,nn" instruction-quotations call 
        cpu-de
] unit-test

[ HEX: 1FF ] [
  <cpu> HEX: 1FF HEX: 2000 pick write-word 
        HEX: 2000 over set-cpu-pc
        dup "LD HL,nn" instruction-quotations call 
        cpu-hl
] unit-test

! Test decrement-sp
[ 2 ] [
  <cpu> [ cpu-sp ] keep
        [ 2 swap decrement-sp ] keep
         cpu-sp -  
] unit-test

! Test save-pc
[ HEX: 2000 ] [
  <cpu> [ HEX: 2000 swap set-cpu-pc ] keep
        [ save-pc ] keep
        [ cpu-sp ] keep
        read-word
] unit-test

! Test push-pc
[ HEX: 2000 ] [
  <cpu> [ HEX: 2000 swap set-cpu-pc ] keep
        [ push-pc ] keep
        pop-pc
] unit-test

! Test some flags
[ t ] [
  <cpu> zero-flag over set-cpu-f 
        flag-z?
] unit-test

[ f ] [
  <cpu> zero-flag over set-cpu-f 
        flag-nz?
] unit-test

[ t ] [
  <cpu> carry-flag over set-cpu-f 
        flag-c?
] unit-test

[ f ] [
  <cpu> carry-flag over set-cpu-f 
        flag-nc?
] unit-test

! Test each instruction
[ emulate-NOP ] [
  <cpu> 0 0 pick cpu-ram set-nth
        dup read-instruction instructions nth 
        car dup -rot execute
] unit-test

[ emulate-LD_BC,nn 1 2 HEX: 0201 ] [
  <cpu> 1 0 pick cpu-ram set-nth
        1 1 pick cpu-ram set-nth
        2 2 pick cpu-ram set-nth
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-c ] keep
        [ cpu-b ] keep
        [ cpu-bc ] keep
        drop
] unit-test

[ emulate-LD_(BC),A 1 ] [
  <cpu> 2 0 pick cpu-ram set-nth
        1 over set-cpu-a
        HEX: 2000 over set-cpu-bc
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ HEX: 2000 swap cpu-ram nth ] keep
        drop
] unit-test

[ emulate-INC_BC HEX: 0001 HEX: 0100 HEX: 0000 ] [
  <cpu> 3 0 pick cpu-ram set-nth
        HEX: 0000 over set-cpu-bc
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-bc ] keep
        3 1 pick cpu-ram set-nth
        HEX: 00FF over set-cpu-bc
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-bc ] keep
        3 2 pick cpu-ram set-nth
        HEX: FFFF over set-cpu-bc
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-bc ] keep
        drop
] unit-test

[ emulate-INC_B HEX: 01 f t f f  
                HEX: 00 t f t f 
                HEX: 80 f t t t 
                HEX: 90 f t t t 
] [
  <cpu> 4 0 pick cpu-ram set-nth
        HEX: 00 over set-cpu-b
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-b ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        4 1 pick cpu-ram set-nth
        HEX: FF over set-cpu-b
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-b ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        4 2 pick cpu-ram set-nth
        HEX: 7F over set-cpu-b
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-b ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        4 3 pick cpu-ram set-nth
        HEX: 8F over set-cpu-b
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-b ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        drop
] unit-test

[ emulate-DEC_B HEX: FF f t t t  
                HEX: 00 t f f f 
                HEX: 7F f t t f 
                HEX: 8F f t t t 
] [
  <cpu> 5 0 pick cpu-ram set-nth
        HEX: 00 over set-cpu-b
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-b ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        5 1 pick cpu-ram set-nth
        HEX: 01 over set-cpu-b
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-b ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        5 2 pick cpu-ram set-nth
        HEX: 80 over set-cpu-b
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-b ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        5 3 pick cpu-ram set-nth
        HEX: 90 over set-cpu-b
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-b ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        drop
] unit-test

[ emulate-LD_B,n 1 HEX: 0100 ] [
  <cpu> 6 0 pick cpu-ram set-nth
        1 1 pick cpu-ram set-nth
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-b ] keep
        [ cpu-bc ] keep
        drop
] unit-test

[ emulate-RLCA BIN: 00000011 1 BIN: 11111110 0 ] [
  <cpu> 7 0 pick cpu-ram set-nth
        19 over set-cpu-f
        BIN: 10000001 over set-cpu-a
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f ] keep
        7 1 pick cpu-ram set-nth
        19 over set-cpu-f
        BIN: 01111111 over set-cpu-a
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f ] keep
        drop
] unit-test

[ emulate-ADD_HL,BC HEX: 04 HEX: 06 HEX: 0406 f f 
                    HEX: 00 HEX: 00 HEX: 0000 f f
                    HEX: 00 HEX: 00 HEX: 0000 t t
                    HEX: 10 HEX: 00 HEX: 1000 f t
                    HEX: 10 HEX: 00 HEX: 1000 f t
] [
  <cpu> 9 0 pick cpu-ram set-nth
        HEX: 0102 over set-cpu-bc
        HEX: 0304 over set-cpu-hl
        236 over set-cpu-f
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-h ] keep
        [ cpu-l ] keep
        [ cpu-hl ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        9 1 pick cpu-ram set-nth
        HEX: 0000 over set-cpu-bc
        HEX: 0000 over set-cpu-hl
        236 over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-h ] keep
        [ cpu-l ] keep
        [ cpu-hl ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        9 2 pick cpu-ram set-nth
        HEX: FFFF over set-cpu-bc
        HEX: 0001 over set-cpu-hl
        236 over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-h ] keep
        [ cpu-l ] keep
        [ cpu-hl ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        9 3 pick cpu-ram set-nth
        HEX: 0FFF over set-cpu-bc
        HEX: 0001 over set-cpu-hl
        236 over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-h ] keep
        [ cpu-l ] keep
        [ cpu-hl ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        9 4 pick cpu-ram set-nth
        HEX: 0001 over set-cpu-bc
        HEX: 0FFF over set-cpu-hl
        236 over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-h ] keep
        [ cpu-l ] keep
        [ cpu-hl ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        drop
] unit-test

[ emulate-LD_A,(BC) HEX: 42 ] [
  <cpu> HEX: 0A 0 pick cpu-ram set-nth
        HEX: 2000 over set-cpu-bc
        HEX: 42 HEX: 2000 pick cpu-ram set-nth 
        HEX: 01 over set-cpu-a
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        drop
] unit-test

[ emulate-DEC_BC HEX: FF HEX: FF HEX: FFFF 
                 HEX: 01 HEX: 02 HEX: 0102
                 HEX: FD HEX: FF HEX: FDFF
] [
  <cpu> HEX: 0B 0 pick cpu-ram set-nth
        HEX: 0000 over set-cpu-bc
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-b ] keep
        [ cpu-c ] keep
        [ cpu-bc ] keep
        HEX: 0B 1 pick cpu-ram set-nth
        HEX: 0103 over set-cpu-bc
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-b ] keep
        [ cpu-c ] keep
        [ cpu-bc ] keep
        HEX: 0B 2 pick cpu-ram set-nth
        HEX: FE00 over set-cpu-bc
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-b ] keep
        [ cpu-c ] keep
        [ cpu-bc ] keep
        drop
] unit-test

[ emulate-INC_C HEX: 01 f t f f  
                HEX: 00 t f t f 
                HEX: 80 f t t t 
                HEX: 90 f t t t 
] [
  <cpu> HEX: 0C 0 pick cpu-ram set-nth
        HEX: 00 over set-cpu-c
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-c ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        HEX: 0C 1 pick cpu-ram set-nth
        HEX: FF over set-cpu-c
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-c ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        HEX: 0C 2 pick cpu-ram set-nth
        HEX: 7F over set-cpu-c
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-c ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        HEX: 0C 3 pick cpu-ram set-nth
        HEX: 8F over set-cpu-c
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-c ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        drop
] unit-test

[ emulate-DEC_C HEX: FF f t t t  
                HEX: 00 t f f f 
                HEX: 7F f t t f 
                HEX: 8F f t t t 
] [
  <cpu> HEX: 0D 0 pick cpu-ram set-nth
        HEX: 00 over set-cpu-c
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-c ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        HEX: 0D 1 pick cpu-ram set-nth
        HEX: 01 over set-cpu-c
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-c ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        HEX: 0D 2 pick cpu-ram set-nth
        HEX: 80 over set-cpu-c
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-c ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        HEX: 0D 3 pick cpu-ram set-nth
        HEX: 90 over set-cpu-c
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-c ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        drop
] unit-test

[ emulate-LD_C,n 1 HEX: 0001 ] [
  <cpu> HEX: 0E 0 pick cpu-ram set-nth
        1 1 pick cpu-ram set-nth
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-c ] keep
        [ cpu-bc ] keep
        drop
] unit-test

[ emulate-RRCA BIN: 11000000 1 BIN: 01111111 0 ] [
  <cpu> HEX: 0F 0 pick cpu-ram set-nth
        19 over set-cpu-f
        BIN: 10000001 over set-cpu-a
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f ] keep
        HEX: 0F 1 pick cpu-ram set-nth
        19 over set-cpu-f
        BIN: 11111110 over set-cpu-a
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f ] keep
        drop
] unit-test

[ emulate-LD_DE,nn 1 2 HEX: 0201 ] [
  <cpu> HEX: 11 0 pick cpu-ram set-nth
        1 1 pick cpu-ram set-nth
        2 2 pick cpu-ram set-nth
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-e ] keep
        [ cpu-d ] keep
        [ cpu-de ] keep
        drop
] unit-test

[ emulate-LD_(DE),A 1 ] [
  <cpu> HEX: 12 0 pick cpu-ram set-nth
        1 over set-cpu-a
        HEX: 2000 over set-cpu-de
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ HEX: 2000 swap cpu-ram nth ] keep
        drop
] unit-test

[ emulate-INC_DE HEX: 0001 HEX: 0100 HEX: 0000 ] [
  <cpu> HEX: 13 0 pick cpu-ram set-nth
        HEX: 0000 over set-cpu-de
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-de ] keep
        HEX: 13 1 pick cpu-ram set-nth
        HEX: 00FF over set-cpu-de
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-de ] keep
        HEX: 13 2 pick cpu-ram set-nth
        HEX: FFFF over set-cpu-de
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-de ] keep
        drop
] unit-test

[ emulate-INC_D HEX: 01 f t f f  
                HEX: 00 t f t f 
                HEX: 80 f t t t 
                HEX: 90 f t t t 
] [
  <cpu> HEX: 14 0 pick cpu-ram set-nth
        HEX: 00 over set-cpu-d
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-d ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        HEX: 14 1 pick cpu-ram set-nth
        HEX: FF over set-cpu-d
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-d ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        HEX: 14 2 pick cpu-ram set-nth
        HEX: 7F over set-cpu-d
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-d ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        HEX: 14 3 pick cpu-ram set-nth
        HEX: 8F over set-cpu-d
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-d ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        drop
] unit-test

[ emulate-DEC_D HEX: FF f t t t  
                HEX: 00 t f f f 
                HEX: 7F f t t f 
                HEX: 8F f t t t 
] [
  <cpu> HEX: 15 0 pick cpu-ram set-nth
        HEX: 00 over set-cpu-d
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-d ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        HEX: 15 1 pick cpu-ram set-nth
        HEX: 01 over set-cpu-d
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-d ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        HEX: 15 2 pick cpu-ram set-nth
        HEX: 80 over set-cpu-d
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-d ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        HEX: 15 3 pick cpu-ram set-nth
        HEX: 90 over set-cpu-d
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-d ] keep
        [ flag-z? ] keep
        [ flag-nz? ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        drop
] unit-test

[ emulate-LD_D,n 1 HEX: 0100 ] [
  <cpu> HEX: 16 0 pick cpu-ram set-nth
        1 1 pick cpu-ram set-nth
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-d ] keep
        [ cpu-de ] keep
        drop
] unit-test

[ emulate-RLA BIN: 11111110 0 BIN: 00000011 1 ] [
  <cpu> HEX: 17 0 pick cpu-ram set-nth
        0 over set-cpu-f
        BIN: 01111111 over set-cpu-a
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f ] keep
        HEX: 17 1 pick cpu-ram set-nth
        19 over set-cpu-f
        BIN: 10000001 over set-cpu-a
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f ] keep
        drop
] unit-test

[ emulate-ADD_A,B HEX: 01 HEX: 01  f f f
                  HEX: 00 HEX: 01  t f t
                  HEX: A0 HEX: 50  f t f
] [
  <cpu> HEX: 80 0 pick cpu-ram set-nth
        HEX: 00 over set-cpu-a
        HEX: 01 over set-cpu-b
        0 over set-cpu-f
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-b ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
        HEX: 80 1 pick cpu-ram set-nth
        HEX: FF over set-cpu-a
        HEX: 01 over set-cpu-b
        0 over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-b ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
        HEX: 80 2 pick cpu-ram set-nth
        HEX: 50 over set-cpu-a
        HEX: 50 over set-cpu-b
        0 over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep 
        [ cpu-a ] keep
        [ cpu-b ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
         drop
] unit-test

[ emulate-ADD_A,C HEX: 01 HEX: 01  f f f
                  HEX: 00 HEX: 01  t f t
                  HEX: A0 HEX: 50  f t f
] [
  <cpu> HEX: 81 0 pick cpu-ram set-nth
        HEX: 00 over set-cpu-a
        HEX: 01 over set-cpu-c
        0 over set-cpu-f
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-c ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
        HEX: 81 1 pick cpu-ram set-nth
        HEX: FF over set-cpu-a
        HEX: 01 over set-cpu-c
        0 over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-c ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
        HEX: 81 2 pick cpu-ram set-nth
        HEX: 50 over set-cpu-a
        HEX: 50 over set-cpu-c
        0 over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep 
        [ cpu-a ] keep
        [ cpu-c ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
         drop
] unit-test

[ emulate-ADD_A,A HEX: 00 f f t
                  HEX: FE t t f
                  HEX: 00 t f t
] [
  <cpu> HEX: 87 0 pick cpu-ram set-nth
        HEX: 00 over set-cpu-a
        0 over set-cpu-f
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
        HEX: 87 1 pick cpu-ram set-nth
        HEX: FF over set-cpu-a
        0 over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
        HEX: 87 2 pick cpu-ram set-nth
        HEX: 80 over set-cpu-a
        0 over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep 
        [ cpu-a ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
         drop
] unit-test


[ emulate-SUB_n HEX: FF f t t t
                HEX: 00 t f f f
                HEX: DA f t f f
                HEX: 7F f f f t
] [
  <cpu> HEX: D6 0 pick cpu-ram set-nth
        HEX: 01 1 pick cpu-ram set-nth
        HEX: 00 over set-cpu-a
        0 over set-cpu-f
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        HEX: D6 2 pick cpu-ram set-nth
        HEX: 02 3 pick cpu-ram set-nth
        HEX: 02 over set-cpu-a
        0 over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        HEX: D6 4 pick cpu-ram set-nth
        HEX: 25 5 pick cpu-ram set-nth
        HEX: FF over set-cpu-a
        0 over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        HEX: D6 6 pick cpu-ram set-nth
        HEX: 01 7 pick cpu-ram set-nth
        HEX: 80 over set-cpu-a
        0 over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
         drop
] unit-test

[ emulate-SBC_A,n HEX: FE f t t t
                HEX: FF f t t t
                HEX: D9 f t f f
                HEX: 7E f f f t
] [
  <cpu> HEX: DE 0 pick cpu-ram set-nth
        HEX: 01 1 pick cpu-ram set-nth
        HEX: 00 over set-cpu-a
        HEX: FF over set-cpu-f
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        HEX: DE 2 pick cpu-ram set-nth
        HEX: 02 3 pick cpu-ram set-nth
        HEX: 02 over set-cpu-a
        HEX: FF over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        HEX: DE 4 pick cpu-ram set-nth
        HEX: 25 5 pick cpu-ram set-nth
        HEX: FF over set-cpu-a
        HEX: FF over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
        HEX: DE 6 pick cpu-ram set-nth
        HEX: 01 7 pick cpu-ram set-nth
        HEX: 80 over set-cpu-a
        HEX: FF over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        [ cpu-f zero-flag bitand 0 = not ] keep
        [ cpu-f sign-flag bitand 0 = not ] keep
        [ cpu-f carry-flag bitand 0 = not ] keep
        [ cpu-f half-carry-flag bitand 0 = not ] keep
         drop
] unit-test

[ emulate-EX_(SP),HL HEX: 41 HEX: 40 HEX: 5051 ] [
  <cpu> HEX: E3 0 pick cpu-ram set-nth
        HEX: 2021 over set-cpu-sp
        HEX: 4041 over set-cpu-hl
        HEX: 51 HEX: 2021 pick cpu-ram set-nth
        HEX: 50 HEX: 2022 pick cpu-ram set-nth
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ HEX: 2021 swap cpu-ram nth ] keep
        [ HEX: 2022 swap cpu-ram nth ] keep
	[ cpu-hl ] keep
        drop
] unit-test

[ emulate-ADD_A,(HL) HEX: 51
] [
  <cpu> HEX: 86 0 pick cpu-ram set-nth
        HEX: 01 over set-cpu-a
        HEX: 2001 over set-cpu-hl
	HEX: 50 HEX: 2001 pick cpu-ram set-nth
        236 over set-cpu-f
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-a ] keep
        drop
] unit-test

[ emulate-SCF 1 1 t
] [
  <cpu> HEX: 37 0 pick cpu-ram set-nth
        carry-flag over set-cpu-f
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        [ cpu-f ] keep
	HEX: 37 1 pick cpu-ram set-nth
        0 over set-cpu-f
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        [ cpu-f ] keep	
        drop
	256 [ <cpu> [ set-cpu-f ] keep [ emulate-SCF ] keep cpu-f carry-flag bitand 0 = not ] map [ ] all?
] unit-test

[ emulate-INC_(HL) HEX: 00 
                   HEX: 01 
                   HEX: 80 ] [
  <cpu> HEX: 34 0 pick cpu-ram set-nth
        HEX: 3500 over set-cpu-hl
	HEX: FF HEX: 3500 pick cpu-ram set-nth
        [ read-instruction instructions nth car dup ] keep 
        [ swap execute ] keep
        HEX: 3500 over cpu-ram nth swap
	HEX: 34 1 pick cpu-ram set-nth
        HEX: 3500 over set-cpu-hl
	HEX: 00 HEX: 3500 pick cpu-ram set-nth
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        HEX: 3500 over cpu-ram nth swap
	HEX: 34 2 pick cpu-ram set-nth
        HEX: 3500 over set-cpu-hl 
	HEX: 7F HEX: 3500 pick cpu-ram set-nth
        [ read-instruction instructions nth car ] keep 
        [ swap execute ] keep
        HEX: 3500 over cpu-ram nth swap
	drop
] unit-test
