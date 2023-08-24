USING: cpu.x86.assembler.operands.private help.markup help.syntax math ;
IN: cpu.x86.assembler.operands

HELP: indirect
{ $class-description "Tuple that represents an indirect addressing operand. It has the following slots:"
  { $slots
    { "index" { "Register for the index value. It must not be " { $link ESP } " or " { $link RSP } "." } }
    { "displacement" { "An integer offset." } }
  }
} ;

HELP: [RIP+]
{ $values { "displacement" number } { "indirect" indirect } }
{ $description "Creates an indirect operand relative to the RIP register." }
{ $examples
  { $unchecked-example
    "USING: cpu.x86.assembler cpu.x86.assembler.operands make tools.disassembler ;"
    "[ 0x1234 [RIP+] EAX MOV ] B{ } make disassemble"
    "00000000015cef50: 890534120000  mov [rip+0x1234], eax"
  }
} ;

HELP: []
{ $values { "base/displacement" "register or an integer" } { "indirect" indirect } }
{ $description "Creates an indirect operand from a given address or " { $link register } "." } ;

HELP: n-bit-version-of
{ $values { "register" register } { "n" integer } { "register'" register } }
{ $description "Returns a less wide version of the given register." } ;

ARTICLE: "cpu.x86.assembler.operands" "CPU x86 registers and memory operands"
"Indirect operand constructors for various addressing formats:"
{ $subsections [] [RIP+] [+] [++] [+*2+] [+*4+] [+*8+] }
"Register correspondences:"
{ $subsections
  8-bit-version-of
  16-bit-version-of
  32-bit-version-of
  64-bit-version-of
  n-bit-version-of
  native-version-of
} ;
