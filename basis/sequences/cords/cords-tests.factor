USING: sequences.cords strings tools.test kernel sequences ;

{ "hello world" } [ "hello" " world" cord-append dup like ] unit-test
