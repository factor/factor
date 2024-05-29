USING: tools.test math math.functions kernel sequences lists
monads lazy ;
FROM: monads => do ;
IN: monads.tests

{ 5 } [ 1 identity-monad return [ 4 + ] fmap run-identity ] unit-test
[ "OH HAI" identity-monad fail ] must-fail

{ 666 } [
    111 <just> [ 6 * ] fmap [ ] [ "OOPS" throw ] if-maybe
] unit-test

{ nothing } [
    111 <just> [ maybe-monad fail ] bind
] unit-test

{ 100 } [
    5 either-monad return [ 10 * ] [ 20 * ] if-either
] unit-test

{ T{ left f "OOPS" } } [
    5 either-monad return >>= [ drop "OOPS" either-monad fail ] swap call
] unit-test

{ { 10 20 30 } } [
    { 1 2 3 } [ 10 * ] fmap
] unit-test

{ { } } [
    { 1 2 3 } [ drop "OOPS" array-monad fail ] bind
] unit-test

{ 5 } [
    5 state-monad return "initial state" run-st
] unit-test

{ 8 } [
    5 state-monad return [ 3 + state-monad return ] bind
    "initial state" run-st
] unit-test

{ 8 } [
    5 state-monad return >>=
    [ 3 + state-monad return ] swap call
    "initial state" run-st
] unit-test

{ 11 } [
    f state-monad return >>=
    [ drop get-st ] swap call
    11 run-st
] unit-test

{ 15 } [
    f state-monad return
    [ drop get-st ] bind
    [ 4 + put-st ] bind
    [ drop get-st ] bind
    11 run-st
] unit-test

{ 15 } [
    {
        [ f return-st ]
        [ drop get-st ]
        [ 4 + put-st ]
        [ drop get-st ]
    } do
    11 run-st
] unit-test

{ nothing } [
    {
        [ "hi" <just> ]
        [ " bye" append <just> ]
        [ drop nothing ]
        [ reverse <just> ]
    } do
] unit-test

LAZY: nats-from ( n -- list )
    dup 1 + nats-from cons ;

: nats ( -- list ) 0 nats-from ;

{ 3 } [
    {
        [ nats ]
        [ dup 3 = [ list-monad return ] [ list-monad fail ] if ]
    } do car
] unit-test

{ 9/11 } [
    {
        [ ask ]
    } do 9/11 run-reader
] unit-test

{ 8 } [
    {
        [ ask ]
        [ 3 + reader-monad return ]
    } do
    5 run-reader
] unit-test

{ 6 } [
    f reader-monad return [ drop ask ] bind [ 1 + ] local 5 run-reader
] unit-test

{ f { 1 2 3 } } [
    5 writer-monad return
    [ drop { 1 2 3 } tell ] bind
    run-writer
] unit-test

{
    T{ writer
        { value 1.618033988749895 }
        { log
            "Started with five, took square root, added one, divided by two."
        }
    }
} [
    {
        [ 5 "Started with five, " <writer> ]
        [ sqrt "took square root, " <writer> ]
        [ 1 + "added one, " <writer> ]
        [ 2 / "divided by two." <writer> ]
    } do
] unit-test

{ T{ identity f 7 } }
[
    4 identity-monad return
    [ 3 + ] identity-monad return
    identity-monad apply
] unit-test

{ nothing } [
    5 <just> nothing maybe-monad apply
] unit-test

{ T{ just f 15 } } [
    5 <just> [ 10 + ] <just> maybe-monad apply
] unit-test
