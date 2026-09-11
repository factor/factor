USING: tools.test kernel concurrency.conditions dlists threads
deques accessors calendar locals timers ;

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

! A callback already queued before notification must not remove/resume twice.
{ t } [
  [let
    <dlist> :> queue
    queue 1 seconds queue-timeout :> timer
    timer stop-timer
    queue pop-back t >>notified? drop
    timer quot>> call( -- )
    queue deque-empty?
  ]
] unit-test
