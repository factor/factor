USING: accessors continuations destructors io.backend.unix
io.directories io.encodings.utf8 io.files io.files.unix io.pathnames kernel
strings system tools.ps.linux tools.test unix.ffi unix.linux.proc ;
IN: tools.ps.linux.tests

: <fixture-directory> ( -- fd )
    "process" absolute-path open-read <fd> init-fd ;

! A pathname lookup after replacement would read the new process's stat.
{ "[old name)]" "[replacement]" } [
    [
        "process" make-directory
        "" "process/cmdline" utf8 set-file-contents
        "42 (old name)) S 7" "process/stat" utf8 set-file-contents
        <fixture-directory> [
            dup parse-proc-pid-cmdline f assert=
            "process" "retired" move-file
            "process" make-directory
            "" "process/cmdline" utf8 set-file-contents
            "42 (replacement) R 9" "process/stat" utf8 set-file-contents
            ps-cmdline
        ] with-disposal
        <fixture-directory> [ ps-cmdline ] with-disposal
    ] with-test-directory
] unit-test

os linux? [
    { t } [ "self" safe-ps-cmdline string? ] unit-test
    { f } [ "factor-no-such-pid" safe-ps-cmdline ] unit-test
] when

! NUL separates arguments; a newline inside an argument is not EOF.
{ "program first\nsecond tail" } [
    [
        "process" make-directory
        "program\0first\nsecond\0tail\0" "process/cmdline" utf8 set-file-contents
        <fixture-directory> [ ps-cmdline ] with-disposal
    ] with-test-directory
] unit-test

! Failed relative reads still release the directory descriptor.
{ t -1 } [
    [
        "process" make-directory
        <fixture-directory> dup
        [ [ "missing" proc-pid-contents ] with-disposal ]
        [ 2drop ] recover [ disposed>> ] [ fd>> F_SETFL 0 fcntl ] bi
    ] with-test-directory
] unit-test
