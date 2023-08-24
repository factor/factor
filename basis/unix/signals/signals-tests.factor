USING: calendar continuations io kernel libc math namespaces
threads tools.test unix.ffi unix.process unix.signals ;
IN: unix.signals.tests

SYMBOL: sigusr1-count
0 sigusr1-count set-global

CONSTANT: test-sigusr1-handler [ 1 sigusr1-count +@ ]

"=========" print
"NOTE: This test uses SIGUSR1. It may break or cause unwanted behavior" print
"if other SIGUSR1 handlers are installed." print
"=========" print flush

test-sigusr1-handler SIGUSR1 add-signal-handler
[

    [ 1 ] [
        sigusr1-count get-global
        SIGUSR1 raise yield drop
        1.0 seconds sleep
        sigusr1-count get-global
        swap -
    ] unit-test

] [ test-sigusr1-handler SIGUSR1 remove-signal-handler ] finally

{ 0 } [
    sigusr1-count get-global
    SIGUSR1 raise yield drop
    1.0 seconds sleep
    sigusr1-count get-global swap -
] unit-test
