USING: kernel lists math sequences errors vectors prettyprint io unparser namespaces 
       words parser hashtables lazy parser-combinators kernel-internals strings ;
IN: cpu-8080

TUPLE: cpu b c d e f h l a pc sp halted? last-interrupt cycles ram ;

GENERIC: reset        ( cpu            -- )
GENERIC: update-video ( value addr cpu -- )
GENERIC: read-port    ( port cpu       -- byte )
GENERIC: write-port   ( value port cpu -- )

M: cpu update-video ( value addr cpu -- )
  3drop ;

M: cpu read-port ( port cpu -- byte )
  #! Read a byte from the hardware port. 'port' should
  #! be an 8-bit value.
  2drop 0 ;

M: cpu write-port ( value port cpu -- )
  #! Write a byte to the hardware port, where 'port' is
  #! an 8-bit value.
  3drop ;

: carry-flag        HEX: 01 ; inline
: parity-flag       HEX: 04 ; inline
: half-carry-flag   HEX: 10 ; inline
: interrupt-flag    HEX: 20 ; inline
: zero-flag         HEX: 40 ; inline
: sign-flag         HEX: 80 ; inline

: >word< ( word -- byte byte )
  #! Explode a word into its two 8 bit values.
  dup HEX: FF bitand swap -8 shift HEX: FF bitand swap ;

: cpu-af ( cpu -- word )
  #! Return the 16-bit pseudo register AF.
  [ cpu-a 8 shift ] keep cpu-f bitor ;

: set-cpu-af ( value cpu -- )
  #! Set the value of the 16-bit pseudo register AF
  >r >word< r> tuck set-cpu-f set-cpu-a ;

: cpu-bc ( cpu -- word )
  #! Return the 16-bit pseudo register BC.
  [ cpu-b 8 shift ] keep cpu-c bitor ;

: set-cpu-bc ( value cpu -- )
  #! Set the value of the 16-bit pseudo register BC
  >r >word< r> tuck set-cpu-c set-cpu-b ;

: cpu-de ( cpu -- word )
  #! Return the 16-bit pseudo register DE.
  [ cpu-d 8 shift ] keep cpu-e bitor ;

: set-cpu-de ( value cpu -- )
  #! Set the value of the 16-bit pseudo register DE
  >r >word< r> tuck set-cpu-e set-cpu-d ;

: cpu-hl ( cpu -- word )
  #! Return the 16-bit pseudo register HL.
  [ cpu-h 8 shift ] keep cpu-l bitor ;

: set-cpu-hl ( value cpu -- )
  #! Set the value of the 16-bit pseudo register HL
  >r >word< r> tuck set-cpu-l set-cpu-h ;

: flag-set? ( flag cpu -- bool )
  cpu-f bitand 0 = not ;

: flag-clear? ( flag cpu -- bool )
  cpu-f bitand 0 = ;

: flag-nz? ( cpu -- bool )
  #! Test flag status
  cpu-f zero-flag bitand 0 = ;

: flag-z? ( cpu -- bool )
  #! Test flag status
  cpu-f zero-flag bitand 0 = not ;

: flag-nc? ( cpu -- bool )
  #! Test flag status
  cpu-f carry-flag bitand 0 = ;

: flag-c? ( cpu -- bool )
  #! Test flag status
  cpu-f carry-flag bitand 0 = not ;

: flag-po? ( cpu -- bool )
  #! Test flag status
  cpu-f parity-flag bitand 0 =  ;

: flag-pe? ( cpu -- bool )
  #! Test flag status
  cpu-f parity-flag bitand 0 = not ;

: flag-p? ( cpu -- bool )
  #! Test flag status
  cpu-f sign-flag bitand 0 = ;

: flag-m? ( cpu -- bool )
  #! Test flag status
  cpu-f sign-flag bitand 0 = not ;

: read-byte ( addr cpu -- byte )
  #! Read one byte from memory at the specified address.
  #! The address is 16-bit, but if a value greater than
  #! 0xFFFF is provided then return a default value.
  over HEX: FFFF <= [
    cpu-ram nth
  ] [
    2drop HEX: FF
  ] ifte ;

: read-word ( addr cpu -- word )  
  #! Read a 16-bit word from memory at the specified address.
  #! The address is 16-bit, but if a value greater than
  #! 0xFFFF is provided then return a default value.
  [ read-byte ] 2keep >r 1 + r> read-byte 8 shift bitor ;
 
: next-byte ( cpu -- byte )
  #! Return the value of the byte at PC, and increment PC.
  [ cpu-pc ] keep
  [ read-byte ] keep 
  [ cpu-pc 1 + ] keep
  set-cpu-pc ;

: next-word ( cpu -- word )
  #! Return the value of the word at PC, and increment PC.
  [ cpu-pc ] keep
  [ read-word ] keep 
  [ cpu-pc 2 + ] keep
  set-cpu-pc ;


: write-byte ( value addr cpu -- )
  #! Write a byte to the specified memory address.
  over dup HEX: 2000 < swap HEX: FFFF > or [
    3drop
  ] [
    3dup cpu-ram set-nth
    update-video
  ] ifte ;


: write-word ( value addr cpu -- )
  #! Write a 16-bit word to the specified memory address.
  >r >r >word< r> r> [ write-byte ] 2keep >r 1 + r> write-byte ;

: cpu-a-bitand ( quot cpu -- )
  #! A &= quot call 
  [ cpu-a swap call bitand ] keep set-cpu-a ; inline

: cpu-a-bitor ( quot cpu -- )
  #! A |= quot call 
  [ cpu-a swap call bitor ] keep set-cpu-a ; inline

: cpu-a-bitxor ( quot cpu -- )
  #! A ^= quot call 
  [ cpu-a swap call bitxor ] keep set-cpu-a ; inline

: cpu-a-bitxor= ( value cpu -- )
  #! cpu-a ^= value
  [ cpu-a bitxor ] keep set-cpu-a ;

: cpu-f-bitand ( quot cpu -- )
  #! F &= quot call 
  [ cpu-f swap call bitand ] keep set-cpu-f ; inline

: cpu-f-bitor ( quot cpu -- )
  #! F |= quot call 
  [ cpu-f swap call bitor ] keep set-cpu-f ; inline

: cpu-f-bitxor ( quot cpu -- )
  #! F |= quot call 
  [ cpu-f swap call bitxor ] keep set-cpu-f ; inline

: cpu-f-bitor= ( value cpu -- )
  #! cpu-f |= value
  [ cpu-f bitor ] keep set-cpu-f ;

: cpu-f-bitand= ( value cpu -- )
  #! cpu-f &= value
  [ cpu-f bitand ] keep set-cpu-f ;

: cpu-f-bitxor= ( value cpu -- )
  #! cpu-f ^= value
  [ cpu-f bitxor ] keep set-cpu-f ;

: set-flag ( cpu flag -- )
  swap cpu-f-bitor= ;

: clear-flag ( cpu flag -- )
   bitnot HEX: FF bitand swap cpu-f-bitand= ;

: update-zero-flag ( result cpu -- )
  #! If the result of an instruction has the value 0, this
  #! flag is set, otherwise it is reset.
  swap HEX: FF bitand 0 = [ zero-flag set-flag ] [ zero-flag clear-flag ] ifte ;

: update-sign-flag ( result cpu -- )
  #! If the most significant bit of the result 
  #! has the value 1 then the flag is set, otherwise
  #! it is reset.
  swap HEX: 80 bitand 0 = [ sign-flag clear-flag ] [ sign-flag set-flag ] ifte ;

: update-parity-flag ( result cpu -- )
  #! If the modulo 2 sum of the bits of the result
  #! is 0, (ie. if the result has even parity) this flag
  #! is set, otherwise it is reset.
  swap HEX: FF bitand 2 mod 0 = [ parity-flag set-flag ] [ parity-flag clear-flag ] ifte ;

: update-carry-flag ( result cpu -- )
  #! If the instruction resulted in a carry (from addition) 
  #! or a borrow (from subtraction or a comparison) out of the
  #! higher order bit, this flag is set, otherwise it is reset.
  swap dup HEX: 100 >= swap 0 < or [ carry-flag set-flag ] [ carry-flag clear-flag ] ifte ;

: update-half-carry-flag ( original change-by result cpu -- )
  #! If the instruction caused a carry out of bit 3 and into bit 4 of the
  #! resulting value, the half carry flag is set, otherwise it is reset.
  #! The 'original' is the original value of the register being changed.
  #! 'change-by' is the amount it is being added or decremented by.
  #! 'result' is the result of that change.
  >r bitxor bitxor HEX: 10 bitand 0 = not r> 
  swap [ half-carry-flag set-flag ] [ half-carry-flag clear-flag ] ifte ;

: update-flags ( result cpu -- )
  2dup update-carry-flag
  2dup update-parity-flag
  2dup update-sign-flag
  update-zero-flag ;

: update-flags-no-carry ( result cpu -- )
  2dup update-parity-flag
  2dup update-sign-flag
  update-zero-flag ;

: add-byte ( lhs rhs cpu -- result )
  #! Add rhs to lhs
  >r 2dup + r> ( lhs rhs result cpu )
  [ update-flags ] 2keep 
  [ update-half-carry-flag ] 2keep
  drop HEX: FF bitand ;

: add-carry ( change-by result cpu -- change-by result )
  #! Add the effect of the carry flag to the result
  flag-c? [ 1 + >r 1 + r> ] when ;

: add-byte-with-carry ( lhs rhs cpu -- result )
  #! Add rhs to lhs plus carry.
  >r 2dup + r> ( lhs rhs result cpu )
  [ add-carry ] keep
  [ update-flags ] 2keep 
  [ update-half-carry-flag ] 2keep
  drop HEX: FF bitand ;

: sub-carry ( change-by result cpu -- change-by result ) 
  #! Subtract the effect of the carry flag from the result
  flag-c? [ 1 - >r 1 - r>  ] when ;

: sub-byte ( lhs rhs cpu -- result )
  #! Subtract rhs from lhs
  >r 2dup - r> 
  [ update-flags ] 2keep 
  [ update-half-carry-flag ] 2keep
  drop HEX: FF bitand ;

: sub-byte-with-carry ( lhs rhs cpu -- result )
  #! Subtract rhs from lhs and take carry into account
  >r 2dup - r> 
  [ sub-carry ] keep 
  [ update-flags ] 2keep 
  [ update-half-carry-flag ] 2keep
  drop HEX: FF bitand ;
 
: inc-byte ( byte cpu -- result )
  #! Increment byte by one. Note that carry flag is not affected
  #! by this operation.
  >r 1 2dup + r> ( lhs rhs result cpu )
  [ update-flags-no-carry ] 2keep 
  [ update-half-carry-flag ] 2keep
  drop HEX: FF bitand ;

: dec-byte ( byte cpu -- result )
  #! Decrement byte by one. Note that carry flag is not affected
  #! by this operation.
  >r 1 2dup - r> ( lhs rhs result cpu )
  [ update-flags-no-carry ] 2keep 
  [ update-half-carry-flag ] 2keep
  drop HEX: FF bitand ;

: inc-word ( w cpu -- w )
  #! Increment word by one. Note that no flags are modified.
  drop 1 + HEX: FFFF bitand ;

: dec-word ( w cpu -- w )
  #! Decrement word by one. Note that no flags are modified.
  drop 1 - HEX: FFFF bitand ;

: add-word ( lhs rhs cpu -- result )
  #! Add rhs to lhs. Note that only the carry flag is modified
  #! and only if there is a carry out of the double precision add.
  >r + r> over HEX: FFFF > [ carry-flag set-flag ] [ drop ] ifte HEX: FFFF bitand ;

: bit3or ( lhs rhs -- 0|1 )
  #! bitor bit 3 of the two numbers on the stack
  BIN: 00001000 bitand -3 shift >r
  BIN: 00001000 bitand -3 shift r> 
  bitor ;

: and-byte ( lhs rhs cpu -- result )
  #! Logically and rhs to lhs. The carry flag is cleared and
  #! the half carry is set to the ORing of bits 3 of the operands.
  [ drop bit3or ] 3keep ( bit3or lhs rhs cpu )
  >r bitand r> [ update-flags ] 2keep 
  [ carry-flag clear-flag ] keep
  rot 0 = [ half-carry-flag set-flag ] [ half-carry-flag clear-flag ] ifte
  HEX: FF bitand ;

: xor-byte ( lhs rhs cpu -- result )
  #! Logically xor rhs to lhs. The carry and half-carry flags are cleared.
  >r bitxor r> [ update-flags ] 2keep 
  [ half-carry-flag carry-flag bitor clear-flag ] keep
  drop HEX: FF bitand ;

: or-byte ( lhs rhs cpu -- result )
  #! Logically or rhs to lhs. The carry and half-carry flags are cleared.
  >r bitor r> [ update-flags ] 2keep 
  [ half-carry-flag carry-flag bitor clear-flag ] keep
  drop HEX: FF bitand ;

: flags ( seq -- seq )
  [ 0 [ execute bitor ] reduce ] map ;

: decrement-sp ( n cpu -- )
  #! Decrement the stackpointer by n.  
  [ cpu-sp ] keep 
  >r swap - r> set-cpu-sp ;

: save-pc ( cpu -- )
  #! Save the value of the PC on the stack.
  [ cpu-pc ] keep ( pc cpu )
  [ cpu-sp ] keep ( pc sp cpu )
  write-word ;

: push-pc ( cpu -- )
  #! Push the value of the PC on the stack.
  2 over decrement-sp
  save-pc ;

: pop-pc ( cpu -- pc )
  #! Pop the value of the PC off the stack.
  [ cpu-sp ] keep
  [ read-word ] keep 
  -2 swap decrement-sp ;

: push-sp ( value cpu -- )
  [ 2 swap decrement-sp ] keep
  [ cpu-sp ] keep
  write-word ;
  
: pop-sp ( cpu -- value )
  [ cpu-sp ] keep
  [ read-word ] keep
  -2 swap decrement-sp ;

: call-sub ( addr cpu -- )
  #! Call the address as a subroutine.
  dup push-pc 
  >r HEX: FFFF bitand r> set-cpu-pc ;

: ret-from-sub ( cpu -- )
  [ pop-pc ] keep set-cpu-pc ;
 
: interrupt ( number cpu -- )
  #! Perform a hardware interrupt
!  "***Interrupt: " write over 16 >base print 
  dup cpu-f interrupt-flag bitand 0 = not [ ( number cpu -- )
    dup push-pc
    set-cpu-pc
  ] [
    2drop
  ] ifte ;

: inc-cycles ( n cpu -- )
  #! Increment the number of cpu cycles
  [ cpu-cycles + ] keep set-cpu-cycles ;
  
: instruction-cycles ( -- vector )
  #! Return a 256 element vector containing the cycles for
  #! each opcode in the 8080 instruction set.
  @{ 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f }@ ;

: instructions ( -- vector )
  #! Return a 256 element vector containing the emulation words for
  #! each opcode in the 8080 instruction set.
  @{ 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f 
    f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f f }@ ; inline

: not-implemented ( <cpu> -- )
  drop ;

instructions length [ 
  dup instructions nth [
    drop
  ] [
    [ not-implemented ] swap instructions set-nth 
  ] ifte
] each

M: cpu reset ( cpu -- )
  #! Reset the CPU to its poweron state
  [ 0 swap set-cpu-b  ] keep
  [ 0 swap set-cpu-c  ] keep
  [ 0 swap set-cpu-d  ] keep
  [ 0 swap set-cpu-e  ] keep
  [ 0 swap set-cpu-h  ] keep
  [ 0 swap set-cpu-l  ] keep
  [ 0 swap set-cpu-a  ] keep
  [ 0 swap set-cpu-f  ] keep
  [ 0 swap set-cpu-pc  ] keep
  [ HEX: F000 swap set-cpu-sp  ] keep 
  [ HEX: FFFF 0 <repeated> >vector swap set-cpu-ram ] keep
  [ f swap set-cpu-halted? ] keep
  [ HEX: 10 swap set-cpu-last-interrupt ] keep
  0 swap set-cpu-cycles ;

C: cpu ( cpu -- cpu )
  [ reset ] keep ;

: (load-rom) ( n ram -- )
  read1 [ ( n ram ch )
    -rot [ set-nth ] 2keep >r 1 + r> (load-rom)
  ] [
    2drop
  ] ifte* ;

  #! Reads the ROM from stdin and stores it in ROM from
  #! offset n.
: load-rom ( filename <cpu> -- )
  #! Load the contents of the file into ROM.
  #! (address 0x0000-0x1FFF).
  cpu-ram swap <file-reader> [ 
    0 swap (load-rom)
  ] with-stream ;

: load-rom* ( addr filename <cpu> -- )
  #! Load the contents of the file into ROM, starting at
  #! the specified address.
  cpu-ram swap <file-reader> [ 
    (load-rom)
  ] with-stream ;

: read-instruction ( cpu -- word )
  #! Read the next instruction from the cpu's program 
  #! counter, and increment the program counter.
  [ cpu-pc ] keep ( pc cpu )
  [ over 1 + swap set-cpu-pc ] keep
  read-byte ;

: get-cycles ( n -- opcode )
  #! Returns the cycles for the given instruction value.
  #! If the opcode is not defined throw an error.
  dup instruction-cycles nth [ 
    nip  
  ] [
    [ "Undefined 8080 opcode: " % number>string % ] "" make throw
  ] ifte* ;

: process-interrupts ( cpu -- )
  #! Process any hardware interrupts
  [ cpu-cycles ] keep 
  over 16667 < [ ( cycles cpu -- )
    2drop
  ] [ 
    [ >r 16667 - r> set-cpu-cycles ] keep
    dup cpu-last-interrupt HEX: 10 = [
      HEX: 08 over set-cpu-last-interrupt HEX: 08 swap interrupt
    ] [
      HEX: 10 over set-cpu-last-interrupt HEX: 10 swap interrupt
    ] ifte     
  ] ifte ;

: step ( cpu -- )
  #! Run a single 8080 instruction
  [ read-instruction ] keep ( n cpu )
  over get-cycles over inc-cycles
  [ swap instructions dispatch ] keep
  [ cpu-pc HEX: FFFF bitand ] keep 
  [ set-cpu-pc ] keep 
  process-interrupts ;

: peek-instruction ( cpu -- word )
  #! Return the next instruction from the cpu's program
  #! counter, but don't increment the counter.
  [ cpu-pc ] keep read-byte instructions nth car ;

: cpu. ( cpu -- )
  [ " PC: " write cpu-pc 16 >base 4 CHAR: \s pad-left write ] keep 
  [ " B: " write cpu-b 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " C: " write cpu-c 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " D: " write cpu-d 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " E: " write cpu-e 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " F: " write cpu-f 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " H: " write cpu-h 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " L: " write cpu-l 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " A: " write cpu-a 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " SP: " write cpu-sp 16 >base 4 CHAR: \s pad-left write ] keep 
  [ " cycles: " write cpu-cycles number>string 5 CHAR: \s pad-left write ] keep 
  [ " " write peek-instruction word-name write " " write ] keep
  terpri drop ;

: cpu*. ( cpu -- )
  [ " PC: " write cpu-pc 16 >base 4 CHAR: \s pad-left write ] keep 
  [ " B: " write cpu-b 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " C: " write cpu-c 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " D: " write cpu-d 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " E: " write cpu-e 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " F: " write cpu-f 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " H: " write cpu-h 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " L: " write cpu-l 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " A: " write cpu-a 16 >base 2 CHAR: \s pad-left write ] keep 
  [ " SP: " write cpu-sp 16 >base 4 CHAR: \s pad-left write ] keep 
  [ " cycles: " write cpu-cycles number>string 5 CHAR: \s pad-left write ] keep 
  terpri drop ;

: test-step ( cpu -- cpu )
  [ step ] keep dup cpu. ;

: test-cpu ( -- cpu )
  <cpu> "invaders.rom" over load-rom dup cpu. ;

: test-n ( n -- )
  test-cpu swap [ test-step ] times ;

: run-n ( cpu n -- )
  [ dup step ] times ;

: register-lookup ( string -- vector )
  #! Given a string containing a register name, return a vector
  #! where the 1st item is the getter and the 2nd is the setter
  #! for that register.
  {{
    [[ "A"  { cpu-a  set-cpu-a  } ]]
    [[ "B"  { cpu-b  set-cpu-b  } ]]
    [[ "C"  { cpu-c  set-cpu-c  } ]]
    [[ "D"  { cpu-d  set-cpu-d  } ]]
    [[ "E"  { cpu-e  set-cpu-e  } ]]
    [[ "H"  { cpu-h  set-cpu-h  } ]]
    [[ "L"  { cpu-l  set-cpu-l  } ]]
    [[ "AF" { cpu-af set-cpu-af } ]]
    [[ "BC" { cpu-bc set-cpu-bc } ]]
    [[ "DE" { cpu-de set-cpu-de } ]]
    [[ "HL" { cpu-hl set-cpu-hl } ]]
    [[ "SP" { cpu-sp set-cpu-sp } ]]
  }} hash ;


: flag-lookup ( string -- vector )
  #! Given a string containing a flag name, return a vector
  #! where the 1st item is a word that tests that flag.
  {{
    [[ "NZ"  { flag-nz?  } ]]
    [[ "NC"  { flag-nc?  } ]]
    [[ "PO"  { flag-po?  } ]]
    [[ "PE"  { flag-pe?  } ]]
    [[ "Z"  { flag-z?  } ]]
    [[ "C"  { flag-c? } ]]
    [[ "P"  { flag-p?  } ]]
    [[ "M" { flag-m?  } ]]
  }} hash ;

SYMBOL: $1
SYMBOL: $2
SYMBOL: $3
SYMBOL: $4

: replace-patterns ( vector tree -- tree )
  #! Copy the tree, replacing each occurence of 
  #! $1, $2, etc with the relevant item from the 
  #! given index.
  dup cons? [ ( vector tree )
    uncons ( vector car cdr )
    >r dupd replace-patterns ( vector v R: cdr )
    swap r> replace-patterns cons
  ] [ ( vector value )
    dup $1 = [ drop 0 over nth  ] when 
    dup $2 = [ drop 1 over nth  ] when 
    dup $3 = [ drop 2 over nth  ] when 
    dup $4 = [ drop 3 over nth  ] when 
    nip
  ] ifte ;

: test-rp 
  { 4 5 3 } [ 1 $2 [ $1 4 ] ] replace-patterns ;

: (emulate-RST) ( n cpu -- )
  #! RST nn
  [ cpu-sp 2 - dup ] keep ( sp sp cpu )
  [ set-cpu-sp ] keep ( sp cpu )
  [ cpu-pc ] keep ( sp pc cpu )
  swapd [ write-word ] keep ( cpu )
  >r 8 * r> set-cpu-pc ;

: (emulate-CALL) ( cpu -- )
  #! 205 - CALL nn
  [ next-word HEX: FFFF bitand ] keep ( addr cpu )
  [ cpu-sp 2 - dup ] keep ( addr sp sp cpu )
  [ set-cpu-sp ] keep ( addr sp cpu )
  [ cpu-pc ] keep ( addr sp pc cpu )
  swapd [ write-word ] keep ( addr cpu )
  set-cpu-pc ;

: (emulate-RLCA) ( cpu -- )
  #! The content of the accumulator is rotated left
  #! one position. The low order bit and the carry flag
  #! are both set to the value shifted out of the high
  #! order bit position. Only the carry flag is affected.
  [ cpu-a -7 shift ] keep 
  over 0 = [ dup carry-flag clear-flag ] [ dup carry-flag set-flag ] ifte
  [ cpu-a 1 shift HEX: FF bitand ] keep 
  >r bitor r> set-cpu-a ;

: (emulate-RRCA) ( cpu -- )
  #! The content of the accumulator is rotated right
  #! one position. The high order bit and the carry flag
  #! are both set to the value shifted out of the low
  #! order bit position. Only the carry flag is affected.
  [ cpu-a 1 bitand 7 shift ] keep 
  over 0 = [ dup carry-flag clear-flag ] [ dup carry-flag set-flag ] ifte
  [ cpu-a 254 bitand -1 shift ] keep 
  >r bitor r> set-cpu-a ;

: (emulate-RLA) ( cpu -- )  
  #! The content of the accumulator is rotated left
  #! one position through the carry flag. The low
  #! order bit is set equal to the carry flag and
  #! the carry flag is set to the value shifted out 
  #! of the high order bit. Only the carry flag is
  #! affected.
  [ carry-flag swap flag-set? [ 1 ] [ 0 ] ifte ] keep 
  [ cpu-a 127 bitand 7 shift ] keep 
  dup cpu-a 128 bitand 0 = [ dup carry-flag clear-flag ] [ dup carry-flag set-flag ] ifte
  >r bitor r> set-cpu-a ;

: (emulate-RRA) ( cpu -- )  
  #! The content of the accumulator is rotated right
  #! one position through the carry flag. The high order
  #! bit is set to the carry flag and the carry flag is
  #! set to the value shifted out of the low order bit. 
  #! Only the carry flag is affected.
  [ carry-flag swap flag-set? [ BIN: 10000000 ] [ 0 ] ifte ] keep 
  [ cpu-a 254 bitand -1 shift ] keep 
  dup cpu-a 1 bitand 0 = [ dup carry-flag clear-flag ] [ dup carry-flag set-flag ] ifte
  >r bitor r> set-cpu-a ;

: (emulate-CPL) ( cpu -- )  
  #! The contents of the accumulator are complemented
  #! (zero bits become one, one bits becomes zero).
  #! No flags are affected.
  HEX: FF swap cpu-a-bitxor= ;

: (emulate-DAA) ( cpu -- )  
  #! The eight bit number in the accumulator is
  #! adjusted to form two four-bit binary-coded-decimal
  #! digits.
  [
    dup half-carry-flag swap flag-set? swap 
    cpu-a BIN: 1111 bitand 9 > or [ 6 ] [ 0 ] ifte 
  ] keep 
  [ cpu-a + ] keep
  [ update-flags ] 2keep  
  [ swap HEX: FF bitand swap set-cpu-a ] keep 
  [
    dup carry-flag swap flag-set? swap 
    cpu-a -4 shift BIN: 1111 bitand 9 > or [ 96 ] [ 0 ] ifte 
  ] keep 
  [ cpu-a + ] keep
  [ update-flags ] 2keep  
  swap HEX: FF bitand swap set-cpu-a ;
  
: patterns ( -- hashtable )
  #! table of code quotation patterns for each type of instruction.
  {{
    [[ "NOP"          [ drop ]               ]]
    [[ "RET-NN"          [ ret-from-sub  ]               ]]
    [[ "RST-0"      [ 0 swap (emulate-RST) ] ]]
    [[ "RST-8"      [ 8 swap (emulate-RST) ] ]]
    [[ "RST-10H"      [ HEX: 10 swap (emulate-RST) ] ]]
    [[ "RST-18H"      [ HEX: 18 swap (emulate-RST) ] ]]
    [[ "RST-20H"      [ HEX: 20 swap (emulate-RST) ] ]]
    [[ "RST-28H"      [ HEX: 28 swap (emulate-RST) ] ]]
    [[ "RST-30H"      [ HEX: 30 swap (emulate-RST) ] ]]
    [[ "RST-38H"      [ HEX: 38 swap (emulate-RST) ] ]]
    [[ "RET-F|FF"      [ dup $1 [ 6 over inc-cycles ret-from-sub ] [ drop ] ifte ] ]]
    [[ "CP-N"      [ [ cpu-a ] keep [ next-byte ] keep sub-byte drop ] ]]
    [[ "CP-R"      [ [ cpu-a ] keep [ $1 ] keep sub-byte drop  ] ]]
    [[ "CP-(RR)"      [ [ cpu-a ] keep [ $1 ] keep [ read-byte ] keep sub-byte drop ] ]]
    [[ "OR-N"      [ [ cpu-a ] keep [ next-byte ] keep [ or-byte ] keep set-cpu-a ] ]]
    [[ "OR-R"      [ [ cpu-a ] keep [ $1 ] keep [ or-byte ] keep set-cpu-a ] ]]
    [[ "OR-(RR)"      [ [ cpu-a ] keep [ $1 ] keep [ read-byte ] keep [ or-byte ] keep set-cpu-a  ] ]]
    [[ "XOR-N"      [ [ cpu-a ] keep [ next-byte ] keep [ xor-byte ] keep set-cpu-a ] ]]
    [[ "XOR-R"      [ [ cpu-a ] keep [ $1 ] keep [ xor-byte ] keep set-cpu-a ] ]]
    [[ "XOR-(RR)"   [ [ cpu-a ] keep [ $1 ] keep [ read-byte ] keep [ xor-byte ] keep set-cpu-a  ] ]]
    [[ "AND-N"      [ [ cpu-a ] keep [ next-byte ] keep [ and-byte ] keep set-cpu-a  ] ]]
    [[ "AND-R"      [ [ cpu-a ] keep [ $1 ] keep [ and-byte ] keep set-cpu-a ] ]]
    [[ "AND-(RR)"      [ [ cpu-a ] keep [ $1 ] keep [ read-byte ] keep [ and-byte ] keep set-cpu-a  ] ]]
    [[ "ADC-R,N"      [ [ $1 ] keep [ next-byte ] keep [ add-byte-with-carry ] keep $2 ] ]]
    [[ "ADC-R,R"      [ [ $1 ] keep [ $3 ] keep [ add-byte-with-carry ] keep $2 ] ]]
    [[ "ADC-R,(RR)"      [ [ $1 ] keep [ $3 ] keep [ read-byte ] keep [ add-byte-with-carry ] keep $2 ] ]]
    [[ "ADD-R,N"      [ [ $1 ] keep [ next-byte ] keep [ add-byte ] keep $2 ] ]]
    [[ "ADD-R,R"      [ [ $1 ] keep [ $3 ] keep [ add-byte ] keep $2 ] ]]
    [[ "ADD-RR,RR"    [ [ $1 ] keep [ $3 ] keep [ add-word ] keep $2 ] ]]
    [[ "ADD-R,(RR)"    [ [ $1 ] keep [ $3 ] keep [ read-byte ] keep [ add-byte ] keep $2   ]  ]]
    [[ "SBC-R,N"      [ [ $1 ] keep [ next-byte ] keep [ sub-byte-with-carry ] keep $2 ] ]]
    [[ "SBC-R,R"      [ [ $1 ] keep [ $3 ] keep [ sub-byte-with-carry ] keep $2 ] ]]
    [[ "SBC-R,(RR)"      [ [ $1 ] keep [ $3 ] keep [ read-byte ] keep [ sub-byte-with-carry ] keep $2 ] ]]
    [[ "SUB-R"      [ [ cpu-a ] keep [ $1 ] keep [ sub-byte ] keep set-cpu-a ] ]]
    [[ "SUB-(RR)"      [ [ cpu-a ] keep [ $1 ] keep [ read-byte ] keep [ sub-byte ] keep set-cpu-a ] ]]
    [[ "SUB-N"      [ [ cpu-a ] keep [ next-byte ] keep [ sub-byte ] keep set-cpu-a ] ]]
    [[ "CPL"          [ (emulate-CPL) ]               ]]
    [[ "DAA"          [ (emulate-DAA) ]               ]]
    [[ "RLA"          [ (emulate-RLA) ]               ]]
    [[ "RRA"          [ (emulate-RRA) ]               ]]
    [[ "CCF"          [ carry-flag swap cpu-f-bitxor= ]               ]]
    [[ "SCF"          [ carry-flag swap cpu-f-bitor= ]               ]]
    [[ "RLCA"          [ (emulate-RLCA) ]               ]]
    [[ "RRCA"          [ (emulate-RRCA) ]               ]]
    [[ "HALT"          [ drop  ]               ]]
    [[ "DI"          [ [ 255 interrupt-flag - ] swap cpu-f-bitand  ]               ]]
    [[ "EI"          [ [ interrupt-flag ] swap cpu-f-bitor  ]  ]]  
    [[ "POP-RR"     [ [ pop-sp ] keep $2 ] ]]
    [[ "PUSH-RR"     [ [ $1 ] keep push-sp ] ]]
    [[ "INC-R"     [ [ $1 ] keep [ inc-byte ] keep $2 ] ]]
    [[ "DEC-R"     [ [ $1 ] keep [ dec-byte ] keep $2 ] ]]
    [[ "INC-RR"     [ [ $1 ] keep [ inc-word ] keep $2 ] ]]
    [[ "DEC-RR"     [ [ $1 ] keep [ dec-word ] keep $2 ] ]]
    [[ "DEC-(RR)"     [ [ $1 ] keep [ read-byte ] keep [ dec-byte ] keep [ $1 ] keep write-byte ] ]]
    [[ "INC-(RR)" [ [ $1 ] keep [ read-byte ] keep [ inc-byte ] keep  [ $1 ] keep write-byte ] ]]
    [[ "JP-NN"           [ [ cpu-pc ] keep [ read-word ] keep set-cpu-pc ]               ]]
    [[ "JP-F|FF,NN"      [ [ $1 ] keep swap [ [ next-word ] keep [ set-cpu-pc ] keep [ cpu-cycles ] keep swap 5 + swap set-cpu-cycles ] [ [ cpu-pc 2 + ] keep set-cpu-pc ] ifte ] ]]
    [[ "JP-(RR)"      [ [ $1 ] keep set-cpu-pc ] ]]
    [[ "CALL-NN"         [ (emulate-CALL) ] ]]
    [[ "CALL-F|FF,NN"    [ [ $1 ] keep swap [ 7 over inc-cycles (emulate-CALL) ] [ [ cpu-pc 2 + ] keep set-cpu-pc ] ifte ]   ]]
    [[ "LD-RR,NN"     [ [ next-word ] keep $2 ] ]]
    [[ "LD-RR,RR"     [ [ $3 ] keep $2 ] ]]
    [[ "LD-R,N"     [ [ next-byte ] keep $2 ] ]]
    [[ "LD-(RR),N"    [ [ next-byte ] keep [ $1 ] keep write-byte ] ]]
    [[ "LD-(RR),R"    [ [ $3 ] keep [ $1 ] keep write-byte ] ]]
    [[ "LD-R,R"    [ [ $3 ] keep $2 ] ]]
    [[ "LD-R,(RR)"    [ [ $3 ] keep [ read-byte ] keep $2  ] ]]
    [[ "LD-(NN),RR"    [ [ $1 ] keep [ next-word ] keep write-word ] ]]
    [[ "LD-(NN),R"    [  [ $1 ] keep [ next-word ] keep write-byte ] ]]
    [[ "LD-RR,(NN)"    [ [ next-word ] keep [ read-word ] keep $2 ]  ]]
    [[ "LD-R,(NN)"    [ [ next-word ] keep [ read-byte ] keep $2 ] ]]
    [[ "OUT-(N),R"    [ [ $1 ] keep [ next-byte ] keep write-port ] ]]
    [[ "IN-R,(N)"    [ [ next-byte ] keep [ read-port ] keep set-cpu-a ] ]]
    [[ "EX-(RR),RR"  [  [ $1 ] keep [ read-word ] keep [ $3 ] keep [ $1 ] keep [ write-word ] keep $4 ] ]]
    [[ "EX-RR,RR"    [ [ $1 ] keep [ $3 ] keep [ $2 ] keep $4 ] ]]
  }} ;

: 8-bit-registers ( -- parser )
  #! A parser for 8-bit registers. On a successfull parse the
  #! parse tree contains a vector. The first item in the vector
  #! is the getter word for that register with stack effect
  #! ( cpu -- value ). The second item is the setter word with
  #! stack effect ( value cpu -- ).
  "A" token 
  "B" token  <|>
  "C" token  <|>
  "D" token  <|>
  "E" token  <|>
  "H" token  <|>
  "L" token  <|> [ register-lookup ] <@ ;

: all-flags
  #! A parser for 16-bit flags. 
  "NZ" token  
  "NC" token <|>
  "PO" token <|>
  "PE" token <|> 
  "Z" token <|> 
  "C" token <|> 
  "P" token <|> 
  "M" token <|> [ flag-lookup ] <@ ;

: 16-bit-registers
  #! A parser for 16-bit registers. On a successfull parse the
  #! parse tree contains a vector. The first item in the vector
  #! is the getter word for that register with stack effect
  #! ( cpu -- value ). The second item is the setter word with
  #! stack effect ( value cpu -- ).
  "AF" token  
  "BC" token <|>
  "DE" token <|>
  "HL" token <|>
  "SP" token <|> [ register-lookup ] <@ ;

: all-registers ( -- parser )
  #! Return a parser that can parse the format
  #! for 8 bit or 16 bit registers. 
  8-bit-registers 16-bit-registers <|> ;

: indirect ( parser -- parser )
  #! Given a parser, return a parser which parses the original
  #! wrapped in brackets, representing an indirect reference.
  #! eg. BC -> (BC). The value of the original parser is left in
  #! the parse tree.
  "(" token swap &> ")" token <& ;

: generate-instruction ( vector string -- quot )
  #! Generate the quotation for an instruction, given the instruction in 
  #! the 'string' and a vector containing the arguments for that instruction.
  patterns hash replace-patterns ;

: simple-instruction ( token -- parser )
  #! Return a parser for then instruction identified by the token. 
  #! The parser return parses the token only and expects no additional
  #! arguments to the instruction.
  token [ [ { } clone , , \ generate-instruction , ] [ ] make ] <@ ;

: complex-instruction ( type token -- parser )
  #! Return a parser for an instruction identified by the token. 
  #! The instruction is expected to take additional arguments by 
  #! being combined with other parsers. Then 'type' is used for a lookup
  #! in a pattern hashtable to return the instruction quotation pattern.
  token swap [ nip [ , \ generate-instruction , ] [ ] make ] cons <@ ;

: NOP-instruction ( -- parser )
  "NOP" simple-instruction ;

: RET-NN-instruction ( -- parser )  
  "RET-NN" "RET" complex-instruction  
  "nn" token sp <&
  just [ { } clone swons  ] <@ ;

: RST-0-instruction ( -- parser )  
  "RST-0" "RST" complex-instruction  
  "0" token sp <&
  just [ { } clone swons  ] <@ ;

: RST-8-instruction ( -- parser )  
  "RST-8" "RST" complex-instruction  
  "8" token sp <&
  just [ { } clone swons  ] <@ ;

: RST-10H-instruction ( -- parser )  
  "RST-10H" "RST" complex-instruction  
  "10H" token sp <&
  just [ { } clone swons  ] <@ ;

: RST-18H-instruction ( -- parser )  
  "RST-18H" "RST" complex-instruction  
  "18H" token sp <&
  just [ { } clone swons  ] <@ ;

: RST-20H-instruction ( -- parser )  
  "RST-20H" "RST" complex-instruction  
  "20H" token sp <&
  just [ { } clone swons  ] <@ ;

: RST-28H-instruction ( -- parser )  
  "RST-28H" "RST" complex-instruction  
  "28H" token sp <&
  just [ { } clone swons  ] <@ ;

: RST-30H-instruction ( -- parser )  
  "RST-30H" "RST" complex-instruction  
  "30H" token sp <&
  just [ { } clone swons  ] <@ ;

: RST-38H-instruction ( -- parser )  
  "RST-38H" "RST" complex-instruction  
  "38H" token sp <&
  just [ { } clone swons  ] <@ ;

: JP-NN-instruction ( -- parser )  
  "JP-NN" "JP" complex-instruction  
  "nn" token sp <&
  just [ { } clone swons  ] <@ ;

: JP-F|FF,NN-instruction ( -- parser )
  "JP-F|FF,NN" "JP" complex-instruction  
  all-flags sp <&> 
  ",nn" token <&
  just [ uncons swons ] <@ ;

: JP-(RR)-instruction ( -- parser )
  "JP-(RR)" "JP" complex-instruction  
  16-bit-registers indirect sp <&>
  just [ uncons swons ] <@ ;

: CALL-NN-instruction ( -- parser )  
  "CALL-NN" "CALL" complex-instruction  
  "nn" token sp <&
  just [ { } clone swons  ] <@ ;

: CALL-F|FF,NN-instruction ( -- parser )
  "CALL-F|FF,NN" "CALL" complex-instruction  
  all-flags sp <&> 
  ",nn" token <&
  just [ uncons swons ] <@ ;

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
  "DEC-R" "DEC" complex-instruction  8-bit-registers sp <&> 
  just [ uncons swons ] <@ ;

: DEC-RR-instruction ( -- parser )
  "DEC-RR" "DEC" complex-instruction  16-bit-registers sp <&> 
  just [ uncons swons ] <@ ;

: DEC-(RR)-instruction ( -- parser )
  "DEC-(RR)" "DEC" complex-instruction  
  16-bit-registers indirect sp <&>
  just [ uncons swons ] <@ ;

: POP-RR-instruction ( -- parser )
  "POP-RR" "POP" complex-instruction  all-registers sp <&> 
  just [ uncons swons ] <@ ;

: PUSH-RR-instruction ( -- parser )
  "PUSH-RR" "PUSH" complex-instruction  all-registers sp <&> 
  just [ uncons swons ] <@ ;

: INC-R-instruction ( -- parser )
  "INC-R" "INC" complex-instruction  8-bit-registers sp <&> 
  just [ uncons swons ] <@ ;

: INC-RR-instruction ( -- parser )
  "INC-RR" "INC" complex-instruction  16-bit-registers sp <&> 
  just [ uncons swons ] <@ ;
   
: INC-(RR)-instruction  ( -- parser )
  "INC-(RR)" "INC" complex-instruction
  all-registers indirect sp <&> just [ uncons swons ] <@ ;

: RET-F|FF-instruction ( -- parser )
  "RET-F|FF" "RET" complex-instruction  all-flags sp <&> 
  just [ uncons swons ] <@ ;

: AND-N-instruction ( -- parser )
  "AND-N" "AND" complex-instruction
  "n" token sp <&
  just [ { } clone swons  ] <@ ;

: AND-R-instruction  ( -- parser )
  "AND-R" "AND" complex-instruction
  8-bit-registers sp <&> just [ uncons swons ] <@ ;

: AND-(RR)-instruction  ( -- parser )
  "AND-(RR)" "AND" complex-instruction
  16-bit-registers indirect sp <&> just [ uncons swons ] <@ ;

: XOR-N-instruction ( -- parser )
  "XOR-N" "XOR" complex-instruction
  "n" token sp <&
  just [ { } clone swons  ] <@ ;

: XOR-R-instruction  ( -- parser )
  "XOR-R" "XOR" complex-instruction
  8-bit-registers sp <&> just [ uncons swons ] <@ ;

: XOR-(RR)-instruction  ( -- parser )
  "XOR-(RR)" "XOR" complex-instruction
  16-bit-registers indirect sp <&> just [ uncons swons ] <@ ;

: OR-N-instruction ( -- parser )
  "OR-N" "OR" complex-instruction
  "n" token sp <&
  just [ { } clone swons  ] <@ ;

: OR-R-instruction  ( -- parser )
  "OR-R" "OR" complex-instruction
  8-bit-registers sp <&> just [ uncons swons ] <@ ;

: OR-(RR)-instruction  ( -- parser )
  "OR-(RR)" "OR" complex-instruction
  16-bit-registers indirect sp <&> just [ uncons swons ] <@ ;

: CP-N-instruction ( -- parser )
  "CP-N" "CP" complex-instruction
  "n" token sp <&
  just [ { } clone swons  ] <@ ;

: CP-R-instruction  ( -- parser )
  "CP-R" "CP" complex-instruction
  8-bit-registers sp <&> just [ uncons swons ] <@ ;

: CP-(RR)-instruction  ( -- parser )
  "CP-(RR)" "CP" complex-instruction
  16-bit-registers indirect sp <&> just [ uncons swons ] <@ ;

: ADC-R,N-instruction ( -- parser )
  "ADC-R,N" "ADC" complex-instruction
  8-bit-registers sp <&>
  ",n" token <& 
  just [ uncons swons ] <@ ;  

: ADC-R,R-instruction ( -- parser )
  "ADC-R,R" "ADC" complex-instruction
  8-bit-registers sp <&>
  "," token <& 
  8-bit-registers <&>
  just [ unswons unswons >r swap append r> cons ] <@ ;  

: ADC-R,(RR)-instruction ( -- parser )
  "ADC-R,(RR)" "ADC" complex-instruction
  8-bit-registers sp <&>
  "," token <& 
  16-bit-registers indirect <&>
  just [ unswons unswons >r swap append r> cons ] <@ ;  

: SBC-R,N-instruction ( -- parser )
  "SBC-R,N" "SBC" complex-instruction
  8-bit-registers sp <&>
  ",n" token <& 
  just [ uncons swons ] <@ ;  

: SBC-R,R-instruction ( -- parser )
  "SBC-R,R" "SBC" complex-instruction
  8-bit-registers sp <&>
  "," token <& 
  8-bit-registers <&>
  just [ unswons unswons >r swap append r> cons ] <@ ;  

: SBC-R,(RR)-instruction ( -- parser )
  "SBC-R,(RR)" "SBC" complex-instruction
  8-bit-registers sp <&>
  "," token <& 
  16-bit-registers indirect  <&>
  just [ unswons unswons >r swap append r> cons ] <@ ;  

: SUB-R-instruction ( -- parser )
  "SUB-R" "SUB" complex-instruction
  8-bit-registers sp <&>
  just [ uncons swons ] <@ ;  

: SUB-(RR)-instruction ( -- parser )
  "SUB-(RR)" "SUB" complex-instruction
  16-bit-registers indirect sp <&>
  just [ uncons swons ] <@ ;  

: SUB-N-instruction ( -- parser )
  "SUB-N" "SUB" complex-instruction
  "n" token sp <&
  just [ { } clone swons  ] <@ ;

: ADD-R,N-instruction ( -- parser )
  "ADD-R,N" "ADD" complex-instruction
  8-bit-registers sp <&>
  ",n" token <& 
  just [ uncons swons ] <@ ;  

: ADD-R,R-instruction ( -- parser )
  "ADD-R,R" "ADD" complex-instruction
  8-bit-registers sp <&>
  "," token <& 
  8-bit-registers <&>
  just [ unswons unswons >r swap append r> cons ] <@ ;  

: ADD-RR,RR-instruction ( -- parser )
  "ADD-RR,RR" "ADD" complex-instruction
  16-bit-registers sp <&>
  "," token <& 
  16-bit-registers <&>
  just [ unswons unswons >r swap append r> cons ] <@ ;  

: ADD-R,(RR)-instruction ( -- parser )
  "ADD-R,(RR)" "ADD" complex-instruction
  8-bit-registers sp <&>
  "," token <& 
  16-bit-registers indirect <&>
  just [ unswons unswons >r swap append r> cons ] <@ ;  
  
: LD-RR,NN-instruction
  #! LD BC,nn
  "LD-RR,NN" "LD" complex-instruction
  16-bit-registers sp <&>
  ",nn" token <& 
  just [ uncons swons ] <@ ;

: LD-R,N-instruction
  #! LD B,n
  "LD-R,N" "LD" complex-instruction
  8-bit-registers sp <&>
  ",n" token <& 
  just [ uncons swons ] <@ ;
  
: LD-(RR),N-instruction
  "LD-(RR),N" "LD" complex-instruction
  16-bit-registers indirect sp <&> 
  ",n" token <&
  just [ uncons swons ] <@ ;

: LD-(RR),R-instruction
  #! LD (BC),A
  "LD-(RR),R" "LD" complex-instruction
  16-bit-registers indirect sp <&> 
  "," token <&
  8-bit-registers <&>
  just [ unswons unswons >r swap append r> cons ] <@ ;  

: LD-R,R-instruction
  "LD-R,R" "LD" complex-instruction
  8-bit-registers sp <&> 
  "," token <&
  8-bit-registers <&>
  just [ unswons unswons >r swap append r> cons ] <@ ;  

: LD-RR,RR-instruction
  "LD-RR,RR" "LD" complex-instruction
  16-bit-registers sp <&> 
  "," token <&
  16-bit-registers <&>
  just [ unswons unswons >r swap append r> cons ] <@ ;  

: LD-R,(RR)-instruction
  "LD-R,(RR)" "LD" complex-instruction
  8-bit-registers sp <&> 
  "," token <&
  16-bit-registers indirect <&>
  just [ unswons unswons >r swap append r> cons ] <@ ;  

: LD-(NN),RR-instruction
  "LD-(NN),RR" "LD" complex-instruction
  "nn" token indirect sp <&
  "," token <&
  16-bit-registers <&>
  just [ uncons swons ] <@ ;

: LD-(NN),R-instruction
  "LD-(NN),R" "LD" complex-instruction
  "nn" token indirect sp <&
  "," token <&
  8-bit-registers <&>
  just [ uncons swons ] <@ ;

: LD-RR,(NN)-instruction
  "LD-RR,(NN)" "LD" complex-instruction
  16-bit-registers sp <&>
  "," token <&
  "nn" token indirect <&
  just [ uncons swons ] <@ ;

: LD-R,(NN)-instruction
  "LD-R,(NN)" "LD" complex-instruction
  8-bit-registers sp <&>
  "," token <&
  "nn" token indirect <&
  just [ uncons swons ] <@ ;

: OUT-(N),R-instruction
  "OUT-(N),R" "OUT" complex-instruction
  "n" token indirect sp <&
  "," token <&
  8-bit-registers <&>
  just [ uncons swons ] <@ ;

: IN-R,(N)-instruction
  "IN-R,(N)" "IN" complex-instruction
  8-bit-registers sp <&>
  "," token <&
  "n" token indirect <&
  just [ uncons swons ] <@ ;

: EX-(RR),RR-instruction
  "EX-(RR),RR" "EX" complex-instruction
  16-bit-registers indirect sp <&> 
  "," token <&
  16-bit-registers <&>
  just [ unswons unswons >r swap append r> cons ] <@ ;  

: EX-RR,RR-instruction
  "EX-RR,RR" "EX" complex-instruction
  16-bit-registers sp <&> 
  "," token <&
  16-bit-registers <&>
  just [ unswons unswons >r swap append r> cons ] <@ ;  

: 8080-generator-parser
  NOP-instruction 
  RST-0-instruction <|> 
  RST-8-instruction <|> 
  RST-10H-instruction <|> 
  RST-18H-instruction <|> 
  RST-20H-instruction <|> 
  RST-28H-instruction <|> 
  RST-30H-instruction <|> 
  RST-38H-instruction <|> 
  JP-F|FF,NN-instruction <|> 
  JP-NN-instruction <|> 
  JP-(RR)-instruction <|> 
  CALL-F|FF,NN-instruction <|> 
  CALL-NN-instruction <|> 
  CPL-instruction <|> 
  CCF-instruction <|> 
  SCF-instruction <|> 
  DAA-instruction <|> 
  RLA-instruction <|> 
  RRA-instruction <|> 
  RLCA-instruction <|> 
  RRCA-instruction <|> 
  HALT-instruction <|> 
  DI-instruction <|> 
  EI-instruction <|> 
  AND-N-instruction <|> 
  AND-R-instruction <|> 
  AND-(RR)-instruction <|> 
  XOR-N-instruction <|> 
  XOR-R-instruction <|> 
  XOR-(RR)-instruction <|> 
  OR-N-instruction <|> 
  OR-R-instruction <|> 
  OR-(RR)-instruction <|> 
  CP-N-instruction <|> 
  CP-R-instruction <|> 
  CP-(RR)-instruction <|> 
  DEC-RR-instruction <|> 
  DEC-R-instruction <|> 
  DEC-(RR)-instruction <|> 
  POP-RR-instruction <|> 
  PUSH-RR-instruction <|> 
  INC-RR-instruction <|> 
  INC-R-instruction <|> 
  INC-(RR)-instruction <|>
  LD-RR,NN-instruction <|> 
  LD-R,N-instruction <|> 
  LD-R,R-instruction <|> 
  LD-RR,RR-instruction <|> 
  LD-(RR),N-instruction <|> 
  LD-(RR),R-instruction <|> 
  LD-R,(RR)-instruction <|> 
  LD-(NN),RR-instruction <|> 
  LD-(NN),R-instruction <|> 
  LD-RR,(NN)-instruction <|> 
  LD-R,(NN)-instruction <|> 
  ADC-R,N-instruction <|> 
  ADC-R,R-instruction <|> 
  ADC-R,(RR)-instruction <|> 
  ADD-R,N-instruction <|> 
  ADD-R,R-instruction <|> 
  ADD-RR,RR-instruction <|> 
  ADD-R,(RR)-instruction <|> 
  SBC-R,N-instruction <|> 
  SBC-R,R-instruction <|> 
  SBC-R,(RR)-instruction <|> 
  SUB-R-instruction <|> 
  SUB-(RR)-instruction <|> 
  SUB-N-instruction <|> 
  RET-F|FF-instruction <|> 
  RET-NN-instruction <|>
  OUT-(N),R-instruction <|>
  IN-R,(N)-instruction <|>
  EX-(RR),RR-instruction <|>
  EX-RR,RR-instruction <|>
  just ;

: instruction-quotations ( string -- emulate-quot )
  #! Given an instruction string, return the emulation quotation for
  #! it. This will later be expanded to produce the disassembly and
  #! assembly quotations.
  8080-generator-parser some call call ;

SYMBOL: last-instruction
SYMBOL: last-opcode

: parse-instructions ( list -- emulate-quot )
  #! Process the list of strings, which should make
  #! up an 8080 instruction, and output a quotation
  #! that would implement that instruction.
  dup " " join instruction-quotations
  >r "_" join [ "emulate-" % % ] "" make create-in dup last-instruction global set-hash  
  r> define-compound ;

: INSTRUCTION: string-mode on [ string-mode off parse-instructions ] f ; parsing

: cycles ( n -- )
  #! Set the number of cycles for the last instruction that was defined. 
  scan string>number last-opcode global hash instruction-cycles set-nth ; parsing

: opcode ( n -- )
  #! Set the opcode number for the last instruction that was defined.
  last-instruction global hash unit scan 16 base> ( [word] opcode -- )
  dup last-opcode global set-hash instructions set-nth ; parsing


INSTRUCTION: NOP          ; opcode 00 cycles 04 
INSTRUCTION: LD   BC,nn   ; opcode 01 cycles 10 
INSTRUCTION: LD   (BC),A  ; opcode 02 cycles 07 
INSTRUCTION: INC  BC      ; opcode 03 cycles 06 
INSTRUCTION: INC  B       ; opcode 04 cycles 05 
INSTRUCTION: DEC  B       ; opcode 05 cycles 05 
INSTRUCTION: LD   B,n     ; opcode 06 cycles 07 
INSTRUCTION: RLCA         ; opcode 07 cycles 04 
INSTRUCTION: NOP          ; opcode 08 cycles 04 
INSTRUCTION: ADD  HL,BC   ; opcode 09 cycles 11 
INSTRUCTION: LD   A,(BC)  ; opcode 0A cycles 07 
INSTRUCTION: DEC  BC      ; opcode 0B cycles 06 
INSTRUCTION: INC  C       ; opcode 0C cycles 05 
INSTRUCTION: DEC  C       ; opcode 0D cycles 05 
INSTRUCTION: LD   C,n     ; opcode 0E cycles 07 
INSTRUCTION: RRCA         ; opcode 0F cycles 04 
INSTRUCTION: LD   DE,nn   ; opcode 11 cycles 10 
INSTRUCTION: LD   (DE),A  ; opcode 12 cycles 07 
INSTRUCTION: INC  DE      ; opcode 13 cycles 06 
INSTRUCTION: INC  D       ; opcode 14 cycles 05 
INSTRUCTION: DEC  D       ; opcode 15 cycles 05 
INSTRUCTION: LD   D,n     ; opcode 16 cycles 07 
INSTRUCTION: RLA          ; opcode 17 cycles 04 
INSTRUCTION: ADD  HL,DE   ; opcode 19 cycles 11 
INSTRUCTION: LD   A,(DE)  ; opcode 1A cycles 07 
INSTRUCTION: DEC  DE      ; opcode 1B cycles 06 
INSTRUCTION: INC  E       ; opcode 1C cycles 05 
INSTRUCTION: DEC  E       ; opcode 1D cycles 05 
INSTRUCTION: LD   E,n     ; opcode 1E cycles 07 
INSTRUCTION: RRA          ; opcode 1F cycles 04 
INSTRUCTION: LD   HL,nn   ; opcode 21 cycles 10 
INSTRUCTION: LD   (nn),HL ; opcode 22 cycles 16 
INSTRUCTION: INC  HL      ; opcode 23 cycles 06 
INSTRUCTION: INC  H       ; opcode 24 cycles 05 
INSTRUCTION: DEC  H       ; opcode 25 cycles 05 
INSTRUCTION: LD   H,n     ; opcode 26 cycles 07 
INSTRUCTION: DAA          ; opcode 27 cycles 04 
INSTRUCTION: ADD  HL,HL   ; opcode 29 cycles 11 
INSTRUCTION: LD   HL,(nn) ; opcode 2A cycles 16 
INSTRUCTION: DEC  HL      ; opcode 2B cycles 06 
INSTRUCTION: INC  L       ; opcode 2C cycles 05 
INSTRUCTION: DEC  L       ; opcode 2D cycles 05 
INSTRUCTION: LD   L,n     ; opcode 2E cycles 07 
INSTRUCTION: CPL          ; opcode 2F cycles 04 
INSTRUCTION: LD   SP,nn   ; opcode 31 cycles 10 
INSTRUCTION: LD   (nn),A  ; opcode 32 cycles 13 
INSTRUCTION: INC  SP      ; opcode 33 cycles 06 
INSTRUCTION: INC  (HL)    ; opcode 34 cycles 10 
INSTRUCTION: DEC  (HL)    ; opcode 35 cycles 10 
INSTRUCTION: LD   (HL),n  ; opcode 36 cycles 10 
INSTRUCTION: SCF          ; opcode 37 cycles 04 
INSTRUCTION: ADD  HL,SP   ; opcode 39 cycles 11 
INSTRUCTION: LD   A,(nn)  ; opcode 3A cycles 13 
INSTRUCTION: DEC  SP      ; opcode 3B cycles 06 
INSTRUCTION: INC  A       ; opcode 3C cycles 05 
INSTRUCTION: DEC  A       ; opcode 3D cycles 05 
INSTRUCTION: LD   A,n     ; opcode 3E cycles 07 
INSTRUCTION: CCF          ; opcode 3F cycles 04 
INSTRUCTION: LD   B,B     ; opcode 40 cycles 05 
INSTRUCTION: LD   B,C     ; opcode 41 cycles 05 
INSTRUCTION: LD   B,D     ; opcode 42 cycles 05 
INSTRUCTION: LD   B,E     ; opcode 43 cycles 05 
INSTRUCTION: LD   B,H     ; opcode 44 cycles 05 
INSTRUCTION: LD   B,L     ; opcode 45 cycles 05 
INSTRUCTION: LD   B,(HL)  ; opcode 46 cycles 07 
INSTRUCTION: LD   B,A     ; opcode 47 cycles 05 
INSTRUCTION: LD   C,B     ; opcode 48 cycles 05 
INSTRUCTION: LD   C,C     ; opcode 49 cycles 05 
INSTRUCTION: LD   C,D     ; opcode 4A cycles 05 
INSTRUCTION: LD   C,E     ; opcode 4B cycles 05 
INSTRUCTION: LD   C,H     ; opcode 4C cycles 05 
INSTRUCTION: LD   C,L     ; opcode 4D cycles 05 
INSTRUCTION: LD   C,(HL)  ; opcode 4E cycles 07 
INSTRUCTION: LD   C,A     ; opcode 4F cycles 05 
INSTRUCTION: LD   D,B     ; opcode 50 cycles 05 
INSTRUCTION: LD   D,C     ; opcode 51 cycles 05 
INSTRUCTION: LD   D,D     ; opcode 52 cycles 05 
INSTRUCTION: LD   D,E     ; opcode 53 cycles 05 
INSTRUCTION: LD   D,H     ; opcode 54 cycles 05 
INSTRUCTION: LD   D,L     ; opcode 55 cycles 05 
INSTRUCTION: LD   D,(HL)  ; opcode 56 cycles 07 
INSTRUCTION: LD   D,A     ; opcode 57 cycles 05 
INSTRUCTION: LD   E,B     ; opcode 58 cycles 05 
INSTRUCTION: LD   E,C     ; opcode 59 cycles 05 
INSTRUCTION: LD   E,D     ; opcode 5A cycles 05 
INSTRUCTION: LD   E,E     ; opcode 5B cycles 05 
INSTRUCTION: LD   E,H     ; opcode 5C cycles 05 
INSTRUCTION: LD   E,L     ; opcode 5D cycles 05 
INSTRUCTION: LD   E,(HL)  ; opcode 5E cycles 07 
INSTRUCTION: LD   E,A     ; opcode 5F cycles 05 
INSTRUCTION: LD   H,B     ; opcode 60 cycles 05 
INSTRUCTION: LD   H,C     ; opcode 61 cycles 05 
INSTRUCTION: LD   H,D     ; opcode 62 cycles 05 
INSTRUCTION: LD   H,E     ; opcode 63 cycles 05 
INSTRUCTION: LD   H,H     ; opcode 64 cycles 05 
INSTRUCTION: LD   H,L     ; opcode 65 cycles 05 
INSTRUCTION: LD   H,(HL)  ; opcode 66 cycles 07 
INSTRUCTION: LD   H,A     ; opcode 67 cycles 05 
INSTRUCTION: LD   L,B     ; opcode 68 cycles 05 
INSTRUCTION: LD   L,C     ; opcode 69 cycles 05 
INSTRUCTION: LD   L,D     ; opcode 6A cycles 05 
INSTRUCTION: LD   L,E     ; opcode 6B cycles 05 
INSTRUCTION: LD   L,H     ; opcode 6C cycles 05 
INSTRUCTION: LD   L,L     ; opcode 6D cycles 05 
INSTRUCTION: LD   L,(HL)  ; opcode 6E cycles 07 
INSTRUCTION: LD   L,A     ; opcode 6F cycles 05 
INSTRUCTION: LD   (HL),B  ; opcode 70 cycles 07 
INSTRUCTION: LD   (HL),C  ; opcode 71 cycles 07 
INSTRUCTION: LD   (HL),D  ; opcode 72 cycles 07 
INSTRUCTION: LD   (HL),E  ; opcode 73 cycles 07 
INSTRUCTION: LD   (HL),H  ; opcode 74 cycles 07 
INSTRUCTION: LD   (HL),L  ; opcode 75 cycles 07 
INSTRUCTION: HALT         ; opcode 76 cycles 07 
INSTRUCTION: LD   (HL),A  ; opcode 77 cycles 07 
INSTRUCTION: LD   A,B     ; opcode 78 cycles 05 
INSTRUCTION: LD   A,C     ; opcode 79 cycles 05 
INSTRUCTION: LD   A,D     ; opcode 7A cycles 05 
INSTRUCTION: LD   A,E     ; opcode 7B cycles 05 
INSTRUCTION: LD   A,H     ; opcode 7C cycles 05 
INSTRUCTION: LD   A,L     ; opcode 7D cycles 05 
INSTRUCTION: LD   A,(HL)  ; opcode 7E cycles 07 
INSTRUCTION: LD   A,A     ; opcode 7F cycles 05 
INSTRUCTION: ADD  A,B     ; opcode 80 cycles 04 
INSTRUCTION: ADD  A,C     ; opcode 81 cycles 04 
INSTRUCTION: ADD  A,D     ; opcode 82 cycles 04 
INSTRUCTION: ADD  A,E     ; opcode 83 cycles 04 
INSTRUCTION: ADD  A,H     ; opcode 84 cycles 04 
INSTRUCTION: ADD  A,L     ; opcode 85 cycles 04 
INSTRUCTION: ADD  A,(HL)  ; opcode 86 cycles 07 
INSTRUCTION: ADD  A,A     ; opcode 87 cycles 04 
INSTRUCTION: ADC  A,B     ; opcode 88 cycles 04 
INSTRUCTION: ADC  A,C     ; opcode 89 cycles 04 
INSTRUCTION: ADC  A,D     ; opcode 8A cycles 04 
INSTRUCTION: ADC  A,E     ; opcode 8B cycles 04 
INSTRUCTION: ADC  A,H     ; opcode 8C cycles 04 
INSTRUCTION: ADC  A,L     ; opcode 8D cycles 04 
INSTRUCTION: ADC  A,(HL)  ; opcode 8E cycles 07 
INSTRUCTION: ADC  A,A     ; opcode 8F cycles 04 
INSTRUCTION: SUB  B       ; opcode 90 cycles 04 
INSTRUCTION: SUB  C       ; opcode 91 cycles 04 
INSTRUCTION: SUB  D       ; opcode 92 cycles 04 
INSTRUCTION: SUB  E       ; opcode 93 cycles 04 
INSTRUCTION: SUB  H       ; opcode 94 cycles 04 
INSTRUCTION: SUB  L       ; opcode 95 cycles 04 
INSTRUCTION: SUB  (HL)    ; opcode 96 cycles 07 
INSTRUCTION: SUB  A       ; opcode 97 cycles 04 
INSTRUCTION: SBC  A,B     ; opcode 98 cycles 04 
INSTRUCTION: SBC  A,C     ; opcode 99 cycles 04 
INSTRUCTION: SBC  A,D     ; opcode 9A cycles 04 
INSTRUCTION: SBC  A,E     ; opcode 9B cycles 04 
INSTRUCTION: SBC  A,H     ; opcode 9C cycles 04 
INSTRUCTION: SBC  A,L     ; opcode 9D cycles 04 
INSTRUCTION: SBC  A,(HL)  ; opcode 9E cycles 07 
INSTRUCTION: SBC  A,A     ; opcode 9F cycles 04 
INSTRUCTION: AND  B       ; opcode A0 cycles 04 
INSTRUCTION: AND  C       ; opcode A1 cycles 04 
INSTRUCTION: AND  D       ; opcode A2 cycles 04 
INSTRUCTION: AND  E       ; opcode A3 cycles 04 
INSTRUCTION: AND  H       ; opcode A4 cycles 04 
INSTRUCTION: AND  L       ; opcode A5 cycles 04 
INSTRUCTION: AND  (HL)    ; opcode A6 cycles 07 
INSTRUCTION: AND  A       ; opcode A7 cycles 04 
INSTRUCTION: XOR  B       ; opcode A8 cycles 04 
INSTRUCTION: XOR  C       ; opcode A9 cycles 04 
INSTRUCTION: XOR  D       ; opcode AA cycles 04 
INSTRUCTION: XOR  E       ; opcode AB cycles 04 
INSTRUCTION: XOR  H       ; opcode AC cycles 04 
INSTRUCTION: XOR  L       ; opcode AD cycles 04 
INSTRUCTION: XOR  (HL)    ; opcode AE cycles 07 
INSTRUCTION: XOR  A       ; opcode AF cycles 04 
INSTRUCTION: OR   B       ; opcode B0 cycles 04 
INSTRUCTION: OR   C       ; opcode B1 cycles 04 
INSTRUCTION: OR   D       ; opcode B2 cycles 04 
INSTRUCTION: OR   E       ; opcode B3 cycles 04 
INSTRUCTION: OR   H       ; opcode B4 cycles 04 
INSTRUCTION: OR   L       ; opcode B5 cycles 04 
INSTRUCTION: OR   (HL)    ; opcode B6 cycles 07 
INSTRUCTION: OR   A       ; opcode B7 cycles 04 
INSTRUCTION: CP   B       ; opcode B8 cycles 04 
INSTRUCTION: CP   C       ; opcode B9 cycles 04 
INSTRUCTION: CP   D       ; opcode BA cycles 04 
INSTRUCTION: CP   E       ; opcode BB cycles 04 
INSTRUCTION: CP   H       ; opcode BC cycles 04 
INSTRUCTION: CP   L       ; opcode BD cycles 04 
INSTRUCTION: CP   (HL)    ; opcode BE cycles 07 
INSTRUCTION: CP   A       ; opcode BF cycles 04 
INSTRUCTION: RET  NZ      ; opcode C0 cycles 05 
INSTRUCTION: POP  BC      ; opcode C1 cycles 10 
INSTRUCTION: JP   NZ,nn   ; opcode C2 cycles 10 
INSTRUCTION: JP   nn      ; opcode C3 cycles 10 
INSTRUCTION: CALL NZ,nn   ; opcode C4 cycles 11 
INSTRUCTION: PUSH BC      ; opcode C5 cycles 11 
INSTRUCTION: ADD  A,n     ; opcode C6 cycles 07 
INSTRUCTION: RST  0       ; opcode C7 cycles 11 
INSTRUCTION: RET  Z       ; opcode C8 cycles 05 
INSTRUCTION: RET  nn      ; opcode C9 cycles 10 
INSTRUCTION: JP   Z,nn    ; opcode CA cycles 10 
INSTRUCTION: CALL Z,nn    ; opcode CC cycles 11 
INSTRUCTION: CALL nn      ; opcode CD cycles 17 
INSTRUCTION: ADC  A,n     ; opcode CE cycles 07 
INSTRUCTION: RST  8       ; opcode CF cycles 11 
INSTRUCTION: RET  NC      ; opcode D0 cycles 05 
INSTRUCTION: POP  DE      ; opcode D1 cycles 10 
INSTRUCTION: JP   NC,nn   ; opcode D2 cycles 10 
INSTRUCTION: OUT  (n),A   ; opcode D3 cycles 10 
INSTRUCTION: CALL NC,nn   ; opcode D4 cycles 11 
INSTRUCTION: PUSH DE      ; opcode D5 cycles 11 
INSTRUCTION: SUB  n       ; opcode D6 cycles 07 
INSTRUCTION: RST  10H     ; opcode D7 cycles 11 
INSTRUCTION: RET  C       ; opcode D8 cycles 05 
INSTRUCTION: JP   C,nn    ; opcode DA cycles 10 
INSTRUCTION: IN   A,(n)   ; opcode DB cycles 10 
INSTRUCTION: CALL C,nn    ; opcode DC cycles 11 
INSTRUCTION: SBC  A,n     ; opcode DE cycles 07 
INSTRUCTION: RST  18H     ; opcode DF cycles 11 
INSTRUCTION: RET  PO      ; opcode E0 cycles 05 
INSTRUCTION: POP  HL      ; opcode E1 cycles 10 
INSTRUCTION: JP   PO,nn   ; opcode E2 cycles 10 
INSTRUCTION: EX   (SP),HL ; opcode E3 cycles 04 
INSTRUCTION: CALL PO,nn   ; opcode E4 cycles 11 
INSTRUCTION: PUSH HL      ; opcode E5 cycles 11 
INSTRUCTION: AND  n       ; opcode E6 cycles 07 
INSTRUCTION: RST  20H     ; opcode E7 cycles 11 
INSTRUCTION: RET  PE      ; opcode E8 cycles 05 
INSTRUCTION: JP   (HL)    ; opcode E9 cycles 04 
INSTRUCTION: JP   PE,nn   ; opcode EA cycles 10 
INSTRUCTION: EX   DE,HL   ; opcode EB cycles 04 
INSTRUCTION: CALL PE,nn   ; opcode EC cycles 11 
INSTRUCTION: XOR  n       ; opcode EE cycles 07 
INSTRUCTION: RST  28H     ; opcode EF cycles 11 
INSTRUCTION: RET  P       ; opcode F0 cycles 05 
INSTRUCTION: POP  AF      ; opcode F1 cycles 10 
INSTRUCTION: JP   P,nn    ; opcode F2 cycles 10 
INSTRUCTION: DI           ; opcode F3 cycles 04 
INSTRUCTION: CALL P,nn    ; opcode F4 cycles 11 
INSTRUCTION: PUSH AF      ; opcode F5 cycles 11 
INSTRUCTION: OR   n       ; opcode F6 cycles 07 
INSTRUCTION: RST  30H     ; opcode F7 cycles 11 
INSTRUCTION: RET  M       ; opcode F8 cycles 05 
INSTRUCTION: LD   SP,HL   ; opcode F9 cycles 06 
INSTRUCTION: JP   M,nn    ; opcode FA cycles 10 
INSTRUCTION: EI           ; opcode FB cycles 04 
INSTRUCTION: CALL M,nn    ; opcode FC cycles 11 
INSTRUCTION: CP   n       ; opcode FE cycles 07 
INSTRUCTION: RST  38H     ; opcode FF cycles 11 

: each-8bit ( n quot -- )
  8 [ ( n quot bit )
   pick over -1 * shift 1 bitand pick call 
  ] repeat 2drop ;

: >ppm ( cpu filename -- cpu )
  #! Dump the current screen image to a ppm image file with the given name.
  <file-writer> [
    "P3" print
    "256 224" print
    "1" print
    224 [ ( cpu h -- h )
      32 [ ( cpu h w -- w )
        over 32 * over +  HEX: 2400 + ( cpu h w addr )
        >r pick r> swap cpu-ram nth [
          0 = [
            " 0 0 0" write
          ] [
            " 1 1 1" write
          ] ifte
        ] each-8bit
      ] repeat terpri
    ] repeat
  ] with-stream ;

USE: test
: time-test ( -- )
  test-cpu [ 1000000 run-n ] time ;

