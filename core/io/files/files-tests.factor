IN: temporary
USING: tools.test io.files io threads kernel continuations io.encodings.ascii ;

[ "passwd" ] [ "/etc/passwd" file-name ] unit-test
[ "awk" ] [ "/usr/libexec/awk/" file-name ] unit-test
[ "awk" ] [ "/usr/libexec/awk///" file-name ] unit-test

[ ] [
    "test-foo.txt" resource-path ascii [
        "Hello world." print
    ] with-file-writer
] unit-test

[ ] [
    "test-foo.txt" resource-path ascii [
        "Hello appender." print
    ] with-file-appender
] unit-test

[ ] [
    "test-bar.txt" resource-path ascii [
        "Hello appender." print
    ] with-file-appender
] unit-test

[ "Hello world.\nHello appender.\n" ] [
    "test-foo.txt" resource-path ascii file-contents
] unit-test

[ "Hello appender.\n" ] [
    "test-bar.txt" resource-path ascii file-contents
] unit-test

[ ] [ "test-foo.txt" resource-path delete-file ] unit-test

[ ] [ "test-bar.txt" resource-path delete-file ] unit-test

[ f ] [ "test-foo.txt" resource-path exists? ] unit-test

[ f ] [ "test-bar.txt" resource-path exists? ] unit-test

[ ] [ "test-blah" resource-path make-directory ] unit-test

[ ] [
    "test-blah/fooz" resource-path ascii <file-writer> dispose
] unit-test

[ t ] [
    "test-blah/fooz" resource-path exists?
] unit-test

[ ] [ "test-blah/fooz" resource-path delete-file ] unit-test

[ ] [ "test-blah" resource-path delete-directory ] unit-test

[ f ] [ "test-blah" resource-path exists? ] unit-test

[ ] [ "test-quux.txt" resource-path ascii [ [ yield "Hi" write ] in-thread ] with-file-writer ] unit-test

[ ] [ "test-quux.txt" resource-path delete-file ] unit-test

[ ] [ "test-quux.txt" resource-path ascii [ [ yield "Hi" write ] in-thread ] with-file-writer ] unit-test

[ ] [ "test-quux.txt" "quux-test.txt" [ resource-path ] 2apply rename-file ] unit-test
[ t ] [ "quux-test.txt" resource-path exists? ] unit-test

[ ] [ "quux-test.txt" resource-path delete-file ] unit-test

