IN: temporary
USE: namespaces
USE: io
USE: test
USE: generic
USE: kernel

[ "xyzzy" ] [ [ "xyzzy" write ] string-out ] unit-test

[ { "" } ] [ "" string-lines ] unit-test
[ { "" "" } ] [ "\n" string-lines ] unit-test
[ { "" "" } ] [ "\r" string-lines ] unit-test
[ { "" "" } ] [ "\r\n" string-lines ] unit-test
[ { "hello" } ] [ "hello" string-lines ] unit-test
[ { "hello" "" } ] [ "hello\n" string-lines ] unit-test
[ { "hello" "" } ] [ "hello\r" string-lines ] unit-test
[ { "hello" "" } ] [ "hello\r\n" string-lines ] unit-test
[ { "hello" "hi" } ] [ "hello\nhi" string-lines ] unit-test
[ { "hello" "hi" } ] [ "hello\rhi" string-lines ] unit-test
[ { "hello" "hi" } ] [ "hello\r\nhi" string-lines ] unit-test
