USING: pcre2 tools.test ;

{ { } } [ "hello" "goodbye" findall ] unit-test

{ { "foo" "bar" "baz" } } [ "foo bar baz" "\\w+" findall ] unit-test
