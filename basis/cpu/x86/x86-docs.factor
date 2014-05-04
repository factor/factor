USING: help.markup help.syntax ;
IN: cpu.x86

HELP: stack-reg
{ $description
  "Symbol of the machine register that holds the (cpu) stack address."
} ;

HELP: ds-reg
{ $description
  "Symbol of the machine register that holds the address to the data stack's location."
} ;

HELP: (%inc)
{ $description
  "Generates machine code for increasing or decreasing the given register a number of cell sizes bytes."
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
  "Generates machine code for loading the address to the nursery into the machine register."
}
{ $examples
  { $unchecked-example
    "USING: cpu.x86 make prettyprint ;"
    "[ RCX load-zone-offset ] B{ } make disassemble"
    "0000000001b48f80: 498d4d10  lea rcx, [r13+0x10]"
  }
} ;
