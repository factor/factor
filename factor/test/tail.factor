! Test tail recursive compilation.

"Checking tail call optimization." print

! Make sure we're doing *some* form of tail call optimization.
! Without it, this will overflow the stack.

: tail-call-0 1000 [ ] times ; compile-maybe tail-call-0

: tail-call-1 ( -- )
    t [ ] [ tail-call-1 ] ifte ; compile-maybe

[ ] [ ] [ tail-call-1 ] test-word

: tail-call-2 ( list -- f )
    [ dup cons? ] [ uncons nip ] while ; compile-maybe

[ f ] [ [ 1 2 3 ] ] [ tail-call-2 ] test-word

: tail-call-3 ( x y -- z )
    [ dup succ ] dip swap 6 = [
        +
    ] [
        swap tail-call-3
    ] ifte ; compile-maybe

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
    ] ifte ; compile-maybe

3 [ 1 2 [ 3 4 ] 5 6 ] tail-call-4 .

"Tail call optimization checks done." print
