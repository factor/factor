USING: help.markup help.syntax math vm ;
IN: cpu.x86.64

HELP: vm-reg
{ $values { "reg" "a register symbol" } }
{ $description
  "Symbol of the machine register that holds the address of the virtual machine."
}
{ $see-also vm } ;

HELP: param-reg
{ $values { "n" number } { "reg" "a register symbol" } }
{ $description "Symbol of the machine register for the nth function parameter (0-based)." } ;
