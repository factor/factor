USING: calendar errors io kernel libs-io math namespaces sequences
shell test ;
IN: temporary

SYMBOL: file "file-appender-test.txt" \ file set
[ \ file get delete-file ] catch drop
[ f ] [ \ file get exists? ] unit-test
\ file get <file-appender> [ "asdf" write ] with-stream
[ t ] [ \ file get exists? ] unit-test
[ 4 ] [ \ file get file-length ] unit-test
\ file get <file-appender> [ "jkl;" write ] with-stream
[ t ] [ \ file get exists? ] unit-test
[ 8 ] [ \ file get file-length ] unit-test
[ "asdfjkl;" ] [ \ file get <file-reader> contents ] unit-test
\ file get delete-file
[ f ] [ \ file get exists? ] unit-test

SYMBOL: directory "test-directory" \ directory set
\ directory get create-directory
[ t ] [ \ directory get directory? ] unit-test
\ directory get delete-directory
[ f ] [ \ directory get directory? ] unit-test

SYMBOL: time "time-test.txt" \ time set
[ \ time get delete-file ] catch drop
\ time get touch-file
[ 0 ] [ \ time get file-length ] unit-test
[ t ] [ \ time get exists? ] unit-test
\ time get 0 unix-time>timestamp dup set-file-times
[ t ] [ \ time get file-write-time 0 unix-time>timestamp = ] unit-test
[ t ] [ \ time get file-access-time 0 unix-time>timestamp = ] unit-test
\ time get touch-file
[ t ] [ now \ time get file-write-time timestamp- 10 < ] unit-test
\ time get delete-file

SYMBOL: longname "" 255 CHAR: a pad-left \ longname set
\ longname get touch-file
[ t ] [ \ longname get exists? ] unit-test
[ 0 ] [ \ longname get file-length ] unit-test
\ longname get delete-file
[ f ] [ \ longname get exists? ] unit-test

