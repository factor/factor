IN: temporary
USING: test inspector prettyprint math ;

[[ 1 2 ]] inspect
[ 1 2 3 ] inspect
f inspect
\ + inspect

[ "hello world how are you" ]
[ [ "hello" "world" "how" "are" "you" ] " " join ]
unit-test
