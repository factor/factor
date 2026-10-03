! Variadic callback/native va_list entry points target ARM64 and RISC-V.
USING: kernel system tools.test ;
IN: compiler.tests.alien-varargs.driver

cpu arm.64? cpu riscv? or [
    "resource:basis/compiler/tests/varargs/cases.factor" run-test-file
] when
