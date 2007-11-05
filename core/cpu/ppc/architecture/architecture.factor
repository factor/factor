! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types cpu.ppc.assembler cpu.architecture generic
kernel kernel.private math memory namespaces sequences words
assocs generator generator.registers generator.fixup system
layouts classes words.private alien combinators ;
IN: cpu.ppc.architecture

TUPLE: ppc-backend ;

! PowerPC register assignments
! r3-r10, r16-r31: integer vregs
! f0-f13: float vregs
! r11, r12: scratch
! r14: data stack
! r15: retain stack

: ds-reg 14 ; inline
: rs-reg 15 ; inline

: reserved-area-size
    os {
        { "linux" [ 2 ] }
        { "macosx" [ 6 ] }
    } case cells ; foldable

: lr-save
    os {
        { "linux" [ 1 ] }
        { "macosx" [ 2 ] }
    } case cells ; foldable

: param@ ( n -- x ) reserved-area-size + ; inline

: param-save-size 8 cells ; foldable

: local@ ( n -- x )
    reserved-area-size param-save-size + + ; inline

: factor-area-size 4 cells ;

: next-save ( n -- i ) cell - ;

: xt-save ( n -- i ) 2 cells - ;

M: ppc-backend stack-frame ( n -- i )
    local@ factor-area-size + 4 cells align ;

M: temp-reg v>operand drop 11 ;

M: int-regs return-reg drop 3 ;
M: int-regs param-regs drop { 3 4 5 6 7 8 9 10 } ;
M: int-regs vregs
    drop {
        3 4 5 6 7 8 9 10
        16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
    } ;

M: float-regs return-reg drop 1 ;
M: float-regs param-regs 
    drop os H{
        { "macosx" { 1 2 3 4 5 6 7 8 9 10 11 12 13 } }
        { "linux" { 1 2 3 4 5 6 7 8 } }
    } at ;
M: float-regs vregs drop { 0 1 2 3 4 5 6 7 8 9 10 11 12 13 } ;

GENERIC: loc>operand ( loc -- reg n )

M: ds-loc loc>operand ds-loc-n cells neg ds-reg swap ;
M: rs-loc loc>operand rs-loc-n cells neg rs-reg swap ;

M: immediate load-literal
    [ v>operand ] 2apply LOAD ;

M: ppc-backend load-indirect ( obj reg -- )
    [ 0 swap LOAD32 rc-absolute-ppc-2/2 rel-literal ] keep
    dup 0 LWZ ;

M: ppc-backend %save-word-xt ( -- )
    0 11 LOAD32 rc-absolute-ppc-2/2 rel-current-word ;

M: ppc-backend %prologue ( n -- )
    0 MFLR
    1 1 pick neg ADDI
    11 1 pick xt-save STW
    dup 11 LI
    11 1 pick next-save STW
    0 1 rot lr-save + STW ;

M: ppc-backend %epilogue ( n -- )
    #! At the end of each word that calls a subroutine, we store
    #! the previous link register value in r0 by popping it off
    #! the stack, set the link register to the contents of r0,
    #! and jump to the link register.
    0 1 pick lr-save + LWZ
    1 1 rot ADDI
    0 MTLR ;

: %load-dlsym ( symbol dll register -- )
    0 swap LOAD32 rc-absolute-ppc-2/2 rel-dlsym ;

M: ppc-backend %profiler-prologue ( word -- )
    3 load-indirect
    4 3 profile-count-offset LWZ
    4 4 1 v>operand ADDI
    4 3 profile-count-offset STW ;

M: ppc-backend %call-label ( label -- ) BL ;

M: ppc-backend %jump-label ( label -- ) B ;

: %prepare-primitive ( word -- )
    #! Save stack pointer to stack_chain->callstack_top, load XT
    4 1 MR
    0 11 LOAD32
    rc-absolute-ppc-2/2 rel-word ;

: (%call) 11 MTLR BLRL ;

M: ppc-backend %call-primitive ( word -- )
    %prepare-primitive (%call) ;

: (%jump) 11 MTCTR BCTR ;

M: ppc-backend %jump-primitive ( word -- )
    %prepare-primitive (%jump) ;

M: ppc-backend %jump-t ( label -- )
    0 "flag" operand f v>operand CMPI BNE ;

: dispatch-template ( word-table# quot -- )
    [
        >r
        "offset" operand "n" operand 1 SRAWI
        0 11 LOAD32 rc-absolute-ppc-2/2 rel-dispatch
        11 dup "offset" operand LWZX
        11 dup compiled-header-size ADDI
        r> call
    ] H{
        { +input+ { { f "n" } } }
        { +scratch+ { { f "offset" } } }
    } with-template ; inline

M: ppc-backend %call-dispatch ( word-table# -- )
    [ (%call) ] dispatch-template ;

M: ppc-backend %jump-dispatch ( word-table# -- )
    [ %epilogue-later (%jump) ] dispatch-template ;

M: ppc-backend %return ( -- ) %epilogue-later BLR ;

M: ppc-backend %unwind drop %return ;

M: ppc-backend %peek ( vreg loc -- )
    >r v>operand r> loc>operand LWZ ;

M: ppc-backend %replace
    >r v>operand r> loc>operand STW ;

M: ppc-backend %unbox-float ( dst src -- )
    [ v>operand ] 2apply float-offset LFD ;

M: ppc-backend %inc-d ( n -- ) ds-reg dup rot cells ADDI ;

M: ppc-backend %inc-r ( n -- ) rs-reg dup rot cells ADDI ;

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
    3 ds-reg 0 LWZ
    ds-reg dup cell SUBI ;

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

: temp@ stack-frame* factor-area-size - swap - ;

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

M: ppc-backend %prepare-alien-invoke
    #! Save Factor stack pointers in case the C code calls a
    #! callback which does a GC, which must reliably trace
    #! all roots.
    "stack_chain" f 11 %load-dlsym
    11 11 0 LWZ
    1 11 0 STW
    ds-reg 11 8 STW
    rs-reg 11 12 STW ;

M: ppc-backend %alien-invoke ( symbol dll -- )
    11 %load-dlsym (%call) ;

M: ppc-backend %alien-callback ( quot -- )
    3 load-indirect "c_to_factor" f %alien-invoke ;

M: ppc-backend %prepare-alien-indirect ( -- )
    "unbox_alien" f %alien-invoke
    3 1 cell temp@ STW ;

M: ppc-backend %alien-indirect ( -- )
    11 1 cell temp@ LWZ (%call) ;

M: ppc-backend %callback-value ( ctype -- )
     ! Save top of data stack
     3 ds-reg 0 LWZ
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
M: ppc-backend %unbox-byte-array ( dst src -- )
    [ v>operand ] 2apply byte-array-offset ADDI ;

M: ppc-backend %unbox-alien ( dst src -- )
    [ v>operand ] 2apply alien-offset LWZ ;

M: ppc-backend %unbox-f ( dst src -- )
    drop 0 swap v>operand LI ;

M: ppc-backend %unbox-any-c-ptr ( dst src -- )
    { "is-byte-array" "end" "start" } [ define-label ] each
    ! Address is computed in R12
    0 12 LI
    ! Load object into R11
    11 swap v>operand MR
    ! We come back here with displaced aliens
    "start" resolve-label
    ! Is the object f?
    0 11 f v>operand CMPI
    ! If so, done
    "end" get BEQ
    ! Is the object an alien?
    0 11 header-offset LWZ
    0 0 alien type-number tag-header CMPI
    "is-byte-array" get BNE
    ! If so, load the offset
    0 11 alien-offset LWZ
    ! Add it to address being computed
    12 12 0 ADD
    ! Now recurse on the underlying alien
    11 11 underlying-alien-offset LWZ
    "start" get B
    "is-byte-array" resolve-label
    ! Add byte array address to address being computed
    12 12 11 ADD
    ! Add an offset to start of byte array's data area
    12 12 byte-array-offset ADDI
    "end" resolve-label
    ! Done, store address in destination register
    v>operand 12 MR ;
