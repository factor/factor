IN: temporary
USING: tools.test io.files io threads kernel continuations ;

[ "passwd" ] [ "/etc/passwd" file-name ] unit-test
[ "awk" ] [ "/usr/libexec/awk/" file-name ] unit-test
[ "awk" ] [ "/usr/libexec/awk///" file-name ] unit-test

[ ] [
    "test-foo.txt" temp-file [
        "Hello world." print
    ] with-file-writer
] unit-test

[ ] [
    "test-foo.txt" temp-file <file-appender> [
        "Hello appender." print
    ] with-stream
] unit-test

[ ] [
    "test-bar.txt" temp-file <file-appender> [
        "Hello appender." print
    ] with-stream
] unit-test

[ "Hello world.\nHello appender.\n" ] [
    "test-foo.txt" temp-file file-contents
] unit-test

[ "Hello appender.\n" ] [
    "test-bar.txt" temp-file file-contents
] unit-test

[ ] [ "test-foo.txt" temp-file delete-file ] unit-test

[ ] [ "test-bar.txt" temp-file delete-file ] unit-test

[ f ] [ "test-foo.txt" temp-file exists? ] unit-test

[ f ] [ "test-bar.txt" temp-file exists? ] unit-test

[ ] [ "test-blah" temp-file make-directory ] unit-test

[ ] [
    "test-blah/fooz" temp-file <file-writer> dispose
] unit-test

[ t ] [
    "test-blah/fooz" temp-file exists?
] unit-test

[ ] [ "test-blah/fooz" temp-file delete-file ] unit-test

[ ] [ "test-blah" temp-file delete-directory ] unit-test

[ f ] [ "test-blah" temp-file exists? ] unit-test

[ ] [ "test-quux.txt" temp-file [ [ yield "Hi" write ] "Test" spawn drop ] with-file-writer ] unit-test

[ ] [ "test-quux.txt" temp-file delete-file ] unit-test

[ ] [ "test-quux.txt" temp-file [ [ yield "Hi" write ] "Test" spawn drop ] with-file-writer ] unit-test

[ ] [ "test-quux.txt" "quux-test.txt" [ temp-file ] 2apply move-file ] unit-test
[ t ] [ "quux-test.txt" temp-file exists? ] unit-test

[ ] [ "quux-test.txt" temp-file delete-file ] unit-test

[ ] [ "delete-tree-test/a/b/c" temp-file make-directories ] unit-test

[ ] [
    "delete-tree-test/a/b/c/d" temp-file
    [ "Hi" print ] with-file-writer
] unit-test

[ ] [
    "delete-tree-test" temp-file delete-tree
] unit-test

[ ] [
    "copy-tree-test/a/b/c" temp-file make-directories
] unit-test

[ ] [
    "copy-tree-test/a/b/c/d" temp-file
    [ "Foobar" write ] with-file-writer
] unit-test

[ ] [
    "copy-tree-test" temp-file
    "copy-destination" temp-file copy-tree
] unit-test

[ "Foobar" ] [
    "copy-destination/a/b/c/d" temp-file file-contents
] unit-test

[ ] [
    "copy-destination" temp-file delete-tree
] unit-test

[ ] [
    "copy-tree-test" temp-file
    "copy-destination" temp-file copy-tree-to
] unit-test

[ "Foobar" ] [
    "copy-destination/copy-tree-test/a/b/c/d" temp-file file-contents
] unit-test

[ ] [
    "copy-destination/copy-tree-test/a/b/c/d" temp-file "" temp-file copy-file-to
] unit-test

[ "Foobar" ] [
    "d" temp-file file-contents
] unit-test

[ ] [ "d" temp-file delete-file ] unit-test

[ ] [ "copy-destination" temp-file delete-tree ] unit-test

[ ] [ "copy-tree-test" temp-file delete-tree ] unit-test

[ t ] [ cwd "core" resource-path [ ] with-directory cwd = ] unit-test
