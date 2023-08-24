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
: pic-tail-reg ( -- reg ) X12 ; inline

: stack-reg ( -- reg ) SP ; inline
: link-reg ( -- reg ) X30 ; inline ! LR
: stack-frame-reg ( -- reg ) X29 ; inline ! FP
: vm-reg ( -- reg ) X28 ; inline
: ds-reg ( -- reg ) X27 ; inline
: rs-reg ( -- reg ) X26 ; inline
: ctx-reg ( -- reg ) X25 ; inline

: push-link-reg ( -- ) -16 stack-reg link-reg STRpre ;
: pop-link-reg ( -- ) 16 stack-reg link-reg LDRpost ;

: load0 ( -- ) 0 ds-reg temp0 LDRuoff ;
: load1 ( -- ) -8 ds-reg temp1 LDUR ;
: load2 ( -- ) -16 ds-reg temp2 LDUR ;
: load1/0 ( -- ) -8 ds-reg temp0 temp1 LDPsoff ;
: load2/1 ( -- ) -16 ds-reg temp1 temp2 LDPsoff ;
: load2/1* ( -- ) -8 ds-reg temp1 temp2 LDPsoff ;
: load3/2 ( -- ) -24 ds-reg temp2 temp3 LDPsoff ;
: load-arg1/2 ( -- ) -8 ds-reg arg2 arg1 LDPsoff ;

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
: push-down-arg3 ( -- ) -8 ds-reg arg3 STRpre ;

: store0 ( -- ) 0 ds-reg temp0 STRuoff ;
: store1 ( -- ) 0 ds-reg temp1 STRuoff ;
: store0/1 ( -- ) -8 ds-reg temp1 temp0 STPsoff ;
: store0/2 ( -- ) -8 ds-reg temp2 temp0 STPsoff ;
: store1/0 ( -- ) -8 ds-reg temp0 temp1 STPsoff ;
: store1/2 ( -- ) -16 ds-reg temp2 temp1 STPsoff ;

:: tag ( reg -- ) tag-bits get reg reg LSLi ;
:: untag ( reg -- ) tag-bits get reg reg ASRi ;
: tagged>offset0 ( -- ) 1 temp0 temp0 ASRi ;

: >r ( -- ) pop0 pushr ;
: r> ( -- ) popr push0 ;

: absolute-jump ( -- word class )
    2 words temp0 LDRl
    temp0 BR
    NOP NOP f rc-absolute-cell ; inline

: absolute-call ( -- word class )
    5 words temp0 LDRl
    push-link-reg
    temp0 BLR
    pop-link-reg
    3 words Br
    NOP NOP f rc-absolute-cell ; inline

[
    ! ! pic-tail-reg 5 [RIP+] LEA
    ! why do we store the address after JMP in EBX, where is it
    ! picked up?
    4 pic-tail-reg ADR
    ! ! 0 JMP f rc-relative rel-word-pic-tail
    ! 0 Br f rc-relative-arm64-branch rel-word-pic-tail
    absolute-jump rel-word-pic-tail
] JIT-WORD-JUMP jit-define

[
    ! ! 0 CALL f rc-relative rel-word-pic
    ! push-link-reg
    ! 0 BL f rc-relative-arm64-branch rel-word-pic
    ! pop-link-reg
    absolute-call rel-word-pic
] JIT-WORD-CALL jit-define

: jit-call ( name -- )
    ! RAX 0 MOV f rc-absolute-cell rel-dlsym
    ! RAX CALL ;
    absolute-call rel-dlsym ;

:: jit-call-1arg ( arg1s name -- )
    ! arg1 arg1s MOVr
    ! name jit-call ;
    arg1s arg1 MOVr
    name jit-call ;

:: jit-call-2arg ( arg1s arg2s name -- )
    ! arg1 arg1s MOV
    ! arg2 arg2s MOV
    ! name jit-call ;
    arg1s arg1 MOVr
    arg2s arg2 MOVr
    name jit-call ;

: jit-load-vm ( -- ) ;

: jit-load-context ( -- )
    ! ctx-reg vm-reg vm-context-offset [+] MOV ;
    vm-context-offset vm-reg ctx-reg LDRuoff ;

: jit-save-context ( -- )
    jit-load-context
    ! The reason for -8 I think is because we are anticipating a CALL
    ! instruction. After the call instruction, the contexts frame_top
    ! will point to the origin jump address.
    ! R11 RSP -8 [+] LEA
    ! ctx-reg context-callstack-top-offset [+] R11 MOV
    stack-reg temp0 MOVsp
    16 temp0 temp0 SUBi
    context-callstack-top-offset ctx-reg temp0 STRuoff
    ! ctx-reg context-datastack-offset [+] ds-reg MOV
    ! ctx-reg context-retainstack-offset [+] rs-reg MOV ;
    context-datastack-offset ctx-reg ds-reg STRuoff
    context-retainstack-offset ctx-reg rs-reg STRuoff ;

! ctx-reg must already have been loaded
: jit-restore-context ( -- )
    ! ds-reg ctx-reg context-datastack-offset [+] MOV
    ! rs-reg ctx-reg context-retainstack-offset [+] MOV ;
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

: jit-jump-quot ( -- )
    ! arg1 quot-entry-point-offset [+] JMP ;
    quot-entry-point-offset arg1 temp0 LDUR
    temp0 BR ;

: jit-call-quot ( -- )
    ! arg1 quot-entry-point-offset [+] CALL ;
    push-link-reg
    quot-entry-point-offset arg1 temp0 LDUR
    temp0 BLR
    pop-link-reg ;

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
    stack-frame-size bootstrap-cell - stack-reg arg1 LDRuoff ;

! These are always in tail position with an existing stack
! frame, and the stack. The frame setup takes this into account.
: jit-inline-cache-miss ( -- )
    jit-save-context
    ! arg1 RBX MOV
    ! arg2 vm-reg MOV
    vm-reg arg2 MOVr
    ! RAX 0 MOV rc-absolute-cell rel-inline-cache-miss
    ! RAX CALL
    absolute-call nip rel-inline-cache-miss
    jit-load-context
    jit-restore-context ;

[ jit-load-return-address jit-inline-cache-miss ] [
    ! RAX CALL
    push-link-reg
    temp0 BLR
    pop-link-reg
] [
    ! RAX JMP
    temp0 BR
] \ inline-cache-miss define-combinator-primitive

[ jit-inline-cache-miss ] [
    ! RAX CALL
    push-link-reg
    temp0 BLR
    pop-link-reg
] [
    ! RAX JMP
    temp0 BR
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
    ! arg1 ds-reg [] MOV
    ! arg1 arg1 alien-offset [+] MOV
    ! arg2 ds-reg -8 [+] MOV
    ! ds-reg 16 SUB ;
    pop-arg1
    alien-offset arg1 arg1 ADDi
    0 arg1 arg1 LDRuoff
    pop-arg2 ;

: jit-push-param ( -- )
    ! ds-reg 8 ADD
    ! ds-reg [] arg2 MOV ;
    push-arg2 ;

: jit-set-context ( -- )
    jit-pop-context-and-param
    jit-save-context
    arg1 jit-switch-context
    ! RSP 8 ADD
    16 stack-reg stack-reg ADDi
    jit-push-param ;

: jit-pop-quot-and-param ( -- )
    ! arg1 ds-reg [] MOV
    ! arg2 ds-reg -8 [+] MOV
    ! ds-reg 16 SUB ;
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
    ! 0 [RIP+] EAX MOV rc-relative rel-safepoint
    3 words temp0 LDRl
    0 temp0 W0 STRuoff
    3 words Br
    NOP NOP rc-absolute-cell rel-safepoint
] JIT-SAFEPOINT jit-define

! C to Factor entry point
[
    0xabcd BRK
    ! ! Optimizing compiler's side of callback accesses
    ! ! arguments that are on the stack via the frame pointer.
    ! ! On x86-32 fastcall, and x86-64, some arguments are passed
    ! ! in registers, and so the only registers that are safe for
    ! ! use here are frame-reg, nv-reg and vm-reg.
    ! frame-reg PUSH
    ! frame-reg stack-reg MOV

    ! ! Save all non-volatile registers
    ! nv-regs [ PUSH ] each
    -16 SP X19 X18 STPpre
    -16 SP X21 X20 STPpre
    -16 SP X23 X22 STPpre
    -16 SP X25 X24 STPpre
    -16 SP X27 X26 STPpre
    -16 SP X29 X28 STPpre
    -16 SP X30 STRpre
    stack-reg stack-frame-reg MOVsp

    jit-save-tib

    ! ! Load VM into vm-reg
    ! vm-reg 0 MOV 0 rc-absolute-cell rel-vm
    2 words vm-reg LDRl
    3 words Br
    NOP NOP 0 rc-absolute-cell rel-vm

    ! ! Save old context
    ! nv-reg vm-reg vm-context-offset [+] MOV
    ! nv-reg PUSH
    vm-context-offset vm-reg ctx-reg LDRuoff
    8 SP ctx-reg STRuoff

    ! ! Switch over to the spare context
    ! nv-reg vm-reg vm-spare-context-offset [+] MOV
    ! vm-reg vm-context-offset [+] nv-reg MOV
    vm-spare-context-offset vm-reg ctx-reg LDRuoff
    vm-context-offset vm-reg ctx-reg STRuoff

    ! ! Save C callstack pointer
    ! nv-reg context-callstack-save-offset [+] stack-reg MOV

    stack-reg temp0 MOVsp
    context-callstack-save-offset ctx-reg temp0 STRuoff
    ! stack-reg X24 MOVsp
    ! NOP

    ! ! Load Factor stack pointers
    ! stack-reg nv-reg context-callstack-bottom-offset [+] MOV
    context-callstack-bottom-offset ctx-reg temp0 LDRuoff
    temp0 stack-reg MOVsp

    ctx-reg jit-update-tib
    jit-install-seh

    ! rs-reg nv-reg context-retainstack-offset [+] MOV
    ! ds-reg nv-reg context-datastack-offset [+] MOV
    context-retainstack-offset ctx-reg rs-reg LDRuoff
    context-datastack-offset ctx-reg ds-reg LDRuoff

    ! ! Call into Factor code
    ! link-reg 0 MOV f rc-absolute-cell rel-word
    ! link-reg CALL
    3 words temp0 LDRl
    temp0 BLR
    3 words Br
    NOP NOP f rc-absolute-cell rel-word

    ! ! Load C callstack pointer
    ! nv-reg vm-reg vm-context-offset [+] MOV
    ! stack-reg nv-reg context-callstack-save-offset [+] MOV
    vm-context-offset vm-reg ctx-reg LDRuoff

    context-callstack-save-offset ctx-reg temp0 LDRuoff
    temp0 stack-reg MOVsp
    ! X24 stack-reg MOVsp
    ! NOP

    ! ! Load old context
    ! nv-reg POP
    ! vm-reg vm-context-offset [+] nv-reg MOV
    8 SP ctx-reg LDRuoff
    vm-context-offset vm-reg ctx-reg STRuoff

    jit-restore-tib

    ! ! Restore non-volatile registers
    ! nv-regs <reversed> [ POP ] each
    ! frame-reg POP
    16 SP X30 LDRpost
    16 SP X29 X28 LDPpost
    16 SP X27 X26 LDPpost
    16 SP X25 X24 LDPpost
    16 SP X23 X22 LDPpost
    16 SP X21 X20 LDPpost
    16 SP X19 X18 LDPpost

    ! ! Callbacks which return structs, or use stdcall/fastcall/thiscall,
    ! ! need a parameter here.

    ! ! See the comment for M\ x86.32 stack-cleanup in cpu.x86.32
    ! 0xffff RET f rc-absolute-2 rel-untagged
    4 words temp0 ADR
    2 temp0 temp0 LDRHuoff
    temp0 stack-reg stack-reg ADDr
    f RET
    NOP f rc-absolute-2 rel-untagged
] CALLBACK-STUB jit-define

[
    ! ! load literal
    ! temp0 0 MOV f rc-absolute-cell rel-literal
    2 words temp0 LDRl
    3 words Br
    NOP NOP f rc-absolute-cell rel-literal
    ! ! increment datastack pointer
    ! ds-reg bootstrap-cell ADD
    ! ! store literal on datastack
    ! ds-reg [] temp0 MOV
    push0
] JIT-PUSH-LITERAL jit-define

! The *-signal-handler subprimitives are special-cased in vm/quotations.cpp
! not to trigger generation of a stack frame, so they can
! peform their own prolog/epilog preserving registers.
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

[
    ! ! load boolean
    ! temp0 ds-reg [] MOV
    ! ! pop boolean
    ! ds-reg bootstrap-cell SUB
    pop0
    ! ! compare boolean with f
    ! temp0 \ f type-number CMP
    \ f type-number temp0 CMPi
    ! ! jump to true branch if not equal
    ! ! 0 JNE f rc-relative rel-word
    ! 0 NE B.cond f rc-relative-arm64-bcond rel-word
    5 words EQ B.cond
    absolute-jump rel-word
    ! ! jump to false branch if equal
    ! ! 0 JMP f rc-relative rel-word
    ! 0 Br f rc-relative-arm64-branch rel-word
    absolute-jump rel-word
] JIT-IF jit-define

[
    >r
    ! ! 0 CALL f rc-relative rel-word
    ! push-link-reg
    ! 0 Br f rc-relative-arm64-branch rel-word
    ! pop-link-reg
    absolute-call rel-word
    r>
] JIT-DIP jit-define

[
    >r >r
    ! ! 0 CALL f rc-relative rel-word
    ! push-link-reg
    ! 0 Br f rc-relative-arm64-branch rel-word
    ! pop-link-reg
    absolute-call rel-word
    r> r>
] JIT-2DIP jit-define

[
    >r >r >r
    ! ! 0 CALL f rc-relative rel-word
    ! push-link-reg
    ! 0 Br f rc-relative-arm64-branch rel-word
    ! pop-link-reg
    absolute-call rel-word
    r> r> r>
] JIT-3DIP jit-define

[
    ! ! load from stack
    ! temp0 ds-reg [] MOV
    ! ! pop stack
    ! ds-reg bootstrap-cell SUB
    pop0
] [
    ! temp0 word-entry-point-offset [+] CALL
    push-link-reg
    temp0 BLR
    pop-link-reg
] [
    ! temp0 word-entry-point-offset [+] JMP
    temp0 BR
] \ (execute) define-combinator-primitive

[
    ! temp0 ds-reg [] MOV
    ! ds-reg bootstrap-cell SUB
    pop0
    ! temp0 word-entry-point-offset [+] JMP
    word-entry-point-offset temp0 temp0 ADDi
    temp0 BR
] JIT-EXECUTE jit-define

! https://elixir.bootlin.com/linux/latest/source/arch/arm64/kernel/stacktrace.c#L22
[
    ! ! make room for LR plus magic number of callback, 16byte align
    ! x64 ! stack-reg stack-frame-size bootstrap-cell - SUB
    stack-frame-size stack-reg stack-reg SUBi
    push-link-reg
] JIT-PROLOG jit-define

[
    ! x64 ! stack-reg stack-frame-size bootstrap-cell - ADD
    pop-link-reg
    stack-frame-size stack-reg stack-reg ADDi
] JIT-EPILOG jit-define

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

[
    ! temp1/32 tag-mask get AND
    tag-mask get temp1 temp1 ANDi
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
    [ NE B.cond ] [
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
    temp1 tag
    ! temp1/32 tuple type-number tag-fixnum CMP
    tuple type-number tag-fixnum temp1 CMPi
    ! [ JNE ]
    ! [ temp1 temp0 tuple-class-offset [+] MOV ]
    [ NE B.cond ] [
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
    [ NE B.cond ] [
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
        word-entry-point-offset temp0 temp0 ADDi
        temp0 BR
        ! ! fall-through on miss
    ] jit-conditional
] MEGA-LOOKUP jit-define

! Comparisons
: jit-compare ( cond -- )
    ! ! load t
    ! temp3 0 MOV t rc-absolute-cell rel-literal
    2 words temp3 LDRl
    3 words Br
    NOP NOP t rc-absolute-cell rel-literal
    ! ! load f
    ! temp1 \ f type-number MOV
    \ f type-number temp2 MOVwi
    ! ! load first value
    ! temp0 ds-reg [] MOV
    ! ! adjust stack pointer
    ! ds-reg bootstrap-cell SUB
    load1/0
    ! ! compare with second value
    ! ds-reg [] temp0 CMP
    temp1 temp0 CMPr
    ! ! move t if true
    ! [ temp1 temp3 ] dip execute( dst src -- )
    [ temp2 temp3 temp0 ] dip CSEL
    ! ! store
    ! ds-reg [] temp1 MOV
    1 push-down0 ;

! Math

! Overflowing fixnum arithmetic
: jit-overflow ( insn func -- )
    ! ds-reg 8 SUB
    jit-save-context
    ! arg1 ds-reg [] MOV
    ! arg2 ds-reg 8 [+] MOV
    load-arg1/2
    ! arg3 arg1 MOV
    ! [ [ arg3 arg2 ] dip call ] dip
    [ [ arg2 arg1 arg3 ] dip call ] dip
    ! ds-reg [] arg3 MOV
    push-down-arg3
    ! [ JNO ]
    [ VC B.cond ] [
        ! arg3 vm-reg MOV
        vm-reg arg3 MOVr
        jit-call
    ] jit-conditional ; inline

: jit-math ( insn -- )
    ! ! load second input
    ! temp0 ds-reg [] MOV
    ! ! pop stack
    ! ds-reg bootstrap-cell SUB
    load1/0
    ! ! compute result
    ! [ ds-reg [] temp0 ] dip execute( dst src -- )
    [ temp0 temp1 temp0 ] dip execute( arg2 arg1 dst -- )
    1 push-down0 ;

: jit-fixnum-/mod ( -- )
    ! ! load second parameter
    ! temp1 ds-reg [] MOV
    ! ! load first parameter
    ! div-arg ds-reg bootstrap-cell neg [+] MOV
    load1/0
    ! ! divide
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
    { fixnum+ [ [ ADDr ] "overflow_fixnum_add" jit-overflow ] }
    { fixnum- [ [ SUBr ] "overflow_fixnum_subtract" jit-overflow ] }
    { fixnum* [
        ! ds-reg 8 SUB
        jit-save-context
        ! RCX ds-reg [] MOV
        ! RBX ds-reg 8 [+] MOV
        load1/0
        ! RBX tag-bits get SAR
        temp0 untag
        ! RAX RCX MOV
        ! RBX IMUL
        ! RAX * RBX = RDX:RAX
        temp1 temp0 temp0 MUL
        ! ds-reg [] RAX MOV
        1 push-down0
        ! [ JNO ]
        [ VC B.cond ] [
            ! arg1 RCX MOV
            temp1 arg1 MOVr
            ! arg1 tag-bits get SAR
            temp1 untag
            ! arg2 RBX MOV
            temp0 arg2 MOVr
            ! arg3 vm-reg MOV
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
        f RET
    ] }

    ! ## Fixnums

    ! ### Add
    { fixnum+fast [ \ ADDr jit-math ] }

    ! ### Bit manipulation
    { fixnum-bitand [ \ ANDr jit-math ] }
    { fixnum-bitnot [
        ! ! complement
        ! ds-reg [] NOT
        load0
        temp0 temp0 MVN
        ! ! clear tag bits
        ! ds-reg [] tag-mask get XOR
        tag-mask get temp0 temp0 EORi
        store0
    ] }
    { fixnum-bitor [ \ ORRr jit-math ] }
    { fixnum-bitxor [ \ EORr jit-math ] }
    { fixnum-shift-fast [
        ! ! load shift count
        ! shift-arg ds-reg [] MOV
        ! ! adjust stack pointer
        ! ds-reg bootstrap-cell SUB
        ! ! load value
        ! temp3 ds-reg [] MOV
        load1/0
        ! ! untag shift count
        ! shift-arg tag-bits get SAR
        temp0 untag
        ! ! make a copy
        ! temp2 temp3 MOV
        temp1 temp2 MOVr
        ! ! compute positive shift value in temp2
        ! temp2 CL SHL
        temp0 temp1 temp1 LSLr
        ! ! compute negative shift value in temp3
        ! shift-arg NEG
        temp0 temp0 NEG
        ! temp3 CL SAR
        temp0 temp2 temp2 ASRr
        ! temp3 tag-mask get bitnot AND
        tag-mask get bitnot temp2 temp2 ANDi
        ! ! if shift count was negative, move temp3 to temp2
        ! shift-arg 0 CMP
        ! temp2 temp3 CMOVGE
        temp2 temp1 temp0 PL CSEL
        ! ! push to stack
        ! ds-reg [] temp2 MOV
        1 push-down0
    ] }

    ! ### Comparisons
    { both-fixnums? [
        ! temp0 ds-reg [] MOV
        ! ds-reg bootstrap-cell SUB
        load1/0
        ! temp0 ds-reg [] OR
        temp1 temp0 temp0 ORRr
        ! temp0 tag-mask get TEST
        tag-mask get temp0 TSTi
        ! temp0 \ f type-number MOV
        \ f type-number temp0 MOVwi
        ! temp1 1 tag-fixnum MOV
        1 tag-fixnum temp1 MOVwi
        ! temp0 temp1 CMOVE
        temp0 temp1 temp0 EQ CSEL
        ! ds-reg [] temp0 MOV
        1 push-down0
    ] }
    { eq? [ EQ jit-compare ] }
    { fixnum> [ GT jit-compare ] }
    { fixnum>= [ GE jit-compare ] }
    { fixnum< [ LT jit-compare ] }
    { fixnum<= [ LE jit-compare ] }

    ! ### Div/mod
    { fixnum-mod [
        jit-fixnum-/mod
        ! ! adjust stack pointer
        ! ds-reg bootstrap-cell SUB
        ! ! push to stack
        ! ds-reg [] mod-arg MOV
        1 push-down0
    ] }
    { fixnum/i-fast [
        jit-fixnum-/mod
        ! ! adjust stack pointer
        ! ds-reg bootstrap-cell SUB
        ! ! tag it
        ! div-arg tag-bits get SHL
        tag-bits get temp2 temp0 LSLi
        ! ! push to stack
        ! ds-reg [] div-arg MOV
        1 push-down0
    ] }
    { fixnum/mod-fast [
        jit-fixnum-/mod
        ! ! tag it
        ! div-arg tag-bits get SHL
        temp2 tag
        ! ! push to stack
        ! ds-reg [] mod-arg MOV
        ! ds-reg bootstrap-cell neg [+] div-arg MOV
        store0/2
    ] }

    ! ### Mul
    { fixnum*fast [
        ! ! load second input
        ! temp0 ds-reg [] MOV
        ! ! pop stack
        ! ds-reg bootstrap-cell SUB
        ! ! load first input
        ! temp1 ds-reg [] MOV
        load1/0
        ! ! untag second input
        ! temp0 tag-bits get SAR
        temp0 untag
        ! ! multiply
        ! temp0 temp1 IMUL2
        temp1 temp0 temp0 MUL
        ! ! push result
        ! ds-reg [] temp0 MOV
        1 push-down0
    ] }

    ! ### Sub
    { fixnum-fast [ \ SUBr jit-math ] }

    ! ## Locals
    { drop-locals [
        ! ! load local count
        ! temp0 ds-reg [] MOV
        ! ! adjust stack pointer
        ! ds-reg bootstrap-cell SUB
        pop0
        ! ! turn local number into offset
        tagged>offset0
        ! ! decrement retain stack pointer
        ! rs-reg temp0 SUB
        temp0 rs-reg rs-reg SUBr
    ] }
    { get-local [
        ! ! load local number
        ! temp0 ds-reg [] MOV
        load0
        ! ! turn local number into offset
        tagged>offset0
        ! ! load local value
        ! temp0 rs-reg temp0 [+] MOV
        temp0 rs-reg temp0 LDRr
        ! ! push to stack
        ! ds-reg [] temp0 MOV
        store0
    ] }
    { load-local [ >r ] }

    ! ## Objects
    { slot [
        ! ! load slot number
        ! temp0 ds-reg [] MOV
        ! ! adjust stack pointer
        ! ds-reg bootstrap-cell SUB
        ! ! load object
        ! temp1 ds-reg [] MOV
        load1/0
        ! ! turn slot number into offset
        tagged>offset0
        ! ! mask off tag
        ! temp1 tag-bits get SHR
        ! temp1 tag-bits get SHL
        tag-mask get bitnot temp1 temp1 ANDi
        ! ! load slot value
        ! temp0 temp1 temp0 [+] MOV
        temp1 temp0 temp0 LDRr
        ! ! push to stack
        ! ds-reg [] temp0 MOV
        1 push-down0
    ] }
    { string-nth-fast [
        ! ! load string index from stack
        ! temp0 ds-reg bootstrap-cell neg [+] MOV
        ! temp0 tag-bits get SHR
        ! ! load string from stack
        ! temp1 ds-reg [] MOV
        load1/0
        ! ! load character
        ! temp0 8-bit-version-of temp0 temp1 string-offset [++] MOV
        ! temp0 temp0 8-bit-version-of MOVZX
        ! temp0 tag-bits get SHL
        temp1 temp0 temp0 LDRBr
        temp0 tag
        ! ! store character to stack
        ! ds-reg bootstrap-cell SUB
        ! ds-reg [] temp0 MOV
        1 push-down0
    ] }
    { tag [
        ! ! load from stack
        ! temp0 ds-reg [] MOV
        load0
        ! ! compute tag
        ! temp0/32 tag-mask get AND
        tag-mask get temp0 temp0 ANDi
        ! ! tag the tag
        ! temp0/32 tag-bits get SHL
        temp0 tag
        ! ! push to stack
        ! ds-reg [] temp0 MOV
        store0
    ] }

    ! ! ## Shufflers

    ! ! ### Drops
    { drop [ 1 ndrop ] }
    { 2drop [ 2 ndrop ] }
    { 3drop [ 3 ndrop ] }
    { 4drop [ 4 ndrop ] }

    ! ! ### Dups
    { dup [ load0 push0 ] }
    { 2dup [ load1/0 push1 push0 ] }
    { 3dup [ load2 load1/0 push2 push1 push0 ] }
    { 4dup [ load3/2 load1/0 push3 push2 push1 push0 ] }
    { dupd [ load1/0 store1 push0 ] }

    ! ! ### Misc shufflers
    { over [ load1 push1 ] }
    { pick [ load2 push2 ] }

    ! ! ### Nips
    { nip [ load0 1 push-down0 ] }
    { 2nip [ load0 2 push-down0 ] }

    ! ! ### Swaps
    { -rot [ pop0 load2/1* store0/2 push1 ] }
    { rot [ pop0 load2/1* store1/0 push2 ] }
    { swap [ load1/0 store0/1 ] }
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
