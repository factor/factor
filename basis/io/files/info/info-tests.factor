USING: io.files.info io.pathnames io.encodings.utf8 io.files
io.directories kernel io.pathnames accessors tools.test
sequences io.files.temp ;
IN: io.files.info.tests

[ t ] [
    temp-directory [ "hi41" "test41" utf8 set-file-contents ] with-directory
    temp-directory "test41" append-path utf8 file-contents "hi41" =
] unit-test

[ t ] [
    temp-directory [ "test41" file-info size>> ] with-directory 4 =
] unit-test

[ t ] [ "/" file-system-info file-system-info? ] unit-test
[ t ] [ file-systems [ file-system-info? ] all? ] unit-test
