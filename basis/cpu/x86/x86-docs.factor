USING: compiler.cfg.registers cpu.x86.assembler
cpu.x86.assembler.operands cpu.x86.assembler.operands.private
help.markup help.syntax layouts math sequences system ;
IN: cpu.x86

HELP: %boolean
{ $values
  { "dst" "register" }
  { "cc" "comparision symbol" }
  { "temp" "temporary register" }
}
{ $description "Helper word for emitting conditional move instructions." }
{ $see-also CMOVL CMOVLE CMOVG CMOVGE CMOVE CMOVNE } ;

HELP: %prepare-var-args
{ $values { "reg-inputs" sequence } }
{ $description "Emits code needed for calling variadic functions. On " { $link unix } " " { $link x86.64 } ", the " { $link AL } " register must contain the number of float registers used." } ;

HELP: JLE
{ $values { "dst" "destination offset (relative to the instruction pointer register)" } }
{ $description "Emits a 'jle' instruction." } ;

HELP: reserved-stack-space
{ $values { "n" integer } }
{ $description "Size in bytes of the register parameter area. It only exists on the windows " { $link x86.64 } " architecture, where it is 32 bytes and allocated by the caller. On all other platforms it is 0." } ;

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

HELP: (%slot)
{ $values
  { "obj" "a register symbol" }
  { "slot" "a register symbol" }
  { "scale" "number of bits required to address all bytes in a " { $link cell } "." }
  { "tag" integer }
  { "op" indirect }
}
{ $description "Creates an indirect operand for addressing a slot in a container." }
{ $examples
  { $unchecked-example
    "USING: cpu.x86 ;"
    "[ RAX RBX 3 -14 (%slot) EDI MOV ] B{ } make disassemble"
    "0000000001dd0990: 897cd80e  mov [rax+rbx*8+0xe], edi"
  }
} ;

HELP: decr-stack-reg
{ $values { "n" number } }
{ $description "Emits an instruction for decrementing the stack register the given number of bytes. If n is equal to the " { $link cell } " size, then a " { $link PUSH } " instruction is emitted instead because it has a shorter encoding." } ;

HELP: incr-stack-reg
{ $values { "n" number } }
{ $description "Emits an instruction for incrementing the stack register the given number of bytes. If n is equal to the " { $link cell } " size, then a " { $link POP } " instruction is emitted instead because it has a shorter encoding." } ;

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

HELP: loc>operand
{ $values { "loc" loc } { "operand" indirect } }
{ $description "Converts a stack location to an operand passable to the " { $link MOV } " instruction." } ;

HELP: store-tagged
{ $values { "dst" "a register symbol" } { "tag" "a builtin class" } }
{ $description "Tags the register with the tag number for the given class." }
{ $examples
  { $unchecked-example
    "USING: cpu.x86 make ;"
    "[ RAX alien store-tagged ] B{ } make disassemble"
    "0000000002275f10: 4883c806  or rax, 0x6"
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

ARTICLE: "cpu.x86" "CPU x86 compiler backend"
"Implementation of " { $vocab-link "cpu.architecture" } " for x86 machines."
$nl
{ $link ADD } " and " { $link SUB } " variants:"
{ $subsections (%inc) decr-stack-reg incr-stack-reg } ;

ABOUT: "cpu.x86"
