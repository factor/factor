USING: crypto errors kernel test strings ;

! No key
[ T{ no-xor-key f } ] [ [ "" dup xor-crypt ] catch ] unit-test
[ T{ no-xor-key f } ] [ [ { } dup xor-crypt ] catch ] unit-test
[ T{ no-xor-key f } ] [ [ V{ } dup xor-crypt ] catch ] unit-test
[ T{ no-xor-key f } ] [ [ "" "asdf" dupd xor-crypt xor-crypt ] catch ] unit-test

! a xor a = 0
[ { 0 0 0 0 0 0 0 } ] [ "abcdefg" dup xor-crypt ] unit-test

[ { 15 15 15 15 } ] [ { 10 10 10 10 } { 5 5 5 5 } xor-crypt ] unit-test

[ "asdf" ] [ "key" "asdf" dupd xor-crypt xor-crypt >string ] unit-test
[ "" ] [ "key" "" xor-crypt >string ] unit-test
[ "a longer message...!" ] [
    "."
    "a longer message...!" dupd xor-crypt xor-crypt >string
] unit-test
[ "a longer message...!" ] [
    "a very long key, longer than the message even."
    "a longer message...!" dupd xor-crypt xor-crypt >string
] unit-test
