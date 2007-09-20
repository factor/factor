USING: io io.mmap kernel tools.test ;
IN: temporary

[ "mmap-test-file.txt" resource-path delete-file ] catch drop
[ ] [ "mmap-test-file.txt" resource-path <file-writer> [ "12345" write ] with-stream ] unit-test
[ ] [ "mmap-test-file.txt" resource-path dup file-length [ CHAR: 2 0 pick set-nth drop ] with-mapped-file ] unit-test
[ 5 ] [ "mmap-test-file.txt" resource-path dup file-length [ length ] with-mapped-file ] unit-test
[ "22345" ] [ "mmap-test-file.txt" resource-path <file-reader> contents ] unit-test
[ "mmap-test-file.txt" resource-path delete-file ] catch drop

