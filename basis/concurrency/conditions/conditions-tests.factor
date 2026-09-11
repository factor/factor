USING: tools.test kernel concurrency.conditions dlists threads
deques ;

{ V{ "leftover" } } [
    "leftover" 1dlist dup
    [ ] "foo" <thread> over push-back
    notify-1
    dlist>sequence
] unit-test

{ } [ <dlist> notify-all ] unit-test

{ V{ } } [
    <dlist> dup
    [ ] "foo" <thread> over push-back
    [ ] "bar" <thread> over push-back
    notify-all
    dlist>sequence
] unit-test
