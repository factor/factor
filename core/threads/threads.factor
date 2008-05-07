! Copyright (C) 2004, 2008 Slava Pestov.
! Copyright (C) 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables heaps kernel kernel.private math
namespaces sequences vectors continuations continuations.private
dlists assocs system combinators init boxes accessors
math.order ;
IN: threads

SYMBOL: initial-thread

TUPLE: thread
name quot exit-handler
id
continuation state
mailbox variables sleep-entry ;

: self ( -- thread ) 40 getenv ; inline

! Thread-local storage
: tnamespace ( -- assoc )
    self variables>> [ H{ } clone dup self (>>variables) ] unless* ;

: tget ( key -- value )
    self variables>> at ;

: tset ( value key -- )
    tnamespace set-at ;

: tchange ( key quot -- )
    tnamespace swap change-at ; inline

: threads 41 getenv ;

: thread ( id -- thread ) threads at ;

: thread-registered? ( thread -- ? )
    id>> threads key? ;

: check-unregistered
    dup thread-registered?
    [ "Thread already stopped" throw ] when ;

: check-registered
    dup thread-registered?
    [ "Thread is not running" throw ] unless ;

<PRIVATE

: register-thread ( thread -- )
    check-unregistered dup id>> threads set-at ;

: unregister-thread ( thread -- )
    check-registered id>> threads delete-at ;

: set-self ( thread -- ) 40 setenv ; inline

PRIVATE>

: new-thread ( quot name class -- thread )
    new
        swap >>name
        swap >>quot
        \ thread counter >>id
        <box> >>continuation
        [ ] >>exit-handler ; inline

: <thread> ( quot name -- thread )
    \ thread new-thread ;

: run-queue 42 getenv ;

: sleep-queue 43 getenv ;

: resume ( thread -- )
    f >>state
    check-registered run-queue push-front ;

: resume-now ( thread -- )
    f >>state
    check-registered run-queue push-back ;

: resume-with ( obj thread -- )
    f >>state
    check-registered 2array run-queue push-front ;

: sleep-time ( -- ms/f )
    {
        { [ run-queue dlist-empty? not ] [ 0 ] }
        { [ sleep-queue heap-empty? ] [ f ] }
        [ sleep-queue heap-peek nip millis [-] ]
    } cond ;

DEFER: stop

<PRIVATE

: schedule-sleep ( thread dt -- )
    >r check-registered dup r> sleep-queue heap-push*
    >>sleep-entry drop ;

: expire-sleep? ( heap -- ? )
    dup heap-empty?
    [ drop f ] [ heap-peek nip millis <= ] if ;

: expire-sleep ( thread -- )
    f >>sleep-entry resume ;

: expire-sleep-loop ( -- )
    sleep-queue
    [ dup expire-sleep? ]
    [ dup heap-pop drop expire-sleep ]
    [ ] while
    drop ;

: start ( namestack thread -- )
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
    dup continuation>> ?box
    [ nip continue-with ] [ drop start ] if ;

: next ( -- * )
    expire-sleep-loop
    run-queue dup dlist-empty? [
        drop no-runnable-threads
    ] [
        pop-back dup array? [ first2 ] [ f swap ] if (next)
    ] if ;

PRIVATE>

: stop ( -- )
    self [ exit-handler>> call ] [ unregister-thread ] bi next ;

: suspend ( quot state -- obj )
    [
        >r
        >r self swap call
        r> self (>>state)
        r> self continuation>> >box
        next
    ] callcc1 2nip ; inline

: yield ( -- ) [ resume ] f suspend drop ;

GENERIC: sleep-until ( time/f -- )

M: integer sleep-until
    [ schedule-sleep ] curry "sleep" suspend drop ;

M: f sleep-until
    drop [ drop ] "interrupt" suspend drop ;

GENERIC: sleep ( dt -- )

M: real sleep
    millis + >integer sleep-until ;

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
    >r [ [ ] [ ] while ] curry r> spawn ;

: in-thread ( quot -- )
    >r datastack r>
    [ >r set-datastack r> call ] 2curry
    "Thread" spawn drop ;

GENERIC: error-in-thread ( error thread -- )

<PRIVATE

: init-threads ( -- )
    H{ } clone 41 setenv
    <dlist> 42 setenv
    <min-heap> 43 setenv
    initial-thread global
    [ drop f "Initial" <thread> ] cache
    <box> >>continuation
    f >>state
    dup register-thread
    set-self ;

[ self error-in-thread stop ]
thread-error-hook set-global

PRIVATE>

[ init-threads ] "threads" add-init-hook
