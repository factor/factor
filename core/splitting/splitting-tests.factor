USING: ascii kernel math sequences splitting strings tools.test ;

{ "hello" "world ." } [ "hello world ." " " split1 ] unit-test
{ "hello" "world-+." } [ "hello-+world-+." "-+" split1 ] unit-test
{ "goodbye" f } [ "goodbye" " " split1 ] unit-test
{ "" "" } [ "great" "great" split1 ] unit-test

{ "hello world" "." } [ "hello world ." " " split1-last ] unit-test
{ "hello-+world" "." } [ "hello-+world-+." "-+" split1-last ] unit-test
{ "goodbye" f } [ "goodbye" " " split1-last ] unit-test
{ "" "" } [ "great" "great" split1-last ] unit-test

{ "hello world" "." } [ "hello world ." " " split1-last-slice [ >string ] bi@ ] unit-test
{ "hello-+world" "." } [ "hello-+world-+." "-+" split1-last-slice [ >string ] bi@ ] unit-test
{ "goodbye" f } [ "goodbye" " " split1-last-slice [ >string ] dip ] unit-test
{ "" f } [ "great" "great" split1-last-slice [ >string ] dip ] unit-test

{ "and end" t } [ "Beginning and end" "Beginning " ?head ] unit-test
{ "Beginning and end" f } [ "Beginning and end" "Beginning x" ?head ] unit-test
{ "Beginning and end" f } [ "Beginning and end" "eginning " ?head ] unit-test

{ "Beginning" t } [ "Beginning and end" " and end" ?tail ] unit-test
{ "Beginning and end" f } [ "Beginning and end" "Beginning x" ?tail ] unit-test
{ "Beginning and end" f } [ "Beginning and end" "eginning " ?tail ] unit-test

{ { "This" "is" "a" "split" "sentence" } }
[ "This is a split sentence" words ]
unit-test

{ { "OneWord" } }
[ "OneWord" words ]
unit-test

{ { "a" "b" "c" "d" "e" "f" } }
[ "aXbYcXdYeXf" "XY" split ] unit-test

{ { "" "" } }
[ " " words ] unit-test

{ { "hey" } }
[ "hey" words ] unit-test

{ "Hello world" t } [ "Hello world\n" "\n" ?tail ] unit-test
{ "Hello world" f } [ "Hello world" "\n" ?tail ] unit-test
{ "" t } [ "\n" "\n" ?tail ] unit-test
{ "" f } [ "" "\n" ?tail ] unit-test

{ { } } [ "" lines ] unit-test
{ { "" } } [ "\n" lines ] unit-test
{ { "" } } [ "\r" lines ] unit-test
{ { "" } } [ "\r\n" lines ] unit-test
{ { "hello" } } [ "hello" lines ] unit-test
{ { "hello" } } [ "hello\n" lines ] unit-test
{ { "hello" } } [ "hello\r" lines ] unit-test
{ { "hello" } } [ "hello\r\n" lines ] unit-test
{ { "hello" "hi" } } [ "hello\nhi" lines ] unit-test
{ { "hello" "hi" } } [ "hello\rhi" lines ] unit-test
{ { "hello" "hi" } } [ "hello\r\nhi" lines ] unit-test
{ { "hello" "" "" } } [ "hello\n\n\n" lines ] unit-test

{ { } } [ SBUF" " lines ] unit-test
{ { "" } } [ SBUF" \n" lines ] unit-test
{ { "" } } [ SBUF" \r" lines ] unit-test
{ { "" } } [ SBUF" \r\n" lines ] unit-test
{ { "hello" } } [ SBUF" hello" lines ] unit-test
{ { "hello" } } [ SBUF" hello\n" lines ] unit-test
{ { "hello" } } [ SBUF" hello\r" lines ] unit-test
{ { "hello" } } [ SBUF" hello\r\n" lines ] unit-test
{ { "hello" "hi" } } [ SBUF" hello\nhi" lines ] unit-test
{ { "hello" "hi" } } [ SBUF" hello\rhi" lines ] unit-test
{ { "hello" "hi" } } [ SBUF" hello\r\nhi" lines ] unit-test
{ { "hello" "" "" } } [ SBUF" hello\n\n\n" lines ] unit-test

{ { "hey" "world" "what's" "happening" } }
[ "heyAworldBwhat'sChappening" [ LETTER? ] split-when ] unit-test
{ { { 2 } { 3 } { 5 1 } { 7 } } } [
    1 { 2 1 3 2 5 1 3 7 }
    [ dupd = dup [ [ 1 + ] dip ] when ] split-when nip
] unit-test

{ { "hey" "world" "what's" "happening" } }
[
    "heyAworldBwhat'sChappening" [ LETTER? ] split-when-slice
    [ >string ] map
] unit-test

{ "" f } [ "" [ blank? ] split1-when ] unit-test
{ "" "ABC" } [ " ABC" [ blank? ] split1-when ] unit-test
{ "a" " bc" } [ "a  bc" [ blank? ] split1-when ] unit-test

{ "" f } [ "" [ blank? ] split1-when-slice ] unit-test
{ "" "ABC" } [ " ABC" [ blank? ] split1-when-slice [ >string ] bi@ ] unit-test
{ "a" " bc" } [ "a  bc" [ blank? ] split1-when-slice [ >string ] bi@ ] unit-test

{ "abarbbarc" }
[ "afoobfooc" "foo" "bar" replace ] unit-test

{ "abc" }
[ "afoobfooc" "foo" "" replace ] unit-test

{ "afoobfooc" }
[ "afoobfooc" "" "bar" replace ] unit-test

{ "afoobfooc" }
[ "afoobfooc" "" "" replace ] unit-test

{ "" } [ "" "" "" replace ] unit-test

{ { "Thi" "s " "i" "s a sequence" } } [
    "This is a sequence" { 3 5 6 } split-indices
] unit-test

{ { "" "This" } } [
    "This" { 0 } split-indices
] unit-test
