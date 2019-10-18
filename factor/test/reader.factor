[ [ one [ two [ three ] four ] five ] ]
[ "one [ two [ three ] four ] five" ]
[ parse ]
test-word

[ [ 1 [ 2 [ 3 ] 4 ] 5 ] ]
[ "1\n[\n2\n[\n3\n]\n4\n]\n5" ]
[ parse ]
test-word

[ [ t t f f ] ]
[ "t t f f" ]
[ parse ]
test-word

[ [ "hello world" ] ]
[ "\"hello world\"" ]
[ parse ]
test-word

[ [ "\n\r\t\\" ] ]
[ "\"\\n\\r\\t\\\\\"" ]
[ parse ]
test-word

[ [ "hello\nworld" x y z ] ]
[ "\"hello\\nworld\" x y z" ]
[ parse ]
test-word

[ "hello world" ]
[ ": hello \"hello world\" ;" ]
[ parse call hello ]
test-word

[ 1 2 ]
[ "~<< my-swap a b -- b a >>~" ]
[ parse call 2 1 my-swap ]
test-word

[ ]
[ "! This is a comment, people." ]
[ parse call ]
test-word

[ ]
[ "( This is a comment, people. )" ]
[ parse call ]
test-word

[ [ "test" $ ] ]
[ "$test" ]
[ parse ]
test-word

[ [ "test" @ ] ]
[ "@test" ]
[ parse ]
test-word

[ [ $ 100 ] ]
[ "$ 100" ]
[ parse ]
test-word

[ [ slava @ jedit . org ] ]
[ "slava @ jedit . org" ]
[ parse ]
test-word

[ [ [ a , b ] ] ]
[ "[ a , b ]" ]
[ parse ]
test-word

[ [ $ ] ]
[ "$" ]
[ parse ]
test-word

[ f ]
[ f ]
[ parse-number ]
test-word

[ 123456789123456789123456789 ]
[ "123456789123456789123456789" ]
[ parse-number ]
test-word

[ "\"hello\\\\backslash\"" ]
[ "hello\\backslash" ]
[ unparse ]
test-word
