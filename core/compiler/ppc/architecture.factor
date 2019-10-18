! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generator
USING: alien assembler-ppc compiler generic kernel
kernel-internals math memory namespaces sequences words
hashtables ;

: code-format 4 ; inline

! PowerPC register assignments
! r3-r10 integer vregs
! f0-f13 float vregs
! r11, r12 scratch
! r14 data stack
! r15 retain stack

! Stack layout:

: param@
    os H{
        { "linux" 8 }
        { "macosx" 24 }
    } hash + ; inline

: local@ param@ 32 + ; inline

: lr@
    os H{
        { "linux" 4 }
        { "macosx" 8 }
    } hash + ; inline

M: int-regs return-reg drop 3 ;
M: int-regs param-regs drop { 3 4 5 6 7 8 9 10 } ;
M: int-regs vregs drop { 3 4 5 6 7 8 9 10 } ;

M: float-regs return-reg drop 1 ;

M: float-regs param-regs 
    drop os H{
        { "macosx" { 1 2 3 4 5 6 7 8 9 10 11 12 13 } }
        { "linux" { 1 2 3 4 5 6 7 8 } }
    } hash ;

M: float-regs vregs drop { 0 1 2 3 4 5 6 7 8 9 10 11 12 13 } ;

GENERIC: loc>operand ( loc -- reg n )

M: ds-loc loc>operand ds-loc-n cells neg 14 swap ;
M: rs-loc loc>operand rs-loc-n cells neg 15 swap ;

M: immediate load-literal
    [ v>operand ] 2apply LOAD ;

M: object load-literal
    v>operand
    [ 0 swap LOAD32 rc-absolute-ppc-2/2 rel-literal ] keep
    dup 0 LWZ ;

: stack-increment
    \ stack-frame-size get local@ 16 align ;

: %prologue ( -- )
    [
        1 1 stack-increment neg STWU
        0 MFLR
        0 1 stack-increment lr@ STW
    ] if-stack-frame ;

: %epilogue ( -- )
    #! At the end of each word that calls a subroutine, we store
    #! the previous link register value in r0 by popping it off
    #! the stack, set the link register to the contents of r0,
    #! and jump to the link register.
    [
        0 1 stack-increment lr@ LWZ
        1 1 stack-increment ADDI
        0 MTLR
    ] if-stack-frame ;

: primitive-addr ( word -- )
    #! Load a word address into r3.
    3 17 rot word-primitive cells LWZ ;

: %call ( label -- )
    #! Far C call for primitives, near C call for compiled defs.
    dup (compile)
    dup primitive? [ primitive-addr  3 MTLR  BLRL ] [ BL ] if ;

: %jump-label ( label -- )
    #! For tail calls. IP not saved on C stack.
    #! WARNING: don't clobber LR here!
    dup primitive? [ primitive-addr  3 MTCTR  BCTR ] [ B ] if ;

: %jump ( label -- )
    %epilogue dup (compile) %jump-label ;

: %jump-t ( label -- )
    0 "flag" operand object-tag CMPI BNE ;

: (%dispatch) ( word-table# -- )
    "n" operand dup 1 SRAWI
    0 "scratch" operand LOAD32 rc-absolute-ppc-2/2 rel-dispatch
    "n" operand dup "scratch" operand ADD
    "n" operand dup 0 LWZ ;

: dispatch-template ( word-table# quot -- )
    [ >r (%dispatch)  "n" operand r> call ] H{
        { +input+ { { f "n" } } }
        { +scratch+ { { f "scratch" } } }
    } with-template ; inline

: %call-dispatch ( word-table# -- )
    [ MTLR BLRL ] dispatch-template ;

: %jump-dispatch ( word-table# -- )
    [ %epilogue MTCTR BCTR ] dispatch-template ;

: %return ( -- ) %epilogue BLR ;

: compile-dlsym ( symbol dll register -- )
    0 swap LOAD32 rc-absolute-ppc-2/2 rel-dlsym ;

M: int-regs (%peek)
    drop >r v>operand r> loc>operand LWZ ;

M: float-regs (%peek)
    drop
    11 swap loc>operand LWZ
    v>operand 11 float-offset LFD ;

M: int-regs (%replace)
    drop >r v>operand r> loc>operand STW ;

: %move-int>int ( dst src -- )
    [ v>operand ] 2apply MR ;

: %move-int>float ( dst src -- )
    [ v>operand ] 2apply float-offset LFD ;

: %inc-d ( n -- ) 14 14 rot cells ADDI ;

: %inc-r ( n -- ) 15 15 rot cells ADDI ;

M: int-regs %save-param-reg drop 1 rot local@ STW ;

M: int-regs %load-param-reg drop 1 rot local@ LWZ ;

: STF float-regs-size 4 = [ STFS ] [ STFD ] if ;

M: float-regs %save-param-reg >r 1 rot local@ r> STF ;

: LF float-regs-size 4 = [ LFS ] [ LFD ] if ;

M: float-regs %load-param-reg >r 1 rot local@ r> LF ;

M: stack-params %load-param-reg ( stack reg reg-class -- )
    drop >r 0 1 rot local@ LWZ 0 1 r> param@ STW ;

M: stack-params %save-param-reg ( stack reg reg-class -- )
    #! Funky. Read the parameter from the caller's stack frame.
    #! This word is used in callbacks
    drop
    0 1 rot param@ stack-increment + LWZ
    0 1 rot local@ STW ;

: %prepare-unbox ( -- )
    ! First parameter is top of stack
    3 14 0 LWZ
    14 14 4 SUBI ;

: %unbox ( n reg-class func -- )
    ! Value must be in r3
    ! Call the unboxer
    f %alien-invoke
    ! Store the return value on the C stack
    over [ [ return-reg ] keep %save-param-reg ] [ 2drop ] if ;

: %unbox-large-struct ( n size -- )
    ! Value must be in r3
    ! Compute destination address
    4 1 roll local@ ADDI
    ! Load struct size
    5 LI
    ! Call the function
    "to_value_struct" f %alien-invoke ;

: %box ( n reg-class func -- )
    ! If the source is a stack location, load it into freg #0.
    ! If the source is f, then we assume the value is already in
    ! freg #0.
    >r
    over [ 0 over param-reg swap %load-param-reg ] [ 2drop ] if
    r> f %alien-invoke ;

: temp@ stack-increment swap - ;

: struct-return@ ( size n -- n ) [ local@ ] [ temp@ ] ?if ;

: %prepare-box-struct ( size -- )
    #! Compute target address for value struct return
    3 1 rot f struct-return@ ADDI
    3 1 0 local@ STW ;

: %box-large-struct ( n size -- )
    #! If n = f, then we're boxing a returned struct
    [ swap struct-return@ ] keep
    ! Compute destination address
    3 1 roll ADDI
    ! Load struct size
    4 LI
    ! Call the function
    "box_value_struct" f %alien-invoke ;

: %alien-invoke ( symbol dll -- )
    12 [ compile-dlsym ] keep MTLR BLRL ;

: %alien-callback ( quot -- )
    0 <int-vreg> load-literal "run_callback" f %alien-invoke ;

: %prepare-alien-indirect ( -- )
    "unbox_alien" f %alien-invoke
    3 1 cell temp@ STW ;

: %alien-indirect ( -- )
    12 1 cell temp@ LWZ
    12 MTLR BLRL ;

: %callback-value ( ctype -- )
     ! Save top of data stack
     3 14 0 LWZ
     3 1 0 local@ STW
     ! Restore data/call/retain stacks
     "unnest_stacks" f %alien-invoke
     ! Restore top of data stack
     3 1 0 local@ LWZ
     ! Unbox former top of data stack to return registers
     unbox-return ;

: %cleanup ( alien-node -- ) drop ;

: %untag ( src dest -- ) 0 0 31 tag-bits - RLWINM ;

: %tag-fixnum ( src dest -- ) tag-bits SLWI ;

: %untag-fixnum ( src dest -- ) tag-bits SRAWI ;

: value-structs?
    #! On Linux/PPC, value structs are passed in the same way
    #! as reference structs, we just have to make a copy first.
    os "linux" = not ;

: small-enough? ( n -- ? ) -32768 32767 between? ;

: struct-small-enough? ( size -- ? ) drop f ;
