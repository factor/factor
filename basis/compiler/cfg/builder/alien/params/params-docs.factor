USING: cpu.architecture help.markup help.syntax kernel math vectors ;
IN: compiler.cfg.builder.alien.params

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

HELP: reg-class-full?
{ $values { "reg-class" vector } { "odd-register?" boolean } { "?" boolean } }
{ $description "The register class is full if there are no registers left in it, or if there is only one register and 'odd-register?' is " { $link t } ". If it is full, then it is emptied as a side-effect." } ;

HELP: stack-params
{ $var-description "Count of the number of bytes of stack allocation required to store the current call frame parameters." } ;

ARTICLE: "compiler.cfg.builder.alien.params"
"Allocation for alien node parameters" "This vocab allocates registers and spill slots for alien calls." ;

ABOUT: "compiler.cfg.builder.alien.params"
