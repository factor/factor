IN: temporary
USING: tools.test io.files ;

[ "/etc" ] [ "/etc/passwd" parent-dir ] unit-test
[ "passwd" ] [ "/etc/passwd" file-name ] unit-test
[ "/usr/libexec" ] [ "/usr/libexec/awk/" parent-dir ] unit-test
[ "awk/" ] [ "/usr/libexec/awk/" file-name ] unit-test

[ ] [
    "test-foo.txt" resource-path <file-writer> [
        "Hello world." print
    ] with-stream
] unit-test

[ ] [
    "test-foo.txt" resource-path <file-appender> [
        "Hello appender." print
    ] with-stream
] unit-test

[ ] [
    "test-bar.txt" resource-path <file-appender> [
        "Hello appender." print
    ] with-stream
] unit-test

[ "Hello world.\nHello appender.\n" ] [
    "test-foo.txt" resource-path <file-reader> contents
] unit-test

[ "Hello appender.\n" ] [
    "test-bar.txt" resource-path <file-reader> contents
] unit-test

[ ] [ "test-foo.txt" resource-path delete-file ] unit-test

[ ] [ "test-bar.txt" resource-path delete-file ] unit-test

[ f ] [ "test-foo.txt" resource-path exists? ] unit-test

[ f ] [ "test-bar.txt" resource-path exists? ] unit-test

[ ] [ "test-blah" resource-path make-directory ] unit-test

[ ] [
    "test-blah/fooz" resource-path <file-writer> stream-close
] unit-test

[ t ] [
    "test-blah/fooz" resource-path exists?
] unit-test

[ ] [ "test-blah/fooz" resource-path delete-file ] unit-test

[ ] [ "test-blah" resource-path delete-directory ] unit-test

[ f ] [ "test-blah" resource-path exists? ] unit-test
