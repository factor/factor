USING: io.streams.escape-codes tools.test ;

{ "Hello" } [ "\e[4mHello\e[0m" strip-ansi-escapes ] unit-test
