USING: splitting tools.test ;
IN: temporary

[ { 1 2 3 } 0 group ] unit-test-fails

[ { "hell" "o wo" "rld" } ] [ "hello world" 4 group ] unit-test

[ "hello" "world ." ] [ "hello world ." " " split1 ] unit-test
[ "hello" "world-+." ] [ "hello-+world-+." "-+" split1 ] unit-test
[ "goodbye" f ] [ "goodbye" " " split1 ] unit-test
[ "" "" ] [ "great" "great" split1 ] unit-test

[ "hello world" "." ] [ "hello world ." " " last-split1 ] unit-test
[ "hello-+world" "." ] [ "hello-+world-+." "-+" last-split1 ] unit-test
[ "goodbye" f ] [ "goodbye" " " last-split1 ] unit-test
[ "" "" ] [ "great" "great" last-split1 ] unit-test

[ "and end" t ] [ "Beginning and end" "Beginning " ?head ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "Beginning x" ?head ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "eginning " ?head ] unit-test

[ "Beginning" t ] [ "Beginning and end" " and end" ?tail ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "Beginning x" ?tail ] unit-test
[ "Beginning and end" f ] [ "Beginning and end" "eginning " ?tail ] unit-test

[ { "This" "is" "a" "split" "sentence" } ]
[ "This is a split sentence" " " split ]
unit-test

[ { "OneWord" } ]
[ "OneWord" " " split ]
unit-test

[ { "a" "b" "c" "d" "e" "f" } ]
[ "aXbYcXdYeXf" "XY" split ] unit-test

[ { "" "" } ]
[ " " " " split ] unit-test

[ { "hey" } ]
[ "hey" " " split ] unit-test

[ "Hello world" t ] [ "Hello world\n" "\n" ?tail ] unit-test
[ "Hello world" f ] [ "Hello world" "\n" ?tail ] unit-test
[ "" t ] [ "\n" "\n" ?tail ] unit-test
[ "" f ] [ "" "\n" ?tail ] unit-test

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
