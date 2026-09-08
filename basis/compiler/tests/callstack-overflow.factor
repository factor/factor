USING: accessors classes.struct continuations kernel kernel.private literals
math memory sequences system threads.private tools.dispatch.private
tools.test ;
QUALIFIED: vm
IN: compiler.tests.callstack-overflow

! This test file is for all callstack overflow-related problems.

: pre ( -- )
    nano-count 0 = [ ] [ ] if ;

: post ( -- ) ;

: do-overflow ( -- )
    pre do-overflow post ;

: recurse ( -- ? )
    [ do-overflow f ] [ ] recover second ERROR-CALLSTACK-OVERFLOW = ;

: overflow-c ( -- ) overflow-c overflow-c ;

: overflow/w-primitive ( -- )
    reset-dispatch-stats overflow/w-primitive post ;

: get-context ( -- ctx ) context vm:context memory>struct ;

: remaining-stack ( -- n )
    get-context [ callstack-top>> ] [ callstack-seg>> start>> ] bi - ;

: overflow/w-compact-gc ( -- )
    remaining-stack dup 500 < [
        drop compact-gc
    ] [ drop overflow/w-compact-gc ] if post ;

! The VM cannot recover from callstack overflow on Windows, because no
! facility exists to run memory protection fault handlers on an
! alternate callstack. So we punt on the whole test-suite.
os windows? [

    ! This tries to verify that enough bytes are cut off from the
    ! callstack to run the error handler. It appears that the previous
    ! limit of 1024 bytes didn't give the gc enough stack space to
    ! work with, so we bumped that limit to 16384.
    { t } [
        10 [ recurse ] replicate [ ] all?
    ] unit-test

    ! ! See how well callstack overflow is handled
    ! [ clear drop ] must-fail
    !
    ! : callstack-overflow callstack-overflow f ;
    ! [ callstack-overflow ] must-fail
    [ overflow-c ] [
        2 head ${ KERNEL-ERROR ERROR-CALLSTACK-OVERFLOW } =
    ] must-fail-with

    ! The way this is problematic is because a primitive is
    ! involved. reset-dispatch-stats is called, decreasing RSP by cell
    ! bytes and then there is < 0x20 bytes stack left. Then SUB RSP,
    ! 0x18 is called to setup the call frame. Then the context is
    ! saved and ctx->callstack_top is set to RSP - 8 which is below
    ! the stack limit. Then dereferencing ctx->callstack_top segfaults
    ! so we need to handle the case specially in
    ! dispatch_non_resumable_signal().
    [ overflow/w-primitive ] [
        2 head ${ KERNEL-ERROR ERROR-CALLSTACK-OVERFLOW } =
    ] must-fail-with

    ! GC temporarily unlocks the callstack's lower guard reserve (#1478).
    ! The x64 native-entry probe can raise a structured overflow before
    ! reaching the 500-byte target. Accept that early check, but require
    ! the collector to remain usable after either successful GC or recovery.
    { } [
        [ overflow/w-compact-gc ] [
            2 head ${ KERNEL-ERROR ERROR-CALLSTACK-OVERFLOW } assert=
        ] recover
        compact-gc
    ] unit-test
] unless
