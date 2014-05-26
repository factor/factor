USING: cpu.x86.assembler.operands.private help.markup help.syntax math ;
IN: cpu.x86.assembler.operands

HELP: [RIP+]
{ $values { "displacement" number } { "indirect" indirect } }
{ $description "Creates an indirect operand relative to the RIP register." } ;
