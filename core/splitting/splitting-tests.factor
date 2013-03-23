USING: splitting tools.test kernel sequences arrays strings ascii math ;
IN: splitting.tests

[ "hello" "world ." ] [ "hello world ." " " split1 ] unit-test
[ "hello" "world-+." ] [ "hello-+world-+." "-+" split1 ] unit-test
[ "goodbye" f ] [ "goodbye" " " split1 ] unit-test
[ "" "" ] [ "great" "great" split1 ] unit-test

[ "hello world" "." ] [ "hello world ." " " split1-last ] unit-test
[ "hello-+world" "." ] [ "hello-+world-+." "-+" split1-last ] unit-test
[ "goodbye" f ] [ "goodbye" " " split1-last ] unit-test
[ "" "" ] [ "great" "great" split1-last ] unit-test

[ "hello world" "." ] [ "hello world ." " " split1-last-slice [ >string ] bi@ ] unit-test
[ "hello-+world" "." ] [ "hello-+world-+." "-+" split1-last-slice [ >string ] bi@ ] unit-test
[ "goodbye" f ] [ "goodbye" " " split1-last-slice [ >string ] dip ] unit-test
[ "" f ] [ "great" "great" split1-last-slice [ >string ] dip ] unit-test

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

[ { SBUF" " } ] [ SBUF" " string-lines ] unit-test
[ { SBUF" " SBUF"  " } ] [ SBUF" \n" string-lines ] unit-test
[ { SBUF" " SBUF" " } ] [ SBUF" \r" string-lines ] unit-test
[ { SBUF" " SBUF" " } ] [ SBUF" \r\n" string-lines ] unit-test
[ { SBUF" hello" } ] [ SBUF" hello" string-lines ] unit-test
[ { SBUF" hello" SBUF" " } ] [ SBUF" hello\n" string-lines ] unit-test
[ { SBUF" hello" SBUF" " } ] [ SBUF" hello\r" string-lines ] unit-test
[ { SBUF" hello" SBUF" " } ] [ SBUF" hello\r\n" string-lines ] unit-test
[ { SBUF" hello" SBUF" hi" } ] [ SBUF" hello\nhi" string-lines ] unit-test
[ { SBUF" hello" SBUF" hi" } ] [ SBUF" hello\rhi" string-lines ] unit-test
[ { SBUF" hello" SBUF" hi" } ] [ SBUF" hello\r\nhi" string-lines ] unit-test

[ { "hey" "world" "what's" "happening" } ]
[ "heyAworldBwhat'sChappening" [ LETTER? ] split-when ] unit-test

[ "" f ] [ "" [ blank? ] split1-when ] unit-test
[ "" "ABC" ] [ " ABC" [ blank? ] split1-when ] unit-test
[ "a" " bc" ] [ "a  bc" [ blank? ] split1-when ] unit-test

{ { } } [ { } { 0 } split* ] unit-test
{ { { 1 2 3 } } } [ { 1 2 3 } { 0 } split* ] unit-test
{ { { 0 } } } [ { 0 } { 0 } split* ] unit-test
{ { { 0 } { 0 } } } [ { 0 0 } { 0 } split* ] unit-test
{ { { 1 2 0 } { 3 0 } { 0 } } } [ { 1 2 0 3 0 0 } { 0 } split* ] unit-test

{ { } } [ { } [ 0 > ] split*-when ] unit-test
{ { { 0 } } } [ { 0 } [ 0 > ] split*-when ] unit-test
{ { { 0 0 } } } [ { 0 0 } [ 0 > ] split*-when ] unit-test
{ { { 1 } { 2 } { 0 3 } { 0 0 } } } [ { 1 2 0 3 0 0 } [ 0 > ] split*-when ] unit-test

{ "abarbbarc" }
[ "afoobfooc" "foo" "bar" replace ] unit-test

{ "abc" }
[ "afoobfooc" "foo" "" replace ] unit-test

{ "afoobfooc" }
[ "afoobfooc" "" "bar" replace ] unit-test

{ "afoobfooc" }
[ "afoobfooc" "" "" replace ] unit-test

{ "" } [ "" "" "" replace ] unit-test
