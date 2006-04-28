! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: alien assembler generic kernel kernel-internals math
memory namespaces sequences words ;

! PowerPC register assignments
! r3-r10 vregs
! r11 linkage
! r14 data stack
! r15 call stack

: vregs { 3 4 5 6 7 8 9 10 } ; inline

M: int-regs return-reg drop 3 ;
M: int-regs fastcall-regs drop { 3 4 5 6 7 8 9 10 } ;

M: float-regs return-reg drop 1 ;
M: float-regs fastcall-regs drop { 1 2 3 4 5 6 7 8 } ;

! Mach-O -vs- Linux/PPC
: stack@ macosx? 24 8 ? + ;
: lr@ macosx? 8 4 ? + ;

GENERIC: loc>operand

M: ds-loc loc>operand ds-loc-n cells neg 14 swap ;
M: cs-loc loc>operand cs-loc-n cells neg 15 swap ;

M: immediate load-literal ( literal vreg -- )
    >r address r> v>operand LOAD ;

M: object load-literal ( literal vreg -- )
    v>operand swap
    add-literal over
    LOAD32 rel-2/2 rel-address
    dup 0 LWZ ;

: stack-increment \ stack-reserve get 32 max stack@ 16 align ;

: %prologue ( n -- )
    \ stack-reserve set
    1 1 stack-increment neg STWU
    0 MFLR
    0 1 stack-increment lr@ STW ;

: %epilogue ( -- )
    #! At the end of each word that calls a subroutine, we store
    #! the previous link register value in r0 by popping it off
    #! the stack, set the link register to the contents of r0,
    #! and jump to the link register.
    0 1 stack-increment lr@ LWZ
    1 1 stack-increment ADDI
    0 MTLR ;

: word-addr ( word -- )
    #! Load a word address into r3.
    dup word-xt 3 LOAD32  rel-2/2 rel-word ;

: %call ( label -- )
    #! Far C call for primitives, near C call for compiled defs.
    dup postpone-word
    dup primitive? [ word-addr  3 MTLR  BLRL ] [ BL ] if ;

: %jump-label ( label -- )
    #! For tail calls. IP not saved on C stack.
    dup primitive? [ word-addr  3 MTCTR  BCTR ] [ B ] if ;

: %jump ( label -- )
    %epilogue dup postpone-word %jump-label ;

: %jump-t ( label vreg -- )
    0 swap v>operand f address CMPI BNE ;

: %dispatch ( vreg -- )
    v>operand dup dup 1 SRAWI
    ! The value 24 is a magic number. It is the length of the
    ! instruction sequence that follows to be generated.
    compiled-offset 24 + 11 LOAD32  rel-2/2 rel-address
    dup dup 11 ADD
    dup dup 0 LWZ
    MTLR
    BLR ;

: %return ( -- ) %epilogue BLR ;

: %peek ( vreg loc -- ) >r v>operand r> loc>operand LWZ ;

: %replace ( vreg loc -- ) >r v>operand r> loc>operand STW ;

: %inc-d ( n -- ) 14 14 rot cells ADDI ;

: %inc-r ( n -- ) 15 15 rot cells ADDI ;

GENERIC: freg>stack ( stack reg reg-class -- )

GENERIC: stack>freg ( stack reg reg-class -- )

M: int-regs freg>stack drop 1 rot stack@ STW ;

M: int-regs stack>freg drop 1 rot stack@ LWZ ;

: STF float-regs-size 4 = [ STFS ] [ STFD ] if ;

M: float-regs freg>stack >r 1 rot stack@ r> STF ;

: LF float-regs-size 4 = [ LFS ] [ LFD ] if ;

M: float-regs stack>freg >r 1 rot stack@ r> LF ;

M: stack-params stack>freg
    drop 2dup = [
        2drop
    ] [
        >r 0 1 rot stack@ LWZ 0 1 r> stack@ STW
    ] if ;

M: stack-params freg>stack
   >r stack-increment + swap r> stack>freg ;

: (%move) [ fastcall-regs nth ] keep ;

: %stack>freg ( n reg reg-class -- ) (%move) stack>freg ;

: %freg>stack ( n reg reg-class -- ) (%move) freg>stack ;

: %unbox ( n reg-class func -- )
    ! Call the unboxer
    f %alien-invoke
    ! Store the return value on the C stack
    [ return-reg ] keep freg>stack ;

: %box ( n reg-class func -- )
    ! If the source is a stack location, load it into freg #0.
    ! If the source is f, then we assume the value is already in
    ! freg #0.
    pick [
        >r [ fastcall-regs first ] keep stack>freg r>
    ] [
        2nip
    ] if
    f %alien-invoke ;

: struct-ptr/size ( n reg-class size func -- )
    rot drop
    ! Load destination address
    >r >r 3 1 rot stack@ ADDI r>
    ! Load struct size
    4 LI
    r> f %alien-invoke ;

: %unbox-struct ( n reg-class size -- )
    "unbox_value_struct" struct-ptr/size ;

: %box-struct ( n reg-class size -- )
    "box_value_struct" struct-ptr/size ;

: compile-dlsym ( symbol dll register -- )
    >r 2dup dlsym r> LOAD32 rel-2/2 rel-dlsym ;

: %alien-invoke ( symbol dll -- )
    11 [ compile-dlsym ] keep MTLR BLRL ;

: %alien-callback ( quot -- )
    T{ vreg f 0 } load-literal "run_callback" f %alien-invoke ;

: save-return 0 swap [ return-reg ] keep freg>stack ;
: load-return 0 swap [ return-reg ] keep stack>freg ;

: %callback-value ( reg-class func -- )
    ! Call the unboxer
    f %alien-invoke
    ! Save return register
    dup save-return
    ! Restore data/callstacks
    "unnest_stacks" f %alien-invoke
    ! Restore return register
    load-return ;
