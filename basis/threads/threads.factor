! Copyright (C) 2004, 2010 Slava Pestov.
! Copyright (C) 2005 Mackenzie Straight.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays hashtables heaps kernel kernel.private math
namespaces sequences vectors continuations continuations.private
dlists assocs system combinators init boxes accessors math.order
deques strings quotations fry ;
IN: threads

<PRIVATE

! Wrap sub-primitives; we don't want them inlined into callers
! since their behavior depends on what frames are on the callstack
: context ( -- context )
    2 context-object ; inline

: set-context ( obj context -- obj' )
    (set-context) ; inline

: start-context ( obj quot: ( obj -- * ) -- obj' )
    (start-context) ; inline

: set-context-and-delete ( obj context -- * )
    (set-context-and-delete) ; inline

: start-context-and-delete ( obj quot: ( obj -- * ) -- * )
    (start-context-and-delete) ; inline

! Context introspection
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

<PRIVATE

: register-thread ( thread -- )
    dup id>> threads set-at ;

: unregister-thread ( thread -- )
    id>> threads delete-at ;

: set-self ( thread -- ) 63 set-special-object ; inline

PRIVATE>

: run-queue ( -- dlist )
    65 special-object { dlist } declare ; inline

: sleep-queue ( -- heap )
    66 special-object { min-heap } declare ; inline

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
    f >>state run-queue push-front ;

: resume-now ( thread -- )
    f >>state run-queue push-back ;

: resume-with ( obj thread -- )
    f >>state 2array run-queue push-front ;

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
    dupd sleep-queue heap-push* >>sleep-entry drop ;

: expire-sleep? ( -- ? )
    sleep-queue dup heap-empty?
    [ drop f ] [ heap-peek nip nano-count <= ] if ;

: expire-sleep ( thread -- )
    f >>sleep-entry resume ;

: expire-sleep-loop ( -- )
    [ expire-sleep? ]
    [ sleep-queue heap-pop drop expire-sleep ]
    while ;

CONSTANT: [start]
    [
        set-namestack
        init-catchstack
        self quot>> call
        stop
    ]

: no-runnable-threads ( -- ) die ;

GENERIC: (next) ( obj thread -- obj' )

M: thread (next)
    dup runnable>>
    [ context>> box> set-context ]
    [ t >>runnable drop [start] start-context ] if ;

: (stop) ( obj thread -- * )
    dup runnable>>
    [ context>> box> set-context-and-delete ]
    [ t >>runnable drop [start] start-context-and-delete ] if ;

: next ( -- obj thread )
    expire-sleep-loop
    run-queue pop-back
    dup array? [ first2 ] [ [ f ] dip ] if
    f >>state
    dup set-self ;

PRIVATE>

: stop ( -- * )
    self [ exit-handler>> call( -- ) ] [ unregister-thread ] bi
    next (stop) ;

: suspend ( state -- obj )
    [ self ] dip >>state
    [ context ] dip context>> >box
    next (next) ;

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

: init-threads ( -- )
    init-thread-state
    init-initial-thread ;

PRIVATE>

[ init-threads ] "threads" add-startup-hook
