! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types cpu.ppc.assembler cpu.architecture generic
kernel kernel.private math memory namespaces sequences words
assocs generator generator.registers generator.fixup system
layouts math.functions classes words.private alien ;
IN: cpu.ppc.architecture

TUPLE: ppc-backend ;

M: ppc-backend code-format 4 ;

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
    } at + ; inline

: local@ param@ 32 + ; inline

: lr@
    os H{
        { "linux" 4 }
        { "macosx" 8 }
    } at + ; inline

M: temp-reg v>operand drop 11 ;

M: int-regs return-reg drop 3 ;
M: int-regs param-regs drop { 3 4 5 6 7 8 9 10 } ;
M: int-regs vregs drop { 3 4 5 6 7 8 9 10 } ;

M: float-regs return-reg drop 1 ;

M: float-regs param-regs 
    drop os H{
        { "macosx" { 1 2 3 4 5 6 7 8 9 10 11 12 13 } }
        { "linux" { 1 2 3 4 5 6 7 8 } }
    } at ;

M: float-regs vregs drop { 0 1 2 3 4 5 6 7 8 9 10 11 12 13 } ;

GENERIC: loc>operand ( loc -- reg n )

M: ds-loc loc>operand ds-loc-n cells neg 14 swap ;
M: rs-loc loc>operand rs-loc-n cells neg 15 swap ;

M: immediate load-literal
    [ v>operand ] 2apply LOAD ;

M: ppc-backend load-indirect ( obj reg -- )
    [ 0 swap LOAD32 rc-absolute-ppc-2/2 rel-literal ] keep
    dup 0 LWZ ;

M: ppc-backend stack-frame ( n -- i ) local@ 16 align ;

M: ppc-backend %prologue ( n -- )
    1 1 pick stack-frame neg STWU
    0 MFLR
    0 1 rot stack-frame lr@ STW ;

M: ppc-backend %epilogue ( n -- )
    #! At the end of each word that calls a subroutine, we store
    #! the previous link register value in r0 by popping it off
    #! the stack, set the link register to the contents of r0,
    #! and jump to the link register.
    0 1 pick stack-frame lr@ LWZ
    1 1 rot stack-frame ADDI
    0 MTLR ;

: compile-dlsym ( symbol dll register -- )
    0 swap LOAD32 rc-absolute-ppc-2/2 rel-dlsym ;

M: ppc-backend %profiler-prologue ( word -- )
    "end" define-label
    "profiling" f 12 compile-dlsym
    12 12 0 LWZ
    0 12 0 CMPI
    "end" get BEQ
    12 load-indirect
    11 12 profile-count-offset LWZ
    11 11 1 v>operand ADDI
    11 12 profile-count-offset STW
    "end" resolve-label ;

: primitive-addr ( word -- )
    #! Load a word address into r3.
    3 17 rot word-primitive cells LWZ ;

M: ppc-backend %call ( label -- )
    #! Far C call for primitives, near C call for compiled defs.
    dup primitive? [ primitive-addr  3 MTLR  BLRL ] [ BL ] if ;

M: ppc-backend %jump-label ( label -- )
    #! For tail calls. IP not saved on C stack.
    #! WARNING: don't clobber LR here!
    dup primitive? [ primitive-addr  3 MTCTR  BCTR ] [ B ] if ;

M: ppc-backend %jump-t ( label -- )
    0 "flag" operand object tag-number CMPI BNE ;

: (%dispatch) ( word-table# -- )
    "offset" operand "n" operand 1 SRAWI
    0 "base" operand LOAD32 rc-absolute-ppc-2/2 rel-dispatch
    "base" operand dup "offset" operand LWZX ;

: dispatch-template ( word-table# quot -- )
    [ >r (%dispatch)  "base" operand r> call ] H{
        { +input+ { { f "n" } } }
        { +scratch+ { { f "base" } { f "offset" } } }
    } with-template ; inline

M: ppc-backend %call-dispatch ( word-table# -- )
    [ MTLR BLRL ] dispatch-template ;

M: ppc-backend %jump-dispatch ( word-table# -- )
    [ %epilogue-later MTCTR BCTR ] dispatch-template ;

M: ppc-backend %return ( -- ) %epilogue-later BLR ;

M: ppc-backend %unwind drop %return ;

M: int-regs (%peek)
    drop >r v>operand r> loc>operand LWZ ;

M: float-regs (%peek)
    drop
    11 swap loc>operand LWZ
    v>operand 11 float-offset LFD ;

M: int-regs (%replace)
    drop >r v>operand r> loc>operand STW ;

M: ppc-backend %move-int>int ( dst src -- )
    [ v>operand ] 2apply MR ;

M: ppc-backend %move-int>float ( dst src -- )
    [ v>operand ] 2apply float-offset LFD ;

M: ppc-backend %inc-d ( n -- ) 14 14 rot cells ADDI ;

M: ppc-backend %inc-r ( n -- ) 15 15 rot cells ADDI ;

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
    0 1 rot param@ stack-frame* + LWZ
    0 1 rot local@ STW ;

M: ppc-backend %prepare-unbox ( -- )
    ! First parameter is top of stack
    3 14 0 LWZ
    14 14 4 SUBI ;

M: ppc-backend %unbox ( n reg-class func -- )
    ! Value must be in r3
    ! Call the unboxer
    f %alien-invoke
    ! Store the return value on the C stack
    over [ [ return-reg ] keep %save-param-reg ] [ 2drop ] if ;

M: ppc-backend %unbox-long-long ( n func -- )
    ! Value must be in r3:r4
    ! Call the unboxer
    f %alien-invoke
    ! Store the return value on the C stack
    [
        3 1 pick local@ STW
        4 1 rot cell + local@ STW
    ] when* ;

M: ppc-backend %unbox-large-struct ( n size -- )
    ! Value must be in r3
    ! Compute destination address
    4 1 roll local@ ADDI
    ! Load struct size
    5 LI
    ! Call the function
    "to_value_struct" f %alien-invoke ;

M: ppc-backend %box ( n reg-class func -- )
    ! If the source is a stack location, load it into freg #0.
    ! If the source is f, then we assume the value is already in
    ! freg #0.
    >r
    over [ 0 over param-reg swap %load-param-reg ] [ 2drop ] if
    r> f %alien-invoke ;

M: ppc-backend %box-long-long ( n func -- )
    >r [
        3 1 pick local@ LWZ
        4 1 rot cell + local@ LWZ
    ] when* r> f %alien-invoke ;

: temp@ stack-frame* swap - ;

: struct-return@ ( size n -- n ) [ local@ ] [ temp@ ] ?if ;

M: ppc-backend %prepare-box-struct ( size -- )
    #! Compute target address for value struct return
    3 1 rot f struct-return@ ADDI
    3 1 0 local@ STW ;

M: ppc-backend %box-large-struct ( n size -- )
    #! If n = f, then we're boxing a returned struct
    [ swap struct-return@ ] keep
    ! Compute destination address
    3 1 roll ADDI
    ! Load struct size
    4 LI
    ! Call the function
    "box_value_struct" f %alien-invoke ;

M: ppc-backend %alien-invoke ( symbol dll -- )
    12 [ compile-dlsym ] keep MTLR BLRL ;

M: ppc-backend %alien-callback ( quot -- )
    0 <int-vreg> load-literal "run_callback" f %alien-invoke ;

M: ppc-backend %prepare-alien-indirect ( -- )
    "unbox_alien" f %alien-invoke
    3 1 cell temp@ STW ;

M: ppc-backend %alien-indirect ( -- )
    12 1 cell temp@ LWZ
    12 MTLR BLRL ;

M: ppc-backend %callback-value ( ctype -- )
     ! Save top of data stack
     3 14 0 LWZ
     3 1 0 local@ STW
     ! Restore data/call/retain stacks
     "unnest_stacks" f %alien-invoke
     ! Restore top of data stack
     3 1 0 local@ LWZ
     ! Unbox former top of data stack to return registers
     unbox-return ;

M: ppc-backend %cleanup ( alien-node -- ) drop ;

: %untag ( src dest -- ) 0 0 31 tag-bits get - RLWINM ;

: %tag-fixnum ( src dest -- ) tag-bits get SLWI ;

: %untag-fixnum ( src dest -- ) tag-bits get SRAWI ;

M: ppc-backend value-structs?
    #! On Linux/PPC, value structs are passed in the same way
    #! as reference structs, we just have to make a copy first.
    os "linux" = not ;

M: ppc-backend fp-shadows-int? ( -- ? ) macosx? ;

M: ppc-backend small-enough? ( n -- ? ) -32768 32767 between? ;

M: ppc-backend struct-small-enough? ( size -- ? ) drop f ;

M: ppc-backend %box-small-struct
    drop "No small structs" throw ;

M: ppc-backend %unbox-small-struct
    drop "No small structs" throw ;

! Alien intrinsics
M: ppc-backend %unbox-byte-array ( quot src -- )
    "address" operand "alien" operand "offset" operand ADD
    "address" operand alien-offset
    roll call ;

M: ppc-backend %unbox-alien ( quot src -- )
    "address" operand "alien" operand alien-offset LWZ
    "address" operand dup "offset" operand ADD
    "address" operand 0
    roll call ;

M: ppc-backend %unbox-f ( quot src -- )
    "offset" operand 0
    roll call ;

M: ppc-backend %complex-alien-accessor ( quot src -- )
    "is-f" define-label
    "is-alien" define-label
    "end" define-label
    0 "alien" operand f v>operand CMPI
    "is-f" get BEQ
    "address" operand "alien" operand header-offset LWZ
    0 "address" operand alien type-number tag-header CMPI
    "is-alien" get BEQ
    [ %unbox-byte-array ] 2keep
    "end" get B
    "is-alien" resolve-label
    [ %unbox-alien ] 2keep
    "end" get B
    "is-f" resolve-label
    %unbox-f
    "end" resolve-label ;
