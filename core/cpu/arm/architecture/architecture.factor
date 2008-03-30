! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays cpu.arm.assembler compiler
kernel kernel.private math namespaces words words.private
generator.registers generator.fixup generator cpu.architecture
system layouts ;
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

: load-cell ( reg -- )
    [
        "end" define-label
        ! Load target address
        PC 0 <+> LDR
        ! Skip an instruction
        "end" get B
        ! The target address
        0 ,
        ! Continue here
        "end" resolve-label
    ] with-scope ;

: call-cell ( -- )
    ! Compute return address; we skip 3 instructions
    LR PC 8 ADD
    ! Load target address
    R12 PC 0 <+> LDR
    ! Jump to target address
    R12 BX
    ! The target address
    0 , ;

M: arm-backend load-indirect ( obj reg -- )
    tuck load-cell rc-absolute-cell rel-literal
    dup 0 <+> LDR ;

M: immediate load-literal
    over v>operand small-enough? [
        [ v>operand ] bi@ swap MOV
    ] [
        v>operand load-indirect
    ] if ;

: lr-save ( n -- i ) cell - ;
: next-save ( n -- i ) 2 cells - ;
: xt-save ( n -- i ) 3 cells - ;
: factor-area-size 5 cells ;

M: arm-backend stack-frame ( n -- i )
    factor-area-size + 8 align ;

M: arm-backend %save-word-xt ( -- )
    R12 PC 9 cells SUB ;

M: arm-backend %save-dispatch-xt ( -- )
    R12 PC 2 cells SUB ;

M: arm-backend %prologue ( n -- )
    SP SP pick SUB
    R11 over MOV
    R11 SP pick next-save <+> STR
    R12 SP pick xt-save <+> STR
    LR SP rot lr-save <+> STR ;

M: arm-backend %epilogue ( n -- )
    LR SP pick lr-save <+> LDR
    SP SP rot ADD ;

: compile-dlsym ( symbol dll reg -- )
    load-cell rc-absolute rel-dlsym ;

: %alien-global ( symbol dll reg -- )
    [ compile-dlsym ] keep dup 0 <+> LDR ;

M: arm-backend %profiler-prologue ( -- )
    #! We can clobber R0 here since it is undefined at the start
    #! of a word.
    R12 load-indirect
    R0 R12 profile-count-offset <+> LDR
    R0 R0 1 v>operand ADD
    R0 R12 profile-count-offset <+> STR ;

M: arm-backend %call-label ( label -- ) BL ;

M: arm-backend %jump-label ( label -- ) B ;

: %prepare-primitive ( -- )
    #! Save stack pointer to stack_chain->callstack_top, load XT
    R1 SP 4 SUB ;

M: arm-backend %call-primitive ( word -- )
    %prepare-primitive
    call-cell rc-absolute-cell rel-word ;

M: arm-backend %jump-primitive ( word -- )
    %prepare-primitive
    ! Load target address
    R12 PC 0 <+> LDR
    ! Jump to target address
    R12 BX
    ! The target address
    0 , rc-absolute-cell rel-word ;

M: arm-backend %jump-t ( label -- )
    "flag" operand f v>operand CMP NE B ;

: (%dispatch) ( word-table# -- )
    #! Load jump table target address into reg.
    "scratch" operand PC "n" operand 1 <LSR> ADD
    "scratch" operand dup 0 <+> LDR
    rc-indirect-arm rel-dispatch
    "scratch" operand dup compiled-header-size ADD ;

M: arm-backend %call-dispatch ( word-table# -- )
    [
        (%dispatch)
        "scratch" operand BLX
    ] H{
        { +input+ { { f "n" } } }
        { +scratch+ { { f "scratch" } } }
    } with-template ;

M: arm-backend %jump-dispatch ( word-table# -- )
    [
        %epilogue-later
        (%dispatch)
        "scratch" operand BX
    ] H{
        { +input+ { { f "n" } } }
        { +scratch+ { { f "scratch" } } }
    } with-template ;

M: arm-backend %return ( -- ) %epilogue-later PC LR MOV ;

M: arm-backend %unwind drop %return ;

M: arm-backend %peek >r v>operand r> loc>operand LDR ;

M: arm-backend %replace >r v>operand r> loc>operand STR ;

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

M: arm-backend %prepare-alien-invoke
    #! Save Factor stack pointers in case the C code calls a
    #! callback which does a GC, which must reliably trace
    #! all roots.
    "stack_chain" f R12 %alien-global
    SP R12 0 <+> STR
    ds-reg R12 8 <+> STR
    rs-reg R12 12 <+> STR ;

M: arm-backend %alien-invoke ( symbol dll -- )
    call-cell rc-absolute-cell rel-dlsym ;

M: arm-backend %prepare-alien-indirect ( -- )
    "unbox_alien" f %alien-invoke
    R0 SP cell temp@ <+> STR ;

M: arm-backend %alien-indirect ( -- )
    R12 SP cell temp@ <+> LDR
    R12 BLX ;

M: arm-backend %alien-callback ( quot -- )
    R0 load-indirect
    "c_to_factor" f %alien-invoke ;

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
M: arm-backend %unbox-byte-array ( dst src -- )
    [ v>operand ] bi@ byte-array-offset ADD ;

M: arm-backend %unbox-alien ( dst src -- )
    [ v>operand ] bi@ alien-offset <+> LDR ;

M: arm-backend %unbox-f ( dst src -- )
    drop v>operand 0 MOV ;

M: arm-backend %unbox-any-c-ptr ( dst src -- )
    #! We need three registers here. R11 and R12 are reserved
    #! temporary registers. The third one is R14, which we have
    #! to save/restore.
    "end" define-label
    "start" define-label
    ! Save R14.
    R14 SP 4 <-> STR
    ! Address is computed in R11
    R11 0 MOV
    ! Load object into R12
    R12 swap v>operand MOV
    ! We come back here with displaced aliens
    "start" resolve-label
    ! Is the object f?
    R12 f v>operand CMP
    ! If so, done
    "end" get EQ B
    ! Is the object an alien?
    R14 R12 header-offset <+/-> LDR
    R14 alien type-number tag-fixnum CMP
    ! Add byte array address to address being computed
    R11 R11 R12 NE ADD
    ! Add an offset to start of byte array's data area
    R11 R11 byte-array-offset NE ADD
    "end" get NE B
    ! If alien, load the offset
    R14 R12 alien-offset <+/-> LDR
    ! Add it to address being computed
    R11 R11 R14 ADD
    ! Now recurse on the underlying alien
    R12 R12 underlying-alien-offset <+/-> LDR
    "start" get B
    "end" resolve-label
    ! Done, store address in destination register
    v>operand R11 MOV
    ! Restore R14.
    R14 SP 4 <-> LDR ;
