! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors io.backend io.directories io.files io.files.info
io.files.info.windows io.files.windows kernel literals math
sequences system tools.test windows.errors windows.kernel32 ;
IN: io.files.info.windows.tests

{ } [ vm-path file-times 3drop ] unit-test

: make-dangling-link ( path -- created? )
    normalize-path "missing" SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE
    CreateSymbolicLink ${ ERROR_PRIVILEGE_NOT_HELD } win32-error=0/f-allowed
    zero? not ;

[
    "tree" make-directory
    "tree/dangling" make-dangling-link [
        { t } [
            "tree/dangling" link-info attributes>> +reparse-point+ swap member?
        ] unit-test

        { f } [ "tree" delete-tree "tree" file-exists? ] unit-test
    ] when
] with-test-directory
