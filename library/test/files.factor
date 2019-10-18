IN: temporary
USE: io
USE: httpd
USE: lists
USE: test

[ "txt" ] [ "foo.txt" file-extension ] unit-test
[ f ] [ "foobar" file-extension ] unit-test
[ "txt" ] [ "foo.bar.txt" file-extension ] unit-test
[ "text/plain" ] [ "foo.bar.txt" mime-type ] unit-test
[ "text/html" ] [ "index.html" mime-type ] unit-test
