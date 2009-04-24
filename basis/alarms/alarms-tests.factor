IN: alarms.tests
USING: alarms alarms.private kernel calendar sequences
tools.test threads concurrency.count-downs ;

[ ] [
    1 <count-down>
    { f } clone 2dup
    [ first cancel-alarm count-down ] 2curry 1 seconds later
    swap set-first
    await
] unit-test

[ ] [
    [
        [ resume ] curry instant later drop
    ] "test" suspend drop
] unit-test
