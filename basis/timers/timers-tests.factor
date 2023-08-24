USING: accessors calendar combinators concurrency.count-downs
concurrency.promises fry kernel math math.order sequences
threads timers tools.test tools.time ;

{ } [
    1 <count-down>
    { f } clone 2dup
    [ first stop-timer count-down ] 2curry 1 seconds later
    swap set-first
    await
] unit-test

{ } [
    self [ resume ] curry instant later drop
    "test" suspend drop
] unit-test

{ t } [
    [
        <promise>
        [ '[ t _ fulfill ] 2 seconds later drop ]
        [ 5 seconds ?promise-timeout drop ] bi
    ] benchmark 1,500,000,000 2,500,000,000 between?
] unit-test

{ { 3 } } [
    { 3 } dup
    '[ 4 _ set-first ] 2 seconds later
    1/2 seconds sleep
    stop-timer
] unit-test

{ { 1 } } [
    { 0 }
    dup '[ 0 _ [ 1 + ] change-nth ] 3 seconds later
    [ stop-timer ] [ start-timer ] bi
    4 seconds sleep
] unit-test

{ { 0 } { 1 } } [
    { 0 }
    dup '[ 3 seconds sleep 1 _ set-first ] 1 seconds later
    2 seconds sleep stop-timer
    1/2 seconds sleep [ clone ] keep
    2 seconds sleep clone
] unit-test

{ { 0 } } [
    { 0 }
    dup '[ 1 _ set-first ] 300 milliseconds later
    150 milliseconds sleep
    [ restart-timer ] [ 200 milliseconds sleep stop-timer ] bi
] unit-test

{ { 1 } } [
    { 0 }
    dup '[ 0 _ [ 1 + ] change-nth ] 200 milliseconds later
    100 milliseconds sleep restart-timer 300 milliseconds sleep
] unit-test

{ { 4 } } [
    { 0 }
    dup '[ 0 _ [ 1 + ] change-nth ] 300 milliseconds 300 milliseconds
    <timer> dup start-timer
    700 milliseconds sleep dup restart-timer
    700 milliseconds sleep stop-timer 500 milliseconds sleep
] unit-test

{ { 2 } } [
    { 0 }
    dup '[ 0 _ [ 1 + ] change-nth ] 300 milliseconds f <timer>
    dup restart-timer
    700 milliseconds sleep
    dup restart-timer drop
    700 milliseconds sleep
] unit-test


{ { 1 } t t t t } [
    { 0 }
    dup '[ 0 _ [ 1 + ] change-nth ] 300 milliseconds f <timer>
    dup start-timer [ thread>> ] keep {
        [ dup restart-timer thread>> eq? ]
        [ dup restart-timer thread>> eq? ]
        [ dup restart-timer thread>> eq? ]
        [ dup restart-timer thread>> eq? ]
    } 2cleave
    700 milliseconds sleep
] unit-test

[
    [ ] 1 seconds later start-timer
] [ timer-already-started? ] must-fail-with
