USING: kernel tools.test accessors concurrency.semaphores ;

{ 0 } [ 1 <semaphore> dup acquire count>> ] unit-test

{ 1 } [ 1 <semaphore> [ acquire ] [ release ] [ count>> ] tri ] unit-test

! this should not work
{ } [ 1 <semaphore> release ] unit-test

{ 1 } [
    1 <semaphore> [ [ ] with-semaphore ] [ count>> ] bi
] unit-test
