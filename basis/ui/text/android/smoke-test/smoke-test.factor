! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: command-line namespaces tools.test ;
IN: ui.text.android.smoke-test

: run-android-text-tests ( -- )
    { "ui.text.android" } command-line [ test-main ] with-variable ;

MAIN: run-android-text-tests
