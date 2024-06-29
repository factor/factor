USING: simple-tokenizer tools.test ;

[ "" tokenize ] must-fail
[ "   " tokenize ] must-fail
{ V{ "a" } } [ "a" tokenize ] unit-test
{ V{ "abc" } } [ "abc" tokenize ] unit-test
{ V{ "abc" } } [ "abc   " tokenize ] unit-test
{ V{ "abc" } } [ "   abc" tokenize ] unit-test
{ V{ "abc" "def" } } [ "abc def" tokenize ] unit-test
{ V{ "abc def" } } [ "abc\\ def" tokenize ] unit-test
{ V{ "abc\\" "def" } } [ "abc\\\\ def" tokenize ] unit-test
{ V{ "abc\\ def" } } [ "\"abc\\\\ def\"" tokenize ] unit-test
{ V{ "abc\\ def" } } [ "  \"abc\\\\ def\"" tokenize ] unit-test
{ V{ "abc\\ def" "hey" } } [ "\"abc\\\\ def\" hey" tokenize ] unit-test
{ V{ "abc def" "hey" } } [ "\"abc def\" \"hey\"" tokenize ] unit-test
[ "\"abc def\" \"hey" tokenize ] must-fail
[ "\"abc def" tokenize ] must-fail
{ V{ "abc def" "h\"ey" } } [ "\"abc def\" \"h\\\"ey\"  " tokenize ] unit-test

{
    V{
        "Hello world.app/Contents/MacOS/hello-ui"
        "-i=boot.macos-ppc.image"
        "-include= math compiler ui"
        "-deploy-vocab=hello-ui"
        "-output-image=Hello world.app/Contents/Resources/hello-ui.image"
        "-no-stack-traces"
        "-no-user-init"
    }
} [
    "\"Hello world.app/Contents/MacOS/hello-ui\" -i=boot.macos-ppc.image \"-include= math compiler ui\" -deploy-vocab=hello-ui \"-output-image=Hello world.app/Contents/Resources/hello-ui.image\" -no-stack-traces -no-user-init" tokenize
] unit-test

{ V{ "ls" "-l" } } [ "ls -l" tokenize ] unit-test
{ V{ "ls" "-l" } } [ "ls -l\n" tokenize ] unit-test
{ V{ "ls" "-l" } } [ "\nls -l" tokenize ] unit-test
{ V{ "ls" "-l" } } [ "\nls -l\n" tokenize ] unit-test
