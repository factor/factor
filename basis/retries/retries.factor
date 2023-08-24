! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar combinators combinators.smart
continuations kernel math math.functions math.parser ranges
namespaces prettyprint random sequences system threads ;
IN: retries

TUPLE: retries count time-strategy errors ;
: new-retries ( class -- obj )
    new
        0 >>count
        V{ } clone >>errors ; inline

TUPLE: counted-retries < retries max-retries ;
: <counted-retries> ( time-strategy max-retries -- retries )
    counted-retries new-retries
        swap >>max-retries
        swap >>time-strategy ; inline

TUPLE: sequence-retries < retries seq ;
: <sequence-retries> ( time-strategy seq -- retries )
    sequence-retries new-retries
        swap >>seq
        swap >>time-strategy ; inline

GENERIC: retries* ( time-strategy seq/n -- obj )
M: integer retries* <counted-retries> ;
M: sequence retries* <sequence-retries> ;

TUPLE: time-strategy ;
TUPLE: immediate < time-strategy ;
C: <immediate> immediate

TUPLE: random-wait < time-strategy lo hi ;
C: <random-wait> random-wait

TUPLE: exponential-wait < time-strategy exp nanos ;
C: <exponential-wait> exponential-wait

GENERIC: retry-obj ( retries -- elt/obj/index retry? )
GENERIC: retry-sleep-time ( retries time-strategy -- nanos/timestamp/0 )
: next-retry ( retries -- elt/obj/index nanos/timestamp/0 ? )
    {
        [ retry-obj ]
        [ [ ] [ time-strategy>> ] bi retry-sleep-time ]
        [ pick [ [ 1 + ] change-count drop ] [ drop ] if swap ]
    } cleave ;

M: immediate retry-sleep-time 2drop 0 ;
M: random-wait retry-sleep-time nip [ lo>> ] [ hi>> ] bi [a..b] random ;
M: exponential-wait retry-sleep-time [ count>> ] [ [ exp>> ^ ] [ nanos>> * ] bi ] bi* ;

: nth* ( n seq -- elt/f ? ) 2dup bounds-check? [ nth t ] [ 2drop f f ] if ;

M: counted-retries retry-obj [ count>> ] [ max-retries>> ] bi dupd < ;
M: sequence-retries retry-obj [ count>> ] [ seq>> ] bi nth* ;

SYMBOL: current-retries
ERROR: retries-failed retries quot ;

: with-retries ( retries quot -- result )
    [ current-retries ] dip dup '[
        f [
            drop
            current-retries get next-retry [
                [ sleep ] unless-zero
                _ [ f ] compose [
                    current-retries get count>>
                    now 4array current-retries get errors>> push f t
                ] recover
            ] [
                current-retries get _ retries-failed
            ] if
        ] loop
    ] with-variable ; inline

: retries ( quot time-strategy n/seq -- result )
    retries* swap with-retries ; inline
