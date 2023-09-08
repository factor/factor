! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators continuations
continuations.private generic generic.single kernel
kernel.private make math namespaces namespaces.private
quotations sequences sequences.private threads threads.private
tools.crossref words variables see io ;
IN: tools.continuations

<PRIVATE

: after-break ( object -- )
    {
        { [ dup continuation? ] [ (continue) ] }
        { [ dup not ] [ "Single stepping abandoned" rethrow ] }
    } cond ;

PRIVATE>

SYMBOL: break-hook

: break ( -- )
    current-continuation get-callstack >>call
    break-hook get call( continuation -- continuation' )
    after-break ;

\ break t "break?" set-word-prop

GLOBAL: breaklist
"breaklist" [ { } ] initialize

: breaklist. ( -- )
    "breaklist" get-global [ synopsis write nl ] each ;

GENERIC: add-breakpoint ( quot -- quot' )

<PRIVATE

M: callable add-breakpoint
    dup [ break ] head?  [ \ break prefix ] unless ;

M: array add-breakpoint
    [ add-breakpoint ] map ;

M: object add-breakpoint ;

: (step-into-quotation) ( quot -- ) add-breakpoint call ;

: (step-into-dip) ( quot -- ) add-breakpoint dip ;

: (step-into-2dip) ( quot -- ) add-breakpoint 2dip ;

: (step-into-3dip) ( quot -- ) add-breakpoint 3dip ;

: (step-into-if) ( true false ? -- ) ? (step-into-quotation) ;

: (step-into-dispatch) ( array n -- ) nth (step-into-quotation) ;

: (step-into-execute) ( word -- )
    {
        { [ dup "step-into" word-prop ] [ "step-into" word-prop call ] }
        { [ dup single-generic? ] [ effective-method (step-into-execute) ] }
        { [ dup uses \ suspend swap member? ] [ execute break ] }
        { [ dup primitive? ] [ execute break ] }
        [ def>> (step-into-quotation) ]
    } cond ;

\ (step-into-execute) t "step-into?" set-word-prop

: (step-into-continuation) ( -- )
    current-continuation get-callstack >>call break ;

: (step-into-call-next-method) ( method -- )
    next-method-quot (step-into-quotation) ;

<< {
    (step-into-quotation)
    (step-into-dip)
    (step-into-2dip)
    (step-into-3dip)
    (step-into-if)
    (step-into-dispatch)
    (step-into-execute)
    (step-into-continuation)
    (step-into-call-next-method)
} [ t "no-compile" set-word-prop ] each >>

: >innermost-frame< ( callstack -- n quot )
    [ innermost-frame-scan 1 + ] [ innermost-frame-executing ] bi ;

: (change-frame) ( callstack quot -- callstack' )
    [ dup innermost-frame-executing quotation? ] dip '[
        clone
        [ >innermost-frame< @ ]
        [ set-innermost-frame-quotation ]
        [ ] tri
    ] when ; inline

: change-frame ( continuation quot -- continuation' )
    ! Applies quot to innermost call frame of the
    ! continuation.
    [ clone ] dip '[ _ (change-frame) ] change-call ; inline

PRIVATE>

: continuation-step ( continuation -- continuation' )
    [
        2dup length = [ nip [ break ] append ] [
            2dup nth \ break = [ nip ] [
                swap 1 + cut [ break ] glue
            ] if
        ] if
    ] change-frame ;

: continuation-step-out ( continuation -- continuation' )
    [ nip \ break suffix ] change-frame ;

{
    { call [ (step-into-quotation) ] }
    { dip [ (step-into-dip) ] }
    { 2dip [ (step-into-2dip) ] }
    { 3dip [ (step-into-3dip) ] }
    { execute [ (step-into-execute) ] }
    { if [ (step-into-if) ] }
    { dispatch [ (step-into-dispatch) ] }
    { current-continuation [ (step-into-continuation) ] }
    { (call-next-method) [ (step-into-call-next-method) ] }
} [ "step-into" set-word-prop ] assoc-each

! Never step into these words
: don't-step-into ( word -- )
    dup '[ _ execute break ] "step-into" set-word-prop ;

{
    >n ndrop recover
    continue continue-with
    stop suspend (spawn)
    set-context start-context
} [ don't-step-into ] each

\ break [ break ] "step-into" set-word-prop

: continuation-step-into ( continuation -- continuation' )
    [
        swap cut [
            swap %
            [ \ break , ] [
                unclip {
                    { [ dup \ break eq? ] [ , ] }
                    { [ dup quotation? ] [ add-breakpoint , \ break , ] }
                    { [ dup array? ] [ add-breakpoint , \ break , ] }
                    { [ dup word? ] [ literalize , \ (step-into-execute) , ] }
                    [ , \ break , ]
                } cond %
            ] if-empty
        ] [ ] make
    ] change-frame ;

: continuation-current ( continuation -- obj )
    call>> >innermost-frame< ?nth ;
