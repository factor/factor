USING: tools.test io.files ;
IN: temporary

[ "/usr/libexec/" ] [ "/usr/libexec/awk/" parent-directory ] unit-test
[ "/etc/" ] [ "/etc/passwd" parent-directory ] unit-test
[ "/" ] [ "/etc/" parent-directory ] unit-test
[ "/" ] [ "/etc" parent-directory ] unit-test
[ "/" ] [ "/" parent-directory ] unit-test
