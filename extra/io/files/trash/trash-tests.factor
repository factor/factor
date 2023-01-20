! Copyright (C) 2020 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: io.directories io.files.trash kernel tools.test ;
IN: io.files.trash.tests

{ } [
    ! temp-file is not used here, because it returns the absolute path, and we
    ! want to ensure send-to-trash works without giving it the full path.
    [ "io.files.trash-tests" dup touch-file send-to-trash ] with-test-directory
] unit-test
