! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays cpu.arm.assembler compiler
kernel kernel.private math namespaces words
words.private generator.registers generator.fixup generator
cpu.architecture system layouts ;
IN: cpu.arm.architecture

TUPLE: arm-backend ;

! ARM register assignments:
! R0-R4, R7-R10 integer vregs
! R11, R12 temporary
! R5 data stack
! R6 retain stack
! R7 primitives

: ds-reg R5 ; inline
: rs-reg R6 ; inline

M: temp-reg v>operand drop R12 ;

M: int-regs return-reg drop R0 ;
M: int-regs param-regs drop { R0 R1 R2 R3 } ;
M: int-regs vregs drop { R0 R1 R2 R3 R4 R7 R8 R9 R10 } ;

! No FPU support yet
M: float-regs param-regs drop { } ;
M: float-regs vregs drop { } ;

: <+/-> dup 0 < [ neg <-> ] [ <+> ] if ;

GENERIC: loc>operand ( loc -- reg addressing )
M: ds-loc loc>operand ds-loc-n cells neg ds-reg swap <+/-> ;
M: rs-loc loc>operand rs-loc-n cells neg rs-reg swap <+/-> ;

M: arm-backend load-indirect ( obj reg -- )
    PC 0 <+> LDR rc-indirect-arm-pc rel-literal ;

M: immediate load-literal
    over v>operand small-enough? [
        [ v>operand ] 2apply swap MOV
    ] [
        v>operand load-indirect
    ] if ;

: lr-save ( n -- i ) cell - ;
: next-save ( n -- i ) 2 cells - ;
: xt-save ( n -- i ) 3 cells - ;
: factor-area-size 5 cells ;

M: arm-backend stack-frame ( n -- i )
    factor-area-size + 8 align ;

M: ppc-backend %save-xt ( -- )
    R12 PC 8 SUB ;

M: arm-backend %prologue ( n -- )
    SP SP pick SUB
    R11 over LI
    R11 SP pick next-save <+> STR
    R12 SP rot xt-save <+> STR
    LR SP pick lr-save <+> STR ;

M: arm-backend %epilogue ( n -- )
    LR SP lr-save <+> LDR
    SP SP rot stack-frame ADD ;

: compile-dlsym ( symbol dll reg -- )
    [
        "end" define-label
        ! Load target address
        PC 0 <+> LDR
        ! Skip an instruction
        "end" get B
        ! The target address
        0 , rc-absolute rel-dlsym
        ! Continue here
        "end" resolve-label
    ] with-scope ;

: %alien-global ( symbol dll reg -- )
    [ compile-dlsym ] keep dup 0 <+> LDR ;

M: arm-backend %profiler-prologue ( word -- )
    #! We can clobber R0 here since it is undefined at the start
    #! of a word.
    "end" define-label
    "profiling" f R12 %alien-global
    R12 0 CMP
    "end" get EQ B
    R12 load-indirect
    R0 R12 profile-count-offset <+> LDR
    R0 R0 1 v>operand ADD
    R0 R12 profile-count-offset <+> STR
    "end" resolve-label ;

M: arm-backend %call-label ( label -- ) BL ;

M: arm-backend %jump-label ( label -- ) B ;

: %load-xt ( word -- )
    0 swap LOAD32  rc-absolute-ppc-2/2 rel-word ;

: %prepare-primitive ( word -- )
    #! Save stack pointer to stack_chain->callstack_top, load XT
    R1 SP MOV
    T{ temp-reg } load-literal
    R12 R12 word-xt-offset <+> LDR ;

M: arm-backend %call-primitive ( word -- )
    %prepare-primitive R12 BLX ;

M: arm-backend %jump-primitive ( word -- )
    %prepare-primitive R12 BX ;

M: arm-backend %jump-t ( label -- )
    "flag" operand f v>operand CMP NE B ;

: (%dispatch) ( word-table# reg -- )
    #! Load jump table target address into reg.
    "scratch" operand PC "n" operand 1 <LSR> ADD
    "scratch" operand 0 <+> LDR
    rc-indirect-arm rel-dispatch ;

M: arm-backend %call-dispatch ( word-table# -- )
    [
        "scratch" operand (%dispatch)
        "scratch" operand BLX
    ] H{
        { +input+ { { f "n" } } }
        { +scratch+ { { f "scratch" } } }
    } with-template ;

M: arm-backend %jump-dispatch ( word-table# -- )
    [
        %epilogue-later
        PC (%dispatch)
    ] H{
        { +input+ { { f "n" } } }
        { +scratch+ { { f "scratch" } } }
    } with-template ;

M: arm-backend %return ( -- ) %epilogue-later PC LR MOV ;

M: arm-backend %unwind drop %return ;

: (%peek/replace)
    >r drop >r v>operand r> loc>operand r> execute ;

M: int-regs (%peek) \ LDR (%peek/replace) ;
M: int-regs (%replace) \ STR (%peek/replace) ;

: (%inc) ( n reg -- )
    dup rot cells dup 0 < [ neg SUB ] [ ADD ] if ;

M: arm-backend %inc-d ( n -- ) ds-reg (%inc) ;

M: arm-backend %inc-r ( n -- ) rs-reg (%inc) ;

: stack@ SP swap <+> ;

M: int-regs %save-param-reg drop swap stack@ STR ;

M: int-regs %load-param-reg drop swap stack@ LDR ;

M: stack-params %save-param-reg
    drop
    R12 swap stack-frame* + stack@ LDR
    R12 swap stack@ STR ;

M: stack-params %load-param-reg
    drop
    R12 rot stack@ LDR
    R12 swap stack@ STR ;

M: arm-backend %prepare-unbox ( -- )
    ! First parameter is top of stack
    R0 R5 4 <-!> LDR ;

M: arm-backend %unbox ( n reg-class func -- )
    ! Value must be in R0.
    ! Call the unboxer
    f %alien-invoke
    ! Store the return value on the C stack
    over [ [ return-reg ] keep %save-param-reg ] [ 2drop ] if ;

M: arm-backend %unbox-long-long ( n func -- )
    ! Value must be in R0:R1.
    ! Call the unboxer
    f %alien-invoke
    ! Store the return value on the C stack
    [
        R0 over stack@ STR
        R1 swap cell + stack@ STR
    ] when* ;

M: arm-backend %unbox-small-struct ( size -- )
    #! Alien must be in R0.
    drop
    "alien_offset" f %alien-invoke
    ! Load first cell
    R0 R0 0 <+> LDR ;

M: arm-backend %unbox-large-struct ( n size -- )
    #! Alien must be in R0.
    ! Compute destination address
    R1 SP roll ADD
    R2 swap MOV
    ! Copy the struct to the stack
    "to_value_struct" f %alien-invoke ;

M: arm-backend %box ( n reg-class func -- )
    ! If the source is a stack location, load it into freg #0.
    ! If the source is f, then we assume the value is already in
    ! freg #0.
    >r
    over [ 0 over param-reg swap %load-param-reg ] [ 2drop ] if
    r> f %alien-invoke ;

M: arm-backend %box-long-long ( n func -- )
    >r [
        R0 over stack@ LDR
        R1 swap cell + stack@ LDR
    ] when* r> f %alien-invoke ;

M: arm-backend %box-small-struct ( size -- )
    #! Box a 4-byte struct returned in R0.
    R2 swap MOV
    "box_small_struct" f %alien-invoke ;

: temp@ stack-frame* factor-area-size - swap - ;

: struct-return@ ( size n -- n )
    [
        stack-frame* +
    ] [
        stack-frame* factor-area-size - swap -
    ] ?if ;

M: arm-backend %prepare-box-struct ( size -- )
    ! Compute target address for value struct return
    R0 SP rot f struct-return@ ADD
    ! Store it as the first parameter
    R0 0 stack@ STR ;

M: arm-backend %box-large-struct ( n size -- )
    ! Compute destination address
    [ swap struct-return@ ] keep
    R0 SP roll ADD
    R1 swap MOV
    ! Copy the struct from the C stack
    "box_value_struct" f %alien-invoke ;

M: arm-backend struct-small-enough? ( size -- ? )
    wince? [ drop f ] [ 4 <= ] if ;

M: ppc-backend %prepare-alien-invoke
    #! Save Factor stack pointers in case the C code calls a
    #! callback which does a GC, which must reliably trace
    #! all roots.
    "stack_chain" f R12 %alien-global
    SP R12 0 <+> STR
    ds-reg 11 8 <+> STR
    rs-reg 11 12 <+> STR ;

M: arm-backend %alien-invoke ( symbol dll -- )
    ! Load target address
    R12 PC 4 <+> LDR
    ! Store address of next instruction in LR
    LR PC 4 ADD
    ! Jump to target address
    R12 BX
    ! The target address
    0 , rc-absolute rel-dlsym ;

M: arm-backend %prepare-alien-indirect ( -- )
    "unbox_alien" f %alien-invoke
    R0 SP cell temp@ <+> STR ;

M: arm-backend %alien-indirect ( -- )
    R12 SP cell temp@ <+> LDR
    R12 BLX ;

M: arm-backend %alien-callback ( quot -- )
    R0 load-indirect
    "run_callback" f %alien-invoke ;

M: arm-backend %callback-value ( ctype -- )
    ! Save top of data stack
    %prepare-unbox
    R0 SP cell temp@ <+> STR
    ! Restore data/call/retain stacks
    "unnest_stacks" f %alien-invoke
    ! Place former top of data stack in R0
    R0 SP cell temp@ <+> LDR
    ! Unbox R0
    unbox-return ;

M: arm-backend %cleanup ( alien-node -- ) drop ;

: %untag ( dest src -- ) BIN: 111 BIC ;

: %untag-fixnum ( dest src -- ) tag-bits get <ASR> MOV ;

: %tag-fixnum ( dest src -- ) tag-bits get <LSL> MOV ;

M: arm-backend value-structs? t ;

M: arm-backend small-enough? ( n -- ? ) 0 255 between? ;

M: long-long-type c-type-stack-align? drop wince? not ;

M: arm-backend fp-shadows-int? ( -- ? ) f ;

! Alien intrinsics
: add-alien-offset "offset" operand tag-bits get <ASR> ADD ;

: (%unbox-alien) <+> roll call ; inline

M: arm-backend %unbox-byte-array ( quot src -- )
    "address" operand "alien" operand add-alien-offset
    "address" operand alien-offset (%unbox-alien) ;

M: arm-backend %unbox-alien ( quot src -- )
    "address" operand "alien" operand alien-offset <+> LDR
    "address" operand dup add-alien-offset
    "address" operand 0 (%unbox-alien) ;

M: arm-backend %unbox-f ( quot src -- )
    "offset" operand dup %untag-fixnum
    "offset" operand 0 (%unbox-alien) ;

M: arm-backend %complex-alien-accessor ( quot src -- )
    "is-f" define-label
    "is-alien" define-label
    "end" define-label
    "alien" operand f v>operand CMP
    "is-f" get EQ B
    "address" operand "alien" operand header-offset neg <-> LDR
    "address" operand alien type-number tag-header CMP
    "is-alien" get EQ B
    [ %unbox-byte-array ] 2keep
    "end" get B
    "is-alien" resolve-label
    [ %unbox-alien ] 2keep
    "end" get B
    "is-f" resolve-label
    %unbox-f
    "end" resolve-label ;
