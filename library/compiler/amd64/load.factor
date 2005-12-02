USING: io kernel parser sequences ;

[
    "/library/compiler/x86/assembler.factor"
    "/library/compiler/amd64/architecture.factor"
] [
    dup print run-resource
] each
