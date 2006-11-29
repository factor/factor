! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: alien assembler generic kernel kernel-internals math
memory namespaces sequences words ;

: code-format cell ; inline

! PowerPC register assignments
! r3-r10 integer vregs
! f0-f13 float vregs
! r11, r12 scratch
! r14 data stack
! r15 call stack

! Stack layout:

! Mach-O -vs- Linux/PPC
: stack@ macosx? 24 8 ? + ;
: lr@ macosx? 8 4 ? + ;

M: int-regs return-reg drop 3 ;
M: int-regs fastcall-regs drop { 3 4 5 6 7 8 9 10 } ;
M: int-regs vregs drop { 3 4 5 6 7 8 9 10 } ;

M: float-regs return-reg drop 1 ;
M: float-regs fastcall-regs drop { 1 2 3 4 5 6 7 8 } ;
M: float-regs vregs drop { 0 1 2 3 4 5 6 7 8 9 10 11 12 13 } ;

GENERIC: loc>operand ( loc -- reg n )

M: ds-loc loc>operand ds-loc-n cells neg 14 swap ;
M: cs-loc loc>operand cs-loc-n cells neg 15 swap ;

M: immediate load-literal
    [ v>operand ] 2apply LOAD ;

M: object load-literal
    v>operand
    [ 0 swap LOAD32 rel-absolute-2/2 rel-literal ] keep
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
    0 3 LOAD32 rel-absolute-2/2 rel-word ;

: %call ( label -- )
    #! Far C call for primitives, near C call for compiled defs.
    dup (compile)
    dup primitive? [ word-addr  3 MTLR  BLRL ] [ BL ] if ;

: %jump-label ( label -- )
    #! For tail calls. IP not saved on C stack.
    dup primitive? [ word-addr  3 MTCTR  BCTR ] [ B ] if ;

: %jump ( label -- )
    %epilogue dup (compile) %jump-label ;

: %jump-t ( label -- )
    0 "flag" operand object-tag CMPI BNE ;

: %dispatch ( -- )
    #! The value 20 is a magic number. It is the length of the
    #! instruction sequence that follows
    [
        "n" operand dup 1 SRAWI
        0 "scratch" operand LOAD32 rel-absolute-2/2 rel-here
        "n" operand dup "scratch" operand ADD
        "n" operand dup 20 LWZ
        "n" operand MTLR
        BLR
    ] H{
        { +input+ { { f "n" } } }
        { +scratch+ { { f "scratch" } } }
    } with-template ;

: %target ( label -- ) 0 , rel-absolute-cell rel-label ;

: %return ( -- ) %epilogue BLR ;

: compile-dlsym ( symbol dll register -- )
    0 swap LOAD32 rel-absolute-2/2 rel-dlsym ;

M: int-regs (%peek)
    drop >r v>operand r> loc>operand LWZ ;

M: float-regs (%peek)
    drop fp-scratch v>operand swap loc>operand LWZ
    fp-scratch [ v>operand ] 2apply float-offset LFD ;

M: int-regs (%replace)
    drop >r v>operand r> loc>operand STW ;

: %move-int>int ( dst src -- )
    [ v>operand ] 2apply MR ;

: %move-int>float ( dst src -- )
    [ v>operand ] 2apply float-offset LFD ;

: %inc-d ( n -- ) 14 14 rot cells ADDI ;

: %inc-r ( n -- ) 15 15 rot cells ADDI ;

M: int-regs %freg>stack drop 1 rot stack@ STW ;

M: int-regs %stack>freg drop 1 rot stack@ LWZ ;

: STF float-regs-size 4 = [ STFS ] [ STFD ] if ;

M: float-regs %freg>stack >r 1 rot stack@ r> STF ;

: LF float-regs-size 4 = [ LFS ] [ LFD ] if ;

M: float-regs %stack>freg >r 1 rot stack@ r> LF ;

M: stack-params %stack>freg
    drop 2dup = [
        2drop
    ] [
        >r 0 1 rot stack@ LWZ 0 1 r> stack@ STW
    ] if ;

M: stack-params %freg>stack
   >r stack-increment + swap r> %stack>freg ;

: %unbox ( n reg-class func -- )
    ! Call the unboxer
    f %alien-invoke
    ! Store the return value on the C stack
    [ return-reg ] keep %freg>stack ;

: %box ( n reg-class func -- )
    ! If the source is a stack location, load it into freg #0.
    ! If the source is f, then we assume the value is already in
    ! freg #0.
    pick [
        >r [ fastcall-regs first ] keep %stack>freg r>
    ] [
        2nip
    ] if
    f %alien-invoke ;

: struct-ptr/size ( n size func -- )
    ! Load destination address
    >r >r 3 1 rot stack@ ADDI r>
    ! Load struct size
    4 LI
    r> f %alien-invoke ;

: %unbox-struct ( n size -- )
    "unbox_value_struct" struct-ptr/size ;

: %box-struct ( n size -- )
    "box_value_struct" struct-ptr/size ;

: %alien-invoke ( symbol dll -- )
    12 [ compile-dlsym ] keep MTLR BLRL ;

: %alien-callback ( quot -- )
    0 <int-vreg> load-literal "run_callback" f %alien-invoke ;

: %prepare-alien-indirect ( -- )
    "unbox_alien" f %alien-invoke
    3 1 12 STW ;

: %alien-indirect ( -- )
    12 1 12 LWZ
    12 MTLR BLRL ;

: save-return 0 swap [ return-reg ] keep %freg>stack ;
: load-return 0 swap [ return-reg ] keep %stack>freg ;

: %callback-value ( reg-class func -- )
    ! Call the unboxer
    f %alien-invoke
    ! Save return register
    dup save-return
    ! Restore data/callstacks
    "unnest_stacks" f %alien-invoke
    ! Restore return register
    load-return ;

: %cleanup ( n -- ) drop ;

: %untag ( dest src -- ) 0 0 31 tag-bits - RLWINM ;

: %tag-fixnum ( src dest -- ) tag-bits SLWI ;

: %untag-fixnum ( src dest -- ) tag-bits SRAWI ;
