! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel system tools.test ;
IN: compiler.tests.safepoints.driver
os unix? [
    "resource:basis/compiler/tests/fixtures/safepoints.factor" run-test-file
] when
