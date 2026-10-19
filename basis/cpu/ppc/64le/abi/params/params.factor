! ELFv2 floating aggregates occupy their packed in-memory parameter slots.
USING: alien.c-types arrays compiler.cfg.builder.alien.boxing
compiler.cfg.builder.alien.params cpu.architecture cpu.ppc
cpu.ppc.64le.abi cpu.ppc.64.varargs kernel layouts locals math namespaces sequences system vectors ;
IN: cpu.ppc.64le.abi.params

SYMBOLS: hfa-remaining hfa-offset ;

:: ppc64le-hfa-param-reps ( type -- reps/f )
    type lookup-c-type :> c-type
    c-type ppc64le-hfa-members :> members
    members [
        members [ third f f 3array ] map :> reps
        ! Zero at index4 disables generic all-or-nothing register grouping.
        ! ELFv2 permits the remaining HFA members to spill to the stack.
        reps first dup first rep-size
        0 members length c-type heap-size 4array append reps set-first
        reps record-reg-reps
    ] [ f ] if ;

M:: ppc64 prepare-abi-parameter-group ( rep-tuple -- )
    rep-tuple length 7 = [
        stack-params get hfa-offset set
        5 rep-tuple nth hfa-remaining set
        6 rep-tuple nth 8 align :> bytes
        bytes stack-params +@
        bytes 8 /i [ int-regs get [ pop* ] unless-empty ] times
    ] when ;

:: ppc64-hfa-reg-input ( vreg rep reg offset -- input )
    vreg rep reg offset ppc64-shadow-reg-input
    dup length 3 = ppc64-stack-shadows? and [ offset suffix ] when ;

M:: ppc64 alloc-abi-parameter ( vreg rep on-stack? odd-register? size -- handled? )
    hfa-remaining get 0 or 0 > [
        on-stack? float-regs get empty? or [
            vreg rep hfa-offset get size 4array stack-values get push
        ] [
            vreg rep float-regs get pop hfa-offset get
            ppc64-hfa-reg-input reg-values get push
        ] if
        size hfa-offset +@
        -1 hfa-remaining +@
        t
    ] [ vreg rep on-stack? odd-register? size ppc64-alloc-float-parameter ] if ;
