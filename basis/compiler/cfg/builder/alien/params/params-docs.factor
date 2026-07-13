USING: cpu.architecture help.markup help.syntax kernel math vectors ;
IN: compiler.cfg.builder.alien.params

HELP: alloc-stack-param
{ $values { "rep" representation } { "size" integer } { "n" integer } }
{ $description "Allocates space for a stack parameter with the given representation and natural byte size, and returns its stack offset." }
{ $examples
  "On 32-bit architectures, the offsets will be aligned to four byte boundaries."
  { $unchecked-example
    "0 stack-params set float-rep 8 alloc-stack-param stack-params get . ."
    "4"
    "0"
  }
} ;

HELP: reg-class-full?
{ $values { "reg-class" vector } { "register-requirement" object } { "?" boolean } }
{ $description "Tests whether the remaining register class can satisfy a scalar or grouped argument requirement. If not, the class is exhausted as a side effect so the complete argument moves to the stack." } ;

HELP: stack-params
{ $var-description "Count of the number of bytes of stack allocation required to store the current call frame parameters." } ;

ARTICLE: "compiler.cfg.builder.alien.params"
"Allocation for alien node parameters" "This vocab allocates registers and spill slots for alien calls." ;

ABOUT: "compiler.cfg.builder.alien.params"
