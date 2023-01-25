! Copyright (C) 2020 Doug Coleman.
! Copyright (C) 2023 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private compiler.codegen.relocation
compiler.constants compiler.units cpu.arm.assembler
cpu.arm.assembler.opcodes generic.single.private
kernel kernel.private layouts locals.backend
math math.private memory namespaces sequences slots.private
strings.private threads.private vocabs ;
IN: bootstrap.assembler.arm

8 \ cell set

big-endian off

! Stack frame
! https://docs.microsoft.com/en-us/cpp/build/arm64-exception-handling?view=vs-2019

! x0	Volatile	Parameter/scratch register 1, result register
! x1-x7	Volatile	Parameter/scratch register 2-8
! x8-x15	Volatile	Scratch registers
! x16-x17	Volatile	Intra-procedure-call scratch registers
! x18	Non-volatile	Platform register: in kernel mode, points to KPCR for the current processor;
!   in user mode, points to TEB
! x19-x28	Non-volatile	Scratch registers
! x29/fp	Non-volatile	Frame pointer
! x30/lr	Non-volatile	Link register

! varargs https://developer.arm.com/documentation/ihi0055/d/?lang=en
: stack-frame-size ( -- n ) 8 bootstrap-cells ;
: volatile-regs ( -- seq ) { X0 X1 X2 X3 X4 X5 X6 X7 X8 X9 X10 X11 X12 X13 X14 X15 X16 X17 } ;
! windows arm - X18 is non-volatile https://docs.microsoft.com/en-us/cpp/build/arm64-windows-abi-conventions?view=msvc-160
: nv-regs ( -- seq ) { X18 X19 X20 X21 X22 X23 X24 X25 X26 X27 X28 X29 X30 } ;

! callee-save = non-volatile aka call-preserved

! x30 is the link register (used to return from subroutines)
! x29 is the frame register
! x19 to x29 are callee-saved
! x18 is the 'platform register', used for some operating-system-specific special purpose,
!   or an additional caller-saved register
! x16 and x17 are the Intra-Procedure-call scratch register
! x9 to x15: used to hold local variables (caller saved)
! x8: used to hold indirect return value address
! x0 to x7: used to hold argument values passed to a subroutine, and also hold
!   results returned from a subroutine


! https://en.wikichip.org/wiki/arm/aarch64
! Generally, X0 through X18 (volatile, can corrupt) while X19-X29 must be preserved (non-volatile)
! Volatile registers' content may change over a subroutine call
! non-volatile register is a type of register with contents that must be preserved over subroutine calls
! Register   Role    Requirement
! X0 -  X7   Parameter/result registers   Can Corrupt (volatile)
! X8         Indirect result location register (volatile)
! X9 -  X15  Temporary registers (volatile)
! X16 - X17  Intra-procedure call temporary (volatile)
! X16 - syscall reg with SVC instruction
! X18        Platform register, otherwise temporary, DONT USE (volatile)

! X19 - X29    Callee-saved register    Must preserve (non-volatile)
! X29 - frame pointer register, must always be valid
! X30    Link Register LR   Can Corrupt
! X31  Stack Pointer SP
! 16-byte stack alignment

! stack walking - {fp, lr} pairs if compiled with frame pointers enabled

: arg1 ( -- reg ) X0 ;
: arg2 ( -- reg ) X1 ;
: arg3 ( -- reg ) X2 ;
: arg4 ( -- reg ) X3 ;

! Red zone
! windows arm64: 16 bytes https://devblogs.microsoft.com/oldnewthing/20190111-00/?p=100685
! windows arm32: 8 bytes
! x86/x64: 0 bytes
! Apple arm64: 128 bytes https://developer.apple.com/documentation/xcode/writing_arm64_code_for_apple_platforms?language=objc
: red-zone-size ( -- n ) 16 ; ! 16 bytes on windows, or 128 bytes on linux? or 0?
! 0 or 16 likely
! no red zone on x86/x64 windows


! https://github.com/MicrosoftDocs/cpp-docs/blob/master/docs/build/arm64-windows-abi-conventions.md

: shift-arg ( -- reg ) X1 ;
: div-arg ( -- reg ) X0 ;
: mod-arg ( -- reg ) X2 ;

! caller-saved registers X9-X15
! callee-saved registers X19-X29
: temp0 ( -- reg ) X9 ;
: temp1 ( -- reg ) X10 ;
: temp2 ( -- reg ) X11 ;
: temp3 ( -- reg ) X12 ;

! : pic-tail-reg ( -- reg ) RBX ;
: return-reg ( -- reg ) X0 ;
: stack-reg ( -- reg ) SP ;
! https://developer.arm.com/documentation/dui0801/a/Overview-of-AArch64-state/Link-registers
: link-reg ( -- reg ) X30 ; ! LR
: stack-frame-reg ( -- reg ) X29 ; ! FP
: vm-reg ( -- reg ) X28 ;
: ds-reg ( -- reg ) X27 ;
: rs-reg ( -- reg ) X26 ;
: ctx-reg ( -- reg ) X13 ;
: word-reg ( -- reg ) X14 ;
! : fixnum>slot@ ( -- ) temp0 1 SAR ;
! : rex-length ( -- n ) 1 ;

! rc-absolute-cell is just CONSTANT: 0
: jit-call ( name -- )
    0 X0 MOVwi64
    f rc-absolute-cell rel-dlsym
    X0 BLR ;
    ! RAX 0 MOV f rc-absolute-cell rel-dlsym
    ! RAX CALL ;

:: jit-call-1arg ( arg1s name -- )
    arg1s arg1 MOVr64
    name jit-call ;
    ! arg1 arg1s MOVr64
    ! name jit-call ;

:: jit-call-2arg ( arg1s arg2s name -- )
    arg1s arg1 MOVr64
    arg2s arg2 MOVr64
    name jit-call ;
    ! arg1 arg1s MOV
    ! arg2 arg2s MOV
    ! name jit-call ;

[
    ! pic-tail-reg 5 [RIP+] LEA
    ! 0 JMP f rc-relative rel-word-pic-tail
] JIT-WORD-JUMP jit-define

: jit-load-vm ( -- )
    ! no-op on x86-64. in factor contexts vm-reg always contains the
    ! vm pointer.
    ;

: jit-load-context ( -- ) ;
    ! ctx-reg vm-reg vm-context-offset [+] MOV ;

: jit-save-context ( -- ) ;
    ! jit-load-context
    ! The reason for -8 I think is because we are anticipating a CALL
    ! instruction. After the call instruction, the contexts frame_top
    ! will point to the origin jump address.
    ! R11 RSP -8 [+] LEA
    ! ctx-reg context-callstack-top-offset [+] R11 MOV
    ! ctx-reg context-datastack-offset [+] ds-reg MOV
    ! ctx-reg context-retainstack-offset [+] rs-reg MOV ;

! ctx-reg must already have been loaded
: jit-restore-context ( -- ) ;
    ! ds-reg ctx-reg context-datastack-offset [+] MOV
    ! rs-reg ctx-reg context-retainstack-offset [+] MOV ;


[

    ! ! ctx-reg is preserved across the call because it is non-volatile
    ! ! in the C ABI
    ! jit-save-context
    ! ! call the primitive
    ! arg1 vm-reg MOV
    ! RAX 0 MOV f f rc-absolute-cell rel-dlsym
    ! RAX CALL
    ! jit-restore-context
] JIT-PRIMITIVE jit-define


: jit-jump-quot ( -- )
    quot-entry-point-offset arg1 ADR
    arg1 BR ;
    ! arg1 quot-entry-point-offset [+] JMP ;

: jit-call-quot ( -- )
    quot-entry-point-offset arg1 ADR
    arg1 BLR ;
    ! arg1 quot-entry-point-offset [+] CALL ;

: signal-handler-save-regs ( -- regs ) { } ;
    ! { RAX RCX RDX RBX RBP RSI RDI R8 R9 R10 R11 R12 R13 R14 R15 } ;


[
    ! temp2 0 MOV f rc-absolute-cell rel-literal
    ! temp1 temp2 CMP
] PIC-CHECK-TUPLE jit-define



: jit->r ( -- )
    1 bootstrap-cells rs-reg rs-reg ADDi64
    -1 bootstrap-cells ds-reg rs-reg LDR-post ;

: jit-r> ( -- )
    1 bootstrap-cells ds-reg ds-reg ADDi64
    -1 bootstrap-cells rs-reg ds-reg LDR-post ;

: jit-2>r ( -- )
    1 bootstrap-cells rs-reg rs-reg ADDi64
    -1 bootstrap-cells ds-reg rs-reg LDR-post
    1 bootstrap-cells rs-reg rs-reg ADDi64
    -1 bootstrap-cells ds-reg rs-reg LDR-post ;

: jit-2r> ( -- )
    1 bootstrap-cells ds-reg ds-reg ADDi64
    -1 bootstrap-cells rs-reg ds-reg LDR-post
    1 bootstrap-cells ds-reg ds-reg ADDi64
    -1 bootstrap-cells rs-reg ds-reg LDR-post ;

: jit-3>r ( -- )
    1 bootstrap-cells rs-reg rs-reg ADDi64
    -1 bootstrap-cells ds-reg rs-reg LDR-post
    1 bootstrap-cells rs-reg rs-reg ADDi64
    -1 bootstrap-cells ds-reg rs-reg LDR-post
    1 bootstrap-cells rs-reg rs-reg ADDi64
    -1 bootstrap-cells ds-reg rs-reg LDR-post ;

: jit-3r> ( -- )
    1 bootstrap-cells ds-reg ds-reg ADDi64
    -1 bootstrap-cells rs-reg ds-reg LDR-post
    1 bootstrap-cells ds-reg ds-reg ADDi64
    -1 bootstrap-cells rs-reg ds-reg LDR-post
    1 bootstrap-cells ds-reg ds-reg ADDi64
    -1 bootstrap-cells rs-reg ds-reg LDR-post ;

! Contexts
: jit-switch-context ( reg -- ) drop ;
    ! ! Push a bogus return address so the GC can track this frame back
    ! ! to the owner
    ! 0 CALL

    ! ! Make the new context the current one
    ! ctx-reg swap MOV
    ! vm-reg vm-context-offset [+] ctx-reg MOV

    ! ! Load new stack pointer
    ! RSP ctx-reg context-callstack-top-offset [+] MOV

    ! ! Load new ds, rs registers
    ! jit-restore-context

    ! ctx-reg jit-update-tib ;

: jit-pop-context-and-param ( -- ) ;
    ! arg1 ds-reg [] MOV
    ! arg1 arg1 alien-offset [+] MOV
    ! arg2 ds-reg -8 [+] MOV
    ! ds-reg 16 SUB ;

: jit-push-param ( -- ) ;
    ! ds-reg 8 ADD
    ! ds-reg [] arg2 MOV ;

: jit-set-context ( -- ) ;
    ! jit-pop-context-and-param
    ! jit-save-context
    ! arg1 jit-switch-context
    ! RSP 8 ADD
    ! jit-push-param ;

: jit-pop-quot-and-param ( -- ) ;
    ! arg1 ds-reg [] MOV
    ! arg2 ds-reg -8 [+] MOV
    ! ds-reg 16 SUB ;

: jit-start-context ( -- ) ;
    ! Create the new context in return-reg. Have to save context
    ! twice, first before calling new_context() which may GC,
    ! and again after popping the two parameters from the stack.
    ! jit-save-context
    ! vm-reg "new_context" jit-call-1arg

    ! jit-pop-quot-and-param
    ! jit-save-context
    ! return-reg jit-switch-context
    ! jit-push-param
    ! jit-jump-quot ;

: jit-delete-current-context ( -- ) ;
    ! vm-reg "delete_context" jit-call-1arg ;

[
    ! jit->r
    ! 0 CALL f rc-relative rel-word
    ! jit-r>
] JIT-DIP jit-define




[
    ! 0 [RIP+] EAX MOV rc-relative rel-safepoint
] JIT-SAFEPOINT jit-define

! # All arm.64 subprimitives
{
    { c-to-factor [
            ! Set up the datastack and retainstack registers
            ! and jump into the quotation


            ! write()
            ! 68 X8 MOVwi64
            ! X2 MOVwi64
            ! 0 SVC

            ! exit(42)

            ! 9999 BRK
            ! 42 X0 MOVwi64
            ! 93 X8 MOVwi64
            ! 0 SVC

            ! Rn Rd MOVr64 ! comment
            arg1 arg2 MOVr64
            vm-reg "begin_callback" jit-call-1arg

            return-reg arg1 MOVr64 ! arg1 is return
            jit-call-quot

            vm-reg "end_callback" jit-call-1arg
    ] }
} define-sub-primitives


! {
    ! ## Contexts
    ! { (set-context) [ jit-set-context ] }
    ! { (set-context-and-delete) [
    !     jit-delete-current-context
    !     jit-set-context
    ! ] }
    ! { (start-context) [ jit-start-context ] }
    ! { (start-context-and-delete) [ jit-start-context-and-delete ] }

    ! ## Entry points
    ! { c-to-factor [
    !     ! dst src MOV
    !     ! arg2 arg1 MOV
    !     ! vm-reg "begin_callback" jit-call-1arg

    !     ! ! call the quotation
    !     ! arg1 return-reg MOV
    !     ! jit-call-quot

    !     ! vm-reg "end_callback" jit-call-1arg

    !     [

    !         ! write()
    !         ! 68 X8 MOVwi64
    !         ! X2 MOVwi64
    !         ! 0 SVC

    !         ! exit(42)
    !         9999 BRK
    !         42 X0 MOVwi64
    !         93 X8 MOVwi64
    !         0 SVC

            

    !         ! Rn Rd MOVr64
    !         ! arg1 arg2 MOVr64
    !         ! vm-reg "begin_callback" jit-call-1arg

    !         ! return-reg arg1 MOVr64 ! arg1 is return
    !         ! jit-call-quot

    !         ! vm-reg "end_callback" jit-call-1arg

    !     ] assemble-arm %

    ! ] }
    ! { unwind-native-frames [ ] }

    ! ## Math
    ! { fixnum+ [ [ ADD ] "overflow_fixnum_add" jit-overflow ] }
    ! { fixnum- [ [ SUB ] "overflow_fixnum_subtract" jit-overflow ] }
    ! { fixnum* [
    !     ds-reg 8 SUB
    !     jit-save-context
    !     RCX ds-reg [] MOV
    !     RBX ds-reg 8 [+] MOV
    !     RBX tag-bits get SAR
    !     RAX RCX MOV
    !     RBX IMUL
    !     ds-reg [] RAX MOV
    !     [ JNO ]
    !     [
    !         arg1 RCX MOV
    !         arg1 tag-bits get SAR
    !         arg2 RBX MOV
    !         arg3 vm-reg MOV
    !         "overflow_fixnum_multiply" jit-call
    !     ]
    !     jit-conditional
    ! ] }

    ! ## Misc
    ! { fpu-state [
    !     RSP 2 SUB
    !     RSP [] FNSTCW
    !     FNINIT
    !     AX RSP [] MOV
    !     RSP 2 ADD
    ! ] }
    ! { set-fpu-state [
    !     RSP 2 SUB
    !     RSP [] arg1 16-bit-version-of MOV
    !     RSP [] FLDCW
    !     RSP 2 ADD
    ! ] }
    ! { set-callstack [
    !     ! Load callstack object
    !     arg4 ds-reg [] MOV
    !     ds-reg bootstrap-cell SUB
    !     ! Get ctx->callstack_bottom
    !     jit-load-context
    !     arg1 ctx-reg context-callstack-bottom-offset [+] MOV
    !     ! Get top of callstack object -- 'src' for memcpy
    !     arg2 arg4 callstack-top-offset [+] LEA
    !     ! Get callstack length, in bytes --- 'len' for memcpy
    !     arg3 arg4 callstack-length-offset [+] MOV
    !     arg3 tag-bits get SHR
    !     ! Compute new stack pointer -- 'dst' for memcpy
    !     arg1 arg3 SUB
    !     ! Install new stack pointer
    !     RSP arg1 MOV
    !     ! Call memcpy; arguments are now in the correct registers
    !     ! Create register shadow area for Win64
    !     RSP 32 SUB
    !     "factor_memcpy" jit-call
    !     ! Tear down register shadow area
    !     RSP 32 ADD
    !     ! Return with new callstack
    !     0 RET
    ! ] }
! } define-sub-primitives



! C to Factor entry point
[

    9999 BRK
    ! ! Optimizing compiler's side of callback accesses
    ! ! arguments that are on the stack via the frame pointer.
    ! ! On x86-32 fastcall, and x86-64, some arguments are passed
    ! ! in registers, and so the only registers that are safe for
    ! ! use here are frame-reg, nv-reg and vm-reg.
    ! frame-reg PUSH
    ! frame-reg stack-reg MOV

    ! -- ! fp is non-volatile

    ! ! Save all non-volatile registers
    ! nv-regs [ PUSH ] each

    -16 SP X18 X19 STP-pre
    -16 SP X20 X21 STP-pre
    -16 SP X22 X23 STP-pre
    -16 SP X24 X25 STP-pre
    -16 SP X26 X27 STP-pre
    -16 SP X28 X29 STP-pre
    -16 SP X30 STR-pre

    ! ! Load VM into vm-reg
    ! vm-reg 0 MOV 0 rc-absolute-cell rel-vm

    104 vm-reg LDR-literal

    ! ! Save old context
    ! nv-reg vm-reg vm-context-offset [+] MOV
    ! nv-reg PUSH

    vm-context-offset vm-reg ctx-reg LDR-uoff
    8 SP ctx-reg STRuoff64

    ! ! Switch over to the spare context
    ! nv-reg vm-reg vm-spare-context-offset [+] MOV
    ! vm-reg vm-context-offset [+] nv-reg MOV

    vm-spare-context-offset vm-reg ctx-reg LDR-uoff
    vm-context-offset vm-reg ctx-reg STRuoff64

    ! ! Save C callstack pointer
    ! nv-reg context-callstack-save-offset [+] stack-reg MOV

    0 stack-reg temp0 ADDi64 ! MOV temp0, stack-reg
    context-callstack-save-offset ctx-reg temp0 STRuoff64

    ! ! Load Factor stack pointers
    ! stack-reg nv-reg context-callstack-bottom-offset [+] MOV

    context-callstack-bottom-offset ctx-reg temp0 LDR-uoff
    0 temp0 stack-reg ADDi64 ! MOV stack-reg, temp0

    ! rs-reg nv-reg context-retainstack-offset [+] MOV
    ! ds-reg nv-reg context-datastack-offset [+] MOV

    context-retainstack-offset ctx-reg rs-reg LDR-uoff
    context-datastack-offset ctx-reg ds-reg LDR-uoff

    ! ! Call into Factor code
    ! link-reg 0 MOV f rc-absolute-cell rel-word
    ! link-reg CALL

    68 word-reg LDR-literal
    word-reg BLR

    ! ! Load C callstack pointer
    ! nv-reg vm-reg vm-context-offset [+] MOV
    ! stack-reg nv-reg context-callstack-save-offset [+] MOV

    vm-context-offset vm-reg ctx-reg LDR-uoff
    context-callstack-save-offset ctx-reg temp0 LDR-uoff
    0 temp0 stack-reg ADDi64 ! MOV stack-reg, temp0

    ! ! Load old context
    ! nv-reg POP
    ! vm-reg vm-context-offset [+] nv-reg MOV

    8 SP ctx-reg LDR-uoff
    vm-context-offset vm-reg ctx-reg STRuoff64

    ! ! Restore non-volatile registers
    ! nv-regs <reversed> [ POP ] each

    16 SP X30 LDR-post
    16 SP X28 X29 LDP-post
    16 SP X26 X27 LDP-post
    16 SP X24 X25 LDP-post
    16 SP X22 X23 LDP-post
    16 SP X20 X21 LDP-post
    16 SP X18 X19 LDP-post

    ! frame-reg POP

    ! ! Callbacks which return structs, or use stdcall/fastcall/thiscall,
    ! ! need a parameter here.

    ! ! See the comment for M\ x86.32 stack-cleanup in cpu.x86.32
    ! 0xffff RET f rc-absolute-2 rel-untagged

    f RET
    ! f rc-absolute-2 rel-untagged ! ?

    NOP NOP 0 rc-absolute-cell rel-vm
    NOP NOP f rc-absolute-cell rel-word

] CALLBACK-STUB jit-define

[
    ! ! load literal
    ! temp0 0 MOV f rc-absolute-cell rel-literal
    ! ! increment datastack pointer
    ! ds-reg bootstrap-cell ADD
    ! ! store literal on datastack
    ! ds-reg [] temp0 MOV
] JIT-PUSH-LITERAL jit-define

[
    ! 0 CALL f rc-relative rel-word-pic
] JIT-WORD-CALL jit-define

! The *-signal-handler subprimitives are special-cased in vm/quotations.cpp
! not to trigger generation of a stack frame, so they can
! peform their own prolog/epilog preserving registers.
!
! It is important that the total is 192/64 and that it matches the
! constants in vm/cpu-x86.*.hpp
: jit-signal-handler-prolog ( -- ) ;
    ! ! Return address already on stack -> 8/4 bytes.

    ! ! Push all registers. 15 regs/120 bytes on 64bit, 7 regs/28 bytes
    ! ! on 32bit -> 128/32 bytes.
    ! signal-handler-save-regs [ PUSH ] each

    ! ! Push flags -> 136/36 bytes
    ! PUSHF

    ! ! Register parameter area 32 bytes, unused on platforms other than
    ! ! windows 64 bit, but including it doesn't hurt. Plus
    ! ! alignment. LEA used so we don't dirty flags -> 192/64 bytes.
    ! stack-reg stack-reg 7 bootstrap-cells neg [+] LEA

    ! jit-load-vm ;

: jit-signal-handler-epilog ( -- ) ;
    ! stack-reg stack-reg 7 bootstrap-cells [+] LEA
    ! POPF
    ! signal-handler-save-regs reverse [ POP ] each ;

[
    ! ! load boolean
    ! temp0 ds-reg [] MOV
    ! ! pop boolean
    ! ds-reg bootstrap-cell SUB
    ! ! compare boolean with f
    ! temp0 \ f type-number CMP
    ! ! jump to true branch if not equal
    ! 0 JNE f rc-relative rel-word
    ! ! jump to false branch if equal
    ! 0 JMP f rc-relative rel-word
] JIT-IF jit-define


[
    ! jit->r
    ! 0 CALL f rc-relative rel-word
    ! jit-r>
] JIT-DIP jit-define

[
    ! jit-2>r
    ! 0 CALL f rc-relative rel-word
    ! jit-2r>
] JIT-2DIP jit-define

[
    ! jit-3>r
    ! 0 CALL f rc-relative rel-word
    ! jit-3r>
] JIT-3DIP jit-define

! [
!     ! load from stack
!     temp0 ds-reg [] MOV
!     ! pop stack
!     ds-reg bootstrap-cell SUB
! ]
! [ temp0 word-entry-point-offset [+] CALL ]
! [ temp0 word-entry-point-offset [+] JMP ]
! \ (execute) define-combinator-primitive

[
    ! temp0 ds-reg [] MOV
    ! ds-reg bootstrap-cell SUB
    ! temp0 word-entry-point-offset [+] JMP
] JIT-EXECUTE jit-define


! https://elixir.bootlin.com/linux/latest/source/arch/arm64/kernel/stacktrace.c#L22
[
    ! x64 ! stack-reg stack-frame-size bootstrap-cell - SUB


    ! : link-reg ( -- reg ) X30 ; ! LR
    ! : stack-frame-reg ( -- reg ) X29 ; ! FP

    ! ! make room for LR plus magic number of callback, 16byte align
    stack-frame-size bootstrap-cell 2 * + stack-reg stack-reg SUBi64
    ! link-reg X29 stack-reg STP
    ! -16 SP link-reg X29 STP-pre
    -16 SP link-reg stack-frame-reg STP-pre
] JIT-PROLOG jit-define

[
    ! x64 ! stack-reg stack-frame-size bootstrap-cell - ADD
    ! -16 SP link-reg X29 LDP-pre
    16 SP link-reg stack-frame-reg LDP-post
    stack-frame-size bootstrap-cell 2 * + stack-reg stack-reg ADDi64
] JIT-EPILOG jit-define

[
    f RET
] JIT-RETURN jit-define

! ! ! Polymorphic inline caches

! The PIC stubs are not permitted to touch pic-tail-reg.

! Load a value from a stack position
[
    ! temp1 ds-reg 0x7f [+] MOV f rc-absolute-1 rel-untagged
] PIC-LOAD jit-define

[
    ! temp1/32 tag-mask get AND
] PIC-TAG jit-define

[
    ! temp0 temp1 MOV
    ! temp1/32 tag-mask get AND
    ! temp1/32 tuple type-number CMP
    ! [ JNE ]
    ! [ temp1 temp0 tuple-class-offset [+] MOV ]
    ! jit-conditional
] PIC-TUPLE jit-define

[
    ! temp1/32 0x7f CMP f rc-absolute-1 rel-untagged
] PIC-CHECK-TAG jit-define

[
    ! 0 JE f rc-relative rel-word
] PIC-HIT jit-define

! ! ! Megamorphic caches

[
    ! ! class = ...
    ! temp0 temp1 MOV
    ! temp1/32 tag-mask get AND
    ! temp1/32 tag-bits get SHL
    ! temp1/32 tuple type-number tag-fixnum CMP
    ! [ JNE ]
    ! [ temp1 temp0 tuple-class-offset [+] MOV ]
    ! jit-conditional
    ! ! cache = ...
    ! temp0 0 MOV f rc-absolute-cell rel-literal
    ! ! key = hashcode(class)
    ! temp2 temp1 MOV
    ! bootstrap-cell 4 = [ temp2 1 SHR ] when
    ! ! key &= cache.length - 1
    ! temp2 mega-cache-size get 1 - bootstrap-cell * AND
    ! ! cache += array-start-offset
    ! temp0 array-start-offset ADD
    ! ! cache += key
    ! temp0 temp2 ADD
    ! ! if(get(cache) == class)
    ! temp0 [] temp1 CMP
    ! [ JNE ]
    ! [
    !     ! megamorphic_cache_hits++
    !     temp1 0 MOV rc-absolute-cell rel-megamorphic-cache-hits
    !     temp1 [] 1 ADD
    !     ! goto get(cache + bootstrap-cell)
    !     temp0 temp0 bootstrap-cell [+] MOV
    !     temp0 word-entry-point-offset [+] JMP
    !     ! fall-through on miss
    ! ] jit-conditional
] MEGA-LOOKUP jit-define

! Comparisons
: jit-compare ( insn -- ) drop ;
    ! ! load t
    ! temp3 0 MOV t rc-absolute-cell rel-literal
    ! ! load f
    ! temp1 \ f type-number MOV
    ! ! load first value
    ! temp0 ds-reg [] MOV
    ! ! adjust stack pointer
    ! ds-reg bootstrap-cell SUB
    ! ! compare with second value
    ! ds-reg [] temp0 CMP
    ! ! move t if true
    ! [ temp1 temp3 ] dip execute( dst src -- )
    ! ! store
    ! ds-reg [] temp1 MOV ;

! Math
: jit-math ( insn -- ) drop ;
    ! ! load second input
    ! temp0 ds-reg [] MOV
    ! ! pop stack
    ! ds-reg bootstrap-cell SUB
    ! ! compute result
    ! [ ds-reg [] temp0 ] dip execute( dst src -- ) ;

: jit-fixnum-/mod ( -- ) ;
    ! ! load second parameter
    ! temp1 ds-reg [] MOV
    ! ! load first parameter
    ! div-arg ds-reg bootstrap-cell neg [+] MOV
    ! ! make a copy
    ! mod-arg div-arg MOV
    ! ! sign-extend
    ! mod-arg bootstrap-cell-bits 1 - SAR
    ! ! divide
    ! temp1 IDIV ;

! # Rest of arm64 subprimitives
{
    ! ! ## Fixnums

    ! ! ### Add
    ! { fixnum+fast [ \ ADD jit-math ] }

    ! ! ### Bit stuff
    ! { fixnum-bitand [ \ AND jit-math ] }
    ! { fixnum-bitnot [
    !     ! complement
    !     ds-reg [] NOT
    !     ! clear tag bits
    !     ds-reg [] tag-mask get XOR
    ! ] }
    ! { fixnum-bitor [ \ OR jit-math ] }
    ! { fixnum-bitxor [ \ XOR jit-math ] }
    ! { fixnum-shift-fast [
    !     ! load shift count
    !     shift-arg ds-reg [] MOV
    !     ! untag shift count
    !     shift-arg tag-bits get SAR
    !     ! adjust stack pointer
    !     ds-reg bootstrap-cell SUB
    !     ! load value
    !     temp3 ds-reg [] MOV
    !     ! make a copy
    !     temp2 temp3 MOV
    !     ! compute positive shift value in temp2
    !     temp2 CL SHL
    !     shift-arg NEG
    !     ! compute negative shift value in temp3
    !     temp3 CL SAR
    !     temp3 tag-mask get bitnot AND
    !     shift-arg 0 CMP
    !     ! if shift count was negative, move temp0 to temp2
    !     temp2 temp3 CMOVGE
    !     ! push to stack
    !     ds-reg [] temp2 MOV
    ! ] }

    ! ! ### Comparisons
    ! { both-fixnums? [
    !     temp0 ds-reg [] MOV
    !     ds-reg bootstrap-cell SUB
    !     temp0 ds-reg [] OR
    !     temp0 tag-mask get TEST
    !     temp0 \ f type-number MOV
    !     temp1 1 tag-fixnum MOV
    !     temp0 temp1 CMOVE
    !     ds-reg [] temp0 MOV
    ! ] }
    ! { eq? [ \ CMOVE jit-compare ] }
    ! { fixnum> [ \ CMOVG jit-compare ] }
    ! { fixnum>= [ \ CMOVGE jit-compare ] }
    ! { fixnum< [ \ CMOVL jit-compare ] }
    ! { fixnum<= [ \ CMOVLE jit-compare ] }

    ! ! ### Div/mod
    ! { fixnum-mod [
    !     jit-fixnum-/mod
    !     ! adjust stack pointer
    !     ds-reg bootstrap-cell SUB
    !     ! push to stack
    !     ds-reg [] mod-arg MOV
    ! ] }
    ! { fixnum/i-fast [
    !     jit-fixnum-/mod
    !     ! adjust stack pointer
    !     ds-reg bootstrap-cell SUB
    !     ! tag it
    !     div-arg tag-bits get SHL
    !     ! push to stack
    !     ds-reg [] div-arg MOV
    ! ] }
    ! { fixnum/mod-fast [
    !     jit-fixnum-/mod
    !     ! tag it
    !     div-arg tag-bits get SHL
    !     ! push to stack
    !     ds-reg [] mod-arg MOV
    !     ds-reg bootstrap-cell neg [+] div-arg MOV
    ! ] }

    ! ! ### Mul
    ! { fixnum*fast [
    !     ! load second input
    !     temp0 ds-reg [] MOV
    !     ! pop stack
    !     ds-reg bootstrap-cell SUB
    !     ! load first input
    !     temp1 ds-reg [] MOV
    !     ! untag second input
    !     temp0 tag-bits get SAR
    !     ! multiply
    !     temp0 temp1 IMUL2
    !     ! push result
    !     ds-reg [] temp0 MOV
    ! ] }

    ! ! ### Sub
    ! { fixnum-fast [ \ SUB jit-math ] }

    ! ! ## Locals
    ! { drop-locals [
    !     ! load local count
    !     temp0 ds-reg [] MOV
    !     ! adjust stack pointer
    !     ds-reg bootstrap-cell SUB
    !     ! turn local number into offset
    !     fixnum>slot@
    !     ! decrement retain stack pointer
    !     rs-reg temp0 SUB
    ! ] }
    ! { get-local [
    !     ! load local number
    !     temp0 ds-reg [] MOV
    !     ! turn local number into offset
    !     fixnum>slot@
    !     ! load local value
    !     temp0 rs-reg temp0 [+] MOV
    !     ! push to stack
    !     ds-reg [] temp0 MOV
    ! ] }
    ! { load-local [ jit->r ] }

    ! ! ## Objects
    ! { slot [
    !     ! load slot number
    !     temp0 ds-reg [] MOV
    !     ! adjust stack pointer
    !     ds-reg bootstrap-cell SUB
    !     ! load object
    !     temp1 ds-reg [] MOV
    !     ! turn slot number into offset
    !     fixnum>slot@
    !     ! mask off tag
    !     temp1 tag-bits get SHR
    !     temp1 tag-bits get SHL
    !     ! load slot value
    !     temp0 temp1 temp0 [+] MOV
    !     ! push to stack
    !     ds-reg [] temp0 MOV
    ! ] }
    ! { string-nth-fast [
    !     ! load string index from stack
    !     temp0 ds-reg bootstrap-cell neg [+] MOV
    !     temp0 tag-bits get SHR
    !     ! load string from stack
    !     temp1 ds-reg [] MOV
    !     ! load character
    !     temp0 8-bit-version-of temp0 temp1 string-offset [++] MOV
    !     temp0 temp0 8-bit-version-of MOVZX
    !     temp0 tag-bits get SHL
    !     ! store character to stack
    !     ds-reg bootstrap-cell SUB
    !     ds-reg [] temp0 MOV
    ! ] }
    ! { tag [
    !     ! load from stack
    !     temp0 ds-reg [] MOV
    !     ! compute tag
    !     temp0/32 tag-mask get AND
    !     ! tag the tag
    !     temp0/32 tag-bits get SHL
    !     ! push to stack
    !     ds-reg [] temp0 MOV
    ! ] }

    ! ! ## Shufflers

    ! ! ### Drops
    ! { drop [ ds-reg bootstrap-cell SUB ] }
    ! { 2drop [ ds-reg 2 bootstrap-cells SUB ] }
    ! { 3drop [ ds-reg 3 bootstrap-cells SUB ] }
    ! { 4drop [ ds-reg 4 bootstrap-cells SUB ] }

    ! ! ### Dups
    ! { dup [
    !     temp0 ds-reg [] MOV
    !     ds-reg bootstrap-cell ADD
    !     ds-reg [] temp0 MOV
    ! ] }
    ! { 2dup [
    !     temp0 ds-reg [] MOV
    !     temp1 ds-reg bootstrap-cell neg [+] MOV
    !     ds-reg 2 bootstrap-cells ADD
    !     ds-reg [] temp0 MOV
    !     ds-reg bootstrap-cell neg [+] temp1 MOV
    ! ] }
    ! { 3dup [
    !     temp0 ds-reg [] MOV
    !     temp1 ds-reg -1 bootstrap-cells [+] MOV
    !     temp3 ds-reg -2 bootstrap-cells [+] MOV
    !     ds-reg 3 bootstrap-cells ADD
    !     ds-reg [] temp0 MOV
    !     ds-reg -1 bootstrap-cells [+] temp1 MOV
    !     ds-reg -2 bootstrap-cells [+] temp3 MOV
    ! ] }
    ! { 4dup [
    !     temp0 ds-reg [] MOV
    !     temp1 ds-reg -1 bootstrap-cells [+] MOV
    !     temp2 ds-reg -2 bootstrap-cells [+] MOV
    !     temp3 ds-reg -3 bootstrap-cells [+] MOV
    !     ds-reg 4 bootstrap-cells ADD
    !     ds-reg [] temp0 MOV
    !     ds-reg -1 bootstrap-cells [+] temp1 MOV
    !     ds-reg -2 bootstrap-cells [+] temp2 MOV
    !     ds-reg -3 bootstrap-cells [+] temp3 MOV
    ! ] }
    ! { dupd [
    !     temp0 ds-reg [] MOV
    !     temp1 ds-reg -1 bootstrap-cells [+] MOV
    !     ds-reg [] temp1 MOV
    !     ds-reg bootstrap-cell ADD
    !     ds-reg [] temp0 MOV
    ! ] }

    ! ! ### Misc shufflers
    ! { over [
    !     temp0 ds-reg -1 bootstrap-cells [+] MOV
    !     ds-reg bootstrap-cell ADD
    !     ds-reg [] temp0 MOV
    ! ] }
    ! { pick [
    !     temp0 ds-reg -2 bootstrap-cells [+] MOV
    !     ds-reg bootstrap-cell ADD
    !     ds-reg [] temp0 MOV
    ! ] }

    ! ! ### Nips
    ! { nip [
    !     temp0 ds-reg [] MOV
    !     ds-reg bootstrap-cell SUB
    !     ds-reg [] temp0 MOV
    ! ] }
    ! { 2nip [
    !     temp0 ds-reg [] MOV
    !     ds-reg 2 bootstrap-cells SUB
    !     ds-reg [] temp0 MOV
    ! ] }

    ! ! ### Swaps
    ! { -rot [
    !     temp0 ds-reg [] MOV
    !     temp1 ds-reg -1 bootstrap-cells [+] MOV
    !     temp3 ds-reg -2 bootstrap-cells [+] MOV
    !     ds-reg -2 bootstrap-cells [+] temp0 MOV
    !     ds-reg -1 bootstrap-cells [+] temp3 MOV
    !     ds-reg [] temp1 MOV
    ! ] }
    ! { rot [
    !     temp0 ds-reg [] MOV
    !     temp1 ds-reg -1 bootstrap-cells [+] MOV
    !     temp3 ds-reg -2 bootstrap-cells [+] MOV
    !     ds-reg -2 bootstrap-cells [+] temp1 MOV
    !     ds-reg -1 bootstrap-cells [+] temp0 MOV
    !     ds-reg [] temp3 MOV
    ! ] }
    ! { swap [
    !     temp0 ds-reg [] MOV
    !     temp1 ds-reg bootstrap-cell neg [+] MOV
    !     ds-reg bootstrap-cell neg [+] temp0 MOV
    !     ds-reg [] temp1 MOV
    ! ] }
    ! { swapd [
    !     temp0 ds-reg -1 bootstrap-cells [+] MOV
    !     temp1 ds-reg -2 bootstrap-cells [+] MOV
    !     ds-reg -2 bootstrap-cells [+] temp0 MOV
    !     ds-reg -1 bootstrap-cells [+] temp1 MOV
    ! ] }

    ! ! ## Signal handling
    ! { leaf-signal-handler [
    !     jit-signal-handler-prolog
    !     jit-save-context
    !     temp0 vm-reg vm-signal-handler-addr-offset [+] MOV
    !     temp0 CALL
    !     jit-signal-handler-epilog
    !     ! Pop the fake leaf frame along with our return address
    !     leaf-stack-frame-size bootstrap-cell - RET
    ! ] }
    ! { signal-handler [
    !     jit-signal-handler-prolog
    !     jit-save-context
    !     temp0 vm-reg vm-signal-handler-addr-offset [+] MOV
    !     temp0 CALL
    !     jit-signal-handler-epilog
    !     0 RET
    ! ] }
} define-sub-primitives

[ "bootstrap.arm.64" forget-vocab ] with-compilation-unit
