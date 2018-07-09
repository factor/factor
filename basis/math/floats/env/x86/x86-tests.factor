USING: math.floats.env math.floats.env.x86 tools.test
classes.struct cpu.x86.assembler cpu.x86.assembler.operands
compiler.test math kernel sequences alien alien.c-types
continuations ;
IN: math.floats.env.x86.tests

[ t ] [
    [ [
        void { } cdecl [
            9 [ FLDZ ] times
            9 [ ST0 FSTP ] times
        ] alien-assembly
    ] compile-call ] collect-fp-exceptions
    +fp-x87-stack-fault+ swap member?
] unit-test
