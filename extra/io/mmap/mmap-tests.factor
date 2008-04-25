USING: io io.mmap io.files kernel tools.test continuations
sequences io.encodings.ascii accessors ;
IN: io.mmap.tests

[ "resource:mmap-test-file.txt" delete-file ] ignore-errors
[ ] [ "12345" "resource:mmap-test-file.txt" ascii set-file-contents ] unit-test
[ ] [ "resource:mmap-test-file.txt" dup file-info size>> [ CHAR: 2 0 pick set-nth drop ] with-mapped-file ] unit-test
[ 5 ] [ "resource:mmap-test-file.txt" dup file-info size>> [ length ] with-mapped-file ] unit-test
[ "22345" ] [ "resource:mmap-test-file.txt" ascii file-contents ] unit-test
[ "resource:mmap-test-file.txt" delete-file ] ignore-errors


