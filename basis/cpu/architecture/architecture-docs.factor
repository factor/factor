USING: assocs cpu.x86.assembler help.markup help.syntax math system words ;
IN: cpu.architecture

HELP: immediate-arithmetic?
{ $values { "n" number } { "?" "a boolean" } }
{ $description
  "Can this value be an immediate operand for " { $link %add-imm } ", "
  { $link %sub-imm } ", or " { $link %mul-imm } "?"
} ;

HELP: machine-registers
{ $description "Mapping from register class to machine registers." } ;

HELP: vm-stack-space
{ $description "Parameter space to reserve in anything making VM calls." } ;

HELP: complex-addressing?
{ $description "Specifies if " { $link %slot } ", " { $link %set-slot } " and " { $link %write-barrier } " accept the 'scale' and 'tag' parameters, and if %load-memory and %store-memory work." } ;

HELP: param-regs
{ $values { "abi" "a calling convention symbol" } { "regs" assoc } }
{ $description "Retrieves the order in which machine registers are used for parameters for the given calling convention." } ;

HELP: %load-immediate
{ $values { "reg" "a register symbol" } { "val" "a value" } }
{ $description "Emits code for loading an immediate value into a register. On " { $link x86 } ", if val is 0, then an " { $link XOR } " instruction is emitted instead of " { $link MOV } "." } ;

HELP: %call
{ $values { "word" word } }
{ $description "Emits code for calling a word in Factor." } ;

HELP: fused-unboxing?
{ $values { "?" "a boolean" } }
{ $description "Whether this architecture support " { $link %load-float } ", " { $link %load-double } ", and " { $link %load-vector } "." } ;

HELP: return-regs
{ $values { "regs" assoc } }
{ $description "What registers that will be used for function return values of which class." } ;
