USING: io kernel parser sequences ;

[
    "/library/compiler/ppc/assembler.factor"
    "/library/compiler/ppc/architecture.factor"
    "/library/compiler/ppc/generator.factor"
    "/library/compiler/ppc/slots.factor"
    "/library/compiler/ppc/stack.factor"
    "/library/compiler/ppc/fixnum.factor"
    "/library/compiler/ppc/alien.factor"
] [
    dup print run-resource
] each
