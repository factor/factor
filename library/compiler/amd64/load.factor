USING: io kernel parser sequences ;

[
    "/library/compiler/x86/assembler.factor"
    "/library/compiler/amd64/assembler.factor"
    "/library/compiler/amd64/architecture.factor"
    "/library/compiler/x86/generator.factor"
    "/library/compiler/x86/slots.factor"
    "/library/compiler/x86/stack.factor"
] [
    dup print run-resource
] each
