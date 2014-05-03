USING: help.markup help.syntax math ;
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
