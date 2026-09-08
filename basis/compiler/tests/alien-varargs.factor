! Variadic callback/native va_list entry points currently target ARM64.
USING: kernel system tools.test ;
IN: compiler.tests.alien-varargs.driver

cpu arm.64? [
    "resource:basis/compiler/tests/varargs/cases.factor" run-test-file
] when
