USING: alarms alarms.private kernel calendar sequences
tools.test threads concurrency.count-downs concurrency.promises
fry tools.time math ;
IN: alarms.tests

[ ] [
    1 <count-down>
    { f } clone 2dup
    [ first cancel-alarm count-down ] 2curry 1 seconds later
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
        '[ t _ fulfill ] 5 seconds later drop
    ] benchmark 4,000,000,000 >
] unit-test

[ { 3 } ] [
    { 3 } dup
    '[ 4 _ set-first ] 2 seconds later
    1/2 seconds sleep
    cancel-alarm
] unit-test
