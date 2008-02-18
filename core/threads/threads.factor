! Copyright (C) 2004, 2008 Slava Pestov.
! Copyright (C) 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
IN: threads
USING: arrays hashtables heaps kernel kernel.private math
namespaces sequences vectors continuations continuations.private
dlists assocs system combinators debugger prettyprint io init ;

SYMBOL: initial-thread

TUPLE: thread
name quot error-handler
id registered?
continuation
mailbox variables ;

: self ( -- thread ) 40 getenv ; inline

! Thread-local storage
: tnamespace ( -- assoc ) self thread-variables ;

: tget ( key -- value ) tnamespace at ;

: tset ( value key -- ) tnamespace set-at ;

: tchange ( key quot -- ) tnamespace change-at ; inline

SYMBOL: threads

threads global [ H{ } assoc-like ] change-at

: thread ( id -- thread ) threads get-global at ;

<PRIVATE

: check-unregistered
    dup thread-registered?
    [ "Registering a thread twice" throw ] when ;

: check-registered
    dup thread-registered?
    [ "Unregistering a thread twice" throw ] unless ;

: register-thread ( thread -- )
    check-unregistered
    t over set-thread-registered?
    dup thread-id threads get-global set-at ;

: unregister-thread ( thread -- )
    check-registered
    f over set-thread-registered?
    thread-id threads get-global delete-at ;

: set-self ( thread -- ) 40 setenv ; inline

PRIVATE>

: <thread> ( quot name error-handler -- thread )
    \ thread counter H{ } clone {
        set-thread-quot
        set-thread-name
        set-thread-error-handler
        set-thread-id
        set-thread-variables
    } \ thread construct ;

SYMBOL: run-queue
SYMBOL: sleep-queue

: resume ( thread -- )
    check-registered run-queue get-global push-front ;

: resume-with ( obj thread -- )
    check-registered 2array run-queue get-global push-front ;

<PRIVATE

: schedule-sleep ( thread ms -- )
    >r check-registered r> sleep-queue get-global heap-push ;

: wake-up? ( heap -- ? )
    dup heap-empty?
    [ drop f ] [ heap-peek nip millis <= ] if ;

: wake-up ( -- )
    sleep-queue get-global
    [ dup wake-up? ] [ dup heap-pop drop resume ] [ ] while
    drop ;

: next ( -- )
    walker-hook [
        continue
    ] [
        wake-up
        run-queue get-global pop-back
        dup array? [ first2 ] [ f swap ] if dup set-self
        dup thread-continuation
        f rot set-thread-continuation
        continue-with
    ] if* ;

PRIVATE>

: sleep-time ( -- ms )
    {
        { [ run-queue get-global dlist-empty? not ] [ 0 ] }
        { [ sleep-queue get-global heap-empty? ] [ f ] }
        { [ t ] [ sleep-queue get-global heap-peek nip millis [-] ] }
    } cond ;

: stop ( -- )
    self unregister-thread next ;

: suspend ( quot -- obj )
    [
        >r self [ set-thread-continuation ] keep r> call next
    ] curry callcc1 ; inline

: yield ( -- ) [ resume ] suspend drop ;

: sleep ( ms -- )
    >fixnum millis + [ schedule-sleep ] curry suspend drop ;

: (spawn) ( thread -- )
    [
        resume [
            dup set-self
            dup register-thread
            init-namespaces
            V{ } set-catchstack
            { } set-retainstack
            >r { } set-datastack r>
            thread-quot [ call stop ] call-clear
        ] 1 (throw)
    ] suspend 2drop ;

: spawn ( quot name -- thread )
    [
        global [
            "Error in thread " write
            dup thread-id pprint
            " (" write
            dup thread-name pprint ")" print
            "spawned to call " write
            thread-quot short.
            nl
            print-error flush
        ] bind
    ] <thread>
    [ (spawn) ] keep ;

: spawn-server ( quot name -- thread )
    >r [ [ ] [ ] while ] curry r> spawn ;

: in-thread ( quot -- )
    >r datastack namestack r>
    [ >r set-namestack set-datastack r> call ] 3curry
    "Thread" spawn drop ;

<PRIVATE

: init-threads ( -- )
    <dlist> run-queue set-global
    <min-heap> sleep-queue set-global
    H{ } clone threads set-global
    initial-thread global
    [ drop f "Initial" [ die ] <thread> ] cache
    f over set-thread-continuation
    f over set-thread-registered?
    dup register-thread
    set-self ;

[ self dup thread-error-handler call stop ]
thread-error-hook set-global

PRIVATE>

[ init-threads ] "threads" add-init-hook
