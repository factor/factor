! Copyright (C) 2006 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators fry io
io.encodings.binary io.files io.pathnames kernel lexer make math
math.parser namespaces parser peg peg.ebnf peg.parsers
quotations sequences sequences.deep words multiline splitting ;
IN: cpu.8080.emulator

TUPLE: cpu b c d e f h l a pc sp halted? last-interrupt cycles
ram ;

GENERIC: reset        ( cpu            -- )
GENERIC: update-video ( value addr cpu -- )
GENERIC: read-port    ( port cpu       -- byte )
GENERIC: write-port   ( value port cpu -- )

M: cpu update-video
    3drop ;

M: cpu read-port
    ! Read a byte from the hardware port. 'port' should
    ! be an 8-bit value.
    2drop 0 ;

M: cpu write-port
    ! Write a byte to the hardware port, where 'port' is
    ! an 8-bit value.
    3drop ;

CONSTANT: carry-flag        0x01
CONSTANT: parity-flag       0x04
CONSTANT: half-carry-flag   0x10
CONSTANT: interrupt-flag    0x20
CONSTANT: zero-flag         0x40
CONSTANT: sign-flag         0x80

: >word< ( word -- byte byte )
    ! Explode a word into its two 8 bit values.
    dup 0xFF bitand swap -8 shift 0xFF bitand swap ;

: af>> ( cpu -- word )
    ! Return the 16-bit pseudo register AF.
    [ a>> 8 shift ] keep f>> bitor ;

: af<< ( value cpu -- )
    ! Set the value of the 16-bit pseudo register AF
    [ >word< ] dip swap >>f swap >>a drop ;

: bc>> ( cpu -- word )
    ! Return the 16-bit pseudo register BC.
    [ b>> 8 shift ] keep c>> bitor ;

: bc<< ( value cpu -- )
    ! Set the value of the 16-bit pseudo register BC
    [ >word< ] dip swap >>c swap >>b drop ;

: de>> ( cpu -- word )
    ! Return the 16-bit pseudo register DE.
    [ d>> 8 shift ] keep e>> bitor ;

: de<< ( value cpu -- )
    ! Set the value of the 16-bit pseudo register DE
    [ >word< ] dip swap >>e swap >>d drop ;

: hl>> ( cpu -- word )
    ! Return the 16-bit pseudo register HL.
    [ h>> 8 shift ] keep l>> bitor ;

: hl<< ( value cpu -- )
    ! Set the value of the 16-bit pseudo register HL
    [ >word< ] dip swap >>l swap >>h drop ;

: flag-set? ( flag cpu -- bool )
    f>> bitand 0 = not ;

: flag-clear? ( flag cpu -- bool )
    f>> bitand 0 = ;

: flag-nz? ( cpu -- bool )
    ! Test flag status
    f>> zero-flag bitand 0 = ;

: flag-z? ( cpu -- bool )
    ! Test flag status
    f>> zero-flag bitand 0 = not ;

: flag-nc? ( cpu -- bool )
    ! Test flag status
    f>> carry-flag bitand 0 = ;

: flag-c? ( cpu -- bool )
    ! Test flag status
    f>> carry-flag bitand 0 = not ;

: flag-po? ( cpu -- bool )
    ! Test flag status
    f>> parity-flag bitand 0 =  ;

: flag-pe? ( cpu -- bool )
    ! Test flag status
    f>> parity-flag bitand 0 = not ;

: flag-p? ( cpu -- bool )
    ! Test flag status
    f>> sign-flag bitand 0 = ;

: flag-m? ( cpu -- bool )
    ! Test flag status
    f>> sign-flag bitand 0 = not ;

: read-byte ( addr cpu -- byte )
    ! Read one byte from memory at the specified address.
    ! The address is 16-bit, but if a value greater than
    ! 0xFFFF is provided then return a default value.
    over 0xFFFF <= [
      ram>> nth
    ] [
      2drop 0xFF
    ] if ;

: read-word ( addr cpu -- word )
    ! Read a 16-bit word from memory at the specified address.
    ! The address is 16-bit, but if a value greater than
    ! 0xFFFF is provided then return a default value.
    [ read-byte ] 2keep [ 1 + ] dip read-byte 8 shift bitor ;

: next-byte ( cpu -- byte )
    ! Return the value of the byte at PC, and increment PC.
    {
      [ pc>> ]
      [ read-byte ]
      [ pc>> 1 + ]
      [ pc<< ]
    } cleave ;

: next-word ( cpu -- word )
    ! Return the value of the word at PC, and increment PC.
    [ pc>> ] keep
    [ read-word ] keep
    [ pc>> 2 + ] keep
    pc<< ;


: write-byte ( value addr cpu -- )
    ! Write a byte to the specified memory address.
    over dup 0x2000 < swap 0xFFFF > or [
      3drop
    ] [
      3dup ram>> set-nth
      update-video
    ] if ;


: write-word ( value addr cpu -- )
    ! Write a 16-bit word to the specified memory address.
    [ >word< ] 2dip [ write-byte ] 2keep [ 1 + ] dip write-byte ;

: cpu-a-bitand ( quot cpu -- )
    ! A &= quot call
    [ a>> swap call bitand ] keep a<< ; inline

: cpu-a-bitor ( quot cpu -- )
    ! A |= quot call
    [ a>> swap call bitor ] keep a<< ; inline

: cpu-a-bitxor ( quot cpu -- )
    ! A ^= quot call
    [ a>> swap call bitxor ] keep a<< ; inline

: cpu-a-bitxor= ( value cpu -- )
    ! cpu-a ^= value
    [ a>> bitxor ] keep a<< ;

: cpu-f-bitand ( quot cpu -- )
    ! F &= quot call
    [ f>> swap call bitand ] keep f<< ; inline

: cpu-f-bitor ( quot cpu -- )
    ! F |= quot call
    [ f>> swap call bitor ] keep f<< ; inline

: cpu-f-bitxor ( quot cpu -- )
    ! F |= quot call
    [ f>> swap call bitxor ] keep f<< ; inline

: cpu-f-bitor= ( value cpu -- )
    ! cpu-f |= value
    [ f>> bitor ] keep f<< ;

: cpu-f-bitand= ( value cpu -- )
    ! cpu-f &= value
    [ f>> bitand ] keep f<< ;

: cpu-f-bitxor= ( value cpu -- )
    ! cpu-f ^= value
    [ f>> bitxor ] keep f<< ;

: set-flag ( cpu flag -- )
    swap cpu-f-bitor= ;

: clear-flag ( cpu flag -- )
    bitnot 0xFF bitand swap cpu-f-bitand= ;

: update-zero-flag ( result cpu -- )
    ! If the result of an instruction has the value 0, this
    ! flag is set, otherwise it is reset.
    swap 0xFF bitand 0 =
    [ zero-flag set-flag ]
    [ zero-flag clear-flag ] if ;

: update-sign-flag ( result cpu -- )
    ! If the most significant bit of the result
    ! has the value 1 then the flag is set, otherwise
    ! it is reset.
    swap 0x80 bitand 0 =
    [ sign-flag clear-flag ]
    [ sign-flag set-flag ] if ;

: update-parity-flag ( result cpu -- )
    ! If the modulo 2 sum of the bits of the result
    ! is 0, (ie. if the result has even parity) this flag
    ! is set, otherwise it is reset.
    swap 0xFF bitand 2 mod 0 =
    [ parity-flag set-flag ]
    [ parity-flag clear-flag ] if ;

: update-carry-flag ( result cpu -- )
    ! If the instruction resulted in a carry (from addition)
    ! or a borrow (from subtraction or a comparison) out of the
    ! higher order bit, this flag is set, otherwise it is reset.
    swap dup 0x100 >= swap 0 < or
    [ carry-flag set-flag ]
    [ carry-flag clear-flag ] if ;

: update-half-carry-flag ( original change-by result cpu -- )
    ! If the instruction caused a carry out of bit 3 and into bit 4 of the
    ! resulting value, the half carry flag is set, otherwise it is reset.
    ! The 'original' is the original value of the register being changed.
    ! 'change-by' is the amount it is being added or decremented by.
    ! 'result' is the result of that change.
    [ bitxor bitxor 0x10 bitand 0 = not ] dip swap
    [ half-carry-flag set-flag ]
    [ half-carry-flag clear-flag ] if ;

: update-flags ( result cpu -- )
    {
        [ update-carry-flag ]
        [ update-parity-flag ]
        [ update-sign-flag ]
        [ update-zero-flag ]
    } 2cleave ;

: update-flags-no-carry ( result cpu -- )
    [ update-parity-flag ]
    [ update-sign-flag ]
    [ update-zero-flag ] 2tri ;

: add-byte ( lhs rhs cpu -- result )
    ! Add rhs to lhs
    [ 2dup + ] dip
    [ update-flags ] 2keep
    [ update-half-carry-flag ] 2keep
    drop 0xFF bitand ;

: add-carry ( change-by result cpu -- change-by result )
    ! Add the effect of the carry flag to the result
    flag-c? [ 1 + [ 1 + ] dip ] when ;

: add-byte-with-carry ( lhs rhs cpu -- result )
    ! Add rhs to lhs plus carry.
    [ 2dup + ] dip
    [ add-carry ] keep
    [ update-flags ] 2keep
    [ update-half-carry-flag ] 2keep
    drop 0xFF bitand ;

: sub-carry ( change-by result cpu -- change-by result )
    ! Subtract the effect of the carry flag from the result
    flag-c? [ 1 - [ 1 - ] dip  ] when ;

: sub-byte ( lhs rhs cpu -- result )
    ! Subtract rhs from lhs
    [ 2dup - ] dip
    [ update-flags ] 2keep
    [ update-half-carry-flag ] 2keep
    drop 0xFF bitand ;

: sub-byte-with-carry ( lhs rhs cpu -- result )
    ! Subtract rhs from lhs and take carry into account
    [ 2dup - ] dip
    [ sub-carry ] keep
    [ update-flags ] 2keep
    [ update-half-carry-flag ] 2keep
    drop 0xFF bitand ;

: inc-byte ( byte cpu -- result )
    ! Increment byte by one. Note that carry flag is not affected
    ! by this operation.
    [ 1 2dup + ] dip
    [ update-flags-no-carry ] 2keep
    [ update-half-carry-flag ] 2keep
    drop 0xFF bitand ;

: dec-byte ( byte cpu -- result )
    ! Decrement byte by one. Note that carry flag is not affected
    ! by this operation.
    [ 1 2dup - ] dip
    [ update-flags-no-carry ] 2keep
    [ update-half-carry-flag ] 2keep
    drop 0xFF bitand ;

: inc-word ( w cpu -- w )
    ! Increment word by one. Note that no flags are modified.
    drop 1 + 0xFFFF bitand ;

: dec-word ( w cpu -- w )
    ! Decrement word by one. Note that no flags are modified.
    drop 1 - 0xFFFF bitand ;

: add-word ( lhs rhs cpu -- result )
    ! Add rhs to lhs. Note that only the carry flag is modified
    ! and only if there is a carry out of the double precision add.
    [ + ] dip over 0xFFFF > [ carry-flag set-flag ] [ drop ] if 0xFFFF bitand ;

: bit3or ( lhs rhs -- 0|1 )
    ! bitor bit 3 of the two numbers on the stack
    [ 0b00001000 bitand -3 shift ] bi@ bitor ;

: and-byte ( lhs rhs cpu -- result )
    ! Logically and rhs to lhs. The carry flag is cleared and
    ! the half carry is set to the ORing of bits 3 of the operands.
    [ drop bit3or ] 3keep ! bit3or lhs rhs cpu
    [ bitand ] dip [ update-flags ] 2keep
    [ carry-flag clear-flag ] keep
    rot 0 = [ half-carry-flag set-flag ] [ half-carry-flag clear-flag ] if
    0xFF bitand ;

: xor-byte ( lhs rhs cpu -- result )
    ! Logically xor rhs to lhs. The carry and half-carry flags are cleared.
    [ bitxor ] dip [ update-flags ] 2keep
    half-carry-flag carry-flag bitor clear-flag
    0xFF bitand ;

: or-byte ( lhs rhs cpu -- result )
    ! Logically or rhs to lhs. The carry and half-carry flags are cleared.
    [ bitor ] dip [ update-flags ] 2keep
    half-carry-flag carry-flag bitor clear-flag
    0xFF bitand ;

: decrement-sp ( n cpu -- )
    ! Decrement the stackpointer by n.
    [ sp>> swap - ] keep sp<< ;

: save-pc ( cpu -- )
    ! Save the value of the PC on the stack.
    [ pc>> ] [ sp>> ] [ write-word ] tri ;

: push-pc ( cpu -- )
    ! Push the value of the PC on the stack.
    [ 2 swap decrement-sp ] [ save-pc ] bi ;

: pop-pc ( cpu -- pc )
    ! Pop the value of the PC off the stack.
    [ sp>> ] [ read-word ] [ -2 swap decrement-sp ] tri ;

: push-sp ( value cpu -- )
    [ 2 swap decrement-sp ] [ sp>> ] [ write-word ] tri ;

: pop-sp ( cpu -- value )
    [ sp>> ] [ read-word ] [ -2 swap decrement-sp ] tri ;

: call-sub ( addr cpu -- )
    ! Call the address as a subroutine.
    dup push-pc
    [ 0xFFFF bitand ] dip pc<< ;

: ret-from-sub ( cpu -- )
    [ pop-pc ] keep pc<< ;

: interrupt ( number cpu -- )
    ! Perform a hardware interrupt
!  "***Interrupt: " write over >hex print
    dup f>> interrupt-flag bitand 0 = not [
      dup push-pc
      pc<<
    ] [
      2drop
    ] if ;

: inc-cycles ( n cpu -- )
    ! Increment the number of cpu cycles
    [ cycles>> + ] keep cycles<< ;

: instruction-cycles ( -- vector )
    ! Return a 256 element vector containing the cycles for
    ! each opcode in the 8080 instruction set.
    \ instruction-cycles get-global [
      256 f <array> \ instruction-cycles set-global
    ] unless
    \ instruction-cycles get-global ;

: not-implemented ( cpu -- )
    drop ;

: instructions ( -- vector )
    ! Return a 256 element vector containing the emulation words for
    ! each opcode in the 8080 instruction set.
    \ instructions get-global [
      256 [ not-implemented ] <array> \ instructions set-global
    ] unless
    \ instructions get-global ;

: set-instruction ( quot n -- )
    instructions set-nth ;

M: cpu reset
    ! Reset the CPU to its poweron state
    0 >>b
    0 >>c
    0 >>d
    0 >>e
    0 >>h
    0 >>l
    0 >>a
    0 >>f
    0 >>pc
    0xF000 >>sp
    0xFFFF 0 <array> >>ram
    f >>halted?
    0x10 >>last-interrupt
    0 >>cycles
    drop ;

: <cpu> ( -- cpu ) cpu new dup reset ;

: (load-rom) ( n ram -- )
    read1 [ ! n ram ch
        -rot [ set-nth ] 2keep [ 1 + ] dip (load-rom)
    ] [
        2drop
    ] if* ;

    ! Reads the ROM from stdin and stores it in ROM from
    ! offset n.
: load-rom ( filename cpu -- )
    ! Load the contents of the file into ROM.
    ! (address 0x0000-0x1FFF).
    ram>> swap binary [
        0 swap (load-rom)
    ] with-file-reader ;

SYMBOL: rom-root

: rom-dir ( -- string )
    rom-root get [
        "~/roms" [ file-exists? ] verify
    ] unless* ;

: load-rom* ( seq cpu -- )
    ! 'seq' is an array of arrays. Each array contains
    ! an address and filename of a ROM file. The ROM
    ! file will be loaded at the specified address. This
    ! file path shoul dbe relative to the '/roms' resource path.
    rom-dir [
        ram>> [
            swap first2 rom-dir prepend-path binary [
                swap (load-rom)
            ] with-file-reader
        ] curry each
    ] [
        !
        ! the ROM files.
        "Set 'rom-root' to the path containing the root of the 8080 ROM files." throw
    ] if ;

: read-instruction ( cpu -- word )
    ! Read the next instruction from the cpu's program
    ! counter, and increment the program counter.
    [ pc>> ] keep ! pc cpu
    [ over 1 + swap pc<< ] keep
    read-byte ;

ERROR: undefined-8080-opcode n ;

: get-cycles ( n -- opcode )
    ! Returns the cycles for the given instruction value.
    ! If the opcode is not defined throw an error.
    dup instruction-cycles nth [
        nip
    ] [
        undefined-8080-opcode
    ] if* ;

: process-interrupts ( cpu -- )
    ! Process any hardware interrupts
    [ cycles>> ] keep
    over 16667 < [
        2drop
    ] [
        [ [ 16667 - ] dip cycles<< ] keep
        dup last-interrupt>> 0x10 = [
            0x08 >>last-interrupt 0x08 swap interrupt
        ] [
            0x10 >>last-interrupt 0x10 swap interrupt
        ] if
    ] if ;

: peek-instruction ( cpu -- word )
    ! Return the next instruction from the cpu's program
    ! counter, but don't increment the counter.
    [ pc>> ] keep read-byte instructions nth first ;

: cpu. ( cpu -- )
    {
        [ " PC: " write pc>> >hex 4 CHAR: \s pad-head write ]
        [ " B: " write b>> >hex 2 CHAR: \s pad-head write ]
        [ " C: " write c>> >hex 2 CHAR: \s pad-head write ]
        [ " D: " write d>> >hex 2 CHAR: \s pad-head write ]
        [ " E: " write e>> >hex 2 CHAR: \s pad-head write ]
        [ " F: " write f>> >hex 2 CHAR: \s pad-head write ]
        [ " H: " write h>> >hex 2 CHAR: \s pad-head write ]
        [ " L: " write l>> >hex 2 CHAR: \s pad-head write ]
        [ " A: " write a>> >hex 2 CHAR: \s pad-head write ]
        [ " SP: " write sp>> >hex 4 CHAR: \s pad-head write ]
        [ " cycles: " write cycles>> number>string 5 CHAR: \s pad-head write ]
        [ bl peek-instruction name>> write bl ]
        [ nl drop ]
    } cleave ;

: cpu*. ( cpu -- )
    {
        [ " PC: " write pc>> >hex 4 CHAR: \s pad-head write ]
        [ " B: " write b>> >hex 2 CHAR: \s pad-head write ]
        [ " C: " write c>> >hex 2 CHAR: \s pad-head write ]
        [ " D: " write d>> >hex 2 CHAR: \s pad-head write ]
        [ " E: " write e>> >hex 2 CHAR: \s pad-head write ]
        [ " F: " write f>> >hex 2 CHAR: \s pad-head write ]
        [ " H: " write h>> >hex 2 CHAR: \s pad-head write ]
        [ " L: " write l>> >hex 2 CHAR: \s pad-head write ]
        [ " A: " write a>> >hex 2 CHAR: \s pad-head write ]
        [ " SP: " write sp>> >hex 4 CHAR: \s pad-head write ]
        [ " cycles: " write cycles>> number>string 5 CHAR: \s pad-head write ]
        [ nl drop ]
    } cleave ;

: register-lookup ( string -- vector )
    ! Given a string containing a register name, return a vector
    ! where the 1st item is the getter and the 2nd is the setter
    ! for that register.
    H{
        { "A"  { a>>  a<<  } }
        { "B"  { b>>  b<<  } }
        { "C"  { c>>  c<<  } }
        { "D"  { d>>  d<<  } }
        { "E"  { e>>  e<<  } }
        { "H"  { h>>  h<<  } }
        { "L"  { l>>  l<<  } }
        { "AF" { af>> af<< } }
        { "BC" { bc>> bc<< } }
        { "DE" { de>> de<< } }
        { "HL" { hl>> hl<< } }
        { "SP" { sp>> sp<< } }
    } at ;


: flag-lookup ( string -- vector )
    ! Given a string containing a flag name, return a vector
    ! where the 1st item is a word that tests that flag.
    H{
        { "NZ" { flag-nz?  } }
        { "NC" { flag-nc?  } }
        { "PO" { flag-po?  } }
        { "PE" { flag-pe?  } }
        { "Z"  { flag-z?  } }
        { "C"  { flag-c? } }
        { "P"  { flag-p?  } }
        { "M"  { flag-m?  } }
    } at ;

SYMBOLS: $1 $2 $3 $4 ;

: replace-patterns ( vector tree -- tree )
    [
        {
            { $1 [ first ] }
            { $2 [ second ] }
            { $3 [ third ] }
            { $4 [ fourth ] }
            [ nip ]
        } case
    ] with deep-map ;

: (emulate-RST) ( n cpu -- )
    ! RST nn
    [ sp>> 2 - dup ] keep ! sp sp cpu
    [ sp<< ] keep ! sp cpu
    [ pc>> ] keep ! sp pc cpu
    swapd [ write-word ] keep ! cpu
    [ 8 * ] dip pc<< ;

: (emulate-CALL) ( cpu -- )
    ! 205 - CALL nn
    [ next-word 0xFFFF bitand ] keep ! addr cpu
    [ sp>> 2 - dup ] keep ! addr sp sp cpu
    [ sp<< ] keep ! addr sp cpu
    [ pc>> ] keep ! addr sp pc cpu
    swapd [ write-word ] keep ! addr cpu
    pc<< ;

: (emulate-RLCA) ( cpu -- )
    ! The content of the accumulator is rotated left
    ! one position. The low order bit and the carry flag
    ! are both set to the value shifd out of the high
    ! order bit position. Only the carry flag is affected.
    [ a>> -7 shift ] keep
    over 0 = [ dup carry-flag clear-flag ] [ dup carry-flag set-flag ] if
    [ a>> 1 shift 0xFF bitand ] keep
    [ bitor ] dip a<< ;

: (emulate-RRCA) ( cpu -- )
    ! The content of the accumulator is rotated right
    ! one position. The high order bit and the carry flag
    ! are both set to the value shifd out of the low
    ! order bit position. Only the carry flag is affected.
    [ a>> 1 bitand 7 shift ] keep
    over 0 = [ dup carry-flag clear-flag ] [ dup carry-flag set-flag ] if
    [ a>> 254 bitand -1 shift ] keep
    [ bitor ] dip a<< ;

: (emulate-RLA) ( cpu -- )
    ! The content of the accumulator is rotated left
    ! one position through the carry flag. The low
    ! order bit is set equal to the carry flag and
    ! the carry flag is set to the value shifd out
    ! of the high order bit. Only the carry flag is
    ! affected.
    [ carry-flag swap flag-set? [ 1 ] [ 0 ] if ] keep
    [ a>> 127 bitand 7 shift ] keep
    dup a>> 128 bitand 0 = [ dup carry-flag clear-flag ] [ dup carry-flag set-flag ] if
    [ bitor ] dip a<< ;

: (emulate-RRA) ( cpu -- )
    ! The content of the accumulator is rotated right
    ! one position through the carry flag. The high order
    ! bit is set to the carry flag and the carry flag is
    ! set to the value shifd out of the low order bit.
    ! Only the carry flag is affected.
    [ carry-flag swap flag-set? [ 0b10000000 ] [ 0 ] if ] keep
    [ a>> 254 bitand -1 shift ] keep
    dup a>> 1 bitand 0 = [ dup carry-flag clear-flag ] [ dup carry-flag set-flag ] if
    [ bitor ] dip a<< ;

: (emulate-CPL) ( cpu -- )
    ! The contents of the accumulator are complemented
    ! (zero bits become one, one bits becomes zero).
    ! No flags are affected.
    0xFF swap cpu-a-bitxor= ;

: (emulate-DAA) ( cpu -- )
    ! The eight bit number in the accumulator is
    ! adjusted to form two four-bit binary-coded-decimal
    ! digits.
    [
        dup half-carry-flag swap flag-set? swap
        a>> 0b1111 bitand 9 > or [ 6 ] [ 0 ] if
    ] keep
    [ a>> + ] keep
    [ update-flags ] 2keep
    [ swap 0xFF bitand swap a<< ] keep
    [
        dup carry-flag swap flag-set? swap
        a>> -4 shift 0b1111 bitand 9 > or [ 96 ] [ 0 ] if
    ] keep
    [ a>> + ] keep
    [ update-flags ] 2keep
    swap 0xFF bitand swap a<< ;

: patterns ( -- hashtable )
    ! table of code quotation patterns for each type of instruction.
    H{
        { "NOP" [ drop ] }
        { "RET-NN" [ ret-from-sub ] }
        { "RST-0" [ 0 swap (emulate-RST) ] }
        { "RST-8" [ 8 swap (emulate-RST) ] }
        { "RST-10H" [ 0x10 swap (emulate-RST) ] }
        { "RST-18H" [ 0x18 swap (emulate-RST) ] }
        { "RST-20H" [ 0x20 swap (emulate-RST) ] }
        { "RST-28H" [ 0x28 swap (emulate-RST) ] }
        { "RST-30H" [ 0x30 swap (emulate-RST) ] }
        { "RST-38H" [ 0x38 swap (emulate-RST) ] }
        { "RET-F|FF" [ dup $1 [ 6 over inc-cycles ret-from-sub ] [ drop ] if ] }
        { "CP-N" [ [ a>> ] keep [ next-byte ] keep sub-byte drop ] }
        { "CP-R" [ [ a>> ] keep [ $1 ] keep sub-byte drop ] }
        { "CP-(RR)" [ [ a>> ] keep [ $1 ] keep [ read-byte ] keep sub-byte drop ] }
        { "OR-N" [ [ a>> ] keep [ next-byte ] keep [ or-byte ] keep a<< ] }
        { "OR-R" [ [ a>> ] keep [ $1 ] keep [ or-byte ] keep a<< ] }
        { "OR-(RR)" [ [ a>> ] keep [ $1 ] keep [ read-byte ] keep [ or-byte ] keep a<< ] }
        { "XOR-N" [ [ a>> ] keep [ next-byte ] keep [ xor-byte ] keep a<< ] }
        { "XOR-R" [ [ a>> ] keep [ $1 ] keep [ xor-byte ] keep a<< ] }
        { "XOR-(RR)" [ [ a>> ] keep [ $1 ] keep [ read-byte ] keep [ xor-byte ] keep a<< ] }
        { "AND-N" [ [ a>> ] keep [ next-byte ] keep [ and-byte ] keep a<< ] }
        { "AND-R" [ [ a>> ] keep [ $1 ] keep [ and-byte ] keep a<< ] }
        { "AND-(RR)" [ [ a>> ] keep [ $1 ] keep [ read-byte ] keep [ and-byte ] keep a<< ] }
        { "ADC-R,N" [ [ $1 ] keep [ next-byte ] keep [ add-byte-with-carry ] keep $2 ] }
        { "ADC-R,R" [ [ $1 ] keep [ $3 ] keep [ add-byte-with-carry ] keep $2 ] }
        { "ADC-R,(RR)" [ [ $1 ] keep [ $3 ] keep [ read-byte ] keep [ add-byte-with-carry ] keep $2 ] }
        { "ADD-R,N" [ [ $1 ] keep [ next-byte ] keep [ add-byte ] keep $2 ] }
        { "ADD-R,R" [ [ $1 ] keep [ $3 ] keep [ add-byte ] keep $2 ] }
        { "ADD-RR,RR" [ [ $1 ] keep [ $3 ] keep [ add-word ] keep $2 ] }
        { "ADD-R,(RR)" [ [ $1 ] keep [ $3 ] keep [ read-byte ] keep [ add-byte ] keep $2 ] }
        { "SBC-R,N" [ [ $1 ] keep [ next-byte ] keep [ sub-byte-with-carry ] keep $2 ] }
        { "SBC-R,R" [ [ $1 ] keep [ $3 ] keep [ sub-byte-with-carry ] keep $2 ] }
        { "SBC-R,(RR)" [ [ $1 ] keep [ $3 ] keep [ read-byte ] keep [ sub-byte-with-carry ] keep $2 ] }
        { "SUB-R" [ [ a>> ] keep [ $1 ] keep [ sub-byte ] keep a<< ] }
        { "SUB-(RR)" [ [ a>> ] keep [ $1 ] keep [ read-byte ] keep [ sub-byte ] keep a<< ] }
        { "SUB-N" [ [ a>> ] keep [ next-byte ] keep [ sub-byte ] keep a<< ] }
        { "CPL" [ (emulate-CPL) ] }
        { "DAA" [ (emulate-DAA) ] }
        { "RLA" [ (emulate-RLA) ] }
        { "RRA" [ (emulate-RRA) ] }
        { "CCF" [ carry-flag swap cpu-f-bitxor= ] }
        { "SCF" [ carry-flag swap cpu-f-bitor= ] }
        { "RLCA" [ (emulate-RLCA) ] }
        { "RRCA" [ (emulate-RRCA) ] }
        { "HALT" [ drop ] }
        { "DI" [ [ 255 interrupt-flag - ] swap cpu-f-bitand ] }
        { "EI" [ [ interrupt-flag ] swap cpu-f-bitor ] }
        { "POP-RR" [ [ pop-sp ] keep $2 ] }
        { "PUSH-RR" [ [ $1 ] keep push-sp ] }
        { "INC-R" [ [ $1 ] keep [ inc-byte ] keep $2 ] }
        { "DEC-R" [ [ $1 ] keep [ dec-byte ] keep $2 ] }
        { "INC-RR" [ [ $1 ] keep [ inc-word ] keep $2 ] }
        { "DEC-RR" [ [ $1 ] keep [ dec-word ] keep $2 ] }
        { "DEC-(RR)" [ [ $1 ] keep [ read-byte ] keep [ dec-byte ] keep [ $1 ] keep write-byte ] }
        { "INC-(RR)" [ [ $1 ] keep [ read-byte ] keep [ inc-byte ] keep [ $1 ] keep write-byte ] }
        { "JP-NN" [ [ pc>> ] keep [ read-word ] keep pc<< ] }
        { "JP-F|FF,NN" [ [ $1 ] guard [ [ next-word ] keep [ pc<< ] keep [ cycles>> ] guard 5 + swap cycles<< ] [ [ pc>> 2 + ] keep pc<< ] if ] }
        { "JP-(RR)" [ [ $1 ] keep pc<< ] }
        { "CALL-NN" [ (emulate-CALL) ] }
        { "CALL-F|FF,NN" [ [ $1 ] guard [ 7 over inc-cycles (emulate-CALL) ] [ [ pc>> 2 + ] keep pc<< ] if ] }
        { "LD-RR,NN" [ [ next-word ] keep $2 ] }
        { "LD-RR,RR" [ [ $3 ] keep $2 ] }
        { "LD-R,N" [ [ next-byte ] keep $2 ] }
        { "LD-(RR),N" [ [ next-byte ] keep [ $1 ] keep write-byte ] }
        { "LD-(RR),R" [ [ $3 ] keep [ $1 ] keep write-byte ] }
        { "LD-R,R" [ [ $3 ] keep $2 ] }
        { "LD-R,(RR)" [ [ $3 ] keep [ read-byte ] keep $2 ] }
        { "LD-(NN),RR" [ [ $1 ] keep [ next-word ] keep write-word ] }
        { "LD-(NN),R" [ [ $1 ] keep [ next-word ] keep write-byte ] }
        { "LD-RR,(NN)" [ [ next-word ] keep [ read-word ] keep $2 ] }
        { "LD-R,(NN)" [ [ next-word ] keep [ read-byte ] keep $2 ] }
        { "OUT-(N),R" [ [ $1 ] keep [ next-byte ] keep write-port ] }
        { "IN-R,(N)" [ [ next-byte ] keep [ read-port ] keep a<< ] }
        { "EX-(RR),RR" [ [ $1 ] keep [ read-word ] keep [ $3 ] keep [ $1 ] keep [ write-word ] keep $4 ] }
        { "EX-RR,RR" [ [ $1 ] keep [ $3 ] keep [ $2 ] keep $4 ] }
    } ;

EBNF-PARSER: 8-bit-registers
    ! A parser for 8-bit registers. On a successfull parse the
    ! parse tree contains a vector. The first item in the vector
    ! is the getter word for that register with stack effect
    ! ( cpu -- value ). The second item is the setter word with
    ! stack effect ( value cpu -- ).
    [=[
        main=("A" | "B" | "C" | "D" | "E" | "H" | "L") => [[ register-lookup ]]
    ]=]

EBNF-PARSER: all-flags
    ! A parser for 16-bit flags.
    [=[
        main=("NZ" | "NC" | "PO" | "PE" | "Z" | "C" | "P" | "M") => [[ flag-lookup ]]
    ]=]

EBNF-PARSER: 16-bit-registers
    ! A parser for 16-bit registers. On a successfull parse the
    ! parse tree contains a vector. The first item in the vector
    ! is the getter word for that register with stack effect
    ! ( cpu -- value ). The second item is the setter word with
    ! stack effect ( value cpu -- ).
    [=[
        main=("AF" | "BC" | "DE" | "HL" | "SP") => [[ register-lookup ]]
    ]=]

: all-registers ( -- parser )
    ! Return a parser that can parse the format
    ! for 8 bit or 16 bit registers.
    [ 16-bit-registers , 8-bit-registers , ] choice* ;

: indirect ( parser -- parser )
    ! Given a parser, return a parser which parses the original
    ! wrapped in brackets, representing an indirect reference.
    ! eg. BC -> (BC). The value of the original parser is left in
    ! the parse tree.
    "(" ")" surrounded-by ;

: generate-instruction ( vector string -- quot )
    ! Generate the quotation for an instruction, given the instruction in
    ! the 'string' and a vector containing the arguments for that instruction.
    patterns at replace-patterns ;

: simple-instruction ( token -- parser )
    ! Return a parser for then instruction identified by the token.
    ! The parser return parses the token only and expects no additional
    ! arguments to the instruction.
    token [ '[ { } _ generate-instruction ] ] action ;

: complex-instruction ( type token -- parser )
    ! Return a parser for an instruction identified by the token.
    ! The instruction is expected to take additional arguments by
    ! being combined with other parsers. Then 'type' is used for a lookup
    ! in a pattern hashtable to return the instruction quotation pattern.
    token swap [ nip '[ _ generate-instruction ] ] curry action ;

: no-params ( ast -- ast )
    first { } swap curry ;

: one-param ( ast -- ast )
    first2 swap curry ;

: two-params ( ast -- ast )
    first3 append swap curry ;

: NOP-instruction ( -- parser )
    "NOP" simple-instruction ;

: RET-NN-instruction ( -- parser )
    [
      "RET-NN" "RET" complex-instruction ,
      "nn" token sp hide ,
    ] seq* [ no-params ] action ;

: RST-0-instruction ( -- parser )
    [
      "RST-0" "RST" complex-instruction ,
      "0" token sp hide ,
    ] seq* [ no-params ] action ;

: RST-8-instruction ( -- parser )
    [
      "RST-8" "RST" complex-instruction ,
      "8" token sp hide ,
    ] seq* [ no-params ] action ;

: RST-10H-instruction ( -- parser )
    [
      "RST-10H" "RST" complex-instruction ,
      "10H" token sp hide ,
    ] seq* [ no-params ] action ;

: RST-18H-instruction ( -- parser )
    [
      "RST-18H" "RST" complex-instruction ,
      "18H" token sp hide ,
    ] seq* [ no-params ] action ;

: RST-20H-instruction ( -- parser )
    [
      "RST-20H" "RST" complex-instruction ,
      "20H" token sp hide ,
    ] seq* [ no-params ] action ;

: RST-28H-instruction ( -- parser )
    [
      "RST-28H" "RST" complex-instruction ,
      "28H" token sp hide ,
    ] seq* [ no-params ] action ;

: RST-30H-instruction ( -- parser )
    [
      "RST-30H" "RST" complex-instruction ,
      "30H" token sp hide ,
    ] seq* [ no-params ] action ;

: RST-38H-instruction ( -- parser )
    [
      "RST-38H" "RST" complex-instruction ,
      "38H" token sp hide ,
    ] seq* [ no-params ] action ;

: JP-NN-instruction ( -- parser )
    [
      "JP-NN" "JP" complex-instruction ,
      "nn" token sp hide ,
    ] seq* [ no-params ] action ;

: JP-F|FF,NN-instruction ( -- parser )
    [
      "JP-F|FF,NN" "JP" complex-instruction ,
      all-flags sp ,
      ",nn" token hide ,
    ] seq* [ one-param ] action ;

: JP-(RR)-instruction ( -- parser )
    [
      "JP-(RR)" "JP" complex-instruction ,
      16-bit-registers indirect sp ,
    ] seq* [ one-param ] action ;

: CALL-NN-instruction ( -- parser )
    [
      "CALL-NN" "CALL" complex-instruction ,
      "nn" token sp hide ,
    ] seq* [ no-params ] action ;

: CALL-F|FF,NN-instruction ( -- parser )
    [
      "CALL-F|FF,NN" "CALL" complex-instruction ,
      all-flags sp ,
      ",nn" token hide ,
    ] seq* [ one-param ] action ;

: RLCA-instruction ( -- parser )
    "RLCA" simple-instruction ;

: RRCA-instruction ( -- parser )
    "RRCA" simple-instruction ;

: HALT-instruction ( -- parser )
    "HALT" simple-instruction ;

: DI-instruction ( -- parser )
    "DI" simple-instruction ;

: EI-instruction ( -- parser )
    "EI" simple-instruction ;

: CPL-instruction ( -- parser )
    "CPL" simple-instruction ;

: CCF-instruction ( -- parser )
    "CCF" simple-instruction ;

: SCF-instruction ( -- parser )
    "SCF" simple-instruction ;

: DAA-instruction ( -- parser )
    "DAA" simple-instruction ;

: RLA-instruction ( -- parser )
    "RLA" simple-instruction ;

: RRA-instruction ( -- parser )
    "RRA" simple-instruction ;

: DEC-R-instruction ( -- parser )
    [
      "DEC-R" "DEC" complex-instruction ,
      8-bit-registers sp ,
    ] seq* [ one-param ] action ;

: DEC-RR-instruction ( -- parser )
    [
      "DEC-RR" "DEC" complex-instruction ,
      16-bit-registers sp ,
    ] seq* [ one-param ] action ;

: DEC-(RR)-instruction ( -- parser )
    [
      "DEC-(RR)" "DEC" complex-instruction ,
      16-bit-registers indirect sp ,
    ] seq* [ one-param ] action ;

: POP-RR-instruction ( -- parser )
    [
      "POP-RR" "POP" complex-instruction ,
      all-registers sp ,
    ] seq* [ one-param ] action ;

: PUSH-RR-instruction ( -- parser )
    [
      "PUSH-RR" "PUSH" complex-instruction ,
      all-registers sp ,
    ] seq* [ one-param ] action ;

: INC-R-instruction ( -- parser )
    [
      "INC-R" "INC" complex-instruction ,
      8-bit-registers sp ,
    ] seq* [ one-param ] action ;

: INC-RR-instruction ( -- parser )
    [
      "INC-RR" "INC" complex-instruction ,
      16-bit-registers sp ,
    ] seq* [ one-param ] action ;

: INC-(RR)-instruction  ( -- parser )
    [
      "INC-(RR)" "INC" complex-instruction ,
      all-registers indirect sp ,
    ] seq* [ one-param ] action ;

: RET-F|FF-instruction ( -- parser )
    [
      "RET-F|FF" "RET" complex-instruction ,
      all-flags sp ,
    ] seq* [ one-param ] action ;

: AND-N-instruction ( -- parser )
    [
      "AND-N" "AND" complex-instruction ,
      "n" token sp hide ,
    ] seq* [ no-params ] action ;

: AND-R-instruction  ( -- parser )
    [
      "AND-R" "AND" complex-instruction ,
      8-bit-registers sp ,
    ] seq* [ one-param ] action ;

: AND-(RR)-instruction  ( -- parser )
    [
      "AND-(RR)" "AND" complex-instruction ,
      16-bit-registers indirect sp ,
    ] seq* [ one-param ] action ;

: XOR-N-instruction ( -- parser )
    [
      "XOR-N" "XOR" complex-instruction ,
      "n" token sp hide ,
    ] seq* [ no-params  ] action ;

: XOR-R-instruction  ( -- parser )
    [
      "XOR-R" "XOR" complex-instruction ,
      8-bit-registers sp ,
    ] seq* [ one-param ] action ;

: XOR-(RR)-instruction  ( -- parser )
    [
      "XOR-(RR)" "XOR" complex-instruction ,
      16-bit-registers indirect sp ,
    ] seq* [ one-param ] action ;

: OR-N-instruction ( -- parser )
    [
      "OR-N" "OR" complex-instruction ,
      "n" token sp hide ,
    ] seq* [ no-params  ] action ;

: OR-R-instruction  ( -- parser )
    [
      "OR-R" "OR" complex-instruction ,
      8-bit-registers sp ,
    ] seq* [ one-param ] action ;

: OR-(RR)-instruction  ( -- parser )
    [
      "OR-(RR)" "OR" complex-instruction ,
      16-bit-registers indirect sp ,
    ] seq* [ one-param ] action ;

: CP-N-instruction ( -- parser )
    [
      "CP-N" "CP" complex-instruction ,
      "n" token sp hide ,
    ] seq* [ no-params ] action ;

: CP-R-instruction  ( -- parser )
    [
      "CP-R" "CP" complex-instruction ,
      8-bit-registers sp ,
    ] seq* [ one-param ] action ;

: CP-(RR)-instruction  ( -- parser )
    [
      "CP-(RR)" "CP" complex-instruction ,
      16-bit-registers indirect sp ,
    ] seq* [ one-param ] action ;

: ADC-R,N-instruction ( -- parser )
    [
      "ADC-R,N" "ADC" complex-instruction ,
      8-bit-registers sp ,
      ",n" token hide ,
    ] seq* [ one-param ] action ;

: ADC-R,R-instruction ( -- parser )
    [
      "ADC-R,R" "ADC" complex-instruction ,
      8-bit-registers sp ,
      "," token hide ,
      8-bit-registers ,
    ] seq* [ two-params ] action ;

: ADC-R,(RR)-instruction ( -- parser )
    [
      "ADC-R,(RR)" "ADC" complex-instruction ,
      8-bit-registers sp ,
      "," token hide ,
      16-bit-registers indirect ,
    ] seq* [ two-params ] action ;

: SBC-R,N-instruction ( -- parser )
    [
      "SBC-R,N" "SBC" complex-instruction ,
      8-bit-registers sp ,
      ",n" token hide ,
    ] seq* [ one-param ] action ;

: SBC-R,R-instruction ( -- parser )
    [
      "SBC-R,R" "SBC" complex-instruction ,
      8-bit-registers sp ,
      "," token hide ,
      8-bit-registers ,
    ] seq* [ two-params  ] action ;

: SBC-R,(RR)-instruction ( -- parser )
    [
      "SBC-R,(RR)" "SBC" complex-instruction ,
      8-bit-registers sp ,
      "," token hide ,
      16-bit-registers indirect ,
    ] seq* [ two-params  ] action ;

: SUB-R-instruction ( -- parser )
    [
      "SUB-R" "SUB" complex-instruction ,
      8-bit-registers sp ,
    ] seq* [ one-param ] action ;

: SUB-(RR)-instruction ( -- parser )
    [
      "SUB-(RR)" "SUB" complex-instruction ,
      16-bit-registers indirect sp ,
    ] seq* [ one-param ] action ;

: SUB-N-instruction ( -- parser )
    [
      "SUB-N" "SUB" complex-instruction ,
      "n" token sp hide ,
    ] seq* [ no-params  ] action ;

: ADD-R,N-instruction ( -- parser )
    [
      "ADD-R,N" "ADD" complex-instruction ,
      8-bit-registers sp ,
      ",n" token hide ,
    ] seq* [ one-param ] action ;

: ADD-R,R-instruction ( -- parser )
    [
      "ADD-R,R" "ADD" complex-instruction ,
      8-bit-registers sp ,
      "," token hide ,
      8-bit-registers ,
    ] seq* [ two-params ] action ;

: ADD-RR,RR-instruction ( -- parser )
    [
      "ADD-RR,RR" "ADD" complex-instruction ,
      16-bit-registers sp ,
      "," token hide ,
      16-bit-registers ,
    ] seq* [ two-params ] action ;

: ADD-R,(RR)-instruction ( -- parser )
    [
      "ADD-R,(RR)" "ADD" complex-instruction ,
      8-bit-registers sp ,
      "," token hide ,
      16-bit-registers indirect ,
    ] seq* [ two-params ] action ;

: LD-RR,NN-instruction ( -- parser )
    ! LD BC,nn
    [
      "LD-RR,NN" "LD" complex-instruction ,
      16-bit-registers sp ,
      ",nn" token hide ,
    ] seq* [ one-param ] action ;

: LD-R,N-instruction ( -- parser )
    ! LD B,n
    [
      "LD-R,N" "LD" complex-instruction ,
      8-bit-registers sp ,
      ",n" token hide ,
    ] seq* [ one-param ] action ;

: LD-(RR),N-instruction ( -- parser )
    [
      "LD-(RR),N" "LD" complex-instruction ,
      16-bit-registers indirect sp ,
      ",n" token hide ,
    ] seq* [ one-param ] action ;

: LD-(RR),R-instruction ( -- parser )
    ! LD (BC),A
    [
      "LD-(RR),R" "LD" complex-instruction ,
      16-bit-registers indirect sp ,
      "," token hide ,
      8-bit-registers ,
    ] seq* [ two-params ] action ;

: LD-R,R-instruction ( -- parser )
    [
      "LD-R,R" "LD" complex-instruction ,
      8-bit-registers sp ,
      "," token hide ,
      8-bit-registers ,
    ] seq* [ two-params ] action ;

: LD-RR,RR-instruction ( -- parser )
    [
      "LD-RR,RR" "LD" complex-instruction ,
      16-bit-registers sp ,
      "," token hide ,
      16-bit-registers ,
    ] seq* [ two-params ] action ;

: LD-R,(RR)-instruction ( -- parser )
    [
      "LD-R,(RR)" "LD" complex-instruction ,
      8-bit-registers sp ,
      "," token hide ,
      16-bit-registers indirect ,
    ] seq* [ two-params ] action ;

: LD-(NN),RR-instruction ( -- parser )
    [
      "LD-(NN),RR" "LD" complex-instruction ,
      "nn" token indirect sp hide ,
      "," token hide ,
      16-bit-registers ,
    ] seq* [ one-param ] action ;

: LD-(NN),R-instruction ( -- parser )
    [
      "LD-(NN),R" "LD" complex-instruction ,
      "nn" token indirect sp hide ,
      "," token hide ,
      8-bit-registers ,
    ] seq* [ one-param ] action ;

: LD-RR,(NN)-instruction ( -- parser )
    [
      "LD-RR,(NN)" "LD" complex-instruction ,
      16-bit-registers sp ,
      "," token hide ,
      "nn" token indirect hide ,
    ] seq* [ one-param ] action ;

: LD-R,(NN)-instruction ( -- parser )
    [
      "LD-R,(NN)" "LD" complex-instruction ,
      8-bit-registers sp ,
      "," token hide ,
      "nn" token indirect hide ,
    ] seq* [ one-param ] action ;

: OUT-(N),R-instruction ( -- parser )
    [
      "OUT-(N),R" "OUT" complex-instruction ,
      "n" token indirect sp hide ,
      "," token hide ,
      8-bit-registers ,
    ] seq* [ one-param ] action ;

: IN-R,(N)-instruction ( -- parser )
    [
      "IN-R,(N)" "IN" complex-instruction ,
      8-bit-registers sp ,
      "," token hide ,
      "n" token indirect hide ,
    ] seq* [ one-param ] action ;

: EX-(RR),RR-instruction ( -- parser )
    [
      "EX-(RR),RR" "EX" complex-instruction ,
      16-bit-registers indirect sp ,
      "," token hide ,
      16-bit-registers ,
    ] seq* [ two-params ] action ;

: EX-RR,RR-instruction ( -- parser )
    [
      "EX-RR,RR" "EX" complex-instruction ,
      16-bit-registers sp ,
      "," token hide ,
      16-bit-registers ,
    ] seq* [ two-params ] action ;

: 8080-generator-parser ( -- parser )
    [
      NOP-instruction  ,
      RST-0-instruction ,
      RST-8-instruction ,
      RST-10H-instruction ,
      RST-18H-instruction ,
      RST-20H-instruction ,
      RST-28H-instruction ,
      RST-30H-instruction ,
      RST-38H-instruction ,
      JP-F|FF,NN-instruction ,
      JP-NN-instruction ,
      JP-(RR)-instruction ,
      CALL-F|FF,NN-instruction ,
      CALL-NN-instruction ,
      CPL-instruction ,
      CCF-instruction ,
      SCF-instruction ,
      DAA-instruction ,
      RLA-instruction ,
      RRA-instruction ,
      RLCA-instruction ,
      RRCA-instruction ,
      HALT-instruction ,
      DI-instruction ,
      EI-instruction ,
      AND-N-instruction ,
      AND-R-instruction ,
      AND-(RR)-instruction ,
      XOR-N-instruction ,
      XOR-R-instruction ,
      XOR-(RR)-instruction ,
      OR-N-instruction ,
      OR-R-instruction ,
      OR-(RR)-instruction ,
      CP-N-instruction ,
      CP-R-instruction ,
      CP-(RR)-instruction ,
      DEC-RR-instruction ,
      DEC-R-instruction ,
      DEC-(RR)-instruction ,
      POP-RR-instruction ,
      PUSH-RR-instruction ,
      INC-RR-instruction ,
      INC-R-instruction ,
      INC-(RR)-instruction ,
      LD-RR,NN-instruction ,
      LD-RR,RR-instruction ,
      LD-R,N-instruction ,
      LD-R,R-instruction ,
      LD-(RR),N-instruction ,
      LD-(RR),R-instruction ,
      LD-R,(RR)-instruction ,
      LD-(NN),RR-instruction ,
      LD-(NN),R-instruction ,
      LD-RR,(NN)-instruction ,
      LD-R,(NN)-instruction ,
      ADC-R,(RR)-instruction ,
      ADC-R,N-instruction ,
      ADC-R,R-instruction ,
      ADD-R,N-instruction ,
      ADD-R,(RR)-instruction ,
      ADD-R,R-instruction ,
      ADD-RR,RR-instruction ,
      SBC-R,N-instruction ,
      SBC-R,R-instruction ,
      SBC-R,(RR)-instruction ,
      SUB-R-instruction ,
      SUB-(RR)-instruction ,
      SUB-N-instruction ,
      RET-F|FF-instruction ,
      RET-NN-instruction ,
      OUT-(N),R-instruction ,
      IN-R,(N)-instruction ,
      EX-(RR),RR-instruction ,
      EX-RR,RR-instruction ,
    ] choice* [ call( -- quot ) ] action ;

: instruction-quotations ( string -- emulate-quot )
    ! Given an instruction string, return the emulation quotation for
    ! it. This will later be expanded to produce the disassembly and
    ! assembly quotations.
    8080-generator-parser parse ;

SYMBOL: last-instruction
SYMBOL: last-opcode

: parse-instructions ( list -- )
    ! Process the list of strings, which should make
    ! up an 8080 instruction, and output a quotation
    ! that would implement that instruction.
    dup join-words instruction-quotations
    [
       "_" join [ "emulate-" % % ] "" make create-word-in
       dup last-instruction set-global
    ] dip ( cpu -- ) define-declared ;

SYNTAX: INSTRUCTION: ";" parse-tokens parse-instructions ;

SYNTAX: cycles:
    ! Set the number of cycles for the last instruction that was defined.
    scan-token string>number last-opcode get-global instruction-cycles set-nth ;

SYNTAX: opcode:
    ! Set the opcode number for the last instruction that was defined.
    last-instruction get-global 1quotation scan-token hex>
    dup last-opcode set-global set-instruction ;
