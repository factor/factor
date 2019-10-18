REQUIRES: core/compiler/optimizer ;

PROVIDE: core/compiler/generator
{ +files+ {
    "architecture.factor"
    "fixup.factor"
    "registers.factor"
    "phantom-stacks.factor"
    "register-alloc.factor"
    "generator.factor"
} } ;
