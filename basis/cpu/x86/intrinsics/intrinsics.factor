! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays alien.accessors
compiler.backend kernel kernel.private math memory namespaces
make sequences words system layouts combinators math.order
math.private alien alien.c-types slots.private cpu.x86.assembler
cpu.x86.assembler.private locals compiler.backend
compiler.codegen.fixup compiler.constants compiler.intrinsics
compiler.cfg.builder compiler.cfg.registers compiler.cfg.stacks
compiler.cfg.templates compiler.codegen ;
IN: cpu.x86.intrinsics

! Type checks
\ tag [
    "in" operand tag-mask get AND
    "in" operand %tag-fixnum
] T{ template
    { input { { f "in" } } }
    { output { "in" } }
} define-intrinsic

! Slots
\ slot {
    ! Slot number is literal and the tag is known
    {
        [ "val" operand %slot-literal-known-tag MOV ] T{ template
            { input { { f "obj" known-tag } { small-slot "n" } } }
            { scratch { { f "val" } } }
            { output { "val" } }
        }
    }
    ! Slot number is literal
    {
        [ "obj" operand %slot-literal-any-tag MOV ] T{ template
            { input { { f "obj" } { small-slot "n" } } }
            { output { "obj" } }
        }
    }
    ! Slot number in a register
    {
        [ "obj" operand %slot-any MOV ] T{ template
            { input { { f "obj" } { f "n" } } }
            { output { "obj" } }
            { clobber { "n" } }
        }
    }
} define-intrinsics

\ (set-slot) {
    ! Slot number is literal and the tag is known
    {
        [ %slot-literal-known-tag "val" operand MOV ] T{ template
            { input { { f "val" } { f "obj" known-tag } { small-slot "n" } } }
            { scratch { { f "scratch" } } }
            { clobber { "obj" } }
        }
    }
    ! Slot number is literal
    {
        [ %slot-literal-any-tag "val" operand MOV ] T{ template
            { input { { f "val" } { f "obj" } { small-slot "n" } } }
            { scratch { { f "scratch" } } }
            { clobber { "obj" } }
        }
    }
    ! Slot number in a register
    {
        [ %slot-any "val" operand MOV ] T{ template
            { input { { f "val" } { f "obj" } { f "n" } } }
            { scratch { { f "scratch" } } }
            { clobber { "obj" "n" } }
        }
    }
} define-intrinsics

! Sometimes, we need to do stuff with operands which are
! less than the word size. Instead of teaching the register
! allocator about the different sized registers, with all
! the complexity this entails, we just push/pop a register
! which is guaranteed to be unused (the tempreg)
: small-reg cell 8 = RBX EBX ? ; inline
: small-reg-8 BL ; inline
: small-reg-16 BX ; inline
: small-reg-32 EBX ; inline

! Fixnums
: fixnum-op ( op hash -- pair )
    >r [ "x" operand "y" operand ] swap suffix r> 2array ;

: fixnum-value-op ( op -- pair )
    T{ template
        { input { { f "x" } { small-tagged "y" } } }
        { output { "x" } }
    } fixnum-op ;

: fixnum-register-op ( op -- pair )
    T{ template
        { input { { f "x" } { f "y" } } }
        { output { "x" } }
    } fixnum-op ;

: define-fixnum-op ( word op -- )
    [ fixnum-value-op ] keep fixnum-register-op
    2array define-intrinsics ;

{
    { fixnum+fast ADD }
    { fixnum-fast SUB }
    { fixnum-bitand AND }
    { fixnum-bitor OR }
    { fixnum-bitxor XOR }
} [
    first2 define-fixnum-op
] each

\ fixnum-bitnot [
    "x" operand NOT
    "x" operand tag-mask get XOR
] T{ template
    { input { { f "x" } } }
    { output { "x" } }
} define-intrinsic

\ fixnum*fast {
    {
        [
            "x" operand "y" get IMUL2
        ] T{ template
            { input { { f "x" } { [ small-tagged? ] "y" } } }
            { output { "x" } }
        }
    } {
        [
            "out" operand "x" operand MOV
            "out" operand %untag-fixnum
            "y" operand "out" operand IMUL2
        ] T{ template
            { input { { f "x" } { f "y" } } }
            { scratch { { f "out" } } }
            { output { "out" } }
        }
    }
} define-intrinsics

: %untag-fixnums ( seq -- )
    [ %untag-fixnum ] unique-operands ;

\ fixnum-shift-fast [
    "x" operand "y" get
    dup 0 < [ neg SAR ] [ SHL ] if
    ! Mask off low bits
    "x" operand %untag
] T{ template
    { input { { f "x" } { [ ] "y" } } }
    { output { "x" } }
} define-intrinsic

: overflow-check ( word -- )
    "end" define-label
    "z" operand "x" operand MOV
    "z" operand "y" operand pick execute
    ! If the previous arithmetic operation overflowed, then we
    ! turn the result into a bignum and leave it in EAX.
    "end" get JNO
    ! There was an overflow. Recompute the original operand.
    { "y" "x" } %untag-fixnums
    "x" operand "y" operand rot execute
    "z" operand "x" operand "y" operand %allot-bignum-signed-1
    "end" resolve-label ; inline

: overflow-template ( word insn -- )
    [ overflow-check ] curry T{ template
        { input { { f "x" } { f "y" } } }
        { scratch { { f "z" } } }
        { output { "z" } }
        { clobber { "x" "y" } }
        { gc t }
    } define-intrinsic ;

\ fixnum+ \ ADD overflow-template
\ fixnum- \ SUB overflow-template

: fixnum-jump ( op inputs -- pair )
    >r [ "x" operand "y" operand CMP ] swap suffix r> 2array ;

: fixnum-value-jump ( op -- pair )
    { { f "x" } { [ small-tagged? ] "y" } } fixnum-jump ;

: fixnum-register-jump ( op -- pair )
    { { f "x" } { f "y" } } fixnum-jump ;

: define-fixnum-jump ( word op -- )
    [ fixnum-value-jump ] keep fixnum-register-jump
    2array define-if-intrinsics ;

{
    { fixnum< JL }
    { fixnum<= JLE }
    { fixnum> JG }
    { fixnum>= JGE }
    { eq? JE }
} [
    first2 define-fixnum-jump
] each

\ fixnum>bignum [
    "x" operand %untag-fixnum
    "x" operand dup "scratch" operand %allot-bignum-signed-1
] T{ template
    { input { { f "x" } } }
    { scratch { { f "scratch" } } }
    { output { "x" } }
    { gc t }
} define-intrinsic

\ bignum>fixnum [
    "nonzero" define-label
    "positive" define-label
    "end" define-label
    "x" operand %untag
    "y" operand "x" operand cell [+] MOV
     ! if the length is 1, its just the sign and nothing else,
     ! so output 0
    "y" operand 1 tag-fixnum CMP
    "nonzero" get JNE
    "y" operand 0 MOV
    "end" get JMP
    "nonzero" resolve-label
    ! load the value
    "y" operand "x" operand 3 cells [+] MOV
    ! load the sign
    "x" operand "x" operand 2 cells [+] MOV
    ! is the sign negative?
    "x" operand 0 CMP
    "positive" get JE
    "y" operand -1 IMUL2
    "positive" resolve-label
    "y" operand 3 SHL
    "end" resolve-label
] T{ template
    { input { { f "x" } } }
    { scratch { { f "y" } } }
    { clobber { "x" } }
    { output { "y" } }
} define-intrinsic

! User environment
: %userenv ( -- )
    "x" operand 0 MOV
    "userenv" f rc-absolute-cell rel-dlsym
    "n" operand fixnum>slot@
    "n" operand "x" operand ADD ;

\ getenv [
    %userenv  "n" operand dup [] MOV
] T{ template
    { input { { f "n" } } }
    { scratch { { f "x" } } }
    { output { "n" } }
} define-intrinsic

\ setenv [
    %userenv  "n" operand [] "val" operand MOV
] T{ template
    { input { { f "val" } { f "n" } } }
    { scratch { { f "x" } } }
    { clobber { "n" } }
} define-intrinsic

! Alien intrinsics
: %alien-accessor ( quot -- )
    "offset" operand %untag-fixnum
    "offset" operand "alien" operand ADD
    "offset" operand [] swap call ; inline

: %alien-integer-get ( quot reg -- )
    small-reg PUSH
    swap %alien-accessor
    "value" operand small-reg MOV
    "value" operand %tag-fixnum
    small-reg POP ; inline

: alien-integer-get-template
    T{ template
        { input {
            { unboxed-c-ptr "alien" c-ptr }
            { f "offset" fixnum }
        } }
        { scratch { { f "value" } } }
        { output { "value" } }
        { clobber { "offset" } }
    } ;

: define-getter ( word quot reg -- )
    [ %alien-integer-get ] 2curry
    alien-integer-get-template
    define-intrinsic ;

: define-unsigned-getter ( word reg -- )
    [ small-reg dup XOR MOV ] swap define-getter ;

: define-signed-getter ( word reg -- )
    [ [ >r MOV small-reg r> MOVSX ] curry ] keep define-getter ;

: %alien-integer-set ( quot reg -- )
    small-reg PUSH
    small-reg "value" operand MOV
    small-reg %untag-fixnum
    swap %alien-accessor
    small-reg POP ; inline

: alien-integer-set-template
    T{ template
        { input {
            { f "value" fixnum }
            { unboxed-c-ptr "alien" c-ptr }
            { f "offset" fixnum }
        } }
        { clobber { "value" "offset" } }
    } ;

: define-setter ( word reg -- )
    [ swap MOV ] swap
    [ %alien-integer-set ] 2curry
    alien-integer-set-template
    define-intrinsic ;

\ alien-unsigned-1 small-reg-8 define-unsigned-getter
\ set-alien-unsigned-1 small-reg-8 define-setter

\ alien-signed-1 small-reg-8 define-signed-getter
\ set-alien-signed-1 small-reg-8 define-setter

\ alien-unsigned-2 small-reg-16 define-unsigned-getter
\ set-alien-unsigned-2 small-reg-16 define-setter

\ alien-signed-2 small-reg-16 define-signed-getter
\ set-alien-signed-2 small-reg-16 define-setter

\ alien-cell [
    "value" operand [ MOV ] %alien-accessor
] T{ template
    { input {
        { unboxed-c-ptr "alien" c-ptr }
        { f "offset" fixnum }
    } }
    { scratch { { unboxed-alien "value" } } }
    { output { "value" } }
    { clobber { "offset" } }
} define-intrinsic

\ set-alien-cell [
    "value" operand [ swap MOV ] %alien-accessor
] T{ template
    { input {
        { unboxed-c-ptr "value" pinned-c-ptr }
        { unboxed-c-ptr "alien" c-ptr }
        { f "offset" fixnum }
    } }
    { clobber { "offset" } }
} define-intrinsic
