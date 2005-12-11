USING: io kernel parser sequences ;

[
    "/library/compiler/x86/assembler.factor"
    "/library/compiler/x86/architecture.factor"
    "/library/compiler/x86/generator.factor"
    "/library/compiler/x86/slots.factor"
    "/library/compiler/x86/stack.factor"
    "/library/compiler/x86/fixnum.factor"
    "/library/compiler/x86/alien.factor"
] [
    run-resource
] each
