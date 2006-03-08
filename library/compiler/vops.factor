! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: arrays errors generic hashtables kernel kernel-internals
lists math memory namespaces parser sequences words ;

! The linear IR is the second of the two intermediate
! representations used by Factor. It is basically a high-level
! assembly language. Linear IR operations are called VOPs.

! This file defines all the types of VOPs. A linear IR program
! is then just a list of VOPs.

: <label> ( -- label )
    #! Make a label.
    gensym  dup t "label" set-word-prop ;

: label? ( obj -- ? )
    dup word? [ "label" word-prop ] [ drop f ] if ;

! A virtual register
TUPLE: vreg n ;

! Register classes
TUPLE: int-regs ;
TUPLE: float-regs size ;

! A pseudo-register class for parameters spilled on the stack
TUPLE: stack-params ;

GENERIC: return-reg ( register-class -- reg )

GENERIC: fastcall-regs ( register-class -- regs )

M: stack-params fastcall-regs drop 0 ;

GENERIC: reg-size ( register-class -- n )

GENERIC: inc-reg-class ( register-class -- )

M: int-regs reg-size drop cell ;

: (inc-reg-class)
    dup class inc
    os "macosx" = [ reg-size stack-params +@ ] [ drop ] if ;

M: int-regs inc-reg-class
    (inc-reg-class) ;

M: float-regs reg-size float-regs-size ;

M: float-regs inc-reg-class
    dup (inc-reg-class)
    os "macosx" = [ reg-size 4 / int-regs +@ ] [ drop ] if ;

! A data stack location.
TUPLE: ds-loc n ;

! A call stack location.
TUPLE: cs-loc n ;

GENERIC: v>operand

M: integer v>operand tag-bits shift ;

M: vreg v>operand vreg-n vregs nth ;

M: f v>operand address ;

! A virtual operation
TUPLE: vop inputs outputs label ;

: (scratch)
    vop get dup vop-inputs swap vop-outputs append
    [ vreg? ] subset [ v>operand ] map vregs diff ;

: scratch ( n -- reg )
    #! Output a scratch register that is not used by the
    #! current VOP.
    \ scratch get nth ;

: with-vop ( vop quot -- )
    swap vop set (scratch) \ scratch set call ; inline

: input ( n -- obj ) vop get vop-inputs nth ;
: input-operand ( n -- n ) input v>operand ;
: output ( n -- obj ) vop get vop-outputs nth ;
: output-operand ( n -- n ) output v>operand ;
: label ( -- label ) vop get vop-label ;

GENERIC: basic-block? ( vop -- ? )
M: vop basic-block? drop f ;

! simplifies some code
M: f basic-block? drop f ;

: make-vop ( inputs outputs label vop -- vop )
    [ >r <vop> r> set-delegate ] keep ;

: empty-vop f f f ;
: label-vop ( label) >r f f r> ;
: label/src-vop ( label src) 1array swap f swap ;
: src-vop ( src) 1array f f ;
: dest-vop ( dest) 1array dup f ;
: src/dest-vop ( src dest) >r 1array r> 1array f ;
: 2-in-vop ( in1 in2) 2array f f ;
: 3-in-vop ( in1 in2 in3) 3array f f ;
: 2-in/label-vop ( in1 in2 label) >r 2array f r> ;
: 2-vop ( in dest) [ 2array ] keep 1array f ;
: 3-vop ( in1 in2 dest) >r 2array r> 1array f ;

! miscellanea
TUPLE: %prologue ;
C: %prologue make-vop ;
: %prologue src-vop <%prologue> ;

TUPLE: %label ;
C: %label make-vop ;
: %label label-vop <%label> ;

! Return vops take a label that is ignored, to have the
! same stack effect as jumps. This is needed for the
! simplifier.
TUPLE: %return ;
C: %return make-vop ;
: %return empty-vop <%return> ;

TUPLE: %jump ;
C: %jump make-vop ;
: %jump label-vop <%jump> ;

TUPLE: %jump-label ;
C: %jump-label make-vop ;
: %jump-label label-vop <%jump-label> ;

TUPLE: %call ;
C: %call make-vop ;
: %call label-vop <%call> ;

TUPLE: %jump-t ;
C: %jump-t make-vop ;
: %jump-t <vreg> label/src-vop <%jump-t> ;

! dispatch tables
TUPLE: %dispatch ;
C: %dispatch make-vop ;
: %dispatch <vreg> src-vop <%dispatch> ;

TUPLE: %target-label ;
C: %target-label make-vop ;
: %target-label label-vop <%target-label> ;

! stack operations
TUPLE: %peek ;
C: %peek make-vop ;

M: %peek basic-block? drop t ;

: %peek-d ( vreg n -- vop )
    <ds-loc> swap <vreg> src/dest-vop <%peek> ;

: %peek-r ( vreg n -- vop )
    <cs-loc> swap <vreg> src/dest-vop <%peek> ;

TUPLE: %replace ;
C: %replace make-vop ;

M: %replace basic-block? drop t ;

: %replace-d ( vreg n -- vop )
    <ds-loc> src/dest-vop <%replace> ;

: %replace-r ( vreg n -- vop )
    <cs-loc> src/dest-vop <%replace> ;

TUPLE: %inc-d ;
C: %inc-d make-vop ;
: %inc-d ( n -- node ) src-vop <%inc-d> ;

M: %inc-d basic-block? drop t ;

TUPLE: %inc-r ;

C: %inc-r make-vop ;

: %inc-r ( n -- ) src-vop <%inc-r> ;

M: %inc-r basic-block? drop t ;

TUPLE: %immediate ;
C: %immediate make-vop ;

: %immediate ( vreg obj -- vop )
    swap <vreg> src/dest-vop <%immediate> ;

M: %immediate basic-block? drop t ;

! indirect load of a literal through a table
TUPLE: %indirect ;
C: %indirect make-vop ;
: %indirect ( vreg obj -- )
    swap <vreg> src/dest-vop <%indirect> ;
M: %indirect basic-block? drop t ;

! object slot accessors
TUPLE: %untag ;
C: %untag make-vop ;
: %untag <vreg> dest-vop <%untag> ;
M: %untag basic-block? drop t ;

: slot-vop [ <vreg> ] 2apply 2-vop ;

TUPLE: %slot ;
C: %slot make-vop ;
: %slot ( n vreg ) slot-vop <%slot> ;
M: %slot basic-block? drop t ;

: set-slot-vop
    rot <vreg> rot <vreg> rot <vreg> dup >r 3array r> 1array f ;

TUPLE: %set-slot ;
C: %set-slot make-vop ;

: %set-slot ( value obj n )
    #! %set-slot writes to vreg obj.
    set-slot-vop <%set-slot> ;

M: %set-slot basic-block? drop t ;

! in the 'fast' versions, the object's type and slot number is
! known at compile time, so these become a single instruction
TUPLE: %fast-slot ;
C: %fast-slot make-vop ;
: %fast-slot ( vreg n )
    swap <vreg> 2-vop <%fast-slot> ;
M: %fast-slot basic-block? drop t ;

TUPLE: %fast-set-slot ;
C: %fast-set-slot make-vop ;
: %fast-set-slot ( value obj n )
    #! %fast-set-slot writes to vreg obj.
    >r >r <vreg> r> <vreg> r> over >r 3array r> 1array f
    <%fast-set-slot> ;
M: %fast-set-slot basic-block? drop t ;

! Char readers and writers
TUPLE: %char-slot ;
C: %char-slot make-vop ;
: %char-slot ( n vreg ) slot-vop <%char-slot> ;
M: %char-slot basic-block? drop t ;

TUPLE: %set-char-slot ;
C: %set-char-slot make-vop ;

: %set-char-slot ( value ch n )
    #! %set-char-slot writes to vreg obj.
    set-slot-vop <%set-char-slot> ;

M: %set-char-slot basic-block? drop t ;

TUPLE: %write-barrier ;
C: %write-barrier make-vop ;
: %write-barrier ( ptr ) <vreg> dest-vop <%write-barrier> ;

! fixnum intrinsics
TUPLE: %fixnum+ ;
C: %fixnum+ make-vop ;       : %fixnum+ 3-vop <%fixnum+> ;
TUPLE: %fixnum- ;
C: %fixnum- make-vop ;       : %fixnum- 3-vop <%fixnum-> ;
TUPLE: %fixnum* ;
C: %fixnum* make-vop ;       : %fixnum* 3-vop <%fixnum*> ;
TUPLE: %fixnum-mod ;
C: %fixnum-mod make-vop ;    : %fixnum-mod 3-vop <%fixnum-mod> ;
TUPLE: %fixnum/i ;
C: %fixnum/i make-vop ;      : %fixnum/i 3-vop <%fixnum/i> ;
TUPLE: %fixnum/mod ;
C: %fixnum/mod make-vop ;    : %fixnum/mod f <%fixnum/mod> ;

TUPLE: %fixnum-bitand ;
C: %fixnum-bitand make-vop ; : %fixnum-bitand 3-vop <%fixnum-bitand> ;
M: %fixnum-bitand basic-block? drop t ;

TUPLE: %fixnum-bitor ;
C: %fixnum-bitor make-vop ;  : %fixnum-bitor 3-vop <%fixnum-bitor> ;
M: %fixnum-bitor basic-block? drop t ;

TUPLE: %fixnum-bitxor ;
C: %fixnum-bitxor make-vop ; : %fixnum-bitxor 3-vop <%fixnum-bitxor> ;
M: %fixnum-bitxor basic-block? drop t ;

TUPLE: %fixnum-bitnot ;
C: %fixnum-bitnot make-vop ; : %fixnum-bitnot 2-vop <%fixnum-bitnot> ;
M: %fixnum-bitnot basic-block? drop t ;

! At the VOP level, the 'shift' operation is split into four
! distinct operations:
! - shifts with a positive count: calls runtime to make
!   a bignum
! - shifts with a small negative count: %fixnum>>
! - shifts with a small negative count: %fixnum>>
! - shifts with a large negative count: %fixnum-sgn
TUPLE: %fixnum>> ;
C: %fixnum>> make-vop ;   : %fixnum>>   3-vop <%fixnum>>> ;
M: %fixnum>> basic-block? drop t ;

! due to x86 limitations the destination of this VOP must be
! vreg 2 (EDX), and the source must be vreg 0 (EAX).
TUPLE: %fixnum-sgn ;
C: %fixnum-sgn make-vop ; : %fixnum-sgn src/dest-vop <%fixnum-sgn> ;
M: %fixnum-sgn basic-block? drop t ;

! Integer comparison followed by a conditional branch is
! optimized
TUPLE: %jump-fixnum<= ;
C: %jump-fixnum<= make-vop ;
: %jump-fixnum<= 2-in/label-vop <%jump-fixnum<=> ;

TUPLE: %jump-fixnum< ;
C: %jump-fixnum< make-vop ; 
: %jump-fixnum< 2-in/label-vop <%jump-fixnum<> ;

TUPLE: %jump-fixnum>= ;
C: %jump-fixnum>= make-vop ;
: %jump-fixnum>= 2-in/label-vop <%jump-fixnum>=> ;

TUPLE: %jump-fixnum> ;
C: %jump-fixnum> make-vop ; 
: %jump-fixnum> 2-in/label-vop <%jump-fixnum>> ;

TUPLE: %jump-eq? ;
C: %jump-eq? make-vop ;     
: %jump-eq? 2-in/label-vop <%jump-eq?> ;

! some slightly optimized inline assembly
TUPLE: %type ;
C: %type make-vop ;
: %type ( vreg ) <vreg> dest-vop <%type> ;

TUPLE: %tag ;
C: %tag make-vop ;
: %tag ( vreg ) <vreg> dest-vop <%tag> ;
M: %tag basic-block? drop t ;

TUPLE: %getenv ;
C: %getenv make-vop ;
: %getenv swap src/dest-vop <%getenv> ;
M: %getenv basic-block? drop t ;

TUPLE: %setenv ;
C: %setenv make-vop ;
: %setenv 2-in-vop <%setenv> ;

TUPLE: %stack>freg ;
C: %stack>freg make-vop ;
: %stack>freg ( n reg reg-class -- vop ) 3-in-vop <%stack>freg> ;

TUPLE: %freg>stack ;
C: %freg>stack make-vop ;
: %freg>stack ( n reg reg-class -- vop ) 3-in-vop <%freg>stack> ;

TUPLE: %cleanup ;
C: %cleanup make-vop ;
: %cleanup ( n -- vop ) src-vop <%cleanup> ;

TUPLE: %unbox ;
C: %unbox make-vop ;
: %unbox ( n reg-class func -- vop ) 3-in-vop <%unbox> ;

TUPLE: %unbox-struct ;
C: %unbox-struct make-vop ;
: %unbox-struct ( n reg-class size -- vop )
    3-in-vop <%unbox-struct> ;

TUPLE: %box ;
C: %box make-vop ;
: %box ( n reg-class func -- vop ) 3-in-vop <%box> ;

TUPLE: %alien-invoke ;
C: %alien-invoke make-vop ;
: %alien-invoke ( func lib -- vop ) 2-in-vop <%alien-invoke> ;

TUPLE: %alien-callback ;
C: %alien-callback make-vop ;
: %alien-callback ( quot -- vop ) src-vop <%alien-callback> ;

TUPLE: %callback-value ;
C: %callback-value make-vop ;
: %callback-value ( reg-class func -- vop )
    2-in-vop <%callback-value> ;
