USING: kernel tools.test accessors concurrency.semaphores ;

USING: concurrency.futures concurrency.promises locals threads ;

! A notified waiter must recheck availability if another thread barges in.
{ f 0 } [
    1 <semaphore> [| semaphore |
        semaphore acquire
        [ semaphore [ semaphore count>> ] with-semaphore ] future :> waiter
        yield
        semaphore release semaphore acquire
        yield waiter promise-fulfilled?
        semaphore release waiter ?future
    ] call
] unit-test

{ 0 } [ 1 <semaphore> dup acquire count>> ] unit-test

{ 1 } [ 1 <semaphore> [ acquire ] [ release ] [ count>> ] tri ] unit-test

! this should not work
{ } [ 1 <semaphore> release ] unit-test

{ 1 } [
    1 <semaphore> [ [ ] with-semaphore ] [ count>> ] bi
] unit-test
