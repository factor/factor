USING: io io.mmap io.files kernel tools.test continuations
sequences io.encodings.ascii accessors ;
IN: io.windows.mmap.tests

[ ] [ "a" "mmap-grow-test.txt" temp-file ascii set-file-contents ] unit-test
[ 1 ] [ "mmap-grow-test.txt" temp-file file-info size>> ] unit-test
[ ] [ "mmap-grow-test.txt" temp-file 100 [ [ ] change-each ] with-mapped-file ] unit-test
[ 100 ] [ "mmap-grow-test.txt" temp-file file-info size>> ] unit-test
