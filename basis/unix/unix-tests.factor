USING: accessors continuations kernel libc locals math namespaces
sequences tools.test unix ;
IN: unix.tests

SYMBOL: call-count

: interrupted-once ( a b -- n )
    call-count [ 1 + ] change
    call-count get 1 = [ 2drop EINTR set-errno -1 ] [ + ] if ;

{ 42 2 } [
    0 call-count [
        19 23 [ interrupted-once ] unix-system-call
        call-count get
    ] with-variable
] unit-test

: fail-with-arguments ( a b -- n )
    2drop EACCES set-errno -1 ;

{ t } [
    [ 19 23 [ fail-with-arguments ] unix-system-call drop f ] [
        [ args>> { 19 23 } = ]
        [ errno>> EACCES = ]
        [ word>> \ fail-with-arguments = ] tri and and
    ] recover
] unit-test

: interrupted-close ( fd -- n )
    drop call-count [ 1 + ] change EINTR set-errno -1 ;

! close(2) must not be retried, but its return value must still be returned.
{ -1 1 } [
    0 call-count [
        42 [ interrupted-close ] unix-system-call-allow-eintr
        call-count get
    ] with-variable
] unit-test

: interrupted-change ( a b c d e f -- n )
    3drop 3drop EINTR set-errno -1 ;

! kevent(2) has six arguments; the old wrapper left all six on the stack.
{ -1 } [
    1 2 3 4 5 6 [ interrupted-change ] unix-system-call-allow-eintr
] unit-test

[ 19 23 [ fail-with-arguments ] unix-system-call-allow-eintr ]
[ errno>> EACCES = ] must-fail-with
