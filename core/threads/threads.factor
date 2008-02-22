! Copyright (C) 2004, 2008 Slava Pestov.
! Copyright (C) 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
IN: threads
USING: arrays hashtables heaps kernel kernel.private math
namespaces sequences vectors continuations continuations.private
dlists assocs system combinators debugger prettyprint io init
boxes ;

SYMBOL: initial-thread

TUPLE: thread
name quot error-handler exit-handler
id
continuation state
mailbox variables sleep-entry ;

: self ( -- thread ) 40 getenv ; inline

! Thread-local storage
: tnamespace ( -- assoc )
    self dup thread-variables
    [ ] [ H{ } clone dup rot set-thread-variables ] ?if ;

: tget ( key -- value )
    self thread-variables at ;

: tset ( value key -- )
    tnamespace set-at ;

: tchange ( key quot -- )
    tnamespace change-at ; inline

: threads 41 getenv ;

threads global [ H{ } assoc-like ] change-at

: thread ( id -- thread ) threads at ;

: thread-registered? ( thread -- ? )
    thread-id threads key? ;

: check-unregistered
    dup thread-registered?
    [ "Thread already stopped" throw ] when ;

: check-registered
    dup thread-registered?
    [ "Thread is not running" throw ] unless ;

<PRIVATE

: register-thread ( thread -- )
    check-unregistered dup thread-id threads set-at ;

: unregister-thread ( thread -- )
    check-registered thread-id threads delete-at ;

: set-self ( thread -- ) 40 setenv ; inline

PRIVATE>

: <thread> ( quot name error-handler -- thread )
    \ thread counter <box> [ ] {
        set-thread-quot
        set-thread-name
        set-thread-error-handler
        set-thread-id
        set-thread-continuation
        set-thread-exit-handler
    } \ thread construct ;

: run-queue 42 getenv ;

: sleep-queue 43 getenv ;

: resume ( thread -- )
    check-registered run-queue push-front ;

: resume-now ( thread -- )
    check-registered run-queue push-back ;

: resume-with ( obj thread -- )
    check-registered 2array run-queue push-front ;

<PRIVATE

: schedule-sleep ( thread ms -- )
    >r check-registered dup r> sleep-queue heap-push*
    swap set-thread-sleep-entry ;

: expire-sleep? ( heap -- ? )
    dup heap-empty?
    [ drop f ] [ heap-peek nip millis <= ] if ;

: expire-sleep ( thread -- )
    f over set-thread-sleep-entry resume ;

: expire-sleep-loop ( -- )
    sleep-queue
    [ dup expire-sleep? ]
    [ dup heap-pop drop expire-sleep ]
    [ ] while
    drop ;

: next ( -- )
    expire-sleep-loop
    run-queue pop-back
    dup array? [ first2 ] [ f swap ] if dup set-self
    f over set-thread-state
    thread-continuation box>
    continue-with ;

PRIVATE>

: sleep-time ( -- ms/f )
    {
        { [ run-queue dlist-empty? not ] [ 0 ] }
        { [ sleep-queue heap-empty? ] [ f ] }
        { [ t ] [ sleep-queue heap-peek nip millis [-] ] }
    } cond ;

: stop ( -- )
    self dup thread-exit-handler call
    unregister-thread next ;

: suspend ( quot state -- obj )
    [
        self thread-continuation >box
        self set-thread-state
        self swap call next
    ] callcc1 2nip ; inline

: yield ( -- ) [ resume ] "yield" suspend drop ;

GENERIC: nap-until ( time -- ? )

M: integer nap-until [ schedule-sleep ] curry "sleep" suspend ;

M: f nap-until drop [ drop ] "interrupt" suspend ;

GENERIC: nap ( time -- ? )

M: real nap millis + >integer nap-until ;

M: f nap nap-until ;

: sleep-until ( time -- )
    nap-until [ "Sleep interrupted" throw ] when ;

: sleep ( time -- )
    nap [ "Sleep interrupted" throw ] when ;

: interrupt ( thread -- )
    dup self eq? [
        drop
    ] [
        dup thread-sleep-entry [ sleep-queue heap-delete ] when*
        f over set-thread-sleep-entry
        t swap resume-with
    ] if ;

: (spawn) ( thread -- )
    [
        resume-now [
            dup set-self
            dup register-thread
            init-namespaces
            V{ } set-catchstack
            { } set-retainstack
            >r { } set-datastack r>
            thread-quot [ call stop ] call-clear
        ] 1 (throw)
    ] "spawn" suspend 2drop ;

: default-thread-error-handler ( error thread -- )
    global [
        "Error in thread " write
        dup thread-id pprint
        " (" write
        dup thread-name pprint ")" print
        "spawned to call " write
        thread-quot short.
        nl
        print-error flush
    ] bind ;

: spawn ( quot name -- thread )
    [ default-thread-error-handler ] <thread> [ (spawn) ] keep ;

: spawn-server ( quot name -- thread )
    >r [ [ ] [ ] while ] curry r> spawn ;

: in-thread ( quot -- )
    >r datastack namestack r>
    [ >r set-namestack set-datastack r> call ] 3curry
    "Thread" spawn drop ;

<PRIVATE

: init-threads ( -- )
    H{ } clone 41 setenv
    <dlist> 42 setenv
    <min-heap> 43 setenv
    initial-thread global
    [ drop f "Initial" [ die ] <thread> ] cache
    <box> over set-thread-continuation
    dup register-thread
    set-self ;

[ self dup thread-error-handler call stop ]
thread-error-hook set-global

PRIVATE>

[ init-threads ] "threads" add-init-hook
