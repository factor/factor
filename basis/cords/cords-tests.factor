IN: cords.tests
USING: cords strings tools.test kernel sequences ;

[ "hello world" ] [ "hello" " world" cord-append dup like ] unit-test
[ "hello world" ] [ { "he" "llo" " world" } cord-concat dup like ] unit-test
