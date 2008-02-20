: walk ( quot -- ) \ break add* call ;

SYMBOL: walker-hook

! Thread local
SYMBOL: interpreter-thread

: get-interpreter-thread ( -- thread )
    interpreter-thread tget dup [
        walker-hook get
        [ "No walker hook" throw ] or
        interpreter-thread
    ] unless* ;

: break ( -- )
    callstack [
        over set-continuation-callstack

        interpreter-thread send-synchronous {
            { [ dup continuation? ] [ (continue) ] }
            { [ dup quotation? ] [ call ] }
            { [ dup not ] [ "Single stepping abandoned" throw ] }
        } cond
    ] curry callcc0 ;

SYMBOL: +suspended+
SYMBOL: +running+
SYMBOL: +stopped+

! Messages sent to interpreter thread
SYMBOL: status

SYMBOL: step
SYMBOL: step-out
SYMBOL: step-into
SYMBOL: step-all
SYMBOL: step-back
SYMBOL: detach
SYMBOL: abandon
SYMBOL: call-in

SYMBOL: get-thread
SYMBOL: get-continuation

<PRIVATE

! Thread locals
SYMBOL: interpreter-running?
SYMBOL: interpreter-stepping?
SYMBOL: interpreter-continuation
SYMBOL: interpreter-history

: change-frame ( continuation quot -- continuation' )
    #! Applies quot to innermost call frame of the
    #! continuation.
    over continuation-call clone
    [
        dup innermost-frame-scan 1+
        swap innermost-frame-quot
        rot call
    ] keep
    [ set-innermost-frame-quot ] keep
    over set-continuation-call ; inline

: step-msg ( continuation -- continuation' )
    [
        2dup nth \ break = [
            nip
        ] [
            swap 1+ cut [ break ] swap 3append
        ] if
    ] change-frame ;

: step-out-msg ( continuation -- continuation' )
    [ nip \ break add ] change-frame ;

GENERIC: (step-into) ( obj -- )

M: wrapper (step-into) wrapped break ;
M: object (step-into) break ;
M: callable (step-into) \ break add* break ;

: (step-into-if) ? walk ;

: (step-into-dispatch) nth walk ;

: (step-into-execute) ( word -- )
    dup "step-into" word-prop [
        call
    ] [
        dup primitive? [
            execute break
        ] [
            word-def walk
        ] if
    ] ?if ;

: (step-into-continuation)
    continuation callstack over set-continuation-call break ;

M: word (step-into) (step-into-execute) ;

{
    { call [ walk ] }
    { (throw) [ drop walk ] }
    { execute [ (step-into-execute) ] }
    { if [ (step-into-if) ] }
    { dispatch [ (step-into-dispatch) ] }
    { continuation [ (step-into-continuation) ] }
} [ "step-into" set-word-prop ] assoc-each

{
    >n ndrop >c c>
    continue continue-with
    (continue-with) stop yield suspend sleep (spawn)
    suspend
} [
    dup [ execute break ] curry
    "step-into" set-word-prop
] each

\ break [ break ] "step-into" set-word-prop

: step-into-msg ( continuation -- continuation' )
    [
        swap cut [
            swap % unclip literalize , \ (step-into) , %
        ] [ ] make
    ] (step) ;

: status-change ( symbol -- )
    +running+ interpreter-status tget set-model ;

: detach-msg ( -- f )
    +detached+ status-change
    f interpreter-stepping? tset
    f interpreter-running? tset
    f ;

: continuation-msg ( -- continuation )
    interpreter-thread tget thread-continuation box-value ;

: keep-running f interpreter-stepping? tset ;

: save-continuation ( continuation -- )
    dup interpreter-continuation tget set-model
    interpreter-history tget push ;

: handle-command ( continuation -- continuation' )
    t interpreter-stepping? tset
    [ interpreter-stepping? tget ] [
        [
            {
                ! These are sent by the walker tool. We reply and
                ! keep cycling.
                { status [ +suspended+ ] }
                { detach [ detach-msg ] }
                { get-thread [ interpreter-thread tget ] }
                { get-continuation [ dup ] }
                ! These change the state of the thread being
                ! interpreted, so we modify the continuation and
                ! output f.
                { step [ (step) keep-running ] }
                { step-out [ (step-out) keep-running ] }
                { step-into [ (step-into) keep-running ] }
                { step-all [ keep-running ] }
                { abandon [ drop f keep-running ] }
                ! Pass quotation to debugged thread
                { call-in [ nip keep-running ] }
                ! Pass previous continuation to debugged thread
                { step-back [ drop interpreter-history tget pop f ] }
            } case
        ] handle-synchronous
    ] [ ] while
    dup continuation? [ dup save-continuation ] when ;

: interpreter-stopped ( -- )
    [
        {
            { detach [ detach-msg ] }
            { status [ +stopped+ ] }
            { get-thread [ interpreter-thread tget ] }
            { get-continuation [ f ] }
            [ drop f ]
        } case
    ] handle-synchronous
    interpreter-stopped ;

: interpreter-loop ( -- )
    [ interpreter-running? tget ] [
        [
            status-change
            {
                { detach [ detach-msg ] }
                { get-thread [ interpreter-thread tget ] }
                { get-continuation [ f ] }
                ! ignore these commands while the thread is
                ! running
                { step [ f ] }
                { step-out [ f ] }
                { step-into [ f ] }
                { step-all [ f ] }
                { step-back [ f ] }
                ! thread has exited so we exit the monitor too
                { f [ interpreter-stopped ] }
                ! thread hit a breakpoint and sent us the
                ! continuation, so we modify it and send it back.
                [ handle-command ]
            } case
        ] handle-synchronous
    ] [ ] while;

PRIVATE>

: start-interpreter-thread ( thread -- thread' )
    [
        [
            interpreter-thread tset
            t interpreter-running tset
            f interpreter-stepping tset
            f <model> interpreter-continuation tset
            V{ } clone interpreter-history tset
            interpreter-loop
        ] curry
    ] keep
    "Interpreter for " over thread-name append spawn
    dup rot set-thread-;
