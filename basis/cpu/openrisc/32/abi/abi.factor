! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.complex arrays compiler.cfg.builder.alien.boxing
compiler.cfg.builder.alien.params
cpu.architecture cpu.openrisc.32.assembler.registers kernel layouts
literals math math.order namespaces sequences system ;
IN: cpu.openrisc.32.abi

! The Linux ABI has one six-word argument area. Hardware floating-point
! values occupy the same GPR words as integers; unnamed varargs always use
! the stack. Factor's internal FP pairs are copied to those words at calls.
M: openrisc.32 return-regs
    { { int-regs ${ R11 R12 } } { float-regs ${ F3 } } } ;
M: openrisc.32 param-regs
    drop { { int-regs ${ R3 R4 R5 R6 R7 R8 } }
           { float-regs ${ C-F0 C-F1 C-F2 C-F3 C-F4 C-F5 } } } ;
M: openrisc.32 dummy-stack-params? f ;
M: openrisc.32 dummy-int-params? t ;
M: openrisc.32 dummy-fp-params? f ;
M: openrisc.32 long-long-on-stack? f ;
M: openrisc.32 long-long-odd-register? f ;
M: openrisc.32 float-right-align-on-stack? f ;
M: openrisc.32 struct-return-on-stack? f ;
: openrisc-complex-float? ( type -- ? )
    lookup-c-type complex-float lookup-c-type = ;

! GCC passes ordinary aggregates indirectly. Complex float is the exception:
! its two components use consecutive GPRs for arguments and results.
M: openrisc.32 value-struct? openrisc-complex-float? ;
M: openrisc.32 return-struct-in-registers? openrisc-complex-float? ;

M: openrisc.32 flatten-struct-type
    dup openrisc-complex-float? [
        drop { { int-rep f f 4 2 } { int-rep f f } } record-reg-reps
    ] [
        heap-size cell align cell /i { int-rep f f } <array> record-reg-reps
    ] if ;
M: openrisc.32 flatten-struct-type-return
    dup openrisc-complex-float? [
        drop { { int-rep f f } { int-rep f f } } record-reg-reps
    ] [ flatten-struct-type ] if ;
M: openrisc.32 struct-components integer-struct-components ;

! A two-word scalar cannot straddle r8 and the stack. Mark its first
! chunk so the shared allocator keeps both words together.
:: group-integer-pair ( reps -- reps )
    reps first cell suffix 2 suffix 0 reps set-nth reps ;

M: openrisc.32 unbox-scalar-parameter
    dup long-long-type? [ unbox ] dip [ group-integer-pair ] when ;

M: openrisc.32 flatten-scalar-parameter
    dup long-long-type? [ flatten-c-type ] dip [ group-integer-pair ] when ;

! GCC's strict argument naming puts every anonymous variadic value on the
! stack, even when r3-r8 remain unused.
M:: openrisc.32 prepare-abi-parameter-group ( rep-tuple -- )
    varargs-parameter? get [
        int-regs get length int-reg-reps get 0 or + int-reg-reps set
        float-regs get length float-reg-reps get 0 or + float-reg-reps set
    ] [
        rep-tuple first :> rep
        rep reg-class-of float-regs eq? [
            rep abi-param-slot-count :> count
            int-regs get :> regs
            count regs length > [
                regs delete-all float-regs get delete-all
            ] [
                regs last n>> :> lo
                count 2 = [ regs length 2 - regs nth n>> ] [ lo 1 + 8 min ] if
                lo swap fp-register boa float-regs get set-last
            ] if
        ] when
    ] if ;
