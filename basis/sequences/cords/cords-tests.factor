USING: sequences.cords strings tools.test kernel sequences ;
IN: sequences.cords.tests

[ "hello world" ] [ "hello" " world" cord-append dup like ] unit-test
