! Real SQLite formatting of argument lists created by an independent C caller.
USING: kernel system tools.test ;
IN: compiler.tests.sqlite-varargs-driver
cpu arm.64? [
    "resource:basis/compiler/tests/sqlite-varargs/cases.factor" run-test-file
] when
