USING: io io.mmap io.files kernel tools.test continuations
sequences io.encodings.ascii accessors ;
IN: io.mmap.tests

[ "mmap-test-file.txt" temp-file delete-file ] ignore-errors
[ ] [ "12345" "mmap-test-file.txt" temp-file ascii set-file-contents ] unit-test
[ ] [ "mmap-test-file.txt" temp-file dup file-info size>> [ CHAR: 2 0 pick set-nth drop ] with-mapped-file ] unit-test
[ 5 ] [ "mmap-test-file.txt" temp-file dup file-info size>> [ length ] with-mapped-file ] unit-test
[ "22345" ] [ "mmap-test-file.txt" temp-file ascii file-contents ] unit-test
[ "mmap-test-file.txt" temp-file delete-file ] ignore-errors

[ ] [ "a" "mmap-grow-test.txt" temp-file ascii set-file-contents ] unit-test
[ 1 ] [ "mmap-grow-test.txt" temp-file file-info size>> ] unit-test
[ ] [ "mmap-grow-test.txt" temp-file 100 [ drop ] with-mapped-file ] unit-test
[ 100 ] [ "mmap-grow-test.txt" temp-file file-info size>> ] unit-test
