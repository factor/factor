"Check compiler's auxiliary quotation code." print

: [call] call ;
: [[call]] [call] ;

: [nop] [ nop ] call ; word must-compile
: [[nop]] [ nop ] [call] ; word must-compile
: [[[nop]]] [ nop ] [[call]] ; word must-compile

[ ] [ ] [ [nop] ] test-word
[ ] [ ] [ [[nop]] ] test-word
[ ] [ ] [ [[[nop]]] ] test-word

: ?call t [ call ] [ drop ] ifte ;
: ?nop [ nop ] ?call ; word must-compile

: ??call t [ call ] [ ?call ] ifte ;
: ??nop [ nop ] ??call ; word must-compile

: ???call t [ call ] [ ???call ] ifte ;
: ???nop [ nop ] ???call ; word must-compile

[ ] [ ] [ ?nop ] test-word
[ ] [ ] [ ??nop ] test-word
[ ] [ ] [ ???nop ] test-word

: while-test [ f ] [ ] while ; word must-compile

[ ] [ ] [ while-test ] test-word

: [while]
    [ over call ] [ dup 2dip ] while 2drop ;

: [while-test] [ f ] [ ] [while] ; word must-compile

[ ] [ ] [ [while-test] ] test-word

: times-test-1 [ nop ] times ; word must-compile
: times-test-2 [ succ ] times ; word must-compile
: times-test-3 0 10 [ succ ] times ; word must-compile

[    ] [ 10   ] [ times-test-1 ] test-word
[ 10 ] [ 0 10 ] [ times-test-2 ] test-word
[ 10 ] [      ] [ times-test-3 ] test-word

: nested-ifte [ [ 1 ] [ 2 ] ifte ] [ [ 3 ] [ 4 ] ifte ] ifte ;
    compile-maybe

[ 1 ] [ t t ] [ nested-ifte ] test-word
[ 2 ] [ f t ] [ nested-ifte ] test-word
[ 3 ] [ t f ] [ nested-ifte ] test-word
[ 4 ] [ f f ] [ nested-ifte ] test-word

: flow-erasure [ 2 2 + ] [ ] dip call ; word must-compile

[ 4 ] [ ] [ flow-erasure ] test-word

"Auxiliary quotation checks done." print
