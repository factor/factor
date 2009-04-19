IN: io.launcher.unix.parser.tests
USING: io.launcher.unix.parser tools.test ;

[ "" tokenize-command ] must-fail
[ "   " tokenize-command ] must-fail
[ V{ "a" } ] [ "a" tokenize-command ] unit-test
[ V{ "abc" } ] [ "abc" tokenize-command ] unit-test
[ V{ "abc" } ] [ "abc   " tokenize-command ] unit-test
[ V{ "abc" } ] [ "   abc" tokenize-command ] unit-test
[ V{ "abc" "def" } ] [ "abc def" tokenize-command ] unit-test
[ V{ "abc def" } ] [ "abc\\ def" tokenize-command ] unit-test
[ V{ "abc\\" "def" } ] [ "abc\\\\ def" tokenize-command ] unit-test
[ V{ "abc\\ def" } ] [ "\"abc\\\\ def\"" tokenize-command ] unit-test
[ V{ "abc\\ def" } ] [ "  \"abc\\\\ def\"" tokenize-command ] unit-test
[ V{ "abc\\ def" "hey" } ] [ "\"abc\\\\ def\" hey" tokenize-command ] unit-test
[ V{ "abc def" "hey" } ] [ "\"abc def\" \"hey\"" tokenize-command ] unit-test
[ "\"abc def\" \"hey" tokenize-command ] must-fail
[ "\"abc def" tokenize-command ] must-fail
[ V{ "abc def" "h\"ey" } ] [ "\"abc def\" \"h\\\"ey\"  " tokenize-command ] unit-test

[
    V{
        "Hello world.app/Contents/MacOS/hello-ui"
        "-i=boot.macosx-ppc.image"
        "-include= math compiler ui"
        "-deploy-vocab=hello-ui"
        "-output-image=Hello world.app/Contents/Resources/hello-ui.image"
        "-no-stack-traces"
        "-no-user-init"
    }
] [
    "\"Hello world.app/Contents/MacOS/hello-ui\" -i=boot.macosx-ppc.image \"-include= math compiler ui\" -deploy-vocab=hello-ui \"-output-image=Hello world.app/Contents/Resources/hello-ui.image\" -no-stack-traces -no-user-init" tokenize-command
] unit-test
