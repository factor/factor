USING: io io.mmap io.files kernel tools.test continuations
sequences io.encodings.ascii ;
IN: io.mmap.tests

[ "mmap-test-file.txt" resource-path delete-file ] ignore-errors
[ ] [ "12345" "mmap-test-file.txt" resource-path ascii set-file-contents ] unit-test
[ ] [ "mmap-test-file.txt" resource-path dup file-info size>> [ CHAR: 2 0 pick set-nth drop ] with-mapped-file ] unit-test
[ 5 ] [ "mmap-test-file.txt" resource-path dup file-info size>> [ length ] with-mapped-file ] unit-test
[ "22345" ] [ "mmap-test-file.txt" resource-path ascii file-contents ] unit-test
[ "mmap-test-file.txt" resource-path delete-file ] ignore-errors
