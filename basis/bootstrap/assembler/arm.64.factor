! Copyright (C) 2020 Doug Coleman.
! Copyright (C) 2023 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private compiler.codegen.relocation
compiler.constants compiler.units cpu.arm.64.assembler
generic.single.private kernel kernel.private layouts
locals.backend math math.private namespaces slots.private
strings.private threads.private vocabs ;
IN: bootstrap.assembler.arm

8 \ cell set

big-endian off

: context-callstack-top-offset ( -- n ) 0 bootstrap-cells ; inline
: context-callstack-bottom-offset ( -- n ) 2 bootstrap-cells ; inline
: context-datastack-offset ( -- n ) 3 bootstrap-cells ; inline
: context-retainstack-offset ( -- n ) 4 bootstrap-cells ; inline
: context-callstack-save-offset ( -- n ) 5 bootstrap-cells ; inline
: context-callstack-seg-offset ( -- n ) 8 bootstrap-cells ; inline

! X0-X17  volatile     scratch registers
! X0-X8                parameter registers
! X0                   result register
! X16-X17              intra-procedure-call registers
! X18-X29 non-volatile scratch registers
! X18                  platform register (TEB pointer under Windows)
! X29/FP               frame pointer
! X30/LR  non-volatile link register

: words ( n -- n ) 4 * ; inline
: stack-frame-size ( -- n ) 8 bootstrap-cells ; inline

: return-reg ( -- reg ) X0 ; inline
: arg1 ( -- reg ) X0 ; inline
: arg2 ( -- reg ) X1 ; inline
: arg3 ( -- reg ) X2 ; inline
: arg4 ( -- reg ) X3 ; inline

: temp0 ( -- reg ) X9 ; inline
: temp1 ( -- reg ) X10 ; inline
: temp2 ( -- reg ) X11 ; inline
: temp3 ( -- reg ) X12 ; inline

: stack-reg ( -- reg ) SP ; inline
: link-reg ( -- reg ) X30 ; inline ! LR
: stack-frame-reg ( -- reg ) X29 ; inline ! FP
: vm-reg ( -- reg ) X28 ; inline
: ds-reg ( -- reg ) X27 ; inline
: rs-reg ( -- reg ) X26 ; inline
: ctx-reg ( -- reg ) X25 ; inline
: return-address ( -- reg ) X24 ; inline

: push-link-reg ( -- ) -16 stack-reg link-reg STRpre ;
: pop-link-reg ( -- ) 16 stack-reg link-reg LDRpost ;

: load0 ( -- ) 0 ds-reg temp0 LDRuoff ;
: load1 ( -- ) -8 ds-reg temp1 LDUR ;
: load2 ( -- ) -16 ds-reg temp2 LDUR ;
: load1/0 ( -- ) -8 ds-reg temp0 temp1 LDPsoff ;
: load2/1 ( -- ) -16 ds-reg temp1 temp2 LDPsoff ;
: load2/1* ( -- ) -8 ds-reg temp1 temp2 LDPsoff ;
: load3/2 ( -- ) -24 ds-reg temp2 temp3 LDPsoff ;
: load-arg1/2 ( -- ) -8 ds-reg arg2 arg1 LDPpre ;

: ndrop ( n -- ) bootstrap-cells ds-reg dup SUBi ;

: pop0 ( -- ) -8 ds-reg temp0 LDRpost ;
: popr ( -- ) -8 rs-reg temp0 LDRpost ;
: pop-arg1 ( -- ) -8 ds-reg arg1 LDRpost ;
: pop-arg2 ( -- ) -8 ds-reg arg2 LDRpost ;

: push0 ( -- ) 8 ds-reg temp0 STRpre ;
: push1 ( -- ) 8 ds-reg temp1 STRpre ;
: push2 ( -- ) 8 ds-reg temp2 STRpre ;
: push3 ( -- ) 8 ds-reg temp3 STRpre ;
: pushr ( -- ) 8 rs-reg temp0 STRpre ;
: push-arg2 ( -- ) 8 ds-reg arg2 STRpre ;

: push-down0 ( n -- ) neg bootstrap-cells ds-reg temp0 STRpre ;

: store0 ( -- ) 0 ds-reg temp0 STRuoff ;
: store1 ( -- ) 0 ds-reg temp1 STRuoff ;
: store0/1 ( -- ) -8 ds-reg temp1 temp0 STPsoff ;
: store0/2 ( -- ) -8 ds-reg temp2 temp0 STPsoff ;
: store2/0 ( -- ) -8 ds-reg temp0 temp2 STPsoff ;
: store1/0 ( -- ) -8 ds-reg temp0 temp1 STPsoff ;
: store1/2 ( -- ) -16 ds-reg temp2 temp1 STPsoff ;

! add tag bits to integers
:: tag* ( reg -- ) tag-bits get reg reg LSLi ;
! remove tag bits
:: untag ( reg -- ) tag-bits get reg reg ASRi ;

: tagged>offset0 ( -- ) 1 temp0 temp0 ASRi ;

! pops an item from the data stack and pushes it
! onto the retain stack (used for dip-like operations)
: >r ( -- ) pop0 pushr ;

! pops an item from the retain stack and pushes it
! onto the data stack (used for dip-like operations)
: r> ( -- ) popr push0 ;

: absolute-jump ( -- word class )
    2 words temp0 LDRl
    temp0 BR
    NOP NOP f rc-absolute-cell ; inline

: absolute-call ( -- word class )
    3 words temp0 LDRl
    temp0 BLR
    3 words Br
    NOP NOP f rc-absolute-cell ; inline

! This is used when a word is called at the end of a quotation.
! JIT-WORD-CALL is used for other word calls.
[
    5 words return-address ADR
    absolute-jump rel-word-pic-tail
] JIT-WORD-JUMP jit-define

! This is used when a word is called.
! JIT-WORD-JUMP is used if the word is the last piece of code in a quotation.
[
    absolute-call rel-word-pic
] JIT-WORD-CALL jit-define

: jit-call ( name -- )
    absolute-call rel-dlsym ;

:: jit-call-1arg ( arg1s name -- )
    arg1s arg1 MOVr
    name jit-call ;

:: jit-call-2arg ( arg1s arg2s name -- )
    ! arg1 arg1s MOV
    ! arg2 arg2s MOV
    ! name jit-call ;
    arg1s arg1 MOVr
    arg2s arg2 MOVr
    name jit-call ;

! loads the address of the vm struct.
! A no-op on ARM (vm-reg always contains this address).
: jit-load-vm ( -- ) ;

! Loads the address of the ctx struct into ctx-reg.
: jit-load-context ( -- )
    vm-context-offset vm-reg ctx-reg LDRuoff ;

! Saves the addresses of the callstack, datastack, and retainstack tops
! into the corresponding fields in the ctx struct.
: jit-save-context ( -- )
    jit-load-context
    ! The reason for -8 I think is because we are anticipating a CALL
    ! instruction. After the call instruction, the contexts frame_top
    ! will point to the origin jump address.
    stack-reg temp0 MOVsp
    context-callstack-top-offset ctx-reg temp0 STRuoff
    context-datastack-offset ctx-reg ds-reg STRuoff
    context-retainstack-offset ctx-reg rs-reg STRuoff ;

! Retrieves the addresses of the datastack and retainstack tops
! from the corresponding fields in the ctx struct.
! ctx-reg must already have been loaded.
: jit-restore-context ( -- )
    context-datastack-offset ctx-reg ds-reg LDRuoff
    context-retainstack-offset ctx-reg rs-reg LDRuoff ;

[
    ! ! ctx-reg is preserved across the call because it is non-volatile
    ! ! in the C ABI
    jit-save-context
    ! ! call the primitive
    ! arg1 vm-reg MOV
    ! RAX 0 MOV f f rc-absolute-cell rel-dlsym
    ! RAX CALL
    vm-reg arg1 MOVr
    f jit-call
    jit-restore-context
] JIT-PRIMITIVE jit-define

! Used to a call a quotation if the quotation is the last piece of code
: jit-jump-quot ( -- )
    quot-entry-point-offset arg1 temp0 LDUR
    temp0 BR ;

! Used to call a quotation if the quotation is not the last piece of code
: jit-call-quot ( -- )
    quot-entry-point-offset arg1 temp0 LDUR
    temp0 BLR ;

! calls a quotation
[
    pop-arg1
]
[ jit-call-quot ]
[ jit-jump-quot ]
\ (call) define-combinator-primitive

[
    jit-save-context
    vm-reg arg2 MOVr
    "lazy_jit_compile" jit-call
]
[ jit-call-quot ]
[ jit-jump-quot ]
\ lazy-jit-compile define-combinator-primitive

[
    ! temp2 0 MOV f rc-absolute-cell rel-literal
    ! temp1 temp2 CMP
    3 words temp2 LDRl
    temp2 temp1 CMPr
    3 words Br
    NOP NOP f rc-absolute-cell rel-literal
] PIC-CHECK-TUPLE jit-define


! Inline cache miss entry points
: jit-load-return-address ( -- )
    ! RBX RSP stack-frame-size bootstrap-cell - [+] MOV ;
    0 stack-reg return-address LDRuoff
    3 words return-address return-address ADDi ;

! These are always in tail position with an existing stack
! frame, and the stack. The frame setup takes this into account.
: jit-inline-cache-miss ( -- )
    jit-save-context
    ! arg1 RBX MOV
    return-address arg1 MOVr
    ! arg2 vm-reg MOV
    vm-reg arg2 MOVr
    ! RAX 0 MOV rc-absolute-cell rel-inline-cache-miss
    ! RAX CALL
    absolute-call nip rel-inline-cache-miss
    jit-load-context
    jit-restore-context ;

[ jit-load-return-address jit-inline-cache-miss ] [
    ! RAX CALL
    arg1 BLR
] [
    ! RAX JMP
    arg1 BR
] \ inline-cache-miss define-combinator-primitive

[ jit-inline-cache-miss ] [
    ! RAX CALL
    arg1 BLR
] [
    ! RAX JMP
    arg1 BR
] \ inline-cache-miss-tail define-combinator-primitive

! Contexts
: jit-switch-context ( reg -- )
    ! ! Push a bogus return address so the GC can track this frame back
    ! ! to the owner
    ! 0 CALL
    0 BL ! ?!

    ! ! Make the new context the current one
    ! ctx-reg swap MOV
    ! vm-reg vm-context-offset [+] ctx-reg MOV
    ctx-reg MOVr
    vm-context-offset vm-reg ctx-reg STRuoff

    ! ! Load new stack pointer
    ! RSP ctx-reg context-callstack-top-offset [+] MOV
    context-callstack-top-offset ctx-reg temp0 LDRuoff
    temp0 stack-reg MOVsp

    ! ! Load new ds, rs registers
    jit-restore-context

    ctx-reg jit-update-tib ;

: jit-pop-context-and-param ( -- )
    pop-arg1
    alien-offset arg1 arg1 ADDi
    0 arg1 arg1 LDRuoff
    pop-arg2 ;

: jit-push-param ( -- )
    push-arg2 ;

: jit-set-context ( -- )
    jit-pop-context-and-param
    jit-save-context
    arg1 jit-switch-context
    16 stack-reg stack-reg ADDi
    jit-push-param ;

: jit-pop-quot-and-param ( -- )
    pop-arg1 pop-arg2 ;

: jit-start-context ( -- )
    ! Create the new context in return-reg. Have to save context
    ! twice, first before calling new_context() which may GC,
    ! and again after popping the two parameters from the stack.
    jit-save-context
    vm-reg "new_context" jit-call-1arg

    jit-pop-quot-and-param
    jit-save-context
    return-reg jit-switch-context
    jit-push-param
    jit-jump-quot ;

: jit-delete-current-context ( -- )
    vm-reg "delete_context" jit-call-1arg ;

! Resets the active context and instead the passed in quotation
! becomes the new code that it executes.
: jit-start-context-and-delete ( -- )
    ! Updates the context to match the values in the data and retain
    ! stack registers. reset_context can GC.
    jit-save-context

    ! Resets the context. The top two ds items are preserved.
    vm-reg "reset_context" jit-call-1arg

    ! Switches to the same context I think.
    ctx-reg jit-switch-context

    ! Pops the quotation from the stack and puts it in arg1.
    ! arg1 ds-reg [] MOV
    ! ds-reg 8 SUB
    pop-arg1

    ! Jump to quotation arg1
    jit-jump-quot ;

[
    3 words temp0 LDRl
    0 temp0 W0 STRuoff
    3 words Br
    NOP NOP rc-absolute-cell rel-safepoint
] JIT-SAFEPOINT jit-define

! The main C to Factor entry point.
! Sets up and executes the boot quote,
! then performs a teardown and returns into C++.
[
    ! ! Optimizing compiler's side of callback accesses
    ! ! arguments that are on the stack via the frame pointer.
    ! ! On x86-32 fastcall, and x86-64, some arguments are passed
    ! ! in registers, and so the only registers that are safe for
    ! ! use here are frame-reg, nv-reg and vm-reg.
    ! frame-reg PUSH
    ! frame-reg stack-reg MOV

    ! Save all non-volatile registers
    -16 SP X19 X18 STPpre
    -16 SP X21 X20 STPpre
    -16 SP X23 X22 STPpre
    -16 SP X25 X24 STPpre
    -16 SP X27 X26 STPpre
    -16 SP X29 X28 STPpre
    -16 SP X30 STRpre
    stack-reg stack-frame-reg MOVsp

    jit-save-tib

    ! Load VM into vm-reg
    2 words vm-reg LDRl
    3 words Br
    NOP NOP 0 rc-absolute-cell rel-vm

    ! Save old context
    vm-context-offset vm-reg ctx-reg LDRuoff
    8 SP ctx-reg STRuoff

    ! Switch over to the spare context
    vm-spare-context-offset vm-reg ctx-reg LDRuoff
    vm-context-offset vm-reg ctx-reg STRuoff

    ! Save C callstack pointer
    stack-reg temp0 MOVsp
    context-callstack-save-offset ctx-reg temp0 STRuoff

    ! Load Factor stack pointers
    context-callstack-bottom-offset ctx-reg temp0 LDRuoff
    temp0 stack-reg MOVsp

    ctx-reg jit-update-tib
    jit-install-seh

    context-retainstack-offset ctx-reg rs-reg LDRuoff
    context-datastack-offset ctx-reg ds-reg LDRuoff

    ! Call into Factor code
    3 words temp0 LDRl
    temp0 BLR
    3 words Br
    NOP NOP f rc-absolute-cell rel-word

    ! Load C callstack pointer
    vm-context-offset vm-reg ctx-reg LDRuoff

    context-callstack-save-offset ctx-reg temp0 LDRuoff
    temp0 stack-reg MOVsp

    ! Load old context
    8 SP ctx-reg LDRuoff
    vm-context-offset vm-reg ctx-reg STRuoff

    jit-restore-tib

    ! Restore non-volatile registers
    16 SP X30 LDRpost
    16 SP X29 X28 LDPpost
    16 SP X27 X26 LDPpost
    16 SP X25 X24 LDPpost
    16 SP X23 X22 LDPpost
    16 SP X21 X20 LDPpost
    16 SP X19 X18 LDPpost

    ! Callbacks which return structs, or use stdcall/fastcall/thiscall,
    ! need a parameter here.

    f RET
] CALLBACK-STUB jit-define

! pushes a literal value to the stack
[
    ! load literal
    2 words temp0 LDRl
    3 words Br
    NOP NOP f rc-absolute-cell rel-literal
    ! store literal on datastack
    push0
] JIT-PUSH-LITERAL jit-define

! The *-signal-handler subprimitives are special-cased in vm/quotations.cpp
! not to trigger generation of a stack frame, so they can
! perform their own prolog/epilog preserving registers.
!
! It is important that the total is 192/64 and that it matches the
! constants in vm/cpu-x86.*.hpp
: jit-signal-handler-prolog ( -- )
    ! ! Return address already on stack -> 8/4 bytes.

    ! ! Push all registers. 15 regs/120 bytes on 64bit, 7 regs/28 bytes
    ! ! on 32bit -> 128/32 bytes.
    ! signal-handler-save-regs [ PUSH ] each

    ! ! Push flags -> 136/36 bytes
    ! PUSHF
    -16 SP X1 X0 STPpre
    -16 SP X3 X2 STPpre
    -16 SP X5 X4 STPpre
    -16 SP X7 X6 STPpre
    -16 SP X9 X8 STPpre
    -16 SP X11 X10 STPpre
    -16 SP X13 X12 STPpre
    -16 SP X15 X14 STPpre
    -16 SP X17 X16 STPpre
    -16 SP X19 X18 STPpre
    -16 SP X21 X20 STPpre
    -16 SP X23 X22 STPpre
    -16 SP X25 X24 STPpre
    -16 SP X27 X26 STPpre
    -16 SP X29 X28 STPpre
    NZCV X0 MRS
    -16 SP X0 X30 STPpre

    ! ! Register parameter area 32 bytes, unused on platforms other than
    ! ! windows 64 bit, but including it doesn't hurt. Plus
    ! ! alignment. LEA used so we don't dirty flags -> 192/64 bytes.
    ! stack-reg stack-reg 7 bootstrap-cells neg [+] LEA
    4 bootstrap-cells stack-reg stack-reg SUBi

    jit-load-vm ;

: jit-signal-handler-epilog ( -- )
    ! stack-reg stack-reg 7 bootstrap-cells [+] LEA
    ! POPF
    ! signal-handler-save-regs reverse [ POP ] each ;
    16 SP X0 X30 LDPpost
    NZCV X0 MSRr
    16 SP X29 X28 LDPpost
    16 SP X27 X26 LDPpost
    16 SP X25 X24 LDPpost
    16 SP X23 X22 LDPpost
    16 SP X21 X20 LDPpost
    16 SP X19 X18 LDPpost
    16 SP X17 X16 LDPpost
    16 SP X15 X14 LDPpost
    16 SP X13 X12 LDPpost
    16 SP X11 X10 LDPpost
    16 SP X9 X8 LDPpost
    16 SP X7 X6 LDPpost
    16 SP X5 X4 LDPpost
    16 SP X3 X2 LDPpost
    16 SP X1 X0 LDPpost ;

! if-statement control flow
[
    ! pop boolean
    pop0
    ! compare boolean with f
    \ f type-number temp0 CMPi
    ! skip over true branch if equal
    5 words EQ B.cond
    ! jump to true branch
    absolute-jump rel-word
    ! jump to false branch
    absolute-jump rel-word
] JIT-IF jit-define

! calls the second item on the stack
[
    >r
    absolute-call rel-word
    r>
] JIT-DIP jit-define

! calls the third item on the stack
[
    >r >r
    absolute-call rel-word
    r> r>
] JIT-2DIP jit-define

! calls the fourth item on the stack
[
    >r >r >r
    absolute-call rel-word
    r> r> r>
] JIT-3DIP jit-define

! executes a word pushed onto the stack with \
[
    ! ! load from stack
    ! temp0 ds-reg [] MOV
    ! ! pop stack
    ! ds-reg bootstrap-cell SUB
    pop0
    word-entry-point-offset temp0 temp0 LDUR
] [
    ! temp0 word-entry-point-offset [+] CALL
    temp0 BLR
] [
    ! temp0 word-entry-point-offset [+] JMP
    temp0 BR
] \ (execute) define-combinator-primitive

[
    ! temp0 ds-reg [] MOV
    ! ds-reg bootstrap-cell SUB
    pop0
    ! temp0 word-entry-point-offset [+] JMP
    word-entry-point-offset temp0 temp0 LDUR
    temp0 BR
] JIT-EXECUTE jit-define

! https://elixir.bootlin.com/linux/latest/source/arch/arm64/kernel/stacktrace.c#L22
! Performs setup for a quotation
[
    ! ! make room for LR plus magic number of callback, 16byte align
    stack-frame-size 2 bootstrap-cells - stack-reg stack-reg SUBi
    push-link-reg
] JIT-PROLOG jit-define

! Performs teardown for a quotation
[
    pop-link-reg
    stack-frame-size 2 bootstrap-cells - stack-reg stack-reg ADDi
] JIT-EPILOG jit-define

! returns to the outer stack frame
[ f RET ] JIT-RETURN jit-define

! ! ! Polymorphic inline caches

! The PIC stubs are not permitted to touch pic-tail-reg.

! Load a value from a stack position
[
    ! temp1 ds-reg 0x7f [+] MOV f rc-absolute-1 rel-untagged
    4 words temp2 ADR
    3 temp2 temp2 LDRBuoff
    temp2 ds-reg temp1 LDRr
    2 words Br
    NOP f rc-absolute-1 rel-untagged
] PIC-LOAD jit-define

! ! Factor 2024 Clinic Code:
! ! this arm relocation could actually work
! ! due to the small bitwidth required
! 0 0 temp2 MOVZ f rc-absolute-arm64-movz rel-untagged
! temp2 temp2 UXTB
! temp2 ds-reg temp1 LDRr

[
    ! temp1/32 tag-mask get AND
    tag-mask get temp1 temp1 ANDSi
] PIC-TAG jit-define

[
    ! temp0 temp1 MOV
    temp1 temp0 MOVr
    ! temp1/32 tag-mask get AND
    tag-mask get temp1 temp1 ANDi
    ! temp1/32 tuple type-number CMP
    tuple type-number temp1 CMPi
    ! [ JNE ]
    ! [ temp1 temp0 tuple-class-offset [+] MOV ]
    [ 4 + NE B.cond ] [
        tuple-class-offset temp0 temp1 LDUR
    ] jit-conditional
] PIC-TUPLE jit-define

[
    ! temp1/32 0x7f CMP f rc-absolute-1 rel-untagged
    4 words temp2 ADR
    3 temp2 temp2 LDRBuoff
    temp2 temp1 CMPr
    2 words Br
    NOP f rc-absolute-1 rel-untagged
] PIC-CHECK-TAG jit-define

! ! Factor 2024 Clinic Code:
! ! this arm relocation could actually work
! ! due to the small bitwidth required
! 0 0 temp2 MOVZ f rc-absolute-arm64-movz rel-untagged
! temp2 temp2 UXTB
! temp2 temp1 CMPr


[
    ! ! 0 JE f rc-relative rel-word
    ! 0 EQ B.cond f rc-relative-arm64-bcond rel-word
    5 words NE B.cond
    absolute-jump rel-word
] PIC-HIT jit-define

! ! ! Megamorphic caches

[
    ! ! class = ...
    ! temp0 temp1 MOV
    temp1 temp0 MOVr
    ! temp1/32 tag-mask get AND
    tag-mask get temp1 temp1 ANDi
    ! temp1/32 tag-bits get SHL
    temp1 tag*
    ! temp1/32 tuple type-number tag-fixnum CMP
    tuple type-number tag-fixnum temp1 CMPi
    ! [ JNE ]
    ! [ temp1 temp0 tuple-class-offset [+] MOV ]
    [ 4 + NE B.cond ] [
        tuple-class-offset temp0 temp1 LDUR
    ] jit-conditional
    ! ! cache = ...
    ! temp0 0 MOV f rc-absolute-cell rel-literal
    2 words temp0 LDRl
    3 words Br
    NOP NOP f rc-absolute-cell rel-literal
    ! ! key = hashcode(class)
    ! temp2 temp1 MOV
    temp1 temp2 MOVr
    ! ! key &= cache.length - 1
    ! temp2 mega-cache-size get 1 - bootstrap-cell * AND
    mega-cache-size get 1 - bootstrap-cells temp2 temp2 ANDi
    ! ! cache += array-start-offset
    ! temp0 array-start-offset ADD
    array-start-offset temp0 temp0 ADDi
    ! ! cache += key
    ! temp0 temp2 ADD
    temp2 temp0 temp0 ADDr
    ! ! if(get(cache) == class)
    ! temp0 [] temp1 CMP
    0 temp0 temp2 LDRuoff
    temp1 temp2 CMPr
    ! [ JNE ]
    [ 4 + NE B.cond ] [
        ! ! megamorphic_cache_hits++
        ! temp1 0 MOV rc-absolute-cell rel-megamorphic-cache-hits
        2 words temp1 LDRl
        3 words Br
        NOP NOP rc-absolute-cell rel-megamorphic-cache-hits
        ! temp1 [] 1 ADD
        1 temp3 MOVwi
        temp3 temp1 STADD
        ! ! goto get(cache + bootstrap-cell)
        ! temp0 temp0 bootstrap-cell [+] MOV
        bootstrap-cell temp0 temp0 LDRuoff
        ! temp0 word-entry-point-offset [+] JMP
        word-entry-point-offset temp0 temp0 LDUR
        temp0 BR
        ! ! fall-through on miss
    ] jit-conditional
] MEGA-LOOKUP jit-define

! helper for comparison operations which return a boolean value
: jit-compare ( cond -- )
    ! load t
    2 words temp3 LDRl
    3 words Br
    NOP NOP t rc-absolute-cell rel-literal
    ! load f
    \ f type-number temp2 MOVwi
    ! load values
    load1/0
    ! compare
    temp0 temp1 CMPr
    ! move t if true (f otherwise)
    [ temp2 temp3 temp0 ] dip CSEL
    ! store
    1 push-down0 ;

! Math

! Overflowing fixnum (integer) arithmetic
: jit-overflow ( insn func -- )
    load-arg1/2
    jit-save-context
    [ [ arg2 arg1 temp0 ] dip call ] dip
    store0
    [ 4 + VC B.cond ] [
        vm-reg arg3 MOVr
        jit-call
    ] jit-conditional ; inline

! non-overflowing fixnum (integer) arithmetic
: jit-math ( insn -- )
    ! load inputs
    load1/0
    ! compute result
    [ temp0 temp1 temp0 ] dip execute( arg2 arg1 dst -- )
    ! store result
    1 push-down0 ;

! fixnum (integer) division and modulo operations.
! Does not tag or push results.
: jit-fixnum-/mod ( -- )
    ! load parameters
    load1/0
    ! divide
    temp0 temp1 temp2 SDIV
    temp1 temp0 temp2 temp0 MSUB ;

! # All arm.64 subprimitives
{
    ! ## Contexts
    { (set-context) [ jit-set-context ] }
    { (set-context-and-delete) [
        jit-delete-current-context
        jit-set-context
    ] }
    { (start-context) [ jit-start-context ] }
    { (start-context-and-delete) [ jit-start-context-and-delete ] }

    ! ## Entry points
    ! called by callback-stub.
    ! this contains some C++ setup/teardown,
    ! as well as the actual call into the boot quote.
    { c-to-factor [
        arg1 arg2 MOVr
        vm-reg "begin_callback" jit-call-1arg

        jit-call-quot

        vm-reg "end_callback" jit-call-1arg
    ] }
    { unwind-native-frames [
        ! ! unwind-native-frames is marked as "special" in
        ! ! vm/quotations.cpp so it does not have a standard prolog
        ! ! Unwind stack frames
        ! RSP arg2 MOV
        arg2 stack-reg MOVsp
        ! ! Load VM pointer into vm-reg, since we're entering from
        ! ! C code
        ! vm-reg 0 MOV 0 rc-absolute-cell rel-vm
        2 words vm-reg LDRl
        3 words Br
        NOP NOP 0 rc-absolute-cell rel-vm
        ! ! Load ds and rs registers
        jit-load-context
        jit-restore-context
        ! ! Clear the fault flag
        ! vm-reg vm-fault-flag-offset [+] 0 MOV
        vm-fault-flag-offset vm-reg XZR STRuoff
        ! ! Call quotation
        jit-jump-quot
    ] }

    ! ## Math
    ! Overflowing fixnum (integer) addition
    { fixnum+ [
        [ ADDSr ] "overflow_fixnum_add" jit-overflow ] }
    ! Overflowing fixnum (integer) subtraction
    { fixnum- [
        [ SUBSr ] "overflow_fixnum_subtract" jit-overflow ] }
    ! Overflowing fixnum (integer) multiplication
    { fixnum* [
        load-arg1/2
        jit-save-context
        arg1 untag
        arg2 arg1 temp0 MUL
        store0
        arg2 arg1 temp1 SMULH
        63 temp0 temp0 ASRi
        temp0 temp1 CMPr
        [ 4 + EQ B.cond ] [
            arg2 untag
            vm-reg arg3 MOVr
            "overflow_fixnum_multiply" jit-call
        ] jit-conditional
    ] }

    ! ## Misc
    { fpu-state [
        ! RSP 2 SUB
        ! RSP [] FNSTCW
        ! FNINIT
        ! AX RSP [] MOV
        ! RSP 2 ADD
        FPSR XZR MSRr
        FPCR arg1 MRS
    ] }

! ! Factor 2024 Clinic Code:
! FPCR arg1 MRS
! FPSR XZR MSRr

    { set-fpu-state [
        ! RSP 2 SUB
        ! RSP [] arg1 16-bit-version-of MOV
        ! RSP [] FLDCW
        ! RSP 2 ADD
        FPCR arg1 MSRr
    ] }
    { set-callstack [
        ! ! Load callstack object
        ! arg4 ds-reg [] MOV
        ! ds-reg bootstrap-cell SUB
        pop0
        ! ! Get ctx->callstack_bottom
        jit-load-context
        ! arg1 ctx-reg context-callstack-bottom-offset [+] MOV
        context-callstack-bottom-offset ctx-reg arg1 LDRuoff
        ! ! Get top of callstack object -- 'src' for memcpy
        ! arg2 arg4 callstack-top-offset [+] LEA
        callstack-top-offset temp0 arg2 ADDi
        ! ! Get callstack length, in bytes --- 'len' for memcpy
        ! arg3 arg4 callstack-length-offset [+] MOV
        2 temp0 temp0 SUBi ! callstack-length-offset
        0 temp0 arg3 LDRuoff
        ! arg3 tag-bits get SHR
        tag-bits get arg3 arg3 LSRi
        ! ! Compute new stack pointer -- 'dst' for memcpy
        ! arg1 arg3 SUB
        arg3 arg1 arg1 SUBr
        ! ! Install new stack pointer
        ! RSP arg1 MOV
        arg1 stack-reg MOVsp
        ! ! Call memcpy; arguments are now in the correct registers
        ! ! Create register shadow area for Win64
        ! RSP 32 SUB
        32 stack-reg stack-reg SUBi
        "factor_memcpy" jit-call
        ! ! Tear down register shadow area
        ! RSP 32 ADD
        32 stack-reg stack-reg ADDi
        ! ! Return with new callstack
        ! 0 RET
        pop-link-reg
        f RET
    ] }

    ! ! Factor 2024 Clinic Code:
    ! ! we think the below two lines
    ! ! 2 temp0 temp0 SUBi ! callstack-length-offset
    ! ! 0 temp0 arg3 LDRuoff
    ! ! may need to be replaced with:
    ! callstack-length-offset arg4 arg3 LDRuoff


    ! ## Fixnums
    ! Non-overflowing fixnum (integer) addition
    { fixnum+fast [ \ ADDr jit-math ] }

    ! ### Bit manipulation
    ! fixnum (integer) bitwise AND
    { fixnum-bitand [ \ ANDr jit-math ] }

    ! fixnum (integer) bitwise NOT
    { fixnum-bitnot [
        load0
        ! complement
        temp0 temp0 MVN
        ! clear tag bits
        tag-mask get temp0 temp0 EORi
        store0
    ] }

    ! fixnum (integer) bitwise OR
    { fixnum-bitor [ \ ORRr jit-math ] }

    ! fixnum (integer) bitwise XOR
    { fixnum-bitxor [ \ EORr jit-math ] }

    ! fixnum (integer) bitwise shift (positive = left, negative = right)
    { fixnum-shift-fast [
        ! load shift count and value
        load1/0
        ! untag shift count
        temp0 untag
        ! make a copy
        temp1 temp2 MOVr
        ! compute positive shift value in temp1
        temp0 temp1 temp1 LSLr
        ! compute negative shift value in temp2
        temp0 temp0 NEG
        temp0 temp2 temp2 ASRr
        tag-mask get bitnot temp2 temp2 ANDi
        ! if shift count was negative
        ! choose temp2 (else temp1)
        0 temp0 CMPi
        temp2 temp1 temp0 MI CSEL
        ! push to stack
        1 push-down0
    ] }

    ! ### Comparisons
    ! returns true if both arguments are fixnums, and false otherwise
    { both-fixnums? [
        load1/0
        temp1 temp0 temp0 ORRr
        tag-mask get temp0 TSTi
        \ f type-number temp0 MOVwi
        1 tag-fixnum temp1 MOVwi
        temp0 temp1 temp0 EQ CSEL
        1 push-down0
    ] }

    ! fixnum (integer) equality comparison
    { eq? [ EQ jit-compare ] }
    ! fixnum (integer) greater-than comparison
    { fixnum> [ GT jit-compare ] }
    ! fixnum (integer) greater-than-or-equal comparison
    { fixnum>= [ GE jit-compare ] }
    ! fixnum (integer) less-than comparison
    { fixnum< [ LT jit-compare ] }
    ! fixnum (integer) less-than-or-equal comparison
    { fixnum<= [ LE jit-compare ] }

    ! ### Div/mod
    ! fixnum (integer) modulo
    { fixnum-mod [
        jit-fixnum-/mod
        ! push to stack
        1 push-down0
    ] }
    ! fixnum (integer) division
    { fixnum/i-fast [
        jit-fixnum-/mod
        ! tag it
        tag-bits get temp2 temp0 LSLi
        ! push to stack
        1 push-down0
    ] }
    ! fixnum (integer) division and modulo
    { fixnum/mod-fast [
        jit-fixnum-/mod
        ! tag it
        temp2 tag*
        ! push to stack
        store2/0
    ] }

    ! ### Mul
    ! Non-overflowing fixnum (integer) multiplication
    { fixnum*fast [
        ! load both inputs
        load1/0
        ! untag second input
        temp0 untag
        ! multiply
        temp1 temp0 temp0 MUL
        ! push result
        1 push-down0
    ] }

    ! ### Sub
    ! Non-overflowing fixnum (integer) subtraction
    { fixnum-fast [ \ SUBr jit-math ] }

    ! ## Locals
    ! Drops all current locals stored on the retainstack.
    { drop-locals [
        ! load local count
        pop0
        ! turn local number into offset
        tagged>offset0
        ! decrement retain stack pointer
        temp0 rs-reg rs-reg SUBr
    ] }

    ! Gets the nth local stored on the retainstack.
    { get-local [
        ! load local number
        load0
        ! turn local number into offset
        tagged>offset0
        ! load local value
        temp0 rs-reg temp0 LDRr
        ! push to stack
        store0
    ] }

    ! Turns the top item on the datastack
    ! into a local stored on the retainstack.
    { load-local [ >r ] }

    ! ## Objects
    ! Reads the nth slot of a given object. (non-bounds-checking)
    { slot [
        ! load object and slot number
        load1/0
        ! turn slot number into offset
        tagged>offset0
        ! mask off tag
        tag-mask get bitnot temp1 temp1 ANDi
        ! load slot value
        temp1 temp0 temp0 LDRr
        ! push to stack
        1 push-down0
    ] }

    ! nth string element selector (non-bounds-checking)
    { string-nth-fast [
        ! load string index and string from stack
        load1/0
        temp1 untag
        ! load character
        string-offset temp0 temp0 ADDi
        temp1 temp0 temp0 LDRBr
        temp0 tag*
        ! store character to stack
        1 push-down0
    ] }

    ! add tag bits to integers
    ! (the local word tag just shifts left)
    { tag [
        ! load from stack
        load0
        ! compute tag
        tag-mask get temp0 temp0 ANDi
        ! tag the tag
        temp0 tag*
        ! push to stack
        store0
    ] }

    ! ## Shufflers

    ! ### Drops
    ! drops the top n stack items
    { drop [ 1 ndrop ] }
    { 2drop [ 2 ndrop ] }
    { 3drop [ 3 ndrop ] }
    { 4drop [ 4 ndrop ] }

    ! ### Dups
    ! duplicates the top n stack items in order
    { dup [ load0 push0 ] }
    { 2dup [ load1/0 push1 push0 ] }
    { 3dup [ load2 load1/0 push2 push1 push0 ] }
    { 4dup [ load3/2 load1/0 push3 push2 push1 push0 ] }
    ! duplicates the second stack item and puts it below the top stack item
    { dupd [ load1/0 store1 push0 ] }

    ! ### Misc shufflers
    ! Duplicates the second stack item and puts it above the top stack item
    { over [ load1 push1 ] }
    ! Duplicates the the third stack item and puts it above the top stack item
    { pick [ load2 push2 ] }

    ! ### Nips
    ! Drops the second stack item
    { nip [ load0 1 push-down0 ] }
    ! Drops the second and third stack items
    { 2nip [ load0 2 push-down0 ] }

    ! ### Swaps
    ! Rotates the top three elements of the stack (1st -> 3rd)
    { -rot [ pop0 load2/1* store0/2 push1 ] }
    ! Rotates the top three elements of the stack (1st -> 2nd)
    { rot [ pop0 load2/1* store1/0 push2 ] }
    ! Swaps the top two elements of the stack
    { swap [ load1/0 store0/1 ] }
    ! Swaps the second and third elements of the stack
    { swapd [ load2/1 store1/2 ] }

    ! ## Signal handling
    { leaf-signal-handler [
        jit-signal-handler-prolog
        jit-save-context
        ! temp0 vm-reg vm-signal-handler-addr-offset [+] MOV
        ! temp0 CALL
        vm-signal-handler-addr-offset vm-reg temp0 LDRuoff
        temp0 BLR
        jit-signal-handler-epilog
        ! Pop the fake leaf frame along with our return address
        ! leaf-stack-frame-size bootstrap-cell - RET
        leaf-stack-frame-size bootstrap-cell - SP SP ADDi
        f RET
    ] }
    { signal-handler [
        jit-signal-handler-prolog
        jit-save-context
        ! temp0 vm-reg vm-signal-handler-addr-offset [+] MOV
        ! temp0 CALL
        vm-signal-handler-addr-offset vm-reg temp0 LDRuoff
        temp0 BLR
        jit-signal-handler-epilog
        ! 0 RET
        f RET
    ] }
} define-sub-primitives

[ "bootstrap.arm.64" forget-vocab ] with-compilation-unit
