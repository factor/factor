IN: scratchpad
USE: httpd
USE: httpd-responder
USE: logging
USE: namespaces
USE: stdio
USE: test
USE: url-encoding

[ "HTTP/1.0 404\nContent-Type: text/html\n" ]
[ "404" "text/html" response ] unit-test

[ 5430 ]
[ f "Content-Length: 5430" header-line content-length ] unit-test


[ "hello world"   ] [ "hello+world"    url-decode ] unit-test
[ "hello world"   ] [ "hello%20world"  url-decode ] unit-test
[ " ! "           ] [ "%20%21%20"      url-decode ] unit-test
[ "hello world"   ] [ "hello world%"   url-decode ] unit-test
[ "hello world"   ] [ "hello world%x"  url-decode ] unit-test
[ "hello%20world" ] [ "hello world"    url-encode ] unit-test
[ "%20%21%20"     ] [ " ! "            url-encode ] unit-test

! These make sure the words work, and don't leave
! extra crap on the stakc
[ ] [ "404 not found" ] [ httpd-error ] test-word

[ "arg" ] [
    [
        "arg" "default-argument" set
        "" responder-argument
    ] with-scope
] unit-test

[ "inspect/global" ] [ "/inspect/global" trim-/ ] unit-test

[ ] [
    [
        "unit/test" log-responder
    ] with-logging
] unit-test

[ ] [ "/" "get" ] [ serve-responder ] test-word
[ ] [ "" "get" ] [ serve-responder ] test-word
[ ] [ "test" "get" ] [ serve-responder ] test-word
[ ] [ "test/" "get" ] [ serve-responder ] test-word
[ ] [ "does-not-exist!" "get" ] [ serve-responder ] test-word
[ ] [ "does-not-exist!/" "get" ] [ serve-responder ] test-word

[ ] [ "inspect/global" "get" ] [ serve-responder ] test-word
