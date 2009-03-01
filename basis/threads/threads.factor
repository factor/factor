! Copyright (C) 2004, 2008 Slava Pestov.
! Copyright (C) 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables heaps kernel kernel.private math
namespaces sequences vectors continuations continuations.private
dlists assocs system combinators init boxes accessors
math.order deques strings quotations fry ;
IN: threads

SYMBOL: initial-thread

TUPLE: thread
{ name string }
{ quot callable initial: [ ] }
{ exit-handler callable initial: [ ] }
{ id integer }
continuation
state
runnable
mailbox
variables
sleep-entry ;

: self ( -- thread ) 63 getenv ; inline

! Thread-local storage
: tnamespace ( -- assoc )
    self variables>> [ H{ } clone dup self (>>variables) ] unless* ;

: tget ( key -- value )
    self variables>> at ;

: tset ( value key -- )
    tnamespace set-at ;

: tchange ( key quot -- )
    tnamespace swap change-at ; inline

: threads ( -- assoc ) 64 getenv ;

: thread ( id -- thread ) threads at ;

: thread-registered? ( thread -- ? )
    id>> threads key? ;

: check-unregistered ( thread -- thread )
    dup thread-registered?
    [ "Thread already stopped" throw ] when ;

: check-registered ( thread -- thread )
    dup thread-registered?
    [ "Thread is not running" throw ] unless ;

<PRIVATE

: register-thread ( thread -- )
    check-unregistered dup id>> threads set-at ;

: unregister-thread ( thread -- )
    check-registered id>> threads delete-at ;

: set-self ( thread -- ) 63 setenv ; inline

PRIVATE>

: new-thread ( quot name class -- thread )
    new
        swap >>name
        swap >>quot
        \ thread counter >>id
        <box> >>continuation ; inline

: <thread> ( quot name -- thread )
    \ thread new-thread ;

: run-queue ( -- dlist ) 65 getenv ;

: sleep-queue ( -- heap ) 66 getenv ;

: resume ( thread -- )
    f >>state
    check-registered run-queue push-front ;

: resume-now ( thread -- )
    f >>state
    check-registered run-queue push-back ;

: resume-with ( obj thread -- )
    f >>state
    check-registered 2array run-queue push-front ;

: sleep-time ( -- us/f )
    {
        { [ run-queue deque-empty? not ] [ 0 ] }
        { [ sleep-queue heap-empty? ] [ f ] }
        [ sleep-queue heap-peek nip micros [-] ]
    } cond ;

DEFER: stop

<PRIVATE

: schedule-sleep ( thread dt -- )
    [ check-registered dup ] dip sleep-queue heap-push*
    >>sleep-entry drop ;

: expire-sleep? ( heap -- ? )
    dup heap-empty?
    [ drop f ] [ heap-peek nip micros <= ] if ;

: expire-sleep ( thread -- )
    f >>sleep-entry resume ;

: expire-sleep-loop ( -- )
    sleep-queue
    [ dup expire-sleep? ]
    [ dup heap-pop drop expire-sleep ]
    while
    drop ;

: start ( namestack thread -- * )
    [
        set-self
        set-namestack
        V{ } set-catchstack
        { } set-retainstack
        { } set-datastack
        self quot>> [ call stop ] call-clear
    ] 2 (throw) ;

DEFER: next

: no-runnable-threads ( -- * )
    ! We should never be in a state where the only threads
    ! are sleeping; the I/O wait thread is always runnable.
    ! However, if it dies, we handle this case
    ! semi-gracefully.
    !
    ! And if sleep-time outputs f, there are no sleeping
    ! threads either... so WTF.
    sleep-time [ die 0 ] unless* (sleep) next ;

: (next) ( arg thread -- * )
    f >>state
    dup set-self
    dup runnable>> [
        continuation>> box> continue-with
    ] [
        t >>runnable start
    ] if ;

: next ( -- * )
    expire-sleep-loop
    run-queue dup deque-empty? [
        drop no-runnable-threads
    ] [
        pop-back dup array? [ first2 ] [ f swap ] if (next)
    ] if ;

PRIVATE>

: stop ( -- )
    self [ exit-handler>> call ] [ unregister-thread ] bi next ;

: suspend ( quot state -- obj )
    [
        [ [ self swap call ] dip self (>>state) ] dip
        self continuation>> >box
        next
    ] callcc1 2nip ; inline

: yield ( -- ) [ resume ] f suspend drop ;

GENERIC: sleep-until ( time/f -- )

M: integer sleep-until
    '[ _ schedule-sleep ] "sleep" suspend drop ;

M: f sleep-until
    drop [ drop ] "interrupt" suspend drop ;

GENERIC: sleep ( dt -- )

M: real sleep
    micros + >integer sleep-until ;

: interrupt ( thread -- )
    dup state>> [
        dup sleep-entry>> [ sleep-queue heap-delete ] when*
        f >>sleep-entry
        dup resume
    ] when drop ;

: (spawn) ( thread -- )
    [ register-thread ] [ namestack swap resume-with ] bi ;

: spawn ( quot name -- thread )
    <thread> [ (spawn) ] keep ;

: spawn-server ( quot name -- thread )
    [ '[ _ loop ] ] dip spawn ;

: in-thread ( quot -- )
    [ datastack ] dip
    '[ _ set-datastack _ call ]
    "Thread" spawn drop ;

GENERIC: error-in-thread ( error thread -- )

<PRIVATE

: init-threads ( -- )
    H{ } clone 64 setenv
    <dlist> 65 setenv
    <min-heap> 66 setenv
    initial-thread global
    [ drop [ ] "Initial" <thread> ] cache
    <box> >>continuation
    t >>runnable
    f >>state
    dup register-thread
    set-self ;

PRIVATE>

[ init-threads ] "threads" add-init-hook
