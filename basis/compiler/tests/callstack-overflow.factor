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

    ! This test crashes with a Memory protection fault on macOS 64-bit
    ! for some reason. See #1478
    cpu x86.64? os macosx? and [
        ! Load up the stack until there is < 500 bytes of it left. Then
        ! run a big gc cycle. 500 bytes isn't enough, so a callstack
        ! overflow would occur during the gc which we can't handle. The
        ! solution is to for the duration of the gc unlock the segment's
        ! lower guard page which gives it pagesize (4096) more bytes to
        ! play with.
        { } [ overflow/w-compact-gc ] unit-test
    ] unless
] unless
