IN: scratchpad
USE: files
USE: httpd
USE: lists
USE: test

[ "txt" ] [ "foo.txt" file-extension ] unit-test
[ f ] [ "foobar" file-extension ] unit-test
[ "txt" ] [ "foo.bar.txt" file-extension ] unit-test
[ "text/plain" ] [ "foo.bar.txt" mime-type ] unit-test
[ "text/html" ] [ "index.html" mime-type ] unit-test

! Some tests to ensure these words simply work, since we can't
! really test them

[ t ] [ cwd directory list? ] unit-test

cwd directory.
