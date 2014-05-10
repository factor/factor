USING: help.markup help.syntax math ;
IN: cpu.x86

HELP: stack-reg
{ $values { "reg" "a register symbol" } }
{ $description
  "Symbol of the machine register that holds the (cpu) stack address."
} ;

HELP: ds-reg
{ $values { "reg" "a register symbol" } }
{ $description
  "Symbol of the machine register that holds the address to the data stack's location."
} ;

HELP: (%inc)
{ $values { "n" number } { "reg" "a register symbol" } }
{ $description
  "Emits machine code for increasing or decreasing the given register a number of cell sizes bytes."
}
{ $examples
  { $unchecked-example
    "USING: cpu.x86 make prettyprint ;"
    "[ 8 ECX (%inc) ] B{ } make disassemble"
    "00000000615e5140: 83c140  add ecx, 0x40"
  }
} ;

HELP: load-zone-offset
{ $values { "nursery-ptr" "a register symbol" } }
{ $description
  "Emits machine code for loading the address to the nursery into the machine register."
}
{ $examples
  { $unchecked-example
    "USING: cpu.x86 make ;"
    "[ RCX load-zone-offset ] B{ } make disassemble"
    "0000000001b48f80: 498d4d10  lea rcx, [r13+0x10]"
  }
} ;

HELP: copy-register*
{ $values
  { "dst" "a register symbol" }
  { "src" "a register symbol" }
  { "rep" "a value representation singleton" }
}
{ $description
  "Emits machine code for copying from a register to another."
}
{ $examples
  { $unchecked-example
    "USING: cpu.x86 make ;"
    "[ XMM1 XMM2 double-rep copy-register* ] B{ } make disassemble"
    "0000000533c61fe0: 0f28ca  movaps xmm1, xmm2"
  }
} ;
