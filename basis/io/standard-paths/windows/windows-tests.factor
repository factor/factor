! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: environment io.directories io.encodings.utf8 io.files
io.pathnames io.standard-paths io.standard-paths.windows kernel
sequences tools.test unicode ;

{ t } [ "cmd.exe" find-in-path "cmd.exe" tail? ] unit-test

{ t } [ "cmd" find-in-path >lower "cmd.exe" tail? ] unit-test

{ t } [
    [
        "probe.EXE" make-directory
        "@exit /b 0" "probe.CMD" utf8 set-file-contents
        "" absolute-path "PATH" [
            ".EXE;.CMD" "PATHEXT" [
                "probe" find-in-path "probe.CMD" absolute-path =
            ] with-os-env
        ] with-os-env
    ] with-test-directory
] unit-test
