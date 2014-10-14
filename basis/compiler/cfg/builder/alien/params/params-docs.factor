USING: cpu.architecture help.markup help.syntax math ;
IN: compiler.cfg.builder.alien.params

HELP: stack-params
{ $var-description "Count of the number of bytes of stack allocation required to store the current call frames parameters." } ;

HELP: alloc-stack-param
{ $values { "rep" representation } { "n" integer } }
{ $description "Allocates space for a stack parameter value of the given representation and returns the previous stack parameter offset." }
{ $examples
  "On 32-bit architectures, the offsets will be aligned to four byte boundaries."
  { $unchecked-example
    "0 stack-params set float-rep alloc-stack-param stack-params get . ."
    "4"
    "0"
  }
} ;
