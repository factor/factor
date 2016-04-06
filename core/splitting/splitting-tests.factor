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
[ "This is a split sentence" " " split ]
unit-test

{ { "OneWord" } }
[ "OneWord" " " split ]
unit-test

{ { "a" "b" "c" "d" "e" "f" } }
[ "aXbYcXdYeXf" "XY" split ] unit-test

{ { "" "" } }
[ " " " " split ] unit-test

{ { "hey" } }
[ "hey" " " split ] unit-test

{ "Hello world" t } [ "Hello world\n" "\n" ?tail ] unit-test
{ "Hello world" f } [ "Hello world" "\n" ?tail ] unit-test
{ "" t } [ "\n" "\n" ?tail ] unit-test
{ "" f } [ "" "\n" ?tail ] unit-test

{ { } } [ "" string-lines ] unit-test
{ { "" } } [ "\n" string-lines ] unit-test
{ { "" } } [ "\r" string-lines ] unit-test
{ { "" } } [ "\r\n" string-lines ] unit-test
{ { "hello" } } [ "hello" string-lines ] unit-test
{ { "hello" } } [ "hello\n" string-lines ] unit-test
{ { "hello" } } [ "hello\r" string-lines ] unit-test
{ { "hello" } } [ "hello\r\n" string-lines ] unit-test
{ { "hello" "hi" } } [ "hello\nhi" string-lines ] unit-test
{ { "hello" "hi" } } [ "hello\rhi" string-lines ] unit-test
{ { "hello" "hi" } } [ "hello\r\nhi" string-lines ] unit-test
{ { "hello" "" "" } } [ "hello\n\n\n" string-lines ] unit-test

{ { } } [ SBUF" " string-lines ] unit-test
{ { "" } } [ SBUF" \n" string-lines ] unit-test
{ { "" } } [ SBUF" \r" string-lines ] unit-test
{ { "" } } [ SBUF" \r\n" string-lines ] unit-test
{ { "hello" } } [ SBUF" hello" string-lines ] unit-test
{ { "hello" } } [ SBUF" hello\n" string-lines ] unit-test
{ { "hello" } } [ SBUF" hello\r" string-lines ] unit-test
{ { "hello" } } [ SBUF" hello\r\n" string-lines ] unit-test
{ { "hello" "hi" } } [ SBUF" hello\nhi" string-lines ] unit-test
{ { "hello" "hi" } } [ SBUF" hello\rhi" string-lines ] unit-test
{ { "hello" "hi" } } [ SBUF" hello\r\nhi" string-lines ] unit-test
{ { "hello" "" "" } } [ SBUF" hello\n\n\n" string-lines ] unit-test

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
