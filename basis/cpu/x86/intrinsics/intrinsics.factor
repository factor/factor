! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays alien.accessors kernel
kernel.private math memory namespaces make sequences words
system layouts combinators math.order math.private alien
alien.c-types slots.private locals cpu.architecture
cpu.x86.assembler cpu.x86.assembler.private cpu.x86.architecture
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
: %constant-slot ( -- op )
    "obj" operand
    "n" literal cells "tag" literal - [+] ;

: %computed-slot ( -- op )
    "n" operand fixnum>slot@
    "n" operand "obj" operand ADD
    "n" operand "tag" literal neg [+] ;

\ (slot) {
    {
        [ "val" operand %constant-slot MOV ] T{ template
            { input { { f "obj" } { small-slot "n" } { small-slot "tag" } } }
            { scratch { { f "val" } } }
            { output { "val" } }
        }
    }
    {
        [ "val" operand %computed-slot MOV ] T{ template
            { input { { f "obj" } { f "n" } { small-slot "tag" } } }
            { scratch { { f "val" } } }
            { output { "val" } }
            { clobber { "n" } }
        }
    }
} define-intrinsics

\ (set-slot) {
    {
        [ %constant-slot "val" operand MOV ] T{ template
            { input { { f "val" } { f "obj" } { small-slot "n" } { small-slot "tag" } } }
            { clobber { "obj" } }
        }
    }
    {
        [ %computed-slot "val" operand MOV ] T{ template
            { input { { f "val" } { f "obj" } { small-slot "n" } { small-slot "tag" } } }
            { clobber { "n" } }
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
            "x" operand "y" literal IMUL2
        ] T{ template
            { input { { f "x" } { small-tagged "y" } } }
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

\ fixnum-shift-fast [
    "x" operand "y" literal
    dup 0 < [ neg SAR ] [ SHL ] if
    ! Mask off low bits
    "x" operand %untag
] T{ template
    { input { { f "x" } { small-tagged "y" } } }
    { output { "x" } }
} define-intrinsic

: fixnum-jump ( op inputs -- pair )
    >r [ "x" operand "y" operand CMP ] swap suffix r> 2array ;

: fixnum-value-jump ( op -- pair )
    { { f "x" } { small-tagged "y" } } fixnum-jump ;

: fixnum-register-jump ( op -- pair )
    { { f "x" } { f "y" } } fixnum-jump ;

: define-fixnum-jump ( word op -- )
    [ fixnum-value-jump ] [ fixnum-register-jump ] bi
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
