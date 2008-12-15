IN: io.files.info.tests

\ file-info must-infer
\ link-info must-infer

[ t ] [
    temp-directory [ "hi41" "test41" utf8 set-file-contents ] with-directory
    temp-directory "test41" append-path utf8 file-contents "hi41" =
] unit-test

[ t ] [
    temp-directory [ "test41" file-info size>> ] with-directory 4 =
] unit-test

[ t ] [ "/" file-system-info file-system-info? ] unit-test
[ t ] [ file-systems [ file-system-info? ] all? ] unit-test
