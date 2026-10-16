! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: command-line namespaces tools.test ;
IN: ui.android.test

: run-android-ui-tests ( -- )
    { "ui" } command-line [ test-main ] with-variable ;

MAIN: run-android-ui-tests
