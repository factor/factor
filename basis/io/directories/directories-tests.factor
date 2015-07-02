USING: continuations destructors io io.directories
io.directories.hierarchy io.encodings.ascii io.encodings.utf8
io.files io.files.info io.files.temp io.launcher io.pathnames
kernel sequences tools.test ;
IN: io.directories.tests

[ { "kernel" } ] [
    "core" resource-path [
        "." directory-files [ "kernel" = ] filter
    ] with-directory
] unit-test

[ { "kernel" } ] [
    "resource:core" [
        "." directory-files [ "kernel" = ] filter
    ] with-directory
] unit-test

[ { "kernel" } ] [
    "resource:core" [
        [ "kernel" = ] filter
    ] with-directory-files
] unit-test

[ ] [ "blahblah" temp-file dup exists? [ delete-directory ] [ drop ] if ] unit-test
[ ] [ "blahblah" temp-file make-directory ] unit-test
[ t ] [ "blahblah" temp-file file-info directory? ] unit-test

[ t ] [
    [ temp-directory "loldir" append-path delete-directory ] ignore-errors
    temp-directory [
        "loldir" make-directory
    ] with-directory
    temp-directory "loldir" append-path exists?
] unit-test

[ ] [
    [ temp-directory "loldir" append-path delete-directory ] ignore-errors
    temp-directory [
        "loldir" make-directory
        "loldir" delete-directory
    ] with-directory
] unit-test

[ "file1 contents" ] [
    [ temp-directory "loldir" append-path delete-directory ] ignore-errors
    temp-directory [
        "file1 contents" "file1" utf8 set-file-contents
        "file1" "file2" copy-file
        "file2" utf8 file-contents
    ] with-directory
    "file1" temp-file delete-file
    "file2" temp-file delete-file
] unit-test

[ "file3 contents" ] [
    temp-directory [
        "file3 contents" "file3" utf8 set-file-contents
        "file3" "file4" move-file
        "file4" utf8 file-contents
    ] with-directory
    "file4" temp-file delete-file
] unit-test

[ "file5" temp-file delete-file ] ignore-errors

[ ] [
    temp-directory [
        "file5" touch-file
        "file5" delete-file
    ] with-directory
] unit-test

[ "file6" temp-file delete-file ] ignore-errors

[ ] [
    temp-directory [
        "file6" touch-file
        "file6" link-info drop
    ] with-directory
] unit-test

[ ] [
    { "Hello world." }
    "test-foo.txt" temp-file ascii set-file-lines
] unit-test

[ ] [
    "test-foo.txt" temp-file ascii [
        "Hello appender." print
    ] with-file-appender
] unit-test

[ ] [
    "test-bar.txt" temp-file ascii [
        "Hello appender." print
    ] with-file-appender
] unit-test

[ "Hello world.\nHello appender.\n" ] [
    "test-foo.txt" temp-file ascii file-contents
] unit-test

[ "Hello appender.\n" ] [
    "test-bar.txt" temp-file ascii file-contents
] unit-test

[ ] [ "test-foo.txt" temp-file delete-file ] unit-test

[ ] [ "test-bar.txt" temp-file delete-file ] unit-test

[ f ] [ "test-foo.txt" temp-file exists? ] unit-test

[ f ] [ "test-bar.txt" temp-file exists? ] unit-test

[ "test-blah" temp-file delete-tree ] ignore-errors

[ ] [ "test-blah" temp-file make-directory ] unit-test

[ ] [
    "test-blah/fooz" temp-file ascii <file-writer> dispose
] unit-test

[ t ] [
    "test-blah/fooz" temp-file exists?
] unit-test

[ ] [ "test-blah/fooz" temp-file delete-file ] unit-test

[ ] [ "test-blah" temp-file delete-directory ] unit-test

[ f ] [ "test-blah" temp-file exists? ] unit-test

[ ] [ "delete-tree-test/a/b/c" temp-file make-directories ] unit-test

[ ] [
    { "Hi" }
    "delete-tree-test/a/b/c/d" temp-file ascii set-file-lines
] unit-test

[ ] [
    "delete-tree-test" temp-file delete-tree
] unit-test

[ ] [
    "copy-tree-test/a/b/c" temp-file make-directories
] unit-test

[ ] [
    "Foobar"
    "copy-tree-test/a/b/c/d" temp-file
    ascii set-file-contents
] unit-test

[ ] [
    "copy-tree-test" temp-file
    "copy-destination" temp-file copy-tree
] unit-test

[ "Foobar" ] [
    "copy-destination/a/b/c/d" temp-file ascii file-contents
] unit-test

[ ] [
    "copy-destination" temp-file delete-tree
] unit-test

[ ] [
    "copy-tree-test" temp-file
    "copy-destination" temp-file copy-tree-into
] unit-test

[ "Foobar" ] [
    "copy-destination/copy-tree-test/a/b/c/d" temp-file ascii file-contents
] unit-test

[ ] [
    "copy-destination/copy-tree-test/a/b/c/d" temp-file "" temp-file copy-file-into
] unit-test

[ "Foobar" ] [
    "d" temp-file ascii file-contents
] unit-test

[ ] [ "d" temp-file delete-file ] unit-test

[ ] [ "copy-destination" temp-file delete-tree ] unit-test

[ ] [ "copy-tree-test" temp-file delete-tree ] unit-test

[ ] [ "resource:deleteme" touch-file ] unit-test
[ ] [ "resource:deleteme" delete-file ] unit-test

! Issue #890

{ } [
    "foo" temp-file [ make-directories ] keep
    [ "touch bar" try-output-process ] with-directory
] unit-test
