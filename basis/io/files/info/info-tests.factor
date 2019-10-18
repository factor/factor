USING: io.files.info io.encodings.utf8 io.files
io.directories kernel io.pathnames accessors tools.test
sequences io.files.temp ;

{ "hi41" } [
    [
        "hi41" "test41" utf8 set-file-contents
        "test41" utf8 file-contents
    ] with-temp-directory
] unit-test

{ 4 } [
    [ "test41" file-info size>> ] with-temp-directory
] unit-test

{ t } [ "/" file-system-info file-system-info-tuple? ] unit-test
{ t } [ file-systems [ file-system-info-tuple? ] all? ] unit-test
