IN: scratchpad
USE: combinators
USE: kernel
USE: math
USE: stack
USE: stdio
USE: test
USE: words

"Check compiler's auxiliary quotation code." print

: [call] call ; inline
: [[call]] [call] ; inline

: [nop] [ nop ] call ; word must-compile
: [[nop]] [ nop ] [call] ; word must-compile
: [[[nop]]] [ nop ] [[call]] ; word must-compile

[ ] [ ] [ [nop] ] test-word
[ ] [ ] [ [[nop]] ] test-word
[ ] [ ] [ [[[nop]]] ] test-word

: ?call t [ call ] [ drop ] ifte ; inline
: ?nop [ nop ] ?call ; word must-compile

: ??call t [ call ] [ ?call ] ifte ; inline
: ??nop [ nop ] ??call ; word must-compile

: ???call t [ call ] [ ???call ] ifte ; inline
: ???nop [ nop ] ???call ; word must-compile

[ ] [ ] [ ?nop ] test-word
[ ] [ ] [ ??nop ] test-word
[ ] [ ] [ ???nop ] test-word

: while-test [ f ] [ ] while ; word must-compile

[ ] [ ] [ while-test ] test-word

: times-test-1 [ nop ] times ; word must-compile
: times-test-2 [ succ ] times ; word must-compile
: times-test-3 0 10 [ succ ] times ; word must-compile

[    ] [ 10   ] [ times-test-1 ] test-word
[ 10 ] [ 0 10 ] [ times-test-2 ] test-word
[ 10 ] [      ] [ times-test-3 ] test-word

: nested-ifte [ [ 1 ] [ 2 ] ifte ] [ [ 3 ] [ 4 ] ifte ] ifte ; word must-compile

[ 1 ] [ t t ] [ nested-ifte ] test-word
[ 2 ] [ f t ] [ nested-ifte ] test-word
[ 3 ] [ t f ] [ nested-ifte ] test-word
[ 4 ] [ f f ] [ nested-ifte ] test-word

: flow-erasure [ 2 2 + ] [ ] swap >r call r> call ; inline word must-compile

[ 4 ] [ ] [ flow-erasure ] test-word

! This got broken when I changed : ifte ? call ; to primitive
: twice-nested-ifte
    t [
        t [
            
        ] [
            twice-nested-ifte
        ] ifte
    ] [
        
    ] ifte ; word must-compile

"Auxiliary quotation checks done." print
