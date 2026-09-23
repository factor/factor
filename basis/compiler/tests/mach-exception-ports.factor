! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel system tools.test ;
IN: compiler.tests.mach-exception-ports.driver

os macos? [
    "resource:basis/compiler/tests/fixtures/mach-exception-ports.factor" run-test-file
] when
