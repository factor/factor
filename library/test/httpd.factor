IN: scratchpad
USE: httpd
USE: httpd-responder
USE: stdio
USE: test
USE: url-encoding

"HTTPD tests" print

[ "hello world"   ] [ "hello+world"    ] [ url-decode ] test-word
[ "hello world"   ] [ "hello%20world"  ] [ url-decode ] test-word
[ " ! "           ] [ "%20%21%20"      ] [ url-decode ] test-word
[ "hello world"   ] [ "hello world%"   ] [ url-decode ] test-word
[ "hello world"   ] [ "hello world%x"  ] [ url-decode ] test-word
[ "hello%20world" ] [ "hello world"    ] [ url-encode ] test-word
[ "%20%21%20"     ] [ " ! "            ] [ url-encode ] test-word

! These make sure the words work, and don't leave
! extra crap on the stakc
[ ] [ "404 not found" ] [ httpd-error ] test-word

[ ] [ "/" "get" ] [ serve-responder ] test-word
[ ] [ "" "get" ] [ serve-responder ] test-word
[ ] [ "test" "get" ] [ serve-responder ] test-word
[ ] [ "test/" "get" ] [ serve-responder ] test-word
[ ] [ "does-not-exist!" "get" ] [ serve-responder ] test-word
[ ] [ "does-not-exist!/" "get" ] [ serve-responder ] test-word

[ ] [ "inspect/global" "get" ] [ serve-responder ] test-word
