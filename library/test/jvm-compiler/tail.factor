IN: scratchpad
USE: combinators
USE: kernel
USE: lists
USE: math
USE: prettyprint
USE: stack
USE: stdio
USE: test
USE: words

! Test tail recursive compilation.

"Checking tail call optimization." print

! Make sure we're doing *some* form of tail call optimization.
! Without it, this will overflow the stack.

: tail-call-0 1000 [ ] times ; word must-compile tail-call-0

: tail-call-1 ( -- )
    t [ ] [ tail-call-1 ] ifte ; word must-compile

[ ] [ ] [ tail-call-1 ] test-word

: tail-call-2 ( list -- f )
    [ dup cons? ] [ uncons nip ] while ; word must-compile

[ f ] [ [ 1 2 3 ] ] [ tail-call-2 ] test-word

: tail-call-3 ( x y -- z )
    >r dup succ r> swap 6 = [
        +
    ] [
        swap tail-call-3
    ] ifte ; word must-compile

[ 15 ] [ 10 5 ] [ tail-call-3 ] test-word

: tail-call-4 ( element tree -- ? )
    dup [
        2dup car = [
            nip
        ] [
            cdr dup cons? [
                tail-call-4
            ] [
                ! don't bomb on dotted pairs
                =
            ] ifte
        ] ifte
    ] [
        2drop f
    ] ifte ; word must-compile

3 [ 1 2 [ 3 4 ] 5 6 ] tail-call-4 .

"Tail call optimization checks done." print
