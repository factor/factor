USING: continuations crypto.xor kernel strings tools.test ;
IN: crypto.xor.tests

! No key
[ ""        dup  xor-crypt           ] [ T{ empty-xor-key } = ] must-fail-with
[ { }       dup  xor-crypt           ] [ T{ empty-xor-key } = ] must-fail-with
[ V{ }      dup  xor-crypt           ] [ T{ empty-xor-key } = ] must-fail-with
[ "" "asdf" dupd xor-crypt xor-crypt ] [ T{ empty-xor-key } = ] must-fail-with

! a xor a = 0
{ "\0\0\0\0\0\0\0" } [ "abcdefg" dup xor-crypt ] unit-test

{ { 15 15 15 15 } } [ { 10 10 10 10 } { 5 5 5 5 } xor-crypt ] unit-test

{ "asdf" } [ "asdf" "key" [ xor-crypt ] [ xor-crypt ] bi >string ] unit-test
{ "" } [ "" "key" xor-crypt >string ] unit-test
{ "a longer message...!" } [
    "a longer message...!"
    "." [ xor-crypt ] [ xor-crypt ] bi >string
] unit-test
{ "a longer message...!" } [
    "a longer message...!"
    "a very long key, longer than the message even."
    [ xor-crypt ] [ xor-crypt ] bi >string
] unit-test
