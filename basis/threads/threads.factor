! Copyright (C) 2004, 2010 Slava Pestov.
! Copyright (C) 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables heaps kernel kernel.private math
namespaces sequences vectors continuations continuations.private
dlists assocs system combinators init boxes accessors math.order
deques strings quotations fry ;
IN: threads

<PRIVATE

! (set-context) and (start-context) are sub-primitives, but
! we don't want them inlined into callers since their behavior
! depends on what frames are on the callstack
: set-context ( obj context -- obj' ) (set-context) ;

: start-context ( obj quot: ( obj -- * ) -- obj' ) (start-context) ;

: namestack-for ( context -- namestack )
    [ 0 ] dip context-object-for ;

: catchstack-for ( context -- catchstack )
    [ 1 ] dip context-object-for ;

: continuation-for ( context -- continuation )
    {
        [ datastack-for ]
        [ callstack-for ]
        [ retainstack-for ]
        [ namestack-for ]
        [ catchstack-for ]
    } cleave <continuation> ;

PRIVATE>

SYMBOL: initial-thread

TUPLE: thread
{ name string }
{ quot callable initial: [ ] }
{ exit-handler callable initial: [ ] }
{ id integer }
{ context box }
state
runnable
mailbox
{ variables hashtable }
sleep-entry ;

: self ( -- thread )
    63 special-object { thread } declare ; inline

: thread-continuation ( thread -- continuation )
    context>> check-box value>> continuation-for ;

! Thread-local storage
: tnamespace ( -- assoc )
    self variables>> ; inline

: tget ( key -- value )
    tnamespace at ;

: tset ( value key -- )
    tnamespace set-at ;

: tchange ( key quot -- )
    [ tnamespace ] dip change-at ; inline

: threads ( -- assoc )
    64 special-object { hashtable } declare ; inline

: thread-registered? ( thread -- ? )
    id>> threads key? ;

ERROR: already-stopped thread ;

: check-unregistered ( thread -- thread )
    dup thread-registered? [ already-stopped ] when ;

ERROR: not-running thread ;

: check-registered ( thread -- thread )
    dup thread-registered? [ not-running ] unless ;

<PRIVATE

: register-thread ( thread -- )
    check-unregistered dup id>> threads set-at ;

: unregister-thread ( thread -- )
    check-registered id>> threads delete-at ;

: set-self ( thread -- ) 63 set-special-object ; inline

PRIVATE>

: run-queue ( -- dlist )
    65 special-object { dlist } declare ; inline

: sleep-queue ( -- heap )
    66 special-object { dlist } declare ; inline

: new-thread ( quot name class -- thread )
    new
        swap >>name
        swap >>quot
        \ thread counter >>id
        H{ } clone >>variables
        <box> >>context ; inline

: <thread> ( quot name -- thread )
    \ thread new-thread ;

: resume ( thread -- )
    f >>state
    check-registered run-queue push-front ;

: resume-now ( thread -- )
    f >>state
    check-registered run-queue push-back ;

: resume-with ( obj thread -- )
    f >>state
    check-registered 2array run-queue push-front ;

: sleep-time ( -- nanos/f )
    {
        { [ run-queue deque-empty? not ] [ 0 ] }
        { [ sleep-queue heap-empty? ] [ f ] }
        [ sleep-queue heap-peek nip nano-count [-] ]
    } cond ;

: interrupt ( thread -- )
    dup state>> [
        dup sleep-entry>> [ sleep-queue heap-delete ] when*
        f >>sleep-entry
        dup resume
    ] when drop ;

DEFER: stop

<PRIVATE

: schedule-sleep ( thread dt -- )
    [ check-registered dup ] dip sleep-queue heap-push*
    >>sleep-entry drop ;

: expire-sleep? ( heap -- ? )
    dup heap-empty?
    [ drop f ] [ heap-peek nip nano-count <= ] if ;

: expire-sleep ( thread -- )
    f >>sleep-entry resume ;

: expire-sleep-loop ( -- )
    sleep-queue
    [ dup expire-sleep? ]
    [ dup heap-pop drop expire-sleep ]
    while
    drop ;

: start ( namestack -- obj )
    [
        set-namestack
        init-catchstack
        self quot>> call
        stop
    ] start-context ;

DEFER: next

: no-runnable-threads ( -- obj )
    ! We should never be in a state where the only threads
    ! are sleeping; the I/O wait thread is always runnable.
    ! However, if it dies, we handle this case
    ! semi-gracefully.
    !
    ! And if sleep-time outputs f, there are no sleeping
    ! threads either... so WTF.
    sleep-time {
        { [ dup not ] [ drop die ] }
        { [ dup 0 = ] [ drop ] }
        [ (sleep) ]
    } cond next ;

: (next) ( obj thread -- obj' )
    f >>state
    dup set-self
    dup runnable>>
    [ context>> box> set-context ] [ t >>runnable drop start ] if ;

: next ( -- obj )
    expire-sleep-loop
    run-queue dup deque-empty?
    [ drop no-runnable-threads ]
    [ pop-back dup array? [ first2 ] [ [ f ] dip ] if (next) ] if ;

: recycler-thread ( -- thread ) 68 special-object ;

: recycler-queue ( -- vector ) 69 special-object ;

: delete-context-later ( context -- )
    recycler-queue push recycler-thread interrupt ;

PRIVATE>

: stop ( -- * )
    self [ exit-handler>> call( -- ) ] [ unregister-thread ] bi
    context delete-context-later next
    die 1 exit ;

: suspend ( state -- obj )
    [ self ] dip >>state
    [ context ] dip context>> >box
    next ;

: yield ( -- ) self resume f suspend drop ;

GENERIC: sleep-until ( n/f -- )

M: integer sleep-until
    [ self ] dip schedule-sleep "sleep" suspend drop ;

M: f sleep-until
    drop "standby" suspend drop ;

GENERIC: sleep ( dt -- )

M: real sleep
    >integer nano-count + sleep-until ;

: (spawn) ( thread -- )
    [ register-thread ] [ [ namestack ] dip resume-with ] bi ;

: spawn ( quot name -- thread )
    <thread> [ (spawn) ] keep ;

: spawn-server ( quot name -- thread )
    [ '[ _ loop ] ] dip spawn ;

: in-thread ( quot -- )
    [ datastack ] dip
    '[ _ set-datastack @ ]
    "Thread" spawn drop ;

GENERIC: error-in-thread ( error thread -- )

<PRIVATE

: init-thread-state ( -- )
    H{ } clone 64 set-special-object
    <dlist> 65 set-special-object
    <min-heap> 66 set-special-object ;

: init-initial-thread ( -- )
    [ ] "Initial" <thread>
    t >>runnable
    [ initial-thread set-global ]
    [ register-thread ]
    [ set-self ]
    tri ;

! The recycler thread deletes contexts belonging to stopped
! threads

: recycler-loop ( -- )
    recycler-queue [ [ delete-context ] each ] [ delete-all ] bi
    f sleep-until
    recycler-loop ;

: init-recycler ( -- )
    [ recycler-loop ] "Context recycler" spawn 68 set-special-object
    V{ } clone 69 set-special-object ;

: init-threads ( -- )
    init-thread-state
    init-initial-thread
    init-recycler ;

PRIVATE>

[ init-threads ] "threads" add-startup-hook
