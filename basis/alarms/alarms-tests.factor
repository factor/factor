USING: alarms alarms.private calendar concurrency.count-downs
concurrency.promises fry kernel math math.order sequences
threads tools.test tools.time ;
IN: alarms.tests

[ ] [
    1 <count-down>
    { f } clone 2dup
    [ first stop-alarm count-down ] 2curry 1 seconds later
    swap set-first
    await
] unit-test

[ ] [
    self [ resume ] curry instant later drop
    "test" suspend drop
] unit-test

[ t ] [
    [
        <promise>
        [ '[ t _ fulfill ] 2 seconds later drop ]
        [ 5 seconds ?promise-timeout drop ] bi
    ] benchmark 1,500,000,000 2,500,000,000 between?
] unit-test

[ { 3 } ] [
    { 3 } dup
    '[ 4 _ set-first ] 2 seconds later
    1/2 seconds sleep
    stop-alarm
] unit-test

[ { 1 } ] [
    { 0 }
    dup '[ 0 _ [ 1 + ] change-nth ] 3 seconds later
    [ stop-alarm ] [ start-alarm ] bi
    4 seconds sleep
] unit-test
