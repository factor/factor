IN: urls.encoding.tests
USING: urls.encoding tools.test arrays kernel assocs present accessors ;

[ "~hello world" ] [ "%7ehello world" url-decode ] unit-test
[ "" ] [ "%XX%XX%XX" url-decode ] unit-test
[ "" ] [ "%XX%XX%X" url-decode ] unit-test

[ "hello world" ] [ "hello%20world" url-decode ] unit-test
[ " ! "         ] [ "%20%21%20"     url-decode ] unit-test
[ "hello world" ] [ "hello world%"  url-decode ] unit-test
[ "hello world" ] [ "hello world%x" url-decode ] unit-test
[ "hello%20world" ] [ "hello world" url-encode ] unit-test

[ "hello world" ] [ "hello+world" query-decode ] unit-test

[ "\u001234hi\u002045" ] [ "\u001234hi\u002045" url-encode url-decode ] unit-test

[ "a=b&a=c" ] [ { { "a" { "b" "c" } } } assoc>query ] unit-test

[ H{ { "a" "b" } } ] [ "a=b" query>assoc ] unit-test

[ H{ { "a" { "b" "c" } } } ] [ "a=b&a=c" query>assoc ] unit-test

[ H{ { "a" { "b" "c" } } } ] [ "a=b;a=c" query>assoc ] unit-test

[ H{ { "text" "hello world" } } ] [ "text=hello+world" query>assoc ] unit-test

[ "a=3" ] [ { { "a" 3 } } assoc>query ] unit-test

[ "a" ] [ { { "a" f } } assoc>query ] unit-test

[ H{ { "a" f } } ] [ "a" query>assoc ] unit-test