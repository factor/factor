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
: vop-out-1 ( vop -- output ) vop-outputs first ;
: vop-out-2 ( vop -- output ) vop-outputs second ;

GENERIC: basic-block? ( vop -- ? )
M: vop basic-block? drop f ;
! simplifies some code
M: f basic-block? drop f ;

GENERIC: calls-label? ( label vop -- ? )
M: vop calls-label? vop-label = ;

: make-vop ( inputs outputs label vop -- vop )
    [ >r <vop> r> set-delegate ] keep ;

: empty-vop f f f ;
: label-vop ( label) >r f f r> ;
: label/src-vop ( label src) unit swap f swap ;
: src-vop ( src) unit f f ;
: dest-vop ( dest) unit dup f ;
: src/dest-vop ( src dest) >r unit r> unit f ;
: 2-in-vop ( in1 in2) 2list f f ;
: 2-in/label-vop ( in1 in2 label) >r 2list f r> ;
: 2-vop ( in dest) [ 2list ] keep unit f ;
: 3-vop ( in1 in2 dest) >r 2list r> unit f ;

! miscellanea
TUPLE: %prologue ;
C: %prologue make-vop ;
: %prologue empty-vop <%prologue> ;

TUPLE: %label ;
C: %label make-vop ;
: %label label-vop <%label> ;
M: %label calls-label? 2drop f ;

! Return vops take a label that is ignored, to have the
! same stack effect as jumps. This is needed for the
! simplifier.
TUPLE: %return ;
C: %return make-vop ;
: %return ( label) label-vop <%return> ;

TUPLE: %return-to ;
C: %return-to make-vop ;
: %return-to label-vop <%return-to> ;

TUPLE: %jump ;
C: %jump make-vop ;
: %jump label-vop <%jump> ;

TUPLE: %jump-label ;
C: %jump-label make-vop ;
: %jump-label label-vop <%jump-label> ;

TUPLE: %call ;
C: %call make-vop ;
: %call label-vop <%call> ;

TUPLE: %call-label ;
C: %call-label make-vop ;
: %call-label label-vop <%call-label> ;

TUPLE: %jump-t ;
C: %jump-t make-vop ;
: %jump-t <vreg> label/src-vop <%jump-t> ;

TUPLE: %jump-f ;
C: %jump-f make-vop ;
: %jump-f <vreg> label/src-vop <%jump-f> ;

! dispatch tables
TUPLE: %dispatch ;
C: %dispatch make-vop ;
: %dispatch <vreg> src-vop <%dispatch> ;

TUPLE: %target-label ;
C: %target-label make-vop ;
: %target-label label-vop <%target-label> ;

TUPLE: %target ;
C: %target make-vop ;
: %target label-vop <%target> ;

TUPLE: %end-dispatch ;
C: %end-dispatch make-vop ;
: %end-dispatch empty-vop <%end-dispatch> ;

! stack operations
TUPLE: %peek-d ;
C: %peek-d make-vop ;
: %peek-d ( vreg n -- ) swap <vreg> src/dest-vop <%peek-d> ;
M: %peek-d basic-block? drop t ;

TUPLE: %replace-d ;
C: %replace-d make-vop ;
: %replace-d ( vreg n -- ) swap <vreg> 2-in-vop <%replace-d> ;
M: %replace-d basic-block? drop t ;

TUPLE: %inc-d ;
C: %inc-d make-vop ;
: %inc-d ( n -- ) src-vop <%inc-d> ;
: %dec-d ( n -- ) neg %inc-d ;
M: %inc-d basic-block? drop t ;

TUPLE: %immediate ;
C: %immediate make-vop ;
: %immediate ( vreg obj -- )
    swap <vreg> src/dest-vop <%immediate> ;
M: %immediate basic-block? drop t ;

TUPLE: %peek-r ;
C: %peek-r make-vop ;
: %peek-r ( vreg n -- ) swap <vreg> src/dest-vop <%peek-r> ;

TUPLE: %replace-r ;
C: %replace-r make-vop ;
: %replace-r ( vreg n -- ) swap <vreg> 2-in-vop <%replace-r> ;

TUPLE: %inc-r ;
C: %inc-r make-vop ;
: %inc-r ( n -- ) src-vop <%inc-r> ;

! this exists, unlike %dec-d which does not, due to x86 quirks
TUPLE: %dec-r ;
C: %dec-r make-vop ;
: %dec-r ( n -- ) src-vop <%dec-r> ;

: in-1 0 0 %peek-d , ;
: in-2 0 1 %peek-d ,  1 0 %peek-d , ;
: in-3 0 2 %peek-d ,  1 1 %peek-d ,  2 0 %peek-d , ;
: out-1 0 0 %replace-d , ;

! indirect load of a literal through a table
TUPLE: %indirect ;
C: %indirect make-vop ;
: %indirect ( vreg obj -- )
    swap <vreg> src/dest-vop <%indirect> ;
M: %indirect basic-block? drop t ;

! object slot accessors
! mask off a tag (see also %untag-fixnum)
TUPLE: %untag ;
C: %untag make-vop ;
: %untag <vreg> dest-vop <%untag> ;
M: %untag basic-block? drop t ;

TUPLE: %slot ;
C: %slot make-vop ;
: %slot ( n vreg ) >r <vreg> r> <vreg> 2-vop <%slot> ;
M: %slot basic-block? drop t ;

TUPLE: %set-slot ;
C: %set-slot make-vop ;
: %set-slot ( value obj n )
    #! %set-slot writes to vreg n.
    >r >r <vreg> r> <vreg> r> <vreg> 3list dup second f
    <%set-slot> ;
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
    >r >r <vreg> r> <vreg> r> over >r 3list r> unit f
    <%fast-set-slot> ;
M: %fast-set-slot basic-block? drop t ;

TUPLE: %write-barrier ;
C: %write-barrier make-vop ;
: %write-barrier ( ptr ) <vreg> unit dup f <%write-barrier> ;

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
TUPLE: %fixnum-bitor ;
C: %fixnum-bitor make-vop ;  : %fixnum-bitor 3-vop <%fixnum-bitor> ;
TUPLE: %fixnum-bitxor ;
C: %fixnum-bitxor make-vop ; : %fixnum-bitxor 3-vop <%fixnum-bitxor> ;
TUPLE: %fixnum-bitnot ;
C: %fixnum-bitnot make-vop ; : %fixnum-bitnot 2-vop <%fixnum-bitnot> ;

TUPLE: %fixnum<= ;
C: %fixnum<= make-vop ;      : %fixnum<= 3-vop <%fixnum<=> ;
TUPLE: %fixnum< ;
C: %fixnum< make-vop ;       : %fixnum< 3-vop <%fixnum<> ;
TUPLE: %fixnum>= ;
C: %fixnum>= make-vop ;      : %fixnum>= 3-vop <%fixnum>=> ;
TUPLE: %fixnum> ;
C: %fixnum> make-vop ;       : %fixnum> 3-vop <%fixnum>> ;
TUPLE: %eq? ;
C: %eq? make-vop ;           : %eq? 3-vop <%eq?> ;

! At the VOP level, the 'shift' operation is split into five
! distinct operations:
! - shifts with a large positive count: calls runtime to make
!   a bignum
! - shifts with a small positive count: %fixnum<<
! - shifts with a small negative count: %fixnum>>
! - shifts with a small negative count: %fixnum>>
! - shifts with a large negative count: %fixnum-sgn
TUPLE: %fixnum<< ;
C: %fixnum<< make-vop ;   : %fixnum<<   3-vop <%fixnum<<> ;
TUPLE: %fixnum>> ;
C: %fixnum>> make-vop ;   : %fixnum>>   3-vop <%fixnum>>> ;
! due to x86 limitations the destination of this VOP must be
! vreg 2 (EDX), and the source must be vreg 0 (EAX).
TUPLE: %fixnum-sgn ;
C: %fixnum-sgn make-vop ; : %fixnum-sgn src/dest-vop <%fixnum-sgn> ;

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
TUPLE: %type ;
C: %type make-vop ;
: %type ( vreg ) <vreg> dest-vop <%type> ;
M: %type basic-block? drop t ;

TUPLE: %arithmetic-type ;
C: %arithmetic-type make-vop ;
: %arithmetic-type <vreg> dest-vop <%arithmetic-type> ;

TUPLE: %tag-fixnum ;
C: %tag-fixnum make-vop ;
: %tag-fixnum <vreg> dest-vop <%tag-fixnum> ;
M: %tag-fixnum basic-block? drop t ;

TUPLE: %untag-fixnum ;
C: %untag-fixnum make-vop ;
: %untag-fixnum <vreg> dest-vop <%untag-fixnum> ;
M: %untag-fixnum basic-block? drop t ;

: check-dest ( vop reg -- )
    swap vop-out-1 = [ "bad VOP destination" throw ] unless ;

: check-src ( vop reg -- )
    swap vop-in-1 = [ "bad VOP source" throw ] unless ;

TUPLE: %getenv ;
C: %getenv make-vop ;
: %getenv swap src/dest-vop <%getenv> ;
M: %getenv basic-block? drop t ;

TUPLE: %setenv ;
C: %setenv make-vop ;
: %setenv 2-in-vop <%setenv> ;
M: %setenv basic-block? drop t ;

! alien operations
TUPLE: %parameters ;
C: %parameters make-vop ;
: %parameters ( n -- vop ) src-vop <%parameters> ;

TUPLE: %parameter ;
C: %parameter make-vop ;
: %parameter ( n -- vop ) src-vop <%parameter> ;

TUPLE: %cleanup ;
C: %cleanup make-vop ;
: %cleanup ( n -- vop ) src-vop <%cleanup> ;

TUPLE: %unbox ;
C: %unbox make-vop ;
: %unbox ( [[ n func ]] -- vop ) src-vop <%unbox> ;

TUPLE: %unbox-float ;
C: %unbox-float make-vop ;
: %unbox-float ( [[ n func ]] -- vop ) src-vop <%unbox-float> ;

TUPLE: %unbox-double ;
C: %unbox-double make-vop ;
: %unbox-double ( [[ n func ]] -- vop ) src-vop <%unbox-double> ;

TUPLE: %box ;
C: %box make-vop ;
: %box ( func -- vop ) src-vop <%box> ;

TUPLE: %box-float ;
C: %box-float make-vop ;
: %box-float ( func -- vop ) src-vop <%box-float> ;

TUPLE: %box-double ;
C: %box-double make-vop ;
: %box-double ( [[ n func ]] -- vop ) src-vop <%box-double> ;

TUPLE: %alien-invoke ;
C: %alien-invoke make-vop ;
: %alien-invoke ( func -- vop ) src-vop <%alien-invoke> ;

TUPLE: %alien-global ;
C: %alien-global make-vop ;
: %alien-global ( global -- vop ) src-vop <%alien-global> ;
