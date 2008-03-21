IN: io.files.tests
USING: tools.test io.files io threads kernel continuations io.encodings.ascii
io.files.unique sequences strings accessors ;

[ ] [ "blahblah" temp-file dup exists? [ delete-directory ] [ drop ] if ] unit-test
[ ] [ "blahblah" temp-file make-directory ] unit-test
[ t ] [ "blahblah" temp-file directory? ] unit-test

[ "passwd" ] [ "/etc/passwd" file-name ] unit-test
[ "awk" ] [ "/usr/libexec/awk/" file-name ] unit-test
[ "awk" ] [ "/usr/libexec/awk///" file-name ] unit-test

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

[ ] [ "test-quux.txt" temp-file ascii [ [ yield "Hi" write ] "Test" spawn drop ] with-file-writer ] unit-test

[ ] [ "test-quux.txt" temp-file delete-file ] unit-test

[ ] [ "test-quux.txt" temp-file ascii [ [ yield "Hi" write ] "Test" spawn drop ] with-file-writer ] unit-test

[ ] [ "test-quux.txt" "quux-test.txt" [ temp-file ] 2apply move-file ] unit-test
[ t ] [ "quux-test.txt" temp-file exists? ] unit-test

[ ] [ "quux-test.txt" temp-file delete-file ] unit-test

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

[ t ] [ cwd "misc" resource-path [ ] with-directory cwd = ] unit-test

[ ] [ "append-test" temp-file dup exists? [ delete-file ] [ drop ] if ] unit-test

[ ] [ "append-test" temp-file ascii <file-appender> dispose ] unit-test



[ 123 ] [
    "core" ".test" [
        [
            ascii [
                123 CHAR: a <repetition> >string write
            ] with-file-writer
        ] keep file-info size>>
    ] with-unique-file
] unit-test
