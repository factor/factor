! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: errors generic kernel namespaces parser ;

! The linear IR is the second of the two intermediate
! representations used by Factor. It is basically a high-level
! assembly language. Linear IR operations are called VOPs.

! A virtual register
TUPLE: vreg n ;

! A virtual operation
TUPLE: vop source dest literal label ;

! Compile a VOP.
GENERIC: generate-node ( vop -- )

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

! miscellanea
VOP: %prologue
: %prologue empty-vop <%prologue> ;
VOP: %label
: %label label-vop <%label> ;
VOP: %return
: %return empty-vop <%return> ;
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
VOP: %dec-d
: %dec-d ( n -- ) >r f f r> f <%dec-d> ;
VOP: %replace-d
: %replace-d ( vreg n -- ) >r <vreg> f r> f <%replace-d> ;
VOP: %inc-d
: %inc-d ( n -- ) >r f f r> f <%inc-d> ;
VOP: %immediate
VOP: %immediate-d
: %immediate-d ( obj -- ) >r f f r> f <%immediate-d> ;
VOP: %peek-r
: %peek-r ( vreg n -- ) >r >r f r> <vreg> r> f <%peek-r> ;
VOP: %dec-r
: %dec-r ( n -- ) >r f f r> f <%dec-r> ;
VOP: %replace-r
: %replace-r ( vreg n -- ) >r <vreg> f r> f <%replace-r> ;
VOP: %inc-r
: %inc-r ( n -- ) >r f f r> f <%inc-r> ;

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
VOP: %fixnum-shift  : %fixnum-shift src/dest-vop <%fixnum-shift> ;
VOP: %fixnum<=      : %fixnum<= src/dest-vop <%fixnum<=> ;
VOP: %fixnum<       : %fixnum< src/dest-vop <%fixnum<> ;
VOP: %fixnum>=      : %fixnum>= src/dest-vop <%fixnum>=> ;
VOP: %fixnum>       : %fixnum> src/dest-vop <%fixnum>> ;

VOP: %eq?           : %eq? src/dest-vop <%eq?> ;

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
