! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien assembler-arm compiler kernel kernel-internals math
namespaces words generic ;
IN: generator

: code-format 4 ; inline

! ARM register assignments:
! R0, R1, R2, R3, R12 integer vregs
! R5 data stack
! R6 retain stack
! R7 cards_offset

: ds-reg R5 ; inline
: rs-reg R6 ; inline

M: int-regs return-reg drop R0 ;
M: int-regs param-regs drop { R0 R1 R2 R3 } ;
M: int-regs vregs drop { R0 R1 R2 R3 R12 } ;

! No FPU support yet
M: float-regs param-regs drop { } ;
M: float-regs vregs drop { } ;

: <+/-> dup 0 < [ neg <-> ] [ <+> ] if ;

GENERIC: loc>operand ( loc -- reg addressing )
M: ds-loc loc>operand ds-loc-n cells neg ds-reg swap <+/-> ;
M: rs-loc loc>operand rs-loc-n cells neg rs-reg swap <+/-> ;

: load-indirect ( obj reg -- )
    PC 0 <+> LDR rc-indirect-arm-pc rel-literal ;

M: immediate load-literal
    over v>operand small-enough? [
        [ v>operand ] 2apply swap MOV
    ] [
        v>operand load-indirect
    ] if ;

M: object load-literal v>operand load-indirect ;

: stack-increment \ stack-frame-size get 4 + 8 align ;

: %prologue ( -- )
    [
        LR SP 4 <-> STR
        SP SP stack-increment SUB
    ] if-stack-frame ;

: %epilogue ( -- )
    [
        SP SP stack-increment ADD
        LR SP 4 <-> LDR
    ] if-stack-frame ;

: primitive-addr ( word dst -- )
    #! Load a word address into dst.
    R7 rot word-primitive cells <+> LDR ;

: %call ( label -- )
    #! Far C call for primitives, near C call for compiled defs.
    dup (compile)
    dup primitive? [ R0 primitive-addr R0 BLX ] [ BL ] if ;

: %jump-label ( label -- )
    #! For tail calls. IP not saved on C stack.
    #! WARNING: don't clobber LR here!
    dup primitive? [ PC primitive-addr ] [ B ] if ;

: %jump ( label -- )
    %epilogue dup (compile) %jump-label ;

: %jump-t ( label -- )
    "flag" operand object-tag CMP NE B ;

: (%dispatch) ( word-table# reg -- )
    #! Load jump table target address into reg.
    "n" operand PC "n" operand 1 <LSR> ADD
    "n" operand 0 <+> LDR
    rc-indirect-arm rel-dispatch ;

: %call-dispatch ( word-table# -- )
    [
        "scratch" operand (%dispatch)
        "scratch" operand BLX
    ] H{
        { +input+ { { f "n" } } }
        { +scratch+ { { f "scratch" } } }
        { +clobber+ { "n" } }
    } with-template ;

: %jump-dispatch ( word-table# -- )
    [
        %epilogue
        PC (%dispatch)
    ] H{
        { +input+ { { f "n" } } }
        { +clobber+ { "n" } }
    } with-template ;

: %return ( -- )
    \ stack-frame-size get no-stack-frame = [
        PC LR MOV
    ] [
        SP SP stack-increment ADD
        PC SP 4 <-> LDR
    ] if ;

: (%peek/replace)
    >r drop >r v>operand r> loc>operand r> execute ;

M: int-regs (%peek) \ LDR (%peek/replace) ;
M: int-regs (%replace) \ STR (%peek/replace) ;

: %move-int>int ( dst src -- ) [ v>operand ] 2apply MOV ;

: (%inc) ( n reg -- )
    dup rot cells dup 0 < [ neg SUB ] [ ADD ] if ;

: %inc-d ( n -- ) ds-reg (%inc) ;
: %inc-r ( n -- ) rs-reg (%inc) ;

: stack@ SP swap <+> ;

M: int-regs %save-param-reg drop swap stack@ STR ;

M: int-regs %load-param-reg drop swap stack@ LDR ;

M: stack-params %save-param-reg
    drop
    R12 swap stack-increment + stack@ LDR
    R12 swap stack@ STR ;

M: stack-params %load-param-reg
    drop
    R12 rot stack@ LDR
    R12 swap stack@ STR ;

: %prepare-unbox ( -- )
    ! First parameter is top of stack
    R0 R5 4 <-!> LDR ;

: %unbox ( n reg-class func -- )
    ! Value must be in R0.
    ! Call the unboxer
    f %alien-invoke
    ! Store the return value on the C stack
    over [ [ return-reg ] keep %save-param-reg ] [ 2drop ] if ;

: %unbox-small-struct ( size -- )
    #! Alien must be in R0.
    drop
    "alien_offset" f %alien-invoke
    ! Load first cell
    R0 R0 0 <+> LDR ;

: %unbox-large-struct ( n size -- )
    #! Alien must be in R0.
    ! Compute destination address
    R1 SP roll ADD
    R2 swap MOV
    ! Copy the struct to the stack
    "to_value_struct" f %alien-invoke ;

: %box ( n reg-class func -- )
    ! If the source is a stack location, load it into freg #0.
    ! If the source is f, then we assume the value is already in
    ! freg #0.
    >r
    over [ 0 over param-reg swap %load-param-reg ] [ 2drop ] if
    r> f %alien-invoke ;

: %box-small-struct ( size -- )
    #! Box a 4-byte struct returned in R0.
    drop "box_struct_1" f %alien-invoke ;

: struct-return@ ( size n -- n )
    [
        stack-increment +
    ] [
        stack-increment swap - cell -
    ] ?if ;

: %prepare-box-struct ( size -- )
    ! Compute target address for value struct return
    R0 SP rot f struct-return@ ADD
    ! Store it as the first parameter
    R0 0 stack@ STR ;

: %box-large-struct ( n size -- )
    ! Compute destination address
    [ swap struct-return@ ] keep
    R0 SP roll ADD
    R1 swap MOV
    ! Copy the struct from the C stack
    "box_value_struct" f %alien-invoke ;

: struct-small-enough? ( size -- ? ) 4 <= ;

: %alien-invoke ( symbol dll -- )
    ! Load target address
    R12 PC 4 <+> LDR
    ! Store address of next instruction in LR
    LR PC 4 ADD
    ! Jump to target address
    R12 BX
    ! The target address
    0 , rc-absolute rel-dlsym ;

: temp@ SP stack-increment 2 cells - <+> ;

: %prepare-alien-indirect ( -- )
    "unbox_alien" f %alien-invoke
    R0 temp@ STR ;

: %alien-indirect ( -- )
    IP temp@ LDR
    IP BLX ;

: %alien-callback ( quot -- )
    R0 load-indirect
    "run_callback" f %alien-invoke ;

: %callback-value ( ctype -- )
    ! Save top of data stack
    %prepare-unbox
    R0 temp@ STR
    ! Restore data/call/retain stacks
    "unnest_stacks" f %alien-invoke
    ! Place former top of data stack in R0
    R0 temp@ LDR
    ! Unbox R0
    unbox-return ;

: %cleanup ( alien-node -- ) drop ;

: %untag ( dest src -- ) BIN: 111 BIC ;

: %untag-fixnum ( dest src -- ) 3 <ASR> MOV ;

: %tag-fixnum ( dest src -- ) 3 <LSL> MOV ;

: value-structs? t ;

: small-enough? ( n -- ? ) 0 255 between? ;
