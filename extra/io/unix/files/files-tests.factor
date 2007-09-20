USING: tools.test io.files ;
IN: temporary

[ "/usr/libexec/" ] [ "/usr/libexec/awk/" parent-dir ] unit-test
[ "/etc/" ] [ "/etc/passwd" parent-dir ] unit-test
[ "/" ] [ "/etc/" parent-dir ] unit-test
[ "/" ] [ "/etc" parent-dir ] unit-test
[ "/" ] [ "/" parent-dir ] unit-test
