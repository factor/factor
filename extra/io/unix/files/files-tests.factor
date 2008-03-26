USING: tools.test io.files ;
IN: io.unix.files.tests

[ "/usr/libexec/" ] [ "/usr/libexec/awk/" parent-directory ] unit-test
[ "/etc/" ] [ "/etc/passwd" parent-directory ] unit-test
[ "/" ] [ "/etc/" parent-directory ] unit-test
[ "/" ] [ "/etc" parent-directory ] unit-test
[ "/" ] [ "/" parent-directory ] unit-test

[ f ] [ "" root-directory? ] unit-test
[ t ] [ "/" root-directory? ] unit-test
[ t ] [ "//" root-directory? ] unit-test
[ t ] [ "///////" root-directory? ] unit-test

[ "/" ] [ "/" file-name ] unit-test
[ "///" ] [ "///" file-name ] unit-test

[ "/" ] [ "/" "../.." append-path ] unit-test
[ "/" ] [ "/" "../../" append-path ] unit-test
[ "/lib" ] [ "/" "../lib" append-path ] unit-test
[ "/lib/" ] [ "/" "../lib/" append-path ] unit-test
[ "/lib" ] [ "/" "../../lib" append-path ] unit-test
[ "/lib/" ] [ "/" "../../lib/" append-path ] unit-test
