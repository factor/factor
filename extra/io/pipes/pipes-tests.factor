USING: io io.pipes io.streams.string io.encodings.utf8 
continuations tools.test kernel ;
IN: io.pipes.tests

[ "Hello" ] [
    utf8 <pipe> "Hello" over stream-write dispose
    dup stream-readln swap dispose
] unit-test

[ { } ] [ { } utf8 with-pipes ] unit-test
[ { f } ] [ { [ f ] } utf8 with-pipes ] unit-test
[ { "Hello" } ] [ "Hello" [ { [ readln ] } utf8 with-pipes ] with-string-reader ] unit-test

[ { f "Hello" } ] [
    {
        [ "Hello" print flush f ]
        [ readln ]
    } utf8 with-pipes
] unit-test
