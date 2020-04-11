USING: destructors io io.directories io.directories.hierarchy
io.encodings.ascii io.encodings.utf8 io.files io.files.info
io.launcher io.pathnames kernel sequences tools.test ;

{ { "kernel" } } [
    "core" resource-path [
        "." directory-files [ "kernel" = ] filter
    ] with-directory
] unit-test

{ { "kernel" } } [
    "resource:core" [
        "." directory-files [ "kernel" = ] filter
    ] with-directory
] unit-test

{ { "kernel" } } [
    "resource:core" [
        [ "kernel" = ] filter
    ] with-directory-files
] unit-test

[
    { t t f } [
        "blahblah" make-directory
        "blahblah" exists?
        "blahblah" file-info directory?
        "blahblah" delete-directory
        "blahblah" exists?
    ] unit-test

    { "file1 contents" } [
        "file1 contents" "file1" utf8 set-file-contents
        "file1" "file2" copy-file
        "file2" utf8 file-contents
        "file1" delete-file
        "file2" delete-file
    ] unit-test

    { "file3 contents" } [
        "file3 contents" "file3" utf8 set-file-contents
        "file3" "file4" move-file
        "file4" utf8 file-contents
        "file4" delete-file
    ] unit-test

    { } [
        "file5" touch-file
        "file5" delete-file
    ] unit-test

    { } [
        "file6" touch-file
        "file6" link-info drop
    ] unit-test

    { } [
        { "Hello world." }
        "test-foo.txt" ascii set-file-lines
    ] unit-test

    { } [
        "test-foo.txt" ascii [
            "Hello appender." print
        ] with-file-appender
    ] unit-test

    { } [
        "test-bar.txt" ascii [
            "Hello appender." print
        ] with-file-appender
    ] unit-test

    { "Hello world.\nHello appender.\n" } [
        "test-foo.txt" ascii file-contents
    ] unit-test

    { "Hello appender.\n" } [
        "test-bar.txt" ascii file-contents
    ] unit-test

    { } [ "test-foo.txt" delete-file ] unit-test
    { } [ "test-bar.txt" delete-file ] unit-test

    { f } [ "test-foo.txt" exists? ] unit-test
    { f } [ "test-bar.txt" exists? ] unit-test

    { } [ "test-blah" make-directory ] unit-test

    { } [
        "test-blah/fooz" ascii <file-writer> dispose
    ] unit-test

    { t } [
        "test-blah/fooz" exists?
    ] unit-test

    { } [ "test-blah/fooz" delete-file ] unit-test
    { } [ "test-blah" delete-directory ] unit-test

    { f } [ "test-blah" exists? ] unit-test

    { } [ "delete-tree-test/a/b/c" make-directories ] unit-test

    { } [
        { "Hi" } "delete-tree-test/a/b/c/d" ascii set-file-lines
    ] unit-test

    { } [ "delete-tree-test" delete-tree ] unit-test

    { } [
        "copy-tree-test/a/b/c" make-directories
    ] unit-test

    { } [
        "Foobar"
        "copy-tree-test/a/b/c/d"
        ascii set-file-contents
    ] unit-test

    { } [
        "copy-tree-test" "copy-destination" copy-tree
    ] unit-test

    { "Foobar" } [
        "copy-destination/a/b/c/d" ascii file-contents
    ] unit-test

    { } [
        "copy-destination" delete-tree
    ] unit-test

    { } [
        "copy-tree-test" "copy-destination" copy-tree-into
    ] unit-test

    { "Foobar" } [
        "copy-destination/copy-tree-test/a/b/c/d" ascii file-contents
    ] unit-test

    ! copy-file
    { } [
        "resource:LICENSE.txt" "test" copy-file
    ] unit-test

    ! copy-file-into
    { } [
        "copy-destination/copy-tree-test/a/b/c/d" "." copy-file-into
    ] unit-test

    { "Foobar" } [
        "d" ascii file-contents
    ] unit-test

    { } [ "d" delete-file ] unit-test

    { } [ "copy-destination" delete-tree ] unit-test

    { } [ "copy-tree-test" delete-tree ] unit-test

    ! Issue #890
    { } [
        "foo" [ make-directories ] keep
        [ "touch bar" try-output-process ] with-directory
    ] unit-test

    { t } [
        "one/two/three" make-parent-directories parent-directory exists?
    ] unit-test

] with-test-directory
