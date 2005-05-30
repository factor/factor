! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: errors generic hashtables kernel lists math namespaces
parser sequences words ;

! The linear IR is the second of the two intermediate
! representations used by Factor. It is basically a high-level
! assembly language. Linear IR operations are called VOPs.

! This file defines all the types of VOPs. A linear IR program
! is then just a list of VOPs.

: <label> ( -- label )
    #! Make a label.
    gensym  dup t "label" set-word-prop ;

: label? ( obj -- ? )
    dup word? [ "label" word-prop ] [ drop f ] ifte ;

! A virtual register
TUPLE: vreg n ;

! A virtual operation
TUPLE: vop inputs outputs label ;
: vop-in-1 ( vop -- input ) vop-inputs first ;
: vop-in-2 ( vop -- input ) vop-inputs second ;
: vop-in-3 ( vop -- input ) vop-inputs third ;
: vop-out-1 ( vop -- output ) vop-outputs car ;

GENERIC: basic-block? ( vop -- ? )
M: vop basic-block? drop f ;
! simplifies some code
M: f basic-block? drop f ;

GENERIC: calls-label? ( label vop -- ? )
M: vop calls-label? vop-label = ;

: make-vop ( inputs outputs label vop -- vop )
    [ >r <vop> r> set-delegate ] keep ;

: VOP:
    #! Followed by a VOP name.
    scan dup [ ] define-tuple
    create-in [ make-vop ] define-constructor ; parsing

: empty-vop f f f ;
: label-vop ( label) >r f f r> ;
: label/src-vop ( label src) unit swap f swap ;
: src-vop ( src) unit f f ;
: dest-vop ( dest) unit dup f ;
: src/dest-vop ( src dest) >r unit r> unit f ;
: binary-vop ( src dest) [ 2list ] keep unit f ;
: 2-in-vop ( in1 in2) 2list f f ;
: 2-in/label-vop ( in1 in2 label) >r 2list f r> ;
: ternary-vop ( in1 in2 dest) >r 2list r> unit f ;

! miscellanea
VOP: %prologue
: %prologue empty-vop <%prologue> ;

VOP: %label
: %label label-vop <%label> ;
M: %label calls-label? 2drop f ;

! Return vops take a label that is ignored, to have the
! same stack effect as jumps. This is needed for the
! simplifier.
VOP: %return
: %return ( label) label-vop <%return> ;

VOP: %return-to
: %return-to label-vop <%return-to> ;

VOP: %jump
: %jump label-vop <%jump> ;

VOP: %jump-label
: %jump-label label-vop <%jump-label> ;

VOP: %call
: %call label-vop <%call> ;

VOP: %call-label
: %call-label label-vop <%call-label> ;

VOP: %jump-t
: %jump-t <vreg> label/src-vop <%jump-t> ;

VOP: %jump-f
: %jump-f <vreg> label/src-vop <%jump-f> ;

! dispatch tables
VOP: %dispatch
: %dispatch <vreg> src-vop <%dispatch> ;

VOP: %target-label
: %target-label label-vop <%target-label> ;

VOP: %target
: %target label-vop <%target> ;

VOP: %end-dispatch
: %end-dispatch empty-vop <%end-dispatch> ;

! stack operations
VOP: %peek-d
: %peek-d ( vreg n -- ) swap <vreg> src/dest-vop <%peek-d> ;
M: %peek-d basic-block? drop t ;

VOP: %replace-d
: %replace-d ( vreg n -- ) swap <vreg> 2-in-vop <%replace-d> ;
M: %replace-d basic-block? drop t ;

VOP: %inc-d
: %inc-d ( n -- ) src-vop <%inc-d> ;
: %dec-d ( n -- ) neg %inc-d ;
M: %inc-d basic-block? drop t ;

VOP: %immediate
: %immediate ( vreg obj -- )
    swap <vreg> src/dest-vop <%immediate> ;
M: %immediate basic-block? drop t ;

VOP: %peek-r
: %peek-r ( vreg n -- ) swap <vreg> src/dest-vop <%peek-r> ;

VOP: %replace-r
: %replace-r ( vreg n -- ) swap <vreg> 2-in-vop <%replace-r> ;

VOP: %inc-r
: %inc-r ( n -- ) src-vop <%inc-r> ;

! this exists, unlike %dec-d which does not, due to x86 quirks
VOP: %dec-r
: %dec-r ( n -- ) src-vop <%dec-r> ;

: in-1 0 0 %peek-d , ;
: in-2 0 1 %peek-d ,  1 0 %peek-d , ;
: in-3 0 2 %peek-d ,  1 1 %peek-d ,  2 0 %peek-d , ;
: out-1 0 0 %replace-d , ;

! indirect load of a literal through a table
VOP: %indirect
: %indirect ( vreg obj -- )
    swap <vreg> src/dest-vop <%indirect> ;
M: %indirect basic-block? drop t ;

! object slot accessors
! mask off a tag (see also %untag-fixnum)
VOP: %untag
: %untag <vreg> dest-vop <%untag> ;
M: %untag basic-block? drop t ;

VOP: %slot
: %slot ( n vreg ) >r <vreg> r> <vreg> binary-vop <%slot> ;
M: %slot basic-block? drop t ;

VOP: %set-slot
: %set-slot ( value obj n )
    #! %set-slot writes to vreg n.
    >r >r <vreg> r> <vreg> r> <vreg> [ 3list ] keep unit f
    <%set-slot> ;
M: %set-slot basic-block? drop t ;

! in the 'fast' versions, the object's type and slot number is
! known at compile time, so these become a single instruction
VOP: %fast-slot
: %fast-slot ( vreg n )
    swap <vreg> binary-vop <%fast-slot> ;
M: %fast-slot basic-block? drop t ;

VOP: %fast-set-slot
: %fast-set-slot ( value obj n )
    #! %fast-set-slot writes to vreg obj.
    >r >r <vreg> r> <vreg> r> over >r 3list r> unit f
    <%fast-set-slot> ;
M: %fast-set-slot basic-block? drop t ;

! fixnum intrinsics
VOP: %fixnum+       : %fixnum+ binary-vop <%fixnum+> ;
VOP: %fixnum-       : %fixnum- binary-vop <%fixnum-> ;
VOP: %fixnum*       : %fixnum* binary-vop <%fixnum*> ;
VOP: %fixnum-mod    : %fixnum-mod binary-vop <%fixnum-mod> ;
VOP: %fixnum/i      : %fixnum/i binary-vop <%fixnum/i> ;
VOP: %fixnum/mod    : %fixnum/mod binary-vop <%fixnum/mod> ;
VOP: %fixnum-bitand : %fixnum-bitand binary-vop <%fixnum-bitand> ;
VOP: %fixnum-bitor  : %fixnum-bitor binary-vop <%fixnum-bitor> ;
VOP: %fixnum-bitxor : %fixnum-bitxor binary-vop <%fixnum-bitxor> ;
VOP: %fixnum-bitnot : %fixnum-bitnot <vreg> dest-vop <%fixnum-bitnot> ;

VOP: %fixnum<=      : %fixnum<= binary-vop <%fixnum<=> ;
VOP: %fixnum<       : %fixnum< binary-vop <%fixnum<> ;
VOP: %fixnum>=      : %fixnum>= binary-vop <%fixnum>=> ;
VOP: %fixnum>       : %fixnum> binary-vop <%fixnum>> ;
VOP: %eq?           : %eq? binary-vop <%eq?> ;

! At the VOP level, the 'shift' operation is split into five
! distinct operations:
! - shifts with a large positive count: calls runtime to make
!   a bignum
! - shifts with a small positive count: %fixnum<<
! - shifts with a small negative count: %fixnum>>
! - shifts with a small negative count: %fixnum>>
! - shifts with a large negative count: %fixnum-sgn
VOP: %fixnum<<   : %fixnum<<   binary-vop <%fixnum<<> ;
VOP: %fixnum>>   : %fixnum>>   binary-vop <%fixnum>>> ;
! due to x86 limitations the destination of this VOP must be
! vreg 2 (EDX), and the source must be vreg 0 (EAX).
VOP: %fixnum-sgn : %fixnum-sgn binary-vop <%fixnum-sgn> ;

! Integer comparison followed by a conditional branch is
! optimized
VOP: %jump-fixnum<=
: %jump-fixnum<= 2-in/label-vop <%jump-fixnum<=> ;

VOP: %jump-fixnum< 
: %jump-fixnum< 2-in/label-vop <%jump-fixnum<> ;

VOP: %jump-fixnum>=
: %jump-fixnum>= 2-in/label-vop <%jump-fixnum>=> ;

VOP: %jump-fixnum> 
: %jump-fixnum> 2-in/label-vop <%jump-fixnum>> ;

VOP: %jump-eq?     
: %jump-eq? 2-in/label-vop <%jump-eq?> ;

: fast-branch ( class -- class )
    {{
        [[ %fixnum<= %jump-fixnum<= ]]
        [[ %fixnum<  %jump-fixnum<  ]]
        [[ %fixnum>= %jump-fixnum>= ]]
        [[ %fixnum>  %jump-fixnum>  ]]
        [[ %eq?      %jump-eq?      ]]
    }} hash ;

PREDICATE: tuple fast-branch
    #! Class of VOPs whose class is a key in fast-branch
    #! hashtable.
    class fast-branch ;

! some slightly optimized inline assembly
VOP: %type
: %type ( vreg ) <vreg> dest-vop <%type> ;
M: %type basic-block? drop t ;

VOP: %arithmetic-type
: %arithmetic-type <vreg> dest-vop <%arithmetic-type> ;

VOP: %tag-fixnum
: %tag-fixnum <vreg> dest-vop <%tag-fixnum> ;
M: %tag-fixnum basic-block? drop t ;

VOP: %untag-fixnum
: %untag-fixnum <vreg> dest-vop <%untag-fixnum> ;
M: %untag-fixnum basic-block? drop t ;

: check-dest ( vop reg -- )
    swap vop-out-1 = [ "bad VOP destination" throw ] unless ;

: check-src ( vop reg -- )
    swap vop-out-1 = [ "bad VOP source" throw ] unless ;

VOP: %getenv
: %getenv swap src/dest-vop <%getenv> ;
M: %getenv basic-block? drop t ;

VOP: %setenv
: %setenv 2-in-vop <%setenv> ;
M: %setenv basic-block? drop t ;

! alien operations
VOP: %parameters
: %parameters ( n -- vop ) src-vop <%parameters> ;

VOP: %parameter
: %parameter ( n -- vop ) src-vop <%parameter> ;

VOP: %cleanup
: %cleanup ( n -- vop ) src-vop <%cleanup> ;

VOP: %unbox
: %unbox ( [[ n func ]] -- vop ) src-vop <%unbox> ;

VOP: %unbox-float
: %unbox-float ( [[ n func ]] -- vop ) src-vop <%unbox-float> ;

VOP: %unbox-double
: %unbox-double ( [[ n func ]] -- vop ) src-vop <%unbox-double> ;

VOP: %box
: %box ( func -- vop ) src-vop <%box> ;

VOP: %box-float
: %box-float ( func -- vop ) src-vop <%box-float> ;

VOP: %box-double
: %box-double ( [[ n func ]] -- vop ) src-vop <%box-double> ;

VOP: %alien-invoke
: %alien-invoke ( func -- vop ) src-vop <%alien-invoke> ;

VOP: %alien-global
: %alien-global ( global -- vop ) src-vop <%alien-global> ;
