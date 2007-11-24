IN: temporary
USING: io.unix.launcher tools.test ;

[ { } ] [ "" tokenize-command ] unit-test
[ { } ] [ "   " tokenize-command ] unit-test
[ { "a" } ] [ "a" tokenize-command ] unit-test
[ { "abc" } ] [ "abc" tokenize-command ] unit-test
[ { "abc" } ] [ "abc   " tokenize-command ] unit-test
[ { "abc" } ] [ "   abc" tokenize-command ] unit-test
[ { "abc" "def" } ] [ "abc def" tokenize-command ] unit-test
[ { "abc def" } ] [ "abc\\ def" tokenize-command ] unit-test
[ { "abc\\" "def" } ] [ "abc\\\\ def" tokenize-command ] unit-test
[ { "abc\\ def" } ] [ "'abc\\\\ def'" tokenize-command ] unit-test
[ { "abc\\ def" } ] [ "  'abc\\\\ def'" tokenize-command ] unit-test
[ { "abc\\ def" "hey" } ] [ "'abc\\\\ def' hey" tokenize-command ] unit-test
[ { "abc def" "hey" } ] [ "'abc def' \"hey\"" tokenize-command ] unit-test
[ "'abc def' \"hey" tokenize-command ] unit-test-fails
[ "'abc def" tokenize-command ] unit-test-fails
[ { "abc def" "h\"ey" } ] [ "'abc def' \"h\"ey\"  " tokenize-command ] unit-test
