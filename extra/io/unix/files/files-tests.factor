USING: tools.test io.files ;
IN: io.unix.files.tests

[ "/usr/libexec/" ] [ "/usr/libexec/awk/" parent-directory ] unit-test
[ "/etc/" ] [ "/etc/passwd" parent-directory ] unit-test
[ "/" ] [ "/etc/" parent-directory ] unit-test
[ "/" ] [ "/etc" parent-directory ] unit-test
[ "/" ] [ "/" parent-directory ] unit-test
[ "asdf" parent-directory ] must-fail

[ f ] [ "" root-directory? ] unit-test
[ t ] [ "/" root-directory? ] unit-test
[ t ] [ "//" root-directory? ] unit-test
[ t ] [ "///////" root-directory? ] unit-test
