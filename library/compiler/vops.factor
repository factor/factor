! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: errors generic hashtables kernel math namespaces parser
words ;

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
TUPLE: vop source dest literal label ;

GENERIC: calls-label? ( label vop -- ? )

M: vop calls-label? vop-label = ;

: make-vop ( source dest literal label vop -- vop )
    [ >r <vop> r> set-delegate ] keep ;

: VOP:
    #! Followed by a VOP name.
    scan dup [ ] define-tuple
    create-in [ make-vop ] define-constructor ; parsing

: empty-vop f f f f ;
: label-vop ( label) >r f f f r> ;
: label/src-vop ( label src) swap >r f f r> ;
: src-vop ( src) f f f ;
: dest-vop ( dest) f swap f f ;
: src/dest-vop ( src dest) f f ;
: literal-vop ( literal) >r f f r> f ;

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
: %peek-d ( vreg n -- ) >r >r f r> <vreg> r> f <%peek-d> ;
VOP: %replace-d
: %replace-d ( vreg n -- ) >r <vreg> f r> f <%replace-d> ;
VOP: %inc-d
: %inc-d ( n -- ) literal-vop <%inc-d> ;
: %dec-d ( n -- ) neg %inc-d ;
VOP: %immediate
VOP: %immediate-d
: %immediate-d ( obj -- ) literal-vop <%immediate-d> ;
VOP: %peek-r
: %peek-r ( vreg n -- ) >r >r f r> <vreg> r> f <%peek-r> ;
VOP: %replace-r
: %replace-r ( vreg n -- ) >r <vreg> f r> f <%replace-r> ;
VOP: %inc-r
: %inc-r ( n -- ) literal-vop <%inc-r> ;
! this exists, unlike %dec-d which does not, due to x86 quirks
VOP: %dec-r
: %dec-r ( n -- ) literal-vop <%dec-r> ;

: in-1 0 0 %peek-d , ;
: in-2 0 1 %peek-d ,  1 0 %peek-d , ;
: in-3 0 2 %peek-d ,  1 1 %peek-d ,  2 0 %peek-d , ;
: out-1 0 0 %replace-d , ;

! indirect load of a literal through a table
VOP: %indirect
: %indirect ( vreg obj -- ) >r <vreg> r> f -rot f <%indirect> ;

! object slot accessors
! mask off a tag (see also %untag-fixnum)
VOP: %untag
: %untag <vreg> dest-vop <%untag> ;
VOP: %slot
: %slot ( n vreg ) >r <vreg> r> <vreg> f f <%slot> ;

VOP: %set-slot
: %set-slot ( vreg:value vreg:obj n )
    >r >r <vreg> r> <vreg> r> <vreg> f <%set-slot> ;

! in the 'fast' versions, the object's type and slot number is
! known at compile time, so these become a single instruction
VOP: %fast-slot
: %fast-slot ( vreg n ) >r >r f r> <vreg> r> f <%fast-slot> ;
VOP: %fast-set-slot
: %fast-set-slot ( vreg:value vreg:obj n )
    >r >r <vreg> r> <vreg> r> f <%fast-set-slot> ;

! fixnum intrinsics
VOP: %fixnum+       : %fixnum+ src/dest-vop <%fixnum+> ;
VOP: %fixnum-       : %fixnum- src/dest-vop <%fixnum-> ;
VOP: %fixnum*       : %fixnum* src/dest-vop <%fixnum*> ;
VOP: %fixnum-mod    : %fixnum-mod src/dest-vop <%fixnum-mod> ;
VOP: %fixnum/i      : %fixnum/i src/dest-vop <%fixnum/i> ;
VOP: %fixnum/mod    : %fixnum/mod src/dest-vop <%fixnum/mod> ;
VOP: %fixnum-bitand : %fixnum-bitand src/dest-vop <%fixnum-bitand> ;
VOP: %fixnum-bitor  : %fixnum-bitor src/dest-vop <%fixnum-bitor> ;
VOP: %fixnum-bitxor : %fixnum-bitxor src/dest-vop <%fixnum-bitxor> ;
VOP: %fixnum-bitnot : %fixnum-bitnot <vreg> dest-vop <%fixnum-bitnot> ;

VOP: %fixnum<=      : %fixnum<= src/dest-vop <%fixnum<=> ;
VOP: %fixnum<       : %fixnum< src/dest-vop <%fixnum<> ;
VOP: %fixnum>=      : %fixnum>= src/dest-vop <%fixnum>=> ;
VOP: %fixnum>       : %fixnum> src/dest-vop <%fixnum>> ;
VOP: %eq?           : %eq? src/dest-vop <%eq?> ;

! At the VOP level, the 'shift' operation is split into five
! distinct operations:
! - shifts with a large positive count: calls runtime to make
!   a bignum
! - shifts with a small positive count: %fixnum<<
! - shifts with a small negative count: %fixnum>>
! - shifts with a small negative count: %fixnum>>
! - shifts with a large negative count: %fixnum-sgn
VOP: %fixnum<<   : %fixnum<<   src/dest-vop <%fixnum<<> ;
VOP: %fixnum>>   : %fixnum>>   src/dest-vop <%fixnum>>> ;
! due to x86 limitations the destination of this VOP must be
! vreg 2 (EDX), and the source must be vreg 0 (EAX).
VOP: %fixnum-sgn : %fixnum-sgn src/dest-vop <%fixnum-sgn> ;

! Integer comparison followed by a conditional branch is
! optimized
VOP: %jump-fixnum<= : %jump-fixnum<= f swap <%jump-fixnum<=> ;
VOP: %jump-fixnum<  : %jump-fixnum< f swap <%jump-fixnum<> ;
VOP: %jump-fixnum>= : %jump-fixnum>= f swap <%jump-fixnum>=> ;
VOP: %jump-fixnum>  : %jump-fixnum> f swap <%jump-fixnum>> ;
VOP: %jump-eq?      : %jump-eq? f swap <%jump-eq?> ;

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

VOP: %arithmetic-type
: %arithmetic-type <vreg> dest-vop <%arithmetic-type> ;

VOP: %tag-fixnum
: %tag-fixnum <vreg> dest-vop <%tag-fixnum> ;

VOP: %untag-fixnum
: %untag-fixnum <vreg> dest-vop <%untag-fixnum> ;

: check-dest ( vop reg -- )
    swap vop-dest = [ "invalid VOP destination" throw ] unless ;

! alien operations
VOP: %parameters
: %parameters ( n -- vop ) literal-vop <%parameters> ;

VOP: %parameter
: %parameter ( n -- vop ) literal-vop <%parameter> ;

VOP: %cleanup
: %cleanup ( n -- vop ) literal-vop <%cleanup> ;

VOP: %unbox
: %unbox ( [[ n func ]] -- vop ) literal-vop <%unbox> ;

VOP: %unbox-float
: %unbox-float ( [[ n func ]] -- vop ) literal-vop <%unbox-float> ;

VOP: %unbox-double
: %unbox-double ( [[ n func ]] -- vop ) literal-vop <%unbox-double> ;

VOP: %box
: %box ( func -- vop ) literal-vop <%box> ;

VOP: %box-float
: %box-float ( func -- vop ) literal-vop <%box-float> ;

VOP: %box-double
: %box-double ( [[ n func ]] -- vop ) literal-vop <%box-double> ;

VOP: %alien-invoke
: %alien-invoke ( func -- vop ) literal-vop <%alien-invoke> ;
